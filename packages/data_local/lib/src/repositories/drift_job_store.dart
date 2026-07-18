import 'dart:convert';

import 'package:core_domain/core_domain.dart';
import 'package:drift/drift.dart';
import 'package:job_engine/job_engine.dart';

import '../database.dart';
import '../ids.dart';

/// The production [JobStore]: SQLite ACID makes [commitBatch] the durable
/// checkpoint the whole crash-consistency story rests on (docs/08 §1).
class DriftJobStore implements JobStore {
  DriftJobStore(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final BridgetuneDatabase _db;
  final DateTime Function() _now;

  @override
  Future<void> createJob(JobRecord job, List<ItemRecord> items) {
    return _db.transaction(() async {
      // Source tracks are snapshotted first — job_items reference them.
      await _db.batch(
        (b) => b.insertAllOnConflictUpdate(_db.trackSnapshots, [
          for (final item in items) _snapshotOf(item.sourceTrack),
        ]),
      );
      await _db
          .into(_db.transferJobs)
          .insert(
            TransferJobsCompanion.insert(
              id: job.id,
              kind: job.kind,
              srcAccountId: job.srcAccount.value,
              dstAccountId: job.dstAccount.value,
              specJson: jsonEncode(job.spec.toJson()),
              state: job.state.name,
              progressDone: Value(job.progressDone),
              progressTotal: Value(job.progressTotal),
              createdAt: _now(),
              updatedAt: _now(),
            ),
          );
      await _db.batch(
        (b) => b.insertAll(_db.jobItems, [
          for (final item in items)
            JobItemsCompanion.insert(
              id: item.id,
              jobId: item.jobId,
              seq: item.seq,
              srcTrackId: trackRowId(
                item.sourceTrack.providerId,
                item.sourceTrack.id,
              ),
              state: item.state.name,
              attemptCount: Value(item.attemptCount),
              nextRetryAt: Value(item.nextRetryAt),
              lastError: Value(item.lastError),
              resolvedDstId: Value(item.resolvedDstId),
            ),
        ]),
      );
    });
  }

  @override
  Future<JobRecord?> job(String id) async {
    final row = await (_db.select(
      _db.transferJobs,
    )..where((j) => j.id.equals(id))).getSingleOrNull();
    return row == null ? null : _jobOf(row);
  }

  @override
  Future<List<JobRecord>> jobsInStates(Set<JobState> states) async {
    final rows =
        await (_db.select(_db.transferJobs)
              ..where((j) => j.state.isIn([for (final s in states) s.name]))
              ..orderBy([(j) => OrderingTerm.asc(j.createdAt)]))
            .get();
    return [for (final row in rows) _jobOf(row)];
  }

  @override
  Future<void> setJobState(String id, JobState state, {String? error}) =>
      (_db.update(_db.transferJobs)..where((j) => j.id.equals(id))).write(
        TransferJobsCompanion(
          state: Value(state.name),
          errorJson: Value(error),
          updatedAt: Value(_now()),
          finishedAt: state.isTerminal ? Value(_now()) : const Value.absent(),
        ),
      );

  @override
  Future<void> updateJobSpec(String id, TransferSpec spec) =>
      (_db.update(_db.transferJobs)..where((j) => j.id.equals(id))).write(
        TransferJobsCompanion(
          specJson: Value(jsonEncode(spec.toJson())),
          updatedAt: Value(_now()),
        ),
      );

  @override
  Future<List<ItemRecord>> claimBatch(
    String jobId,
    int size,
    DateTime now,
  ) async {
    final rows =
        await (_db.select(_db.jobItems).join([
                innerJoin(
                  _db.trackSnapshots,
                  _db.trackSnapshots.id.equalsExp(_db.jobItems.srcTrackId),
                ),
              ])
              ..where(
                _db.jobItems.jobId.equals(jobId) &
                    _db.jobItems.state.equals(ItemState.pending.name) &
                    (_db.jobItems.nextRetryAt.isNull() |
                        _db.jobItems.nextRetryAt.isSmallerOrEqualValue(now)),
              )
              ..orderBy([OrderingTerm.asc(_db.jobItems.seq)])
              ..limit(size))
            .get();
    return [
      for (final row in rows)
        _itemOf(row.readTable(_db.jobItems), row.readTable(_db.trackSnapshots)),
    ];
  }

  @override
  Future<void> commitBatch(
    String jobId,
    List<ItemRecord> updated, {
    required int progressDone,
  }) {
    // THE checkpoint: one transaction or nothing.
    return _db.transaction(() async {
      for (final item in updated) {
        await (_db.update(
          _db.jobItems,
        )..where((i) => i.id.equals(item.id))).write(
          JobItemsCompanion(
            state: Value(item.state.name),
            attemptCount: Value(item.attemptCount),
            nextRetryAt: Value(item.nextRetryAt),
            lastError: Value(item.lastError),
            resolvedDstId: Value(item.resolvedDstId),
          ),
        );
      }
      await (_db.update(
        _db.transferJobs,
      )..where((j) => j.id.equals(jobId))).write(
        TransferJobsCompanion(
          progressDone: Value(progressDone),
          updatedAt: Value(_now()),
        ),
      );
    });
  }

  @override
  Future<List<ItemRecord>> itemsInStates(
    String jobId,
    Set<ItemState> states,
  ) async {
    final rows =
        await (_db.select(_db.jobItems).join([
                innerJoin(
                  _db.trackSnapshots,
                  _db.trackSnapshots.id.equalsExp(_db.jobItems.srcTrackId),
                ),
              ])
              ..where(
                _db.jobItems.jobId.equals(jobId) &
                    _db.jobItems.state.isIn([for (final s in states) s.name]),
              )
              ..orderBy([OrderingTerm.asc(_db.jobItems.seq)]))
            .get();
    return [
      for (final row in rows)
        _itemOf(row.readTable(_db.jobItems), row.readTable(_db.trackSnapshots)),
    ];
  }

  @override
  Future<DateTime?> nextDueAt(String jobId) async {
    final minRetry = _db.jobItems.nextRetryAt.min();
    final row =
        await (_db.selectOnly(_db.jobItems)
              ..addColumns([minRetry])
              ..where(
                _db.jobItems.jobId.equals(jobId) &
                    _db.jobItems.state.equals(ItemState.pending.name) &
                    _db.jobItems.nextRetryAt.isNotNull(),
              ))
            .getSingle();
    return row.read(minRetry);
  }

  // -- mapping ------------------------------------------------------------------

  TrackSnapshotsCompanion _snapshotOf(Track track) =>
      TrackSnapshotsCompanion.insert(
        id: trackRowId(track.providerId, track.id),
        providerId: track.providerId.value,
        providerTrackId: track.id.value,
        title: track.title,
        titleNorm: track.title.toLowerCase(),
        artistsJson: jsonEncode([for (final a in track.artists) a.name]),
        isrc: Value(track.isrc),
        album: Value(track.album?.title),
        durationMs: Value(track.duration?.inMilliseconds),
        releaseYear: Value(track.releaseYear ?? track.album?.releaseYear),
        explicit: Value(track.explicit),
        popularity: Value(track.popularity),
        fetchedAt: _now(),
      );

  JobRecord _jobOf(TransferJob row) => JobRecord(
    id: row.id,
    kind: row.kind,
    srcAccount: AccountId(row.srcAccountId),
    dstAccount: AccountId(row.dstAccountId),
    spec: TransferSpec.fromJson(
      (jsonDecode(row.specJson) as Map).cast<String, Object?>(),
    ),
    state: JobState.values.byName(row.state),
    progressDone: row.progressDone,
    progressTotal: row.progressTotal,
    error: row.errorJson,
  );

  ItemRecord _itemOf(JobItem item, TrackSnapshot track) => ItemRecord(
    id: item.id,
    jobId: item.jobId,
    seq: item.seq,
    sourceTrack: Track(
      providerId: ProviderId(track.providerId),
      id: ProviderTrackId(track.providerTrackId),
      title: track.title,
      artists: [
        for (final name in (jsonDecode(track.artistsJson) as List))
          Artist(name: name as String),
      ],
      album: track.album == null ? null : Album(title: track.album!),
      duration: track.durationMs == null
          ? null
          : Duration(milliseconds: track.durationMs!),
      isrc: track.isrc,
      releaseYear: track.releaseYear,
      explicit: track.explicit,
      popularity: track.popularity,
    ),
    state: ItemState.values.byName(item.state),
    resolvedDstId: item.resolvedDstId,
    attemptCount: item.attemptCount,
    nextRetryAt: item.nextRetryAt,
    lastError: item.lastError,
  );
}
