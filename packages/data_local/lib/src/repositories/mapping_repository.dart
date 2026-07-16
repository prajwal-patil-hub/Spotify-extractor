import 'package:core_domain/core_domain.dart';
import 'package:drift/drift.dart';

import '../database.dart';
import '../ids.dart';

/// A cache decision for one (source track, destination provider) pair.
sealed class MappingLookup {
  const MappingLookup();
}

/// No cached decision — the matching engine must run.
final class MappingMiss extends MappingLookup {
  const MappingMiss();
}

/// A cached positive match: reuse [dstTrackId] without searching.
final class MappingHit extends MappingLookup {
  const MappingHit(this.row);

  final TrackMapping row;

  ProviderTrackId get dstTrackId => ProviderTrackId(row.dstProviderTrackId!);
  double get confidence => row.confidence;
}

/// A memoized "no match exists" decision that is still fresh — skip the
/// search AND the transfer; surface as unavailable-at-destination.
final class ConfirmedMiss extends MappingLookup {
  const ConfirmedMiss(this.row);

  final TrackMapping row;
}

/// The crown jewels (docs/05 §4.2): confirmed cross-provider track
/// equivalences, provider-pair-scoped so no track pair is ever matched
/// twice. Negative results are memoized with a TTL so the most expensive
/// quota (destination search) is spent at most once per [recheckAfter].
class MappingRepository {
  MappingRepository(
    this._db, {
    DateTime Function()? clock,
    this.recheckAfter = const Duration(days: 30),
  }) : _now = clock ?? DateTime.now;

  final BridgetuneDatabase _db;
  final DateTime Function() _now;

  /// Confirmed misses older than this are re-searched (catalogs grow).
  final Duration recheckAfter;

  Future<MappingLookup> lookup({
    required String srcTrackRowId,
    required ProviderId dstProvider,
  }) async {
    final row =
        await (_db.select(_db.trackMappings)..where(
              (m) => m.id.equals(mappingRowId(srcTrackRowId, dstProvider)),
            ))
            .getSingleOrNull();
    if (row == null) return const MappingMiss();
    if (row.dstProviderTrackId != null) return MappingHit(row);
    final stale = _now().difference(row.createdAt) > recheckAfter;
    return stale ? const MappingMiss() : ConfirmedMiss(row);
  }

  /// Records a match decision (positive or confirmed-miss when
  /// [dstTrackId] is null). Manual decisions overwrite automatic ones;
  /// an automatic decision never overwrites a manual one.
  Future<void> record({
    required String srcTrackRowId,
    required ProviderId dstProvider,
    required ProviderTrackId? dstTrackId,
    required double confidence,
    required String method, // isrc|fuzzy|manual|cache
    required String decidedBy, // auto|user
    String signalsJson = '{}',
  }) async {
    final rowId = mappingRowId(srcTrackRowId, dstProvider);
    if (decidedBy == 'auto') {
      final existing = await (_db.select(
        _db.trackMappings,
      )..where((m) => m.id.equals(rowId))).getSingleOrNull();
      if (existing != null && existing.decidedBy == 'user') return;
    }
    await _db
        .into(_db.trackMappings)
        .insertOnConflictUpdate(
          TrackMappingsCompanion.insert(
            id: rowId,
            srcTrackId: srcTrackRowId,
            dstProviderId: dstProvider.value,
            dstProviderTrackId: Value(dstTrackId?.value),
            confidence: confidence,
            matchMethod: method,
            signalsJson: Value(signalsJson),
            decidedBy: decidedBy,
            createdAt: _now(),
          ),
        );
  }

  /// Match-quality telemetry for the analytics dashboard (docs/09 §3).
  Future<({int total, int misses, double avgConfidence})> stats(
    ProviderId dstProvider,
  ) async {
    final count = _db.trackMappings.id.count();
    final missCount = _db.trackMappings.id.count(
      filter: _db.trackMappings.dstProviderTrackId.isNull(),
    );
    final avg = _db.trackMappings.confidence.avg(
      filter: _db.trackMappings.dstProviderTrackId.isNotNull(),
    );
    final row =
        await (_db.selectOnly(_db.trackMappings)
              ..addColumns([count, missCount, avg])
              ..where(
                _db.trackMappings.dstProviderId.equals(dstProvider.value),
              ))
            .getSingle();
    return (
      total: row.read(count) ?? 0,
      misses: row.read(missCount) ?? 0,
      avgConfidence: row.read(avg) ?? 0,
    );
  }
}
