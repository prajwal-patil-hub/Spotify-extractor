import 'package:core_domain/core_domain.dart';
import 'package:provider_api/provider_api.dart';

/// In-memory reference implementation of the port.
///
/// Purposes: validate the contract suite itself, and stand in for real
/// providers in engine tests (matching, jobs, sync) where network is
/// unwanted. Behavior is deliberately "ideal provider": order-preserving,
/// strongly consistent, typed errors.
class FakeMusicProvider implements MusicProvider {
  FakeMusicProvider({
    ProviderId? id,
    ProviderCapabilities? capabilities,
    List<Track>? catalog,
  }) : id = id ?? const ProviderId('fake'),
       _capabilities =
           capabilities ??
           ProviderCapabilities(
             supported: {
               Capability.catalogSearch,
               Capability.likedSongs,
               Capability.playlistDescription,
               Capability.playlistPrivacy,
               Capability.playlistArtworkUpload,
             },
           ),
       _catalog = [...?catalog];

  @override
  final ProviderId id;

  @override
  String get displayName => 'Fake Provider (${id.value})';

  final ProviderCapabilities _capabilities;

  @override
  ProviderCapabilities get capabilities => _capabilities;

  final List<Track> _catalog;
  final Map<AccountId, Map<ProviderPlaylistId, Playlist>> _playlists = {};
  final Map<PlaylistRef, List<ProviderTrackId>> _tracks = {};
  final Map<AccountId, List<Track>> _liked = {};
  int _nextId = 1;

  /// Seeds an account so tests can skip the auth dance.
  AccountId seedAccount(String name) {
    final account = AccountId('fake:$name');
    _playlists.putIfAbsent(account, () => {});
    _liked.putIfAbsent(account, () => []);
    return account;
  }

  void seedCatalog(Iterable<Track> tracks) => _catalog.addAll(tracks);

  // -- lifecycle --------------------------------------------------------------

  @override
  Future<ConnectedAccount> authenticate(AuthBroker broker) async {
    final account = seedAccount('user${_nextId++}');
    return ConnectedAccount(
      provider: id,
      id: account,
      displayName: 'Fake User',
    );
  }

  @override
  Future<void> refreshSession(AccountId account) async {}

  @override
  Future<void> disconnect(AccountId account) async {
    _playlists.remove(account);
    _liked.remove(account);
  }

  // -- catalog ----------------------------------------------------------------

  @override
  Future<SearchResult> searchTrack(AccountId account, TrackQuery query) async {
    _require(Capability.catalogSearch);
    final needle = (query.freeform ?? '${query.title} ${query.artist ?? ''}')
        .toLowerCase();
    final hits = _catalog
        .where(
          (t) =>
              (query.isrc != null && t.isrc == query.isrc) ||
              '${t.title} ${t.primaryArtist?.name ?? ''}'
                  .toLowerCase()
                  .contains(needle.trim()),
        )
        .take(query.limit)
        .toList();
    return SearchResult(tracks: hits);
  }

  // -- reads ------------------------------------------------------------------

  // Port contract: stream methods deliver failures through the stream, never
  // by throwing at call time — hence async* generators throughout.

  @override
  Stream<Playlist> getPlaylists(AccountId account) async* {
    yield* Stream.fromIterable([..._account(account).values]);
  }

  @override
  Stream<Track> getPlaylistTracks(PlaylistRef playlist) async* {
    _checkExists(playlist);
    final ids = _tracks[playlist] ?? const <ProviderTrackId>[];
    for (final trackId in ids) {
      yield _catalog.firstWhere((t) => t.id == trackId);
    }
  }

  @override
  Stream<Track> getLikedSongs(AccountId account) async* {
    _require(Capability.likedSongs);
    yield* Stream.fromIterable([...(_liked[account] ?? const <Track>[])]);
  }

  @override
  Stream<Album> getAlbums(AccountId account) async* {
    _require(Capability.savedAlbums);
  }

  @override
  Stream<Artist> getArtists(AccountId account) async* {
    _require(Capability.followedArtists);
  }

  // -- writes -----------------------------------------------------------------

  @override
  Future<Playlist> createPlaylist(AccountId account, PlaylistSpec spec) async {
    final playlist = Playlist(
      providerId: id,
      id: ProviderPlaylistId('pl${_nextId++}'),
      name: spec.name,
      description: spec.description,
      privacy: spec.privacy ?? PlaylistPrivacy.private,
      collaborative: spec.collaborative,
      trackCount: 0,
    );
    _account(account)[playlist.id] = playlist;
    _tracks[PlaylistRef(account: account, playlist: playlist.id)] = [];
    return playlist;
  }

  @override
  Future<void> updatePlaylist(PlaylistRef playlist, PlaylistPatch patch) async {
    final current = _checkExists(playlist);
    if (patch.description.isSet) _require(Capability.playlistDescription);
    if (patch.privacy.isSet) _require(Capability.playlistPrivacy);
    _playlists[playlist.account]![playlist.playlist] = Playlist(
      providerId: current.providerId,
      id: current.id,
      name: patch.name.resolve(current.name),
      description: patch.description.resolve(current.description),
      privacy: patch.privacy.isSet
          ? patch.privacy.resolve(current.privacy ?? PlaylistPrivacy.private)
          : current.privacy,
      collaborative: current.collaborative,
      trackCount: current.trackCount,
    );
  }

  @override
  Future<void> deletePlaylist(PlaylistRef playlist) async {
    _checkExists(playlist);
    _playlists[playlist.account]!.remove(playlist.playlist);
    _tracks.remove(playlist);
  }

  @override
  Future<void> addTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds, {
    int? position,
  }) async {
    _checkExists(playlist);
    final list = _tracks[playlist]!;
    list.insertAll(position ?? list.length, trackIds);
    _bumpCount(playlist);
  }

  @override
  Future<void> removeTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds,
  ) async {
    _checkExists(playlist);
    _tracks[playlist]!.removeWhere(trackIds.contains);
    _bumpCount(playlist);
  }

  @override
  Future<void> replaceTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds,
  ) async {
    _checkExists(playlist);
    _tracks[playlist]!
      ..clear()
      ..addAll(trackIds);
    _bumpCount(playlist);
  }

  @override
  Future<void> uploadArtwork(PlaylistRef playlist, Artwork artwork) async {
    _require(Capability.playlistArtworkUpload);
    _checkExists(playlist);
  }

  @override
  Future<void> updateDescription(
    PlaylistRef playlist,
    String description,
  ) async {
    _require(Capability.playlistDescription);
    await updatePlaylist(
      playlist,
      PlaylistPatch(description: Field.set(description)),
    );
  }

  // -- internals ---------------------------------------------------------------

  Map<ProviderPlaylistId, Playlist> _account(AccountId account) =>
      _playlists.putIfAbsent(account, () => {});

  Playlist _checkExists(PlaylistRef ref) {
    final playlist = _playlists[ref.account]?[ref.playlist];
    if (playlist == null) {
      throw NotFound(id, 'playlist ${ref.playlist.value} does not exist');
    }
    return playlist;
  }

  void _bumpCount(PlaylistRef ref) {
    final current = _checkExists(ref);
    _playlists[ref.account]![ref.playlist] = Playlist(
      providerId: current.providerId,
      id: current.id,
      name: current.name,
      description: current.description,
      privacy: current.privacy,
      collaborative: current.collaborative,
      trackCount: _tracks[ref]!.length,
    );
  }

  void _require(Capability capability) {
    if (!_capabilities.supports(capability)) {
      throw CapabilityUnsupported(
        id,
        'capability not supported: $capability',
        capability,
      );
    }
  }
}
