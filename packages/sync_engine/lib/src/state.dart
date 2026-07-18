import 'package:meta/meta.dart';

/// The canonical identity a track is synced under — one namespace shared by
/// both sides of a pair. The composition root maps provider track ids to
/// sync ids via the mapping cache (docs/08 §5: "mappings make the two
/// playlists comparable at all").
typedef SyncId = String;

/// One side of a pair at one moment: an ordered track list.
@immutable
class PlaylistState {
  PlaylistState(List<SyncId> tracks) : tracks = List.unmodifiable(tracks);

  PlaylistState.empty() : tracks = const [];

  final List<SyncId> tracks;

  late final Set<SyncId> asSet = tracks.toSet();

  bool contains(SyncId id) => asSet.contains(id);

  Map<String, Object?> toJson() => {'tracks': tracks};

  factory PlaylistState.fromJson(Map<String, Object?> json) =>
      PlaylistState([...(json['tracks']! as List).cast<SyncId>()]);
}
