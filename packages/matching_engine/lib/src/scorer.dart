import 'dart:math';

import 'package:core_domain/core_domain.dart';
import 'package:meta/meta.dart';

import 'aliases.dart';
import 'normalizer.dart';
import 'similarity.dart';

/// Per-signal scores plus the combined total — persisted as `signalsJson`
/// so the review UI can explain every match (docs/05 §4.3).
@immutable
class MatchSignals {
  const MatchSignals({required this.perSignal, required this.notes});

  /// signal name → score in [0,1]; absent = signal unknown on either side.
  final Map<String, double> perSignal;

  /// Human-readable scoring notes ("live/studio mismatch ×0.5").
  final List<String> notes;
}

@immutable
class ScoredCandidate {
  const ScoredCandidate({
    required this.candidate,
    required this.score,
    required this.signals,
  });

  final Track candidate;
  final double score;
  final MatchSignals signals;
}

/// A source track pre-processed once, scored against many candidates.
@immutable
class PreparedTrack {
  PreparedTrack(this.track, {Normalizer normalizer = const Normalizer()})
    : title = normalizer.normalizeTitle(track.title),
      artists = normalizer.normalizeArtists([
        for (final a in track.artists) a.name,
      ]),
      album = track.album == null
          ? null
          : normalizer.normalizeAlbum(track.album!.title);

  final Track track;
  final NormalizedTitle title;
  final List<String> artists;
  final String? album;

  List<String> get allArtists => [...artists, ...title.featuredArtists];
}

/// Weighted signal fusion per docs/07 §4. Weights renormalize over the
/// signals actually present — unknown metadata is excluded, never faked.
class Scorer {
  Scorer({AliasTable? aliases, this.normalizer = const Normalizer()})
    : _aliases = aliases ?? AliasTable();

  final AliasTable _aliases;
  final Normalizer normalizer;

  static const _weights = <String, double>{
    'title': 0.30,
    'artist': 0.25,
    'duration': 0.15,
    'album': 0.10,
    'variants': 0.10,
    'year': 0.05,
    'explicit': 0.03,
    'popularity': 0.02,
  };

  /// Total-score cap when durations disagree by more than 15 s — the
  /// strongest single disqualifier (docs/07 §4).
  static const durationCap = 0.70;

  /// Multiplier for a hard variant-flag mismatch (live/acoustic/
  /// instrumental/karaoke/remix/demo): a different *recording*.
  static const hardVariantPenalty = 0.5;

  ScoredCandidate score(PreparedTrack source, Track rawCandidate) {
    final candidate = PreparedTrack(rawCandidate, normalizer: normalizer);
    final signals = <String, double>{};
    final notes = <String>[];

    // -- ISRC short-circuit: verified equality ⇒ 0.99, guarded by a title
    //    sanity check to catch provider data errors (docs/07 §4).
    final srcIsrc = source.track.isrc;
    if (srcIsrc != null && srcIsrc == rawCandidate.isrc) {
      final sanity = titleSimilarity(source.title.base, candidate.title.base);
      if (sanity >= 0.5) {
        return ScoredCandidate(
          candidate: rawCandidate,
          score: 0.99,
          signals: MatchSignals(
            perSignal: {'isrc': 1.0, 'title': sanity},
            notes: [...notes, 'ISRC verified'],
          ),
        );
      }
      notes.add('ISRC equal but title sanity failed — scoring fuzzily');
    }

    signals['title'] = titleSimilarity(source.title.base, candidate.title.base);
    signals['artist'] = _artistScore(source, candidate);

    final durationScore = _durationScore(
      source.track.duration,
      rawCandidate.duration,
    );
    if (durationScore != null) signals['duration'] = durationScore;

    if (source.album != null && candidate.album != null) {
      signals['album'] = jaroWinkler(source.album!, candidate.album!);
    }

    signals['variants'] = _variantAgreement(
      source.title.flags,
      candidate.title.flags,
    );

    final yearScore = _yearScore(source.track, rawCandidate);
    if (yearScore != null) signals['year'] = yearScore;

    if (source.track.explicit != null && rawCandidate.explicit != null) {
      signals['explicit'] = source.track.explicit == rawCandidate.explicit
          ? 1.0
          : 0.3; // mild: catalogs mislabel — never a hard block
    }

    if (rawCandidate.popularity != null) {
      signals['popularity'] = rawCandidate.popularity! / 100;
    }

    // Weighted sum over present signals, renormalized.
    var weighted = 0.0;
    var weightSum = 0.0;
    signals.forEach((name, value) {
      final w = _weights[name]!;
      weighted += w * value;
      weightSum += w;
    });
    var total = weightSum == 0 ? 0.0 : weighted / weightSum;

    // Hard variant mismatch: a different recording halves the total.
    final hardMismatch = _hardMismatch(
      source.title.flags,
      candidate.title.flags,
    );
    if (hardMismatch != null) {
      total *= hardVariantPenalty;
      notes.add('${hardMismatch.name} mismatch ×$hardVariantPenalty');
    }

    // Duration outlier caps the total regardless of other agreement.
    final srcMs = source.track.duration?.inMilliseconds;
    final dstMs = rawCandidate.duration?.inMilliseconds;
    if (srcMs != null && dstMs != null && (srcMs - dstMs).abs() > 15000) {
      if (total > durationCap) {
        total = durationCap;
        notes.add('duration Δ>15 s caps score at $durationCap');
      }
    }

    return ScoredCandidate(
      candidate: rawCandidate,
      score: double.parse(total.toStringAsFixed(4)),
      signals: MatchSignals(perSignal: signals, notes: notes),
    );
  }

  double _artistScore(PreparedTrack source, PreparedTrack candidate) {
    final srcArtists = source.allArtists;
    final dstArtists = candidate.allArtists;
    if (srcArtists.isEmpty || dstArtists.isEmpty) return 0;

    double pair(String a, String b) =>
        _aliases.areAliases(a, b) ? 1.0 : jaroWinkler(a, b);

    // Primary-artist alignment carries most of the weight (docs/07 §4).
    final primary = pair(srcArtists.first, dstArtists.first);

    // Best-alignment overlap across the full sets (feat. artists included).
    var overlap = 0.0;
    for (final src in srcArtists) {
      overlap += dstArtists.map((dst) => pair(src, dst)).reduce(max);
    }
    overlap /= srcArtists.length;

    return 0.7 * primary + 0.3 * overlap;
  }

  double? _durationScore(Duration? a, Duration? b) {
    if (a == null || b == null) return null;
    final delta = (a.inMilliseconds - b.inMilliseconds).abs();
    if (delta <= 2000) return 1;
    if (delta >= 15000) return 0;
    return 1 - (delta - 2000) / 13000;
  }

  double _variantAgreement(Set<VariantFlag> a, Set<VariantFlag> b) {
    if (a.isEmpty && b.isEmpty) return 1;
    final union = {...a, ...b};
    final agreeing = union.where((f) => a.contains(f) == b.contains(f));
    return agreeing.length / union.length;
  }

  VariantFlag? _hardMismatch(Set<VariantFlag> a, Set<VariantFlag> b) {
    for (final flag in VariantFlag.values.where((f) => f.hard)) {
      if (a.contains(flag) != b.contains(flag)) return flag;
    }
    return null;
  }

  double? _yearScore(Track a, Track b) {
    final ya = a.releaseYear ?? a.album?.releaseYear;
    final yb = b.releaseYear ?? b.album?.releaseYear;
    if (ya == null || yb == null) return null;
    final delta = (ya - yb).abs();
    if (delta == 0) return 1;
    if (delta > 3) return 0;
    return 1 - delta / 4;
  }
}
