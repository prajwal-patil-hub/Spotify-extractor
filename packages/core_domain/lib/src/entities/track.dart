import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../ids.dart';
import 'album.dart';
import 'artist.dart';

/// A track as seen at one provider, unmodified. This is the input to the
/// matching engine and the unit of transfer.
///
/// Every optional field is genuinely optional in the wild (docs/02): ISRC is
/// never available from YouTube Music, explicit flags are frequently absent,
/// and search results often omit albums. Absence must always mean "unknown",
/// never a fabricated default — the matching engine treats unknown and
/// non-matching differently.
@immutable
class Track {
  const Track({
    required this.providerId,
    required this.id,
    required this.title,
    required this.artists,
    this.album,
    this.duration,
    this.isrc,
    this.releaseYear,
    this.explicit,
    this.popularity,
  });

  final ProviderId providerId;
  final ProviderTrackId id;
  final String title;

  /// Ordered as the provider lists them; first artist is primary.
  final List<Artist> artists;

  final Album? album;
  final Duration? duration;

  /// International Standard Recording Code — the strongest cross-catalog
  /// identity signal when present (docs/07).
  final String? isrc;

  final int? releaseYear;

  /// Null means the provider did not say — distinct from `false`.
  final bool? explicit;

  /// Provider-relative popularity, normalized by plugins to 0–100.
  final int? popularity;

  Artist? get primaryArtist => artists.firstOrNull;

  @override
  bool operator ==(Object other) =>
      other is Track &&
      other.providerId == providerId &&
      other.id == id &&
      other.title == title &&
      const ListEquality<Artist>().equals(other.artists, artists) &&
      other.album == album &&
      other.duration == duration &&
      other.isrc == isrc &&
      other.releaseYear == releaseYear &&
      other.explicit == explicit &&
      other.popularity == popularity;

  @override
  int get hashCode => Object.hash(
    providerId,
    id,
    title,
    const ListEquality<Artist>().hash(artists),
    album,
    duration,
    isrc,
    releaseYear,
    explicit,
    popularity,
  );

  @override
  String toString() =>
      'Track(${providerId.value}:${id.value} "$title" by ${primaryArtist?.name ?? '?'})';
}
