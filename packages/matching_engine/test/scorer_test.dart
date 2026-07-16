import 'package:core_domain/core_domain.dart';
import 'package:matching_engine/matching_engine.dart';
import 'package:test/test.dart';

const _src = ProviderId('spotify');
const _dst = ProviderId('ytmusic');

Track _track(
  String id,
  String title,
  String artist, {
  ProviderId provider = _dst,
  String? album,
  int? durationMs,
  String? isrc,
  int? year,
  bool? explicit,
  int? popularity,
}) => Track(
  providerId: provider,
  id: ProviderTrackId(id),
  title: title,
  artists: [Artist(name: artist)],
  album: album == null ? null : Album(title: album, releaseYear: year),
  duration: durationMs == null ? null : Duration(milliseconds: durationMs),
  isrc: isrc,
  releaseYear: year,
  explicit: explicit,
  popularity: popularity,
);

void main() {
  final scorer = Scorer();

  PreparedTrack prep(Track t) => PreparedTrack(t);

  group('ISRC short-circuit', () {
    final source = _track(
      's1',
      'Fast Car',
      'Tracy Chapman',
      provider: _src,
      isrc: 'USEE10180355',
      durationMs: 296000,
    );

    test('verified ISRC equality scores 0.99', () {
      final hit = scorer.score(
        prep(source),
        _track('c1', 'Fast Car', 'Tracy Chapman', isrc: 'USEE10180355'),
      );
      expect(hit.score, 0.99);
      expect(hit.signals.perSignal['isrc'], 1.0);
    });

    test('ISRC equal but wildly different title falls back to fuzzy', () {
      final hit = scorer.score(
        prep(source),
        _track(
          'c2',
          'Completely Different Song',
          'Someone Else',
          isrc: 'USEE10180355',
        ),
      );
      expect(hit.score, lessThan(0.99));
      expect(hit.signals.notes, contains(contains('title sanity failed')));
    });
  });

  group('hard variant mismatch halves the score', () {
    final studio = _track(
      's1',
      'Fast Car',
      'Tracy Chapman',
      provider: _src,
      durationMs: 296000,
    );

    for (final (title, flagName) in [
      ('Fast Car (Live)', 'live'),
      ('Fast Car (Acoustic)', 'acoustic'),
      ('Fast Car (Instrumental)', 'instrumental'),
      ('Fast Car (Karaoke Version)', 'karaoke'),
      ('Fast Car (Club Mix)', 'remix'),
    ]) {
      test('studio request vs "$title" can never auto-match', () {
        final scored = scorer.score(
          prep(studio),
          _track('c1', title, 'Tracy Chapman', durationMs: 296000),
        );
        expect(
          scored.score,
          lessThan(0.70),
          reason: '$flagName mismatch must land below the review threshold',
        );
        expect(scored.signals.notes, contains(contains(flagName)));
      });
    }

    test('matching flags on BOTH sides do not penalize', () {
      final liveSource = _track(
        's1',
        'Fast Car (Live)',
        'Tracy Chapman',
        provider: _src,
        durationMs: 310000,
      );
      final scored = scorer.score(
        prep(liveSource),
        _track('c1', 'Fast Car - Live', 'Tracy Chapman', durationMs: 311000),
      );
      expect(scored.score, greaterThan(0.9));
    });

    test('soft flags (remaster) penalize mildly, never halve', () {
      final scored = scorer.score(
        prep(studio),
        _track(
          'c1',
          'Fast Car (2015 Remaster)',
          'Tracy Chapman',
          durationMs: 296500,
        ),
      );
      expect(scored.score, greaterThan(0.85));
    });
  });

  group('duration', () {
    final source = _track(
      's1',
      'Fast Car',
      'Tracy Chapman',
      provider: _src,
      durationMs: 296000,
    );

    test('Δ>15 s caps the total at 0.70 despite perfect text', () {
      final scored = scorer.score(
        prep(source),
        _track('c1', 'Fast Car', 'Tracy Chapman', durationMs: 340000),
      );
      expect(scored.score, lessThanOrEqualTo(Scorer.durationCap));
      expect(scored.signals.notes, contains(contains('caps score')));
    });

    test('unknown duration is excluded, not penalized', () {
      final scored = scorer.score(
        prep(source),
        _track('c1', 'Fast Car', 'Tracy Chapman'),
      );
      expect(scored.signals.perSignal.containsKey('duration'), isFalse);
      expect(scored.score, greaterThan(0.9));
    });
  });

  group('artists', () {
    test('alias table equates known variants', () {
      final source = _track(
        's1',
        'Just Give Me a Reason',
        'P!nk',
        provider: _src,
        durationMs: 242000,
      );
      final scored = scorer.score(
        prep(source),
        _track('c1', 'Just Give Me a Reason', 'Pink', durationMs: 242000),
      );
      expect(scored.signals.perSignal['artist'], greaterThan(0.99));
    });

    test('wrong artist with identical title stays below auto thresholds', () {
      final source = _track(
        's1',
        'Fast Car',
        'Tracy Chapman',
        provider: _src,
        durationMs: 296000,
      );
      final scored = scorer.score(
        prep(source),
        _track('c1', 'Fast Car', 'Luke Combs', durationMs: 265000),
      );
      expect(scored.score, lessThan(0.70));
    });

    test('featured artists from the title strengthen the match', () {
      final source = _track(
        's1',
        'Empire State of Mind (feat. Alicia Keys)',
        'JAY-Z',
        provider: _src,
        durationMs: 276000,
      );
      final scored = scorer.score(
        prep(source),
        Track(
          providerId: _dst,
          id: const ProviderTrackId('c1'),
          title: 'Empire State of Mind',
          artists: const [
            Artist(name: 'Jay Z'),
            Artist(name: 'Alicia Keys'),
          ],
          duration: const Duration(milliseconds: 276000),
        ),
      );
      expect(scored.score, greaterThan(0.9));
    });
  });

  test('explicit mismatch is mild, never a hard block', () {
    final source = _track(
      's1',
      'Song',
      'Artist',
      provider: _src,
      durationMs: 200000,
      explicit: true,
    );
    final scored = scorer.score(
      prep(source),
      _track('c1', 'Song', 'Artist', durationMs: 200000, explicit: false),
    );
    expect(scored.score, greaterThan(0.85));
  });
}
