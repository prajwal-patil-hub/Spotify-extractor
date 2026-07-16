import 'package:core_domain/core_domain.dart';
import 'package:meta/meta.dart';
import 'package:provider_api/provider_api.dart';

import 'normalizer.dart';
import 'scorer.dart';

/// How the caller obtains candidates — the destination provider's search,
/// or a fixture catalog in tests. The engine never talks to providers
/// directly.
typedef CandidateSearch = Future<List<Track>> Function(TrackQuery query);

enum MatchDecision {
  /// Best candidate clears the active threshold — transfer without review.
  autoApproved,

  /// Candidates exist but none clears the threshold — human review queue.
  needsReview,

  /// The ladder produced no candidates at all — confirmed miss.
  noCandidates,
}

@immutable
class MatchOutcome {
  const MatchOutcome({required this.decision, required this.ranked, this.tier});

  final MatchDecision decision;

  /// All scored candidates, best first (capped pool).
  final List<ScoredCandidate> ranked;

  /// Best candidate's tier AFTER the margin rule — may be one level below
  /// its raw score's tier when the runner-up was too close.
  final ConfidenceTier? tier;

  ScoredCandidate? get best => ranked.isEmpty ? null : ranked.first;
}

/// The pipeline of docs/07: query ladder → candidate pool → score → rank →
/// margin rule → decision. Pure orchestration over injected search.
class MatchEngine {
  MatchEngine({
    Scorer? scorer,
    this.poolCap = 25,
    this.earlyStopScore = 0.95,
    this.marginWindow = 0.05,
  }) : _scorer = scorer ?? Scorer();

  final Scorer _scorer;

  /// Max candidates considered — each search rung costs quota (docs/07 §3).
  final int poolCap;

  /// A candidate at/above this stops the ladder early.
  final double earlyStopScore;

  /// Top must beat runner-up by this much, or the tier demotes one level —
  /// ambiguity is treated as uncertainty (covers, re-recordings).
  final double marginWindow;

  /// The cost-ordered query ladder (docs/07 §3). Stop at the first rung
  /// that satisfies [earlyStopScore]; every rung costs quota.
  @visibleForTesting
  List<TrackQuery> ladder(Track source, {required bool isrcSearchSupported}) {
    final title = source.title;
    final artist = source.primaryArtist?.name;
    final album = source.album?.title;
    final strippedTitle = const Normalizer().normalizeTitle(title).base;
    return [
      if (source.isrc != null && isrcSearchSupported)
        TrackQuery(isrc: source.isrc, title: title),
      if (artist != null && album != null)
        TrackQuery(title: title, artist: artist, album: album),
      if (artist != null) TrackQuery(title: title, artist: artist),
      if (artist != null && strippedTitle != title.toLowerCase())
        TrackQuery(title: strippedTitle, artist: artist),
      TrackQuery(freeform: '$title ${artist ?? ''}'.trim(), limit: 10),
    ];
  }

  Future<MatchOutcome> match(
    Track source, {
    required CandidateSearch search,
    required MatchThreshold threshold,
    bool isrcSearchSupported = false,
  }) async {
    final prepared = PreparedTrack(source);
    final pool = <ProviderTrackId, ScoredCandidate>{};

    for (final query in ladder(
      source,
      isrcSearchSupported: isrcSearchSupported,
    )) {
      final results = await search(query);
      for (final candidate in results) {
        if (pool.length >= poolCap && !pool.containsKey(candidate.id)) {
          continue;
        }
        pool.putIfAbsent(
          candidate.id,
          () => _scorer.score(prepared, candidate),
        );
      }
      final bestSoFar = _rank(pool.values).firstOrNull;
      if (bestSoFar != null && bestSoFar.score >= earlyStopScore) break;
    }

    final ranked = _rank(pool.values);
    if (ranked.isEmpty) {
      return const MatchOutcome(
        decision: MatchDecision.noCandidates,
        ranked: [],
      );
    }

    var tier = ConfidenceTier.fromScore(ranked.first.score);
    if (ranked.length >= 2 &&
        ranked.first.score - ranked[1].score < marginWindow) {
      tier = _demote(tier);
    }

    final autoApproved =
        tier != ConfidenceTier.uncertain &&
        threshold.autoApproves(_tierFloor(tier));
    return MatchOutcome(
      decision: autoApproved
          ? MatchDecision.autoApproved
          : MatchDecision.needsReview,
      ranked: ranked,
      tier: tier,
    );
  }

  List<ScoredCandidate> _rank(Iterable<ScoredCandidate> pool) =>
      pool.toList()..sort((a, b) => b.score.compareTo(a.score));

  ConfidenceTier _demote(ConfidenceTier tier) => switch (tier) {
    ConfidenceTier.exact => ConfidenceTier.veryHigh,
    ConfidenceTier.veryHigh => ConfidenceTier.high,
    ConfidenceTier.high => ConfidenceTier.possible,
    ConfidenceTier.possible ||
    ConfidenceTier.uncertain => ConfidenceTier.uncertain,
  };

  /// The lower bound of a tier — what the margin-demoted confidence is
  /// worth when gating against the user's threshold.
  double _tierFloor(ConfidenceTier tier) => switch (tier) {
    ConfidenceTier.exact => 0.99,
    ConfidenceTier.veryHigh => 0.95,
    ConfidenceTier.high => 0.85,
    ConfidenceTier.possible => 0.70,
    ConfidenceTier.uncertain => 0.0,
  };
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
