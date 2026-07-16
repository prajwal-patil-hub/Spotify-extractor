/// Match-confidence tiers (docs/07 §5). The numeric boundaries live here —
/// and only here — so the matching engine, the job engine's auto-approve
/// gate, and the review UI can never disagree about what "high" means.
library;

enum ConfidenceTier {
  /// 0.99–1.00 — ISRC-verified or equivalent.
  exact,

  /// 0.95–0.98.
  veryHigh,

  /// 0.85–0.94.
  high,

  /// 0.70–0.84 — auto-transfer only under the "relaxed" threshold setting.
  possible,

  /// Below 0.70 — always requires human review.
  uncertain;

  static ConfidenceTier fromScore(double score) {
    if (score.isNaN || score < 0.0 || score > 1.0) {
      throw ArgumentError.value(score, 'score', 'must be within 0.0–1.0');
    }
    if (score >= 0.99) return exact;
    if (score >= 0.95) return veryHigh;
    if (score >= 0.85) return high;
    if (score >= 0.70) return possible;
    return uncertain;
  }
}

/// User-selectable auto-approve threshold (Settings → Matching).
enum MatchThreshold {
  strict(0.95),
  balanced(0.85),
  relaxed(0.70);

  const MatchThreshold(this.minScore);

  final double minScore;

  bool autoApproves(double score) => score >= minScore;
}
