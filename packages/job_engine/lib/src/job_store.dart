import 'model.dart';

/// The engine's storage port. Implementations: `DriftJobStore` in
/// data_local (production — SQLite ACID gives the crash-consistency
/// guarantee), [InMemoryJobStore] here (engine unit tests).
///
/// Contract:
/// - [createJob] persists the job and all items atomically.
/// - [commitBatch] is THE checkpoint: item updates + job progress land in
///   one transaction or not at all.
/// - [claimBatch] returns runnable items (pending, or failed-retryable
///   whose nextRetryAt has passed) in ascending seq order.
abstract interface class JobStore {
  Future<void> createJob(JobRecord job, List<ItemRecord> items);

  Future<JobRecord?> job(String id);

  Future<List<JobRecord>> jobsInStates(Set<JobState> states);

  Future<void> setJobState(String id, JobState state, {String? error});

  Future<void> updateJobSpec(String id, TransferSpec spec);

  Future<List<ItemRecord>> claimBatch(String jobId, int size, DateTime now);

  Future<void> commitBatch(
    String jobId,
    List<ItemRecord> updated, {
    required int progressDone,
  });

  Future<List<ItemRecord>> itemsInStates(String jobId, Set<ItemState> states);

  /// Earliest nextRetryAt among deferred pending items — how long the
  /// runner should sleep when nothing is currently due. Null when nothing
  /// is deferred.
  Future<DateTime?> nextDueAt(String jobId);
}

/// Reference implementation for engine unit tests. Mirrors the atomicity
/// contract in memory (single-threaded isolate semantics make map updates
/// atomic per await-free section).
class InMemoryJobStore implements JobStore {
  final Map<String, JobRecord> _jobs = {};
  final Map<String, Map<String, ItemRecord>> _items = {};

  @override
  Future<void> createJob(JobRecord job, List<ItemRecord> items) async {
    _jobs[job.id] = job;
    _items[job.id] = {for (final i in items) i.id: i};
  }

  @override
  Future<JobRecord?> job(String id) async => _jobs[id];

  @override
  Future<List<JobRecord>> jobsInStates(Set<JobState> states) async => [
    ..._jobs.values.where((j) => states.contains(j.state)),
  ];

  @override
  Future<void> setJobState(String id, JobState state, {String? error}) async {
    _jobs[id] = _jobs[id]!.copyWith(state: state, error: error);
  }

  @override
  Future<void> updateJobSpec(String id, TransferSpec spec) async {
    _jobs[id] = _jobs[id]!.copyWith(spec: spec);
  }

  @override
  Future<List<ItemRecord>> claimBatch(
    String jobId,
    int size,
    DateTime now,
  ) async {
    final due =
        _items[jobId]!.values
            .where(
              (i) =>
                  i.state == ItemState.pending &&
                  (i.nextRetryAt == null || !i.nextRetryAt!.isAfter(now)),
            )
            .toList()
          ..sort((a, b) => a.seq.compareTo(b.seq));
    return due.take(size).toList();
  }

  @override
  Future<void> commitBatch(
    String jobId,
    List<ItemRecord> updated, {
    required int progressDone,
  }) async {
    final items = _items[jobId]!;
    for (final item in updated) {
      items[item.id] = item;
    }
    _jobs[jobId] = _jobs[jobId]!.copyWith(progressDone: progressDone);
  }

  @override
  Future<List<ItemRecord>> itemsInStates(
    String jobId,
    Set<ItemState> states,
  ) async =>
      (_items[jobId]!.values.where((i) => states.contains(i.state)).toList()
        ..sort((a, b) => a.seq.compareTo(b.seq)));

  @override
  Future<DateTime?> nextDueAt(String jobId) async {
    DateTime? earliest;
    for (final item in _items[jobId]!.values) {
      if (item.state != ItemState.pending || item.nextRetryAt == null) {
        continue;
      }
      if (earliest == null || item.nextRetryAt!.isBefore(earliest)) {
        earliest = item.nextRetryAt;
      }
    }
    return earliest;
  }
}
