import 'dart:async';

import 'package:core_domain/core_domain.dart';
import 'package:dio/dio.dart';
import 'package:provider_api/provider_api.dart';

import 'consent.dart';
import 'session_client.dart';
import 'unit_ledger.dart';

/// YouTube Music adapter — the hybrid of docs/01 §3.2.
///
/// Official YouTube Data API v3 (sanctioned, durable, quota-priced by the
/// [UnitLedger]) carries playlist CRUD and reads. The consented session
/// path ([YtmSessionClient]) carries what the official API cannot:
/// music-scoped search and liked songs. Capabilities shrink automatically
/// when the session path is off — the UI adapts, nothing breaks.
class YouTubeMusicProvider implements MusicProvider {
  YouTubeMusicProvider({
    required String clientId,
    required TokenStore tokenStore,
    required ConsentStore consentStore,
    required LedgerStore ledgerStore,
    Dio? httpClient,
    RateGovernor? governor,
    DateTime Function()? clock,
    YtmSessionClient Function(Dio http, String cookie)? sessionClientFactory,
  }) : _tokens = tokenStore,
       _now = clock ?? DateTime.now,
       _governor = governor ?? RateGovernor(capacity: 4, refillPerSecond: 2) {
    _http =
        httpClient ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
    _consent = ConsentGate(store: consentStore, clock: _now);
    ledger = UnitLedger(store: ledgerStore, clock: _now);
    _sessionClientFactory =
        sessionClientFactory ??
        (http, cookie) =>
            HttpYtmSessionClient(httpClient: http, cookieHeader: cookie);
    _authorizer = PkceAuthorizer(
      provider: id,
      httpClient: _http,
      clock: _now,
      config: OAuthConfig(
        authorizationEndpoint: Uri.parse(
          'https://accounts.google.com/o/oauth2/v2/auth',
        ),
        tokenEndpoint: Uri.parse('https://oauth2.googleapis.com/token'),
        clientId: clientId,
        scopes: const ['https://www.googleapis.com/auth/youtube'],
        extraAuthorizationParameters: const {
          'access_type': 'offline', // refresh token
          'prompt': 'consent',
        },
      ),
    );
  }

  static const _api = 'https://www.googleapis.com/youtube/v3';

  final TokenStore _tokens;
  final RateGovernor _governor;
  final DateTime Function() _now;
  late final Dio _http;
  late final PkceAuthorizer _authorizer;
  late final ConsentGate _consent;
  late final YtmSessionClient Function(Dio, String) _sessionClientFactory;

  /// Public: the transfer wizard reads budget state from here.
  late final UnitLedger ledger;

  final Map<AccountId, Future<AuthSession>> _refreshing = {};
  final Map<AccountId, YtmSessionClient> _sessionClients = {};
  bool _sessionEnabled = false;
  bool _enabled = true;

  @override
  ProviderId get id => const ProviderId('ytmusic');

  @override
  String get displayName => 'YouTube Music';

  /// Remote kill switch (docs/02 §2.2 item 5): flipping this off shrinks
  /// capabilities to none; running jobs pause with a clear reason.
  // ignore: avoid_setters_without_getters
  set enabled(bool value) => _enabled = value;

  @override
  ProviderCapabilities get capabilities {
    if (!_enabled) return ProviderCapabilities.none;
    return ProviderCapabilities(
      supported: {
        Capability.catalogSearch,
        Capability.playlistDescription,
        Capability.playlistPrivacy,
        Capability.playlistReorder,
        if (_sessionEnabled) Capability.likedSongs,
      },
      details: {
        Capability.playlistPrivacy: const CapabilityDetail(
          limits: {
            'values': ['public', 'unlisted', 'private'],
          },
        ),
        Capability.catalogSearch: CapabilityDetail(
          note: _sessionEnabled
              ? 'music-scoped search via consented session path'
              : 'official search only: all-YouTube results, 100 units each',
        ),
      },
    );
  }

  // -- session path lifecycle --------------------------------------------------

  /// Must be called at startup: restores session-path state from stored
  /// consent + credential.
  Future<void> initialize(AccountId account) async {
    final consented = await _consent.isCurrent();
    final credential = await _tokens.read(_sessionRef(account));
    _sessionEnabled = consented && credential != null;
    if (_sessionEnabled) {
      _sessionClients[account] = _sessionClientFactory(
        _http,
        credential!.accessToken,
      );
    }
  }

  /// Enables the session path AFTER the user has passed the informed
  /// consent screen. [cookieHeader] is the user's own YTM session cookie —
  /// custody identical to OAuth tokens (docs/06 §2).
  Future<void> enableSessionPath(
    AccountId account, {
    required String cookieHeader,
  }) async {
    await _consent.grant();
    await _tokens.write(
      _sessionRef(account),
      AuthSession(
        accessToken: cookieHeader,
        // Session cookies have no declared expiry; validity is discovered
        // on use (401 → AuthExpired → reconnect prompt).
        expiresAt: _now().add(const Duration(days: 3650)),
      ),
    );
    _sessionClients[account] = _sessionClientFactory(_http, cookieHeader);
    _sessionEnabled = true;
  }

  Future<void> disableSessionPath(AccountId account) async {
    await _consent.revoke();
    await _tokens.delete(_sessionRef(account));
    _sessionClients.remove(account);
    _sessionEnabled = false;
  }

  String _sessionRef(AccountId account) => 'ytmusic/session/${account.value}';

  YtmSessionClient _session(AccountId account) {
    final client = _sessionClients[account];
    if (client == null) {
      throw AuthExpired(id, 'session path not enabled for ${account.value}');
    }
    return client;
  }

  // -- lifecycle ---------------------------------------------------------------

  @override
  Future<ConnectedAccount> authenticate(AuthBroker broker) async {
    final session = await _authorizer.authorize(broker);
    final data = await _decode(
      await _rawRequest(
        'GET',
        '$_api/channels',
        session,
        query: {'part': 'snippet', 'mine': 'true'},
      ),
    );
    final items = data['items'] as List? ?? const [];
    if (items.isEmpty) {
      throw ProviderContractViolation(id, 'channels.mine returned no items');
    }
    final channel = (items.first as Map).cast<String, Object?>();
    final channelId = channel['id']! as String;
    final snippet = (channel['snippet'] as Map?)?.cast<String, Object?>();
    final account = AccountId(channelId);
    await _tokens.write(_tokenRef(account), session);
    return ConnectedAccount(
      provider: id,
      id: account,
      displayName: snippet?['title'] as String? ?? channelId,
    );
  }

  @override
  Future<void> refreshSession(AccountId account) async {
    await _oauthSession(account, forceRefresh: true);
  }

  @override
  Future<void> disconnect(AccountId account) async {
    await disableSessionPath(account);
    await _tokens.delete(_tokenRef(account));
  }

  // -- catalog -----------------------------------------------------------------

  @override
  Future<SearchResult> searchTrack(AccountId account, TrackQuery query) async {
    _requireEnabled();
    final text =
        query.freeform ??
        '${query.title ?? ''} ${query.artist ?? ''} ${query.album ?? ''}'
            .trim();
    if (_sessionEnabled) {
      // Free, music-scoped — always preferred when consented.
      final tracks = await _session(
        account,
      ).searchTracks(text, limit: query.limit);
      return SearchResult(tracks: tracks);
    }
    // Official fallback: all-YouTube search restricted to the Music
    // category. 100 units — the ladder in the matching engine keeps calls
    // to a minimum, the ledger keeps them within budget.
    await ledger.spend(id, YouTubeUnitCosts.search);
    final data = await _json(
      account,
      'GET',
      '$_api/search',
      query: {
        'part': 'snippet',
        'type': 'video',
        'videoCategoryId': '10',
        'maxResults': '${query.limit.clamp(1, 25)}',
        'q': text,
      },
    );
    return SearchResult(
      tracks: [
        for (final item in data['items'] as List? ?? const [])
          _parseSearchItem((item as Map).cast<String, Object?>()),
      ],
    );
  }

  Track _parseSearchItem(Map<String, Object?> item) => _parse(() {
    final snippet = (item['snippet']! as Map).cast<String, Object?>();
    final idNode = (item['id']! as Map).cast<String, Object?>();
    return Track(
      providerId: id,
      id: ProviderTrackId(idNode['videoId']! as String),
      title: snippet['title']! as String,
      artists: [Artist(name: _channelToArtist(snippet))],
      // Official search returns no duration/album — sparse metadata is
      // expected; the matching engine renormalizes (docs/07 §4).
    );
  });

  // -- reads -------------------------------------------------------------------

  @override
  Stream<Playlist> getPlaylists(AccountId account) => _paged(
    account,
    '$_api/playlists',
    {'part': 'snippet,contentDetails,status', 'mine': 'true'},
    (item) => _parsePlaylist(item),
  );

  @override
  Stream<Track> getPlaylistTracks(PlaylistRef playlist) => _paged(
    playlist.account,
    '$_api/playlistItems',
    {'part': 'snippet,contentDetails', 'playlistId': playlist.playlist.value},
    (item) => _parsePlaylistItem(item).track,
  );

  @override
  Stream<Track> getLikedSongs(AccountId account) async* {
    _requireEnabled();
    if (!_sessionEnabled) {
      throw CapabilityUnsupported(
        id,
        'liked songs require the consented session path',
        Capability.likedSongs,
      );
    }
    yield* _session(account).likedSongs();
  }

  @override
  Stream<Album> getAlbums(AccountId account) async* {
    throw CapabilityUnsupported(
      id,
      'saved albums are not accessible on YouTube Music',
      Capability.savedAlbums,
    );
  }

  @override
  Stream<Artist> getArtists(AccountId account) async* {
    throw CapabilityUnsupported(
      id,
      'followed artists are not accessible on YouTube Music',
      Capability.followedArtists,
    );
  }

  // -- writes ------------------------------------------------------------------

  @override
  Future<Playlist> createPlaylist(AccountId account, PlaylistSpec spec) async {
    _requireEnabled();
    await ledger.spend(id, YouTubeUnitCosts.playlistInsert);
    final data = await _json(
      account,
      'POST',
      '$_api/playlists',
      query: {'part': 'snippet,status'},
      body: {
        'snippet': {
          'title': spec.name,
          if (spec.description != null) 'description': spec.description,
        },
        'status': {'privacyStatus': _privacyOf(spec.privacy)},
      },
    );
    return _parsePlaylist(data);
  }

  @override
  Future<void> updatePlaylist(PlaylistRef playlist, PlaylistPatch patch) async {
    if (patch.isEmpty) return;
    _requireEnabled();
    // YouTube's update replaces the snippet — fetch current, then merge.
    final current = await _json(
      playlist.account,
      'GET',
      '$_api/playlists',
      query: {'part': 'snippet,status', 'id': playlist.playlist.value},
    );
    final items = current['items'] as List? ?? const [];
    if (items.isEmpty) {
      throw NotFound(id, 'playlist ${playlist.playlist.value} not found');
    }
    final snapshot = _parsePlaylist(
      (items.first as Map).cast<String, Object?>(),
    );
    await ledger.spend(id, YouTubeUnitCosts.playlistUpdate);
    await _json(
      playlist.account,
      'PUT',
      '$_api/playlists',
      query: {'part': 'snippet,status'},
      body: {
        'id': playlist.playlist.value,
        'snippet': {
          'title': patch.name.resolve(snapshot.name),
          'description': patch.description.resolve(snapshot.description) ?? '',
        },
        'status': {
          'privacyStatus': patch.privacy.isSet
              ? _privacyOf(patch.privacy.resolve(PlaylistPrivacy.private))
              : _privacyOf(snapshot.privacy),
        },
      },
    );
  }

  @override
  Future<void> deletePlaylist(PlaylistRef playlist) async {
    _requireEnabled();
    await ledger.spend(id, YouTubeUnitCosts.playlistDelete);
    await _json(
      playlist.account,
      'DELETE',
      '$_api/playlists',
      query: {'id': playlist.playlist.value},
      decode: false,
    );
  }

  @override
  Future<void> addTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds, {
    int? position,
  }) async {
    _requireEnabled();
    // playlistItems.insert takes one video per call (50 units each) —
    // there is no batch endpoint; sequential inserts preserve order.
    var insertAt = position;
    for (final trackId in trackIds) {
      await ledger.spend(id, YouTubeUnitCosts.playlistItemInsert);
      await _json(
        playlist.account,
        'POST',
        '$_api/playlistItems',
        query: {'part': 'snippet'},
        body: {
          'snippet': {
            'playlistId': playlist.playlist.value,
            'resourceId': {'kind': 'youtube#video', 'videoId': trackId.value},
            'position': ?insertAt,
          },
        },
      );
      if (insertAt != null) insertAt++;
    }
  }

  @override
  Future<void> removeTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds,
  ) async {
    _requireEnabled();
    // Deletion needs playlistItem ids, not video ids — one listing pass
    // maps them (docs/02: reads cost 1 unit vs 50 per delete).
    final wanted = {for (final t in trackIds) t.value};
    final itemIds = <String>[];
    await for (final item in _paged(playlist.account, '$_api/playlistItems', {
      'part': 'snippet,contentDetails',
      'playlistId': playlist.playlist.value,
    }, _parsePlaylistItem)) {
      if (wanted.contains(item.track.id.value)) itemIds.add(item.itemId);
    }
    for (final itemId in itemIds) {
      await ledger.spend(id, YouTubeUnitCosts.playlistItemDelete);
      await _json(
        playlist.account,
        'DELETE',
        '$_api/playlistItems',
        query: {'id': itemId},
        decode: false,
      );
    }
  }

  @override
  Future<void> replaceTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds,
  ) async {
    _requireEnabled();
    final existing = <ProviderTrackId>[];
    await for (final track in getPlaylistTracks(playlist)) {
      existing.add(track.id);
    }
    await removeTracks(playlist, existing);
    await addTracks(playlist, trackIds);
  }

  @override
  Future<void> uploadArtwork(PlaylistRef playlist, Artwork artwork) async {
    throw CapabilityUnsupported(
      id,
      'YouTube Music does not accept custom playlist artwork',
      Capability.playlistArtworkUpload,
    );
  }

  @override
  Future<void> updateDescription(
    PlaylistRef playlist,
    String description,
  ) async {
    await updatePlaylist(
      playlist,
      PlaylistPatch(description: Field.set(description)),
    );
  }

  // -- HTTP core ----------------------------------------------------------------

  void _requireEnabled() {
    if (!_enabled) {
      throw ProviderUnavailable(
        id,
        'YouTube Music provider is disabled (kill switch)',
      );
    }
  }

  String _tokenRef(AccountId account) => 'ytmusic/${account.value}';

  Future<AuthSession> _oauthSession(
    AccountId account, {
    bool forceRefresh = false,
  }) async {
    final stored = await _tokens.read(_tokenRef(account));
    if (stored == null) {
      throw AuthExpired(id, 'no stored session for ${account.value}');
    }
    if (!forceRefresh && !stored.isExpired(_now())) return stored;
    return _refreshing.putIfAbsent(account, () async {
      try {
        final refreshed = await _authorizer.refresh(stored);
        await _tokens.write(_tokenRef(account), refreshed);
        return refreshed;
      } finally {
        unawaited(_refreshing.remove(account));
      }
    });
  }

  Future<Map<String, Object?>> _json(
    AccountId account,
    String method,
    String url, {
    Map<String, String>? query,
    Map<String, Object?>? body,
    bool decode = true,
  }) async {
    _requireEnabled();
    await _governor.acquire();
    var session = await _oauthSession(account);
    var response = await _rawRequest(
      method,
      url,
      session,
      query: query,
      body: body,
    );
    if (response.statusCode == 401) {
      session = await _oauthSession(account, forceRefresh: true);
      response = await _rawRequest(
        method,
        url,
        session,
        query: query,
        body: body,
      );
    }
    _checkStatus(response);
    if (!decode) return const {};
    return _decode(response);
  }

  Future<Response<Object?>> _rawRequest(
    String method,
    String url,
    AuthSession session, {
    Map<String, String>? query,
    Map<String, Object?>? body,
  }) async {
    try {
      return await _http.request<Object?>(
        url,
        queryParameters: query,
        data: body,
        options: Options(
          method: method,
          contentType: body != null ? 'application/json' : null,
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
          responseType: ResponseType.json,
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (e) {
      throw ProviderUnavailable(id, 'network failure: ${e.type.name}');
    }
  }

  void _checkStatus(Response<Object?> response) {
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) return;
    final reason = _errorReason(response);
    switch (status) {
      case 401:
        throw AuthExpired(id, 'HTTP 401 from ${response.realUri.path}');
      case 403 when reason == 'quotaExceeded' || reason == 'dailyLimitExceeded':
        // Google signals quota exhaustion as 403 — align the local ledger
        // (another app on the same project may have spent our budget).
        throw RateLimited(
          id,
          'YouTube quota exhausted (server-reported)',
          retryAfter: ledger.untilReset(),
        );
      case 403:
        throw AuthExpired(id, 'HTTP 403 ($reason)');
      case 404:
        throw NotFound(id, '${response.realUri.path} not found');
      case 429:
        throw RateLimited(id, 'rate limited');
      case >= 500:
        throw ProviderUnavailable(id, 'HTTP $status');
      default:
        throw ProviderContractViolation(
          id,
          'unexpected HTTP $status from ${response.realUri.path}',
        );
    }
  }

  String? _errorReason(Response<Object?> response) {
    final data = response.data;
    if (data is! Map) return null;
    final errors = ((data['error'] as Map?)?['errors'] as List?)
        ?.cast<Map<Object?, Object?>>();
    return errors?.firstOrNull?['reason'] as String?;
  }

  Future<Map<String, Object?>> _decode(Response<Object?> response) async {
    final data = response.data;
    if (data is Map<String, Object?>) return data;
    if (data is Map) return data.cast<String, Object?>();
    throw ProviderContractViolation(
      id,
      'expected JSON object from ${response.realUri.path}',
    );
  }

  /// pageToken-based pagination (YouTube style, vs Spotify's next URLs).
  Stream<T> _paged<T>(
    AccountId account,
    String url,
    Map<String, String> baseQuery,
    T Function(Map<String, Object?> item) parseItem,
  ) async* {
    String? pageToken;
    do {
      await ledger.spend(id, YouTubeUnitCosts.list);
      final data = await _json(
        account,
        'GET',
        url,
        query: {...baseQuery, 'maxResults': '50', 'pageToken': ?pageToken},
      );
      for (final item in data['items'] as List? ?? const []) {
        yield _parse(() => parseItem((item as Map).cast<String, Object?>()));
      }
      pageToken = data['nextPageToken'] as String?;
    } while (pageToken != null);
  }

  // -- parsing -----------------------------------------------------------------

  T _parse<T>(T Function() fn) {
    try {
      return fn();
    } on AppError {
      rethrow;
    } catch (e) {
      throw ProviderContractViolation(id, 'response shape mismatch: $e');
    }
  }

  Playlist _parsePlaylist(Map<String, Object?> json) => _parse(() {
    final snippet = (json['snippet'] as Map?)?.cast<String, Object?>();
    final status = (json['status'] as Map?)?.cast<String, Object?>();
    final contentDetails = (json['contentDetails'] as Map?)
        ?.cast<String, Object?>();
    return Playlist(
      providerId: id,
      id: ProviderPlaylistId(json['id']! as String),
      name: snippet?['title'] as String? ?? '',
      description: switch (snippet?['description']) {
        final String d when d.isNotEmpty => d,
        _ => null,
      },
      privacy: switch (status?['privacyStatus']) {
        'public' => PlaylistPrivacy.public,
        'unlisted' => PlaylistPrivacy.unlisted,
        'private' => PlaylistPrivacy.private,
        _ => null,
      },
      trackCount: contentDetails?['itemCount'] as int? ?? 0,
      etag: json['etag'] as String?,
    );
  });

  ({String itemId, Track track}) _parsePlaylistItem(
    Map<String, Object?> json,
  ) => _parse(() {
    final snippet = (json['snippet']! as Map).cast<String, Object?>();
    final videoId =
        ((snippet['resourceId'] as Map?)?['videoId'] ??
                (json['contentDetails'] as Map?)?['videoId'])!
            as String;
    return (
      itemId: json['id']! as String,
      track: Track(
        providerId: id,
        id: ProviderTrackId(videoId),
        title: snippet['title']! as String,
        artists: [Artist(name: _channelToArtist(snippet))],
      ),
    );
  });

  /// YTM auto-generated music uploads live on `<Artist> - Topic` channels.
  String _channelToArtist(Map<String, Object?> snippet) {
    final channel =
        (snippet['videoOwnerChannelTitle'] ?? snippet['channelTitle'])
            as String? ??
        '';
    return channel.replaceFirst(RegExp(r'\s*-\s*Topic$'), '');
  }

  String _privacyOf(PlaylistPrivacy? privacy) => switch (privacy) {
    PlaylistPrivacy.public => 'public',
    PlaylistPrivacy.unlisted => 'unlisted',
    PlaylistPrivacy.private || null => 'private',
  };
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
