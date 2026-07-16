import 'package:core_domain/core_domain.dart';
import 'package:matching_engine/matching_engine.dart';
import 'package:provider_api/provider_api.dart';
import 'package:test/test.dart';

import 'golden/golden_cases.dart';

/// Simulates a provider search over a case's catalog slice: ISRC-filtered
/// when the query carries one, token-overlap text search otherwise —
/// deliberately generous, like real provider search (returning traps is
/// the point; the scorer must reject them).
CandidateSearch searchOver(List<Track> catalog) => (TrackQuery query) async {
  if (query.isrc != null) {
    final hits = [
      for (final t in catalog)
        if (t.isrc == query.isrc) t,
    ];
    if (hits.isNotEmpty) return hits;
  }
  const normalizer = Normalizer();
  final needle = normalizer.fold(
    query.freeform ?? '${query.title ?? ''} ${query.artist ?? ''}',
  );
  final needleTokens = needle.split(' ').where((t) => t.isNotEmpty).toSet();
  final scored = <(int, Track)>[];
  for (final t in catalog) {
    final hay = normalizer
        .fold('${t.title} ${t.artists.map((a) => a.name).join(' ')}')
        .split(' ')
        .toSet();
    final overlap = needleTokens.intersection(hay).length;
    if (overlap > 0) scored.add((overlap, t));
  }
  scored.sort((a, b) => b.$1.compareTo(a.$1));
  return [for (final (_, t) in scored.take(query.limit)) t];
};

void main() {
  final engine = MatchEngine();

  group('golden set — per case', () {
    for (final c in goldenCases) {
      test(c.name, () async {
        final outcome = await engine.match(
          c.source,
          threshold: MatchThreshold.balanced,
          search: searchOver(c.catalog),
          isrcSearchSupported: true,
        );
        if (c.expectAuto) {
          expect(
            outcome.decision,
            MatchDecision.autoApproved,
            reason:
                'expected auto-approve of ${c.expectedId}; got '
                '${outcome.decision} (best: ${outcome.best?.candidate.title} '
                '@ ${outcome.best?.score}, tier ${outcome.tier})',
          );
          expect(outcome.best!.candidate.id.value, c.expectedId);
        } else {
          // The one unforgivable failure mode is a confident wrong answer.
          expect(
            outcome.decision,
            isNot(MatchDecision.autoApproved),
            reason:
                'must not auto-approve; got '
                '${outcome.best?.candidate.title} @ ${outcome.best?.score}',
          );
        }
      });
    }
  });

  test('golden metrics: precision 100%, auto-rate ≥95%, zero hard-flag '
      'violations (docs/12 §3 exit gate)', () async {
    var positives = 0;
    var autoApproved = 0;
    var autoCorrect = 0;
    var hardFlagViolations = 0;
    const normalizer = Normalizer();

    for (final c in goldenCases) {
      final outcome = await engine.match(
        c.source,
        threshold: MatchThreshold.balanced,
        search: searchOver(c.catalog),
        isrcSearchSupported: true,
      );
      if (c.expectedId != null) positives++;
      if (outcome.decision == MatchDecision.autoApproved) {
        autoApproved++;
        if (outcome.best!.candidate.id.value == c.expectedId) autoCorrect++;
        // A hard-variant disagreement inside an auto-approval is the
        // live-for-studio class of bug — categorically forbidden.
        final srcFlags = normalizer.normalizeTitle(c.source.title).flags;
        final dstFlags = normalizer
            .normalizeTitle(outcome.best!.candidate.title)
            .flags;
        for (final flag in VariantFlag.values.where((f) => f.hard)) {
          if (srcFlags.contains(flag) != dstFlags.contains(flag)) {
            hardFlagViolations++;
          }
        }
      }
    }

    final precision = autoApproved == 0 ? 1.0 : autoCorrect / autoApproved;
    final autoRate = positives == 0 ? 1.0 : autoApproved / positives;

    // ignore: avoid_print
    print(
      'golden metrics: cases=${goldenCases.length} positives=$positives '
      'auto=$autoApproved precision=${(precision * 100).toStringAsFixed(1)}% '
      'autoRate=${(autoRate * 100).toStringAsFixed(1)}% '
      'hardFlagViolations=$hardFlagViolations',
    );

    expect(
      precision,
      1.0,
      reason:
          'a confident wrong match is the one '
          'unforgivable failure — precision must be 100% on the golden set',
    );
    expect(autoRate, greaterThanOrEqualTo(0.95));
    expect(hardFlagViolations, 0);
  });
}
