import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ConfidenceTier.fromScore', () {
    // Exact boundary values from docs/07 §5 — these are contract, not taste.
    const cases = <(double, ConfidenceTier)>[
      (1.00, ConfidenceTier.exact),
      (0.99, ConfidenceTier.exact),
      (0.989, ConfidenceTier.veryHigh),
      (0.95, ConfidenceTier.veryHigh),
      (0.949, ConfidenceTier.high),
      (0.85, ConfidenceTier.high),
      (0.849, ConfidenceTier.possible),
      (0.70, ConfidenceTier.possible),
      (0.699, ConfidenceTier.uncertain),
      (0.0, ConfidenceTier.uncertain),
    ];

    for (final (score, tier) in cases) {
      test('$score → $tier', () {
        expect(ConfidenceTier.fromScore(score), tier);
      });
    }

    test('rejects out-of-range and NaN scores', () {
      expect(() => ConfidenceTier.fromScore(-0.01), throwsArgumentError);
      expect(() => ConfidenceTier.fromScore(1.01), throwsArgumentError);
      expect(() => ConfidenceTier.fromScore(double.nan), throwsArgumentError);
    });
  });

  group('MatchThreshold', () {
    test('auto-approve gates match the settings spec', () {
      expect(MatchThreshold.strict.autoApproves(0.95), isTrue);
      expect(MatchThreshold.strict.autoApproves(0.94), isFalse);
      expect(MatchThreshold.balanced.autoApproves(0.85), isTrue);
      expect(MatchThreshold.balanced.autoApproves(0.84), isFalse);
      expect(MatchThreshold.relaxed.autoApproves(0.70), isTrue);
      expect(MatchThreshold.relaxed.autoApproves(0.69), isFalse);
    });
  });
}
