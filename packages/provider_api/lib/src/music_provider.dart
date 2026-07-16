import 'dart:typed_data';

import 'package:core_domain/core_domain.dart';
import 'package:meta/meta.dart';

import 'auth/auth_broker.dart';

/// One account at one provider, as returned by [MusicProvider.authenticate].
@immutable
class ConnectedAccount {
  const ConnectedAccount({
    required this.provider,
    required this.id,
    required this.displayName,
    this.avatarUrl,
  });

  final ProviderId provider;
  final AccountId id;
  final String displayName;
  final Uri? avatarUrl;
}

/// A playlist addressed at a specific account — every playlist operation
/// needs both, because a user can connect multiple accounts per provider.
@immutable
class PlaylistRef {
  const PlaylistRef({required this.account, required this.playlist});

  final AccountId account;
  final ProviderPlaylistId playlist;

  @override
  bool operator ==(Object other) =>
      other is PlaylistRef &&
      other.account == account &&
      other.playlist == playlist;

  @override
  int get hashCode => Object.hash(account, playlist);
}

/// A catalog search request. Structured fields let providers build fielded
/// queries (the matching engine's query ladder, docs/07 §3); [freeform]
/// bypasses them for manual user searches.
@immutable
class TrackQuery {
  const TrackQuery({
    this.title,
    this.artist,
    this.album,
    this.isrc,
    this.freeform,
    this.limit = 10,
  }) : assert(
         freeform != null || title != null || isrc != null,
         'a query needs freeform text, a title, or an ISRC',
       );

  final String? title;
  final String? artist;
  final String? album;

  /// When set and the provider supports [Capability.isrcSearch], providers
  /// must prefer an ISRC-filtered search over text fields.
  final String? isrc;

  final String? freeform;
  final int limit;
}

/// Ranked catalog search results, source order preserved.
@immutable
class SearchResult {
  const SearchResult({required this.tracks});

  final List<Track> tracks;
}

/// Artwork payload for upload; providers validate against their declared
/// capability limits and throw [CapabilityUnsupported] when out of bounds.
@immutable
class Artwork {
  const Artwork({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;
}

/// The port (docs/04 §4). Every streaming service implements exactly this;
/// nothing outside the plugin may know anything more specific.
///
/// Contract, enforced by the testing_toolkit contract suite:
/// - Streams paginate internally and emit items in provider order.
/// - Every thrown error is a [ProviderError] subtype — nothing else escapes.
/// - Methods for undeclared capabilities throw [CapabilityUnsupported].
/// - All operations are account-scoped; there is no ambient "current user".
abstract interface class MusicProvider {
  ProviderId get id;
  String get displayName;

  /// Read fresh on every use — capabilities can shrink at runtime
  /// (kill switch, consent withdrawal — docs/04 §5).
  ProviderCapabilities get capabilities;

  // -- lifecycle ------------------------------------------------------------

  /// Runs the interactive auth flow, persists the session in the injected
  /// [TokenStore], and returns the account's identity.
  Future<ConnectedAccount> authenticate(AuthBroker broker);

  /// Forces a token refresh for [account] (normally proactive and internal;
  /// exposed for the job engine's reconnect path).
  Future<void> refreshSession(AccountId account);

  /// Revokes (where supported) and deletes the stored session.
  Future<void> disconnect(AccountId account);

  // -- catalog --------------------------------------------------------------

  Future<SearchResult> searchTrack(AccountId account, TrackQuery query);

  // -- library reads (paginated internally) ----------------------------------

  Stream<Playlist> getPlaylists(AccountId account);
  Stream<Track> getPlaylistTracks(PlaylistRef playlist);
  Stream<Track> getLikedSongs(AccountId account);
  Stream<Album> getAlbums(AccountId account);
  Stream<Artist> getArtists(AccountId account);

  // -- playlist writes --------------------------------------------------------

  Future<Playlist> createPlaylist(AccountId account, PlaylistSpec spec);
  Future<void> updatePlaylist(PlaylistRef playlist, PlaylistPatch patch);
  Future<void> deletePlaylist(PlaylistRef playlist);
  Future<void> addTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds, {
    int? position,
  });
  Future<void> removeTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds,
  );
  Future<void> replaceTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds,
  );
  Future<void> uploadArtwork(PlaylistRef playlist, Artwork artwork);
  Future<void> updateDescription(PlaylistRef playlist, String description);
}
