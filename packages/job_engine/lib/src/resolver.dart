import 'package:core_domain/core_domain.dart';
import 'package:meta/meta.dart';

/// How an item's destination track is decided. The composition root wires
/// the mapping cache + matching engine + user threshold into this seam —
/// the job engine never imports either (docs/04 dependency rule).
typedef TrackResolver = Future<TrackResolution> Function(Track source);

@immutable
sealed class TrackResolution {
  const TrackResolution();
}

/// Use [dstTrackId]; transfer proceeds.
final class ResolvedTrack extends TrackResolution {
  const ResolvedTrack(this.dstTrackId, {this.confidence = 1.0});

  final ProviderTrackId dstTrackId;
  final double confidence;
}

/// Below threshold — route the item to the human review queue.
final class ResolutionNeedsReview extends TrackResolution {
  const ResolutionNeedsReview({this.reason = 'below confidence threshold'});

  final String reason;
}

/// Confirmed miss: the destination catalog has no equivalent.
final class ResolutionNoMatch extends TrackResolution {
  const ResolutionNoMatch();
}
