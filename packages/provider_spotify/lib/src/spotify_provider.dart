import 'dart:async';
import 'dart:convert';

import 'package:core_domain/core_domain.dart';
import 'package:dio/dio.dart';
import 'package:provider_api/provider_api.dart';

/// Spotify Web API adapter. API references: docs/02 capability matrix.
///
/// Error mapping, pagination, chunking, and rate governance all live here —
/// callers see only the port and typed errors.
class SpotifyProvider implements MusicProvider {
  SpotifyProvider({
    required String clientId,
    required TokenStore tokenStore,
    Dio? httpClient,
    RateGovernor? governor,
    DateTime Function()? clock,
  }) : _tokens = tokenStore,
       _now = clock ?? DateTime.now,
       // Spotify's practical rolling-window limit (docs/09 §2).
       _governor = governor ?? RateGovernor(capacity: 24, refillPerSecond: 8) {
    _http =
        httpClient ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
    _authorizer = PkceAuthorizer(
      provider: id,
      httpClient: _http,
      clock: _now,
      config: OAuthConfig(
        authorizationEndpoint: Uri.parse(
          'https://accounts.spotify.com/authorize',
        ),
        tokenEndpoint: Uri.parse('https://accounts.spotify.com/api/token'),
        clientId: clientId,
        // Least-privilege set for the MVP feature surface (docs/06 §2).
        scopes: const [
          'playlist-read-private',
          'playlist-read-collaborative',
          'playlist-modify-private',
          'playlist-modify-public',
          'ugc-image-upload',
          'user-library-read',
          'user-library-modify',
          'user-follow-read',
        ],
      ),
    );
  }

  static const _api = 'https://api.spotify.com/v1';
  static const int artworkMaxBytes = 256000;

  final TokenStore _tokens;
  final RateGovernor _governor;
  final DateTime Function() _now;
  late final Dio _http;
  late final PkceAuthorizer _authorizer;
  final Map<AccountId, Future<AuthSession>> _refreshing = {};

  @override
  ProviderId get id => const ProviderId('spotify');

  @override
  String get displayName => 'Spotify';

  @override
  ProviderCapabilities get capabilities => ProviderCapabilities(
    supported: const {
      Capability.likedSongs,
      Capability.savedAlbums,
      Capability.followedArtists,
      Capability.playlistArtworkUpload,
      Capability.playlistDescription,
      Capability.playlistPrivacy,
      Capability.playlistReorder,
      Capability.isrcLookup,
      Capability.isrcSearch,
      Capability.catalogSearch,
    },
    details: const {
      Capability.playlistArtworkUpload: CapabilityDetail(
        note: 'JPEG only, max 256 KB',
        limits: {
          'maxBytes': artworkMaxBytes,
          'formats': ['image/jpeg'],
        },
      ),
      Capability.playlistPrivacy: CapabilityDetail(
        limits: {
          'values': ['public', 'private'],
        },
      ),
    },
  );

  // -- lifecycle --------------------------------------------------------------

  @override
  Future<ConnectedAccount> authenticate(AuthBroker broker) async {
    final session = await _authorizer.authorize(broker);
    final profile = await _decode(
      await _rawRequest('GET', '$_api/me', session),
    );
    final userId = profile['id'];
    if (userId is! String || userId.isEmpty) {
      throw ProviderContractViolation(id, '/me response missing id');
    }
    final account = AccountId(userId);
    await _tokens.write(_tokenRef(account), session);
    final images = profile['images'];
    return ConnectedAccount(
      provider: id,
      id: account,
      displayName: profile['display_name'] as String? ?? userId,
      avatarUrl: switch (images) {
        [final Map<String, Object?> first, ...] when first['url'] is String =>
          Uri.tryParse(first['url']! as String),
        _ => null,
      },
    );
  }

  @override
  Future<void> refreshSession(AccountId account) async {
    await _session(account, forceRefresh: true);
  }

  @override
  Future<void> disconnect(AccountId account) async {
    // Spotify exposes no token-revocation endpoint; deleting custody is the
    // whole operation (users can revoke at spotify.com/account/apps).
    await _tokens.delete(_tokenRef(account));
  }

  // -- catalog ----------------------------------------------------------------

  @override
  Future<SearchResult> searchTrack(AccountId account, TrackQuery query) async {
    final q = _buildSearchQuery(query);
    final data = await _json(
      account,
      'GET',
      '$_api/search',
      query: {'q': q, 'type': 'track', 'limit': '${query.limit.clamp(1, 50)}'},
    );
    final tracks = _mapOf(data, 'tracks');
    return SearchResult(
      tracks: [
        for (final item in _listOf(tracks, 'items')) _parseTrack(_asMap(item)),
      ],
    );
  }

  String _buildSearchQuery(TrackQuery query) {
    if (query.isrc != null) return 'isrc:${query.isrc}';
    if (query.freeform != null) return query.freeform!;
    final parts = <String>[
      'track:"${query.title}"',
      if (query.artist != null) 'artist:"${query.artist}"',
      if (query.album != null) 'album:"${query.album}"',
    ];
    return parts.join(' ');
  }

  // -- reads ------------------------------------------------------------------

  @override
  Stream<Playlist> getPlaylists(AccountId account) => _paged(
    account,
    '$_api/me/playlists?limit=50',
    (item) => _parsePlaylist(_asMap(item)),
  );

  @override
  Stream<Track> getPlaylistTracks(PlaylistRef playlist) => _paged(
    playlist.account,
    '$_api/playlists/${playlist.playlist.value}/tracks?limit=100',
    (item) => _parseTrack(_mapOf(_asMap(item), 'track')),
  );

  @override
  Stream<Track> getLikedSongs(AccountId account) => _paged(
    account,
    '$_api/me/tracks?limit=50',
    (item) => _parseTrack(_mapOf(_asMap(item), 'track')),
  );

  @override
  Stream<Album> getAlbums(AccountId account) => _paged(
    account,
    '$_api/me/albums?limit=50',
    (item) => _parseAlbum(_mapOf(_asMap(item), 'album')),
  );

  @override
  Stream<Artist> getArtists(AccountId account) =>
      _paged(account, '$_api/me/following?type=artist&limit=50', (item) {
        final artist = _asMap(item);
        return Artist(
          name: artist['name'] as String? ?? '',
          id: ProviderArtistId(artist['id'] as String? ?? ''),
        );
      }, rootKey: 'artists');

  // -- writes -----------------------------------------------------------------

  @override
  Future<Playlist> createPlaylist(AccountId account, PlaylistSpec spec) async {
    final data = await _json(
      account,
      'POST',
      '$_api/users/${account.value}/playlists',
      body: {
        'name': spec.name,
        'public': spec.privacy == PlaylistPrivacy.public,
        'collaborative': spec.collaborative,
        if (spec.description != null) 'description': spec.description,
      },
    );
    return _parsePlaylist(data);
  }

  @override
  Future<void> updatePlaylist(PlaylistRef playlist, PlaylistPatch patch) async {
    if (patch.isEmpty) return;
    await _json(
      playlist.account,
      'PUT',
      '$_api/playlists/${playlist.playlist.value}',
      body: {
        if (patch.name.isSet) 'name': patch.name.resolve(''),
        if (patch.description.isSet)
          // Spotify cannot null a description; empty string is the clear.
          'description': patch.description.resolve(null) ?? '',
        if (patch.privacy.isSet)
          'public':
              patch.privacy.resolve(PlaylistPrivacy.private) ==
              PlaylistPrivacy.public,
      },
      decode: false,
    );
  }

  @override
  Future<void> deletePlaylist(PlaylistRef playlist) async {
    // "Deleting" is unfollowing — Spotify's model (docs/02).
    await _json(
      playlist.account,
      'DELETE',
      '$_api/playlists/${playlist.playlist.value}/followers',
      decode: false,
    );
  }

  @override
  Future<void> addTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds, {
    int? position,
  }) async {
    var insertAt = position;
    for (final chunk in _chunks(trackIds, 100)) {
      await _json(
        playlist.account,
        'POST',
        '$_api/playlists/${playlist.playlist.value}/tracks',
        body: {
          'uris': [for (final t in chunk) _uri(t)],
          'position': ?insertAt,
        },
        decode: false,
      );
      if (insertAt != null) insertAt += chunk.length;
    }
  }

  @override
  Future<void> removeTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds,
  ) async {
    for (final chunk in _chunks(trackIds, 100)) {
      await _json(
        playlist.account,
        'DELETE',
        '$_api/playlists/${playlist.playlist.value}/tracks',
        body: {
          'tracks': [
            for (final t in chunk) {'uri': _uri(t)},
          ],
        },
        decode: false,
      );
    }
  }

  @override
  Future<void> replaceTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds,
  ) async {
    // First chunk replaces; the rest append (Spotify PUT caps at 100).
    final chunks = _chunks(trackIds, 100).toList();
    await _json(
      playlist.account,
      'PUT',
      '$_api/playlists/${playlist.playlist.value}/tracks',
      body: {
        'uris': [
          for (final t in chunks.isEmpty ? <ProviderTrackId>[] : chunks.first)
            _uri(t),
        ],
      },
      decode: false,
    );
    for (final chunk in chunks.skip(1)) {
      await addTracks(playlist, chunk);
    }
  }

  @override
  Future<void> uploadArtwork(PlaylistRef playlist, Artwork artwork) async {
    if (artwork.mimeType != 'image/jpeg' ||
        artwork.bytes.length > artworkMaxBytes) {
      throw CapabilityUnsupported(
        id,
        'Spotify artwork must be JPEG under 256 KB '
        '(got ${artwork.mimeType}, ${artwork.bytes.length} bytes)',
        Capability.playlistArtworkUpload,
      );
    }
    await _json(
      playlist.account,
      'PUT',
      '$_api/playlists/${playlist.playlist.value}/images',
      rawBody: base64Encode(artwork.bytes),
      contentType: 'image/jpeg',
      decode: false,
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

  String _tokenRef(AccountId account) => 'spotify/${account.value}';

  String _uri(ProviderTrackId t) => 'spotify:track:${t.value}';

  Iterable<List<T>> _chunks<T>(List<T> items, int size) sync* {
    for (var i = 0; i < items.length; i += size) {
      yield items.sublist(i, i + size > items.length ? items.length : i + size);
    }
  }

  Future<AuthSession> _session(
    AccountId account, {
    bool forceRefresh = false,
  }) async {
    final stored = await _tokens.read(_tokenRef(account));
    if (stored == null) {
      throw AuthExpired(id, 'no stored session for ${account.value}');
    }
    if (!forceRefresh && !stored.isExpired(_now())) return stored;
    // Single-flight per account: concurrent callers share one refresh.
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

  /// One governed, authenticated request with a single 401-refresh retry.
  Future<Response<Object?>> _send(
    AccountId account,
    String method,
    String url, {
    Map<String, String>? query,
    Object? body,
    String? contentType,
  }) async {
    await _governor.acquire();
    var session = await _session(account);
    var response = await _rawRequest(
      method,
      url,
      session,
      query: query,
      body: body,
      contentType: contentType,
    );
    if (response.statusCode == 401) {
      session = await _session(account, forceRefresh: true);
      response = await _rawRequest(
        method,
        url,
        session,
        query: query,
        body: body,
        contentType: contentType,
      );
    }
    return _checkStatus(response);
  }

  Future<Response<Object?>> _rawRequest(
    String method,
    String url,
    AuthSession session, {
    Map<String, String>? query,
    Object? body,
    String? contentType,
  }) async {
    try {
      return await _http.request<Object?>(
        url,
        queryParameters: query,
        data: body,
        options: Options(
          method: method,
          contentType:
              contentType ?? (body != null ? 'application/json' : null),
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
          responseType: ResponseType.json,
          validateStatus: (_) => true, // status → typed errors below
        ),
      );
    } on DioException catch (e) {
      throw ProviderUnavailable(id, 'network failure: ${e.type.name}');
    }
  }

  Response<Object?> _checkStatus(Response<Object?> response) {
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) return response;
    switch (status) {
      case 401 || 403:
        throw AuthExpired(id, 'HTTP $status from ${response.realUri.path}');
      case 404:
        throw NotFound(id, '${response.realUri.path} not found');
      case 429:
        final retryAfter = switch (response.headers.value('retry-after')) {
          final String s when int.tryParse(s) != null => Duration(
            seconds: int.parse(s),
          ),
          _ => null,
        };
        _governor.reportRateLimited(retryAfter: retryAfter);
        throw RateLimited(id, 'rate limited', retryAfter: retryAfter);
      case >= 500:
        throw ProviderUnavailable(id, 'HTTP $status');
      default:
        throw ProviderContractViolation(
          id,
          'unexpected HTTP $status from ${response.realUri.path}',
        );
    }
  }

  Future<Map<String, Object?>> _json(
    AccountId account,
    String method,
    String url, {
    Map<String, String>? query,
    Map<String, Object?>? body,
    Object? rawBody,
    String? contentType,
    bool decode = true,
  }) async {
    final response = await _send(
      account,
      method,
      url,
      query: query,
      body: rawBody ?? body,
      contentType: contentType,
    );
    if (!decode) return const {};
    return _decode(response);
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

  /// Follows Spotify `next` links until exhaustion, emitting parsed items.
  Stream<T> _paged<T>(
    AccountId account,
    String firstUrl,
    T Function(Object? item) parseItem, {
    String? rootKey,
  }) async* {
    String? url = firstUrl;
    while (url != null) {
      final data = await _json(account, 'GET', url);
      final page = rootKey == null ? data : _mapOf(data, rootKey);
      for (final item in _listOf(page, 'items')) {
        yield _parse(() => parseItem(item));
      }
      url = page['next'] as String?;
    }
  }

  // -- parsing ----------------------------------------------------------------

  T _parse<T>(T Function() fn) {
    try {
      return fn();
    } on AppError {
      rethrow;
    } catch (e) {
      throw ProviderContractViolation(id, 'response shape mismatch: $e');
    }
  }

  Map<String, Object?> _asMap(Object? value) => switch (value) {
    final Map<String, Object?> m => m,
    final Map<Object?, Object?> m => m.cast<String, Object?>(),
    _ => throw ProviderContractViolation(id, 'expected object, got $value'),
  };

  Map<String, Object?> _mapOf(Map<String, Object?> json, String key) =>
      _asMap(json[key]);

  List<Object?> _listOf(Map<String, Object?> json, String key) =>
      switch (json[key]) {
        final List<Object?> l => l,
        _ => throw ProviderContractViolation(id, 'expected list at "$key"'),
      };

  Track _parseTrack(Map<String, Object?> json) => _parse(() {
    final album = json['album'] is Map ? _asMap(json['album']) : null;
    final externalIds = json['external_ids'] is Map
        ? _asMap(json['external_ids'])
        : null;
    return Track(
      providerId: id,
      id: ProviderTrackId(json['id']! as String),
      title: json['name']! as String,
      artists: [
        for (final artist in json['artists'] as List? ?? const [])
          Artist(
            name: _asMap(artist)['name'] as String? ?? '',
            id: switch (_asMap(artist)['id']) {
              final String artistId => ProviderArtistId(artistId),
              _ => null,
            },
          ),
      ],
      album: album == null ? null : _parseAlbum(album),
      duration: switch (json['duration_ms']) {
        final int ms => Duration(milliseconds: ms),
        _ => null,
      },
      isrc: externalIds?['isrc'] as String?,
      releaseYear: _yearOf(album?['release_date']),
      explicit: json['explicit'] as bool?,
      popularity: json['popularity'] as int?,
    );
  });

  Album _parseAlbum(Map<String, Object?> json) => Album(
    title: json['name'] as String? ?? '',
    id: switch (json['id']) {
      final String albumId => ProviderAlbumId(albumId),
      _ => null,
    },
    upc: json['external_ids'] is Map
        ? _asMap(json['external_ids'])['upc'] as String?
        : null,
    releaseYear: _yearOf(json['release_date']),
  );

  int? _yearOf(Object? releaseDate) => switch (releaseDate) {
    final String s when s.length >= 4 => int.tryParse(s.substring(0, 4)),
    _ => null,
  };

  Playlist _parsePlaylist(Map<String, Object?> json) => _parse(() {
    final images = json['images'];
    return Playlist(
      providerId: id,
      id: ProviderPlaylistId(json['id']! as String),
      name: json['name']! as String,
      description: switch (json['description']) {
        final String d when d.isNotEmpty => d,
        _ => null,
      },
      privacy: switch (json['public']) {
        true => PlaylistPrivacy.public,
        false => PlaylistPrivacy.private,
        _ => null,
      },
      collaborative: json['collaborative'] as bool? ?? false,
      trackCount: json['tracks'] is Map
          ? _asMap(json['tracks'])['total'] as int? ?? 0
          : 0,
      artworkUrl: switch (images) {
        [final Map<String, Object?> first, ...] when first['url'] is String =>
          Uri.tryParse(first['url']! as String),
        _ => null,
      },
      etag: json['snapshot_id'] as String?,
    );
  });
}
