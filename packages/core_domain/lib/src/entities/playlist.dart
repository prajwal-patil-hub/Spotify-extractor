import 'package:meta/meta.dart';

import '../field.dart';
import '../ids.dart';

/// Privacy levels across providers. Plugins map their native values onto
/// this set and declare which subset they support via capability details.
enum PlaylistPrivacy { public, unlisted, private }

/// A playlist as seen at one provider (metadata only — tracks are streamed
/// separately and never embedded, so a 10k-track playlist stays cheap).
@immutable
class Playlist {
  const Playlist({
    required this.providerId,
    required this.id,
    required this.name,
    required this.trackCount,
    this.description,
    this.privacy,
    this.collaborative = false,
    this.artworkUrl,
    this.etag,
  });

  final ProviderId providerId;
  final ProviderPlaylistId id;
  final String name;
  final int trackCount;
  final String? description;
  final PlaylistPrivacy? privacy;
  final bool collaborative;
  final Uri? artworkUrl;

  /// Provider-side change token (e.g. a snapshot id) enabling O(1) change
  /// detection for incremental sync (docs/08 §5). Opaque to core.
  final String? etag;

  @override
  bool operator ==(Object other) =>
      other is Playlist &&
      other.providerId == providerId &&
      other.id == id &&
      other.name == name &&
      other.trackCount == trackCount &&
      other.description == description &&
      other.privacy == privacy &&
      other.collaborative == collaborative &&
      other.artworkUrl == artworkUrl &&
      other.etag == etag;

  @override
  int get hashCode => Object.hash(
    providerId,
    id,
    name,
    trackCount,
    description,
    privacy,
    collaborative,
    artworkUrl,
    etag,
  );

  @override
  String toString() =>
      'Playlist(${providerId.value}:${id.value} "$name", $trackCount tracks)';
}

/// What to create: input to `MusicProvider.createPlaylist`.
@immutable
class PlaylistSpec {
  const PlaylistSpec({
    required this.name,
    this.description,
    this.privacy,
    this.collaborative = false,
  });

  final String name;
  final String? description;

  /// Null means "provider default" — the plugin decides.
  final PlaylistPrivacy? privacy;
  final bool collaborative;

  @override
  bool operator ==(Object other) =>
      other is PlaylistSpec &&
      other.name == name &&
      other.description == description &&
      other.privacy == privacy &&
      other.collaborative == collaborative;

  @override
  int get hashCode => Object.hash(name, description, privacy, collaborative);
}

/// A partial update: input to `MusicProvider.updatePlaylist`. Uses [Field]
/// so "don't touch the description" and "clear the description" are both
/// expressible.
@immutable
class PlaylistPatch {
  const PlaylistPatch({
    this.name = const Field.keep(),
    this.description = const Field.keep(),
    this.privacy = const Field.keep(),
  });

  final Field<String> name;
  final Field<String?> description;
  final Field<PlaylistPrivacy> privacy;

  bool get isEmpty => !name.isSet && !description.isSet && !privacy.isSet;

  @override
  bool operator ==(Object other) =>
      other is PlaylistPatch &&
      other.name == name &&
      other.description == description &&
      other.privacy == privacy;

  @override
  int get hashCode => Object.hash(name, description, privacy);
}
