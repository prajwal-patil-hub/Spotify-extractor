import 'package:core_domain/core_domain.dart';
import 'package:matching_engine/matching_engine.dart';
import 'package:provider_api/provider_api.dart';
import 'package:test/test.dart';

const _src = ProviderId('spotify');
const _dst = ProviderId('ytmusic');

Track _track(
  String id,
  String title,
  String artist, {
  ProviderId provider = _dst,
  int? durationMs,
  String? isrc,
  String? album,
}) => Track(
  providerId: provider,
  id: ProviderTrackId(id),
  title: title,
  artists: [Artist(name: artist)],
  album: album == null ? null : Album(title: album),
  duration: durationMs == null ? null : Duration(milliseconds: durationMs),
  isrc: isrc,
);

void main() {
  final engine = MatchEngine();

  group('query ladder', () {
    test('ISRC rung leads when available and supported', () {
      final source = _track(
        's',
        'Fast Car',
        'Tracy Chapman',
        provider: _src,
        isrc: 'ISRC1',
        album: 'Tracy Chapman',
      );
      final rungs = engine.ladder(source, isrcSearchSupported: true);
      expect(rungs.first.isrc, 'ISRC1');
      expect(rungs, hasLength(greaterThanOrEqualTo(4)));
    });

    test('ISRC rung is skipped when unsupported (the YTM case)', () {
      final source = _track(
        's',
        'Fast Car',
        'Tracy Chapman',
        provider: _src,
        isrc: 'ISRC1',
      );
      final rungs = engine.ladder(source, isrcSearchSupported: false);
      expect(rungs.every((q) => q.isrc == null), isTrue);
    });

    test('stripped-title rung appears only when qualifiers exist', () {
      final plain = engine.ladder(
        _track('s', 'Fast Car', 'Tracy Chapman', provider: _src),
        isrcSearchSupported: false,
      );
      final qualified = engine.ladder(
        _track(
          's',
          'Fast Car (2015 Remaster)',
          'Tracy Chapman',
          provider: _src,
        ),
        isrcSearchSupported: false,
      );
      expect(qualified.length, plain.length + 1);
    });
  });

  group('match', () {
    test('early-stops the ladder once a very-high candidate appears', () async {
      final queries = <TrackQuery>[];
      final outcome = await engine.match(
        _track(
          's',
          'Fast Car',
          'Tracy Chapman',
          provider: _src,
          durationMs: 296000,
        ),
        threshold: MatchThreshold.balanced,
        search: (q) async {
          queries.add(q);
          return [
            _track('c1', 'Fast Car', 'Tracy Chapman', durationMs: 296000),
          ];
        },
      );
      expect(outcome.decision, MatchDecision.autoApproved);
      expect(queries, hasLength(1), reason: 'later rungs must not run');
    });

    test('margin rule demotes ambiguous winners into review', () async {
      // Two near-identical candidates (a cover situation) — the raw score
      // would auto-approve, the margin rule must not let it.
      final outcome = await engine.match(
        _track(
          's',
          'Hallelujah',
          'Jeff Buckley',
          provider: _src,
          durationMs: 414000,
        ),
        threshold: MatchThreshold.balanced,
        search: (q) async => [
          _track('c1', 'Hallelujah', 'Jeff Buckley', durationMs: 414000),
          _track('c2', 'Hallelujah', 'Jeff Buckley', durationMs: 415000),
        ],
      );
      expect(outcome.ranked, hasLength(2));
      expect(
        outcome.tier,
        isNot(ConfidenceTier.exact),
        reason: 'ambiguity demotes one tier',
      );
    });

    test('no candidates → noCandidates decision', () async {
      final outcome = await engine.match(
        _track('s', 'Obscure B-Side', 'Unknown Artist', provider: _src),
        threshold: MatchThreshold.balanced,
        search: (q) async => [],
      );
      expect(outcome.decision, MatchDecision.noCandidates);
      expect(outcome.best, isNull);
    });

    test('weak candidates → needsReview, ranked list preserved', () async {
      final outcome = await engine.match(
        _track(
          's',
          'Fast Car',
          'Tracy Chapman',
          provider: _src,
          durationMs: 296000,
        ),
        threshold: MatchThreshold.balanced,
        search: (q) async => [
          _track('c1', 'Fast Car', 'Luke Combs', durationMs: 265000),
          _track('c2', 'Fast Car (Karaoke)', 'Sing King', durationMs: 296000),
        ],
      );
      expect(outcome.decision, MatchDecision.needsReview);
      expect(outcome.ranked, hasLength(2));
    });

    test('pool deduplicates candidates returned by multiple rungs', () async {
      final candidate = _track(
        'c1',
        'Fast Car (Live)',
        'Tracy Chapman',
        durationMs: 296000,
      );
      final outcome = await engine.match(
        _track(
          's',
          'Fast Car',
          'Tracy Chapman',
          provider: _src,
          durationMs: 296000,
        ),
        threshold: MatchThreshold.strict,
        search: (q) async => [candidate, candidate],
      );
      expect(outcome.ranked, hasLength(1));
    });

    test(
      'strict vs relaxed thresholds gate the same score differently',
      () async {
        Future<MatchOutcome> run(MatchThreshold t) => engine.match(
          _track(
            's',
            'Fast Car',
            'Tracy Chapman',
            provider: _src,
            durationMs: 296000,
          ),
          threshold: t,
          // Good-but-not-very-high candidate: fuzzy artist, 8 s duration drift.
          search: (q) async => [
            _track('c1', 'Fast Car', 'Tracy Chapman Band', durationMs: 288000),
          ],
        );
        final strict = await run(MatchThreshold.strict);
        final relaxed = await run(MatchThreshold.relaxed);
        expect(strict.decision, MatchDecision.needsReview);
        expect(relaxed.decision, MatchDecision.autoApproved);
      },
    );
  });
}
