import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Everything a provider MAY be able to do beyond baseline playlist CRUD.
///
/// The UI renders exclusively from resolved capabilities (docs/04 §5) —
/// this enum is the vocabulary that makes "never hardcode functionality"
/// enforceable.
enum Capability {
  likedSongs,
  savedAlbums,
  followedArtists,
  playlistArtworkUpload,
  playlistDescription,
  playlistPrivacy,
  playlistReorder,
  collaborativePlaylists,
  folders,
  listeningHistory,
  queue,
  podcasts,
  smartPlaylists,
  isrcLookup,
  isrcSearch,
  catalogSearch,
}

/// Caveats and limits attached to a supported capability, e.g. artwork:
/// `{maxBytes: 256000, formats: [jpeg]}`, or privacy: the subset of
/// [PlaylistPrivacy] values the provider accepts.
@immutable
class CapabilityDetail {
  const CapabilityDetail({this.note, this.limits = const {}});

  /// Human-readable caveat, surfaced verbatim in transfer summaries
  /// (e.g. "artwork must be JPEG under 256 KB").
  final String? note;

  final Map<String, Object?> limits;

  @override
  bool operator ==(Object other) =>
      other is CapabilityDetail &&
      other.note == note &&
      const DeepCollectionEquality().equals(other.limits, limits);

  @override
  int get hashCode =>
      Object.hash(note, const DeepCollectionEquality().hash(limits));
}

/// The set of capabilities a provider supports *right now*.
///
/// Deliberately a value object, not a constant: a provider's capabilities
/// can shrink at runtime (kill switch, declined consent, degraded auth —
/// docs/01 §3.2), so callers must always read them fresh from the provider.
@immutable
class ProviderCapabilities {
  ProviderCapabilities({
    required Set<Capability> supported,
    Map<Capability, CapabilityDetail> details = const {},
  }) : supported = Set.unmodifiable(supported),
       details = Map.unmodifiable(details) {
    final orphaned = details.keys.where((c) => !supported.contains(c));
    assert(
      orphaned.isEmpty,
      'CapabilityDetail given for unsupported capabilities: $orphaned',
    );
  }

  static final ProviderCapabilities none = ProviderCapabilities(
    supported: const {},
  );

  final Set<Capability> supported;
  final Map<Capability, CapabilityDetail> details;

  bool supports(Capability capability) => supported.contains(capability);

  CapabilityDetail? detailOf(Capability capability) => details[capability];

  /// Capabilities available to a transfer/sync between two providers: the
  /// intersection of what both sides support, keeping each side's caveats
  /// (destination's caveat wins when both declare one — the destination is
  /// where the write happens).
  ProviderCapabilities intersect(ProviderCapabilities destination) {
    final common = supported.intersection(destination.supported);
    return ProviderCapabilities(
      supported: common,
      details: {
        for (final c in common)
          if (destination.details[c] != null || details[c] != null)
            c: destination.details[c] ?? details[c]!,
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ProviderCapabilities &&
      const SetEquality<Capability>().equals(other.supported, supported) &&
      const MapEquality<Capability, CapabilityDetail>().equals(
        other.details,
        details,
      );

  @override
  int get hashCode => Object.hash(
    const SetEquality<Capability>().hash(supported),
    const MapEquality<Capability, CapabilityDetail>().hash(details),
  );
}
