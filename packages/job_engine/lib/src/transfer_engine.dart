import 'package:core_domain/core_domain.dart';
import 'package:provider_api/provider_api.dart';

import 'job_store.dart';
import 'model.dart';
import 'resolver.dart';
import 'retry_policy.dart';

/// Runs playlist-transfer jobs to completion with checkpointed batches
/// (docs/08 §1–2). Crash-only design: there is no recovery procedure —
/// [run] on a half-finished job IS the recovery procedure.
class TransferEngine {
  TransferEngine({
    required this._store,
    required MusicProvider destination,
    required TrackResolver resolver,
    this.batchSize = 50,
    RetryPolicy? retryPolicy,
    DateTime Function()? clock,
    Future<void> Function(Duration)? delay,
  }) : _dst = destination,
       _resolve = resolver,
       _policy = retryPolicy ?? const RetryPolicy(),
       _now = clock ?? DateTime.now,
       _delay = delay ?? ((d) => Future<void>.delayed(d));

  final JobStore _store;
  final MusicProvider _dst;
  final TrackResolver _resolve;
  final RetryPolicy _policy;
  final DateTime Function() _now;
  final Future<void> Function(Duration) _delay;
  final int batchSize;

  /// Creates a playlist-transfer job from an ordered source track list.
  /// Pure planning — nothing touches the destination until [run].
  Future<String> planPlaylistTransfer({
    required String jobId,
    required AccountId srcAccount,
    required AccountId dstAccount,
    required TransferSpec spec,
    required List<Track> sourceTracks,
  }) async {
    await _store.createJob(
      JobRecord(
        id: jobId,
        kind: 'playlist_transfer',
        srcAccount: srcAccount,
        dstAccount: dstAccount,
        spec: spec,
        state: JobState.queued,
        progressTotal: sourceTracks.length,
      ),
      [
        for (var i = 0; i < sourceTracks.length; i++)
          ItemRecord(
            id: '$jobId#$i',
            jobId: jobId,
            seq: i,
            sourceTrack: sourceTracks[i],
          ),
      ],
    );
    return jobId;
  }

  // -- control (observed between batches, docs/08 §2) --------------------------

  Future<void> pause(String jobId) =>
      _store.setJobState(jobId, JobState.paused);

  Future<void> resume(String jobId) =>
      _store.setJobState(jobId, JobState.queued);

  /// Cancel leaves the destination as-is (partial, clearly labeled) —
  /// destructive rollback is never automatic (docs/08 §2).
  Future<void> cancel(String jobId) =>
      _store.setJobState(jobId, JobState.cancelled);

  // -- execution ---------------------------------------------------------------

  /// Drives [jobId] until it reaches a terminal, paused, or needs-review
  /// state. Safe to call on a fresh, interrupted, or resumed job alike.
  Future<JobRecord> run(String jobId) async {
    var job = await _requireJob(jobId);
    if (job.state.isTerminal) return job;
    await _store.setJobState(jobId, JobState.running);

    try {
      job = await _ensureDestinationPlaylist(await _requireJob(jobId));
      final playlist = PlaylistRef(
        account: job.dstAccount,
        playlist: ProviderPlaylistId(job.spec.dstPlaylistId!),
      );

      // Idempotence anchor (docs/08 §3): whatever already made it to the
      // destination counts as done — THIS is what makes a crash between
      // "add succeeded" and "checkpoint committed" a non-event on resume.
      final present = <String>{};
      await for (final track in _dst.getPlaylistTracks(playlist)) {
        present.add(track.id.value);
      }

      while (true) {
        final state = (await _requireJob(jobId)).state;
        if (state == JobState.paused || state == JobState.cancelled) {
          return _requireJob(jobId);
        }

        final batch = await _store.claimBatch(jobId, batchSize, _now());
        if (batch.isEmpty) {
          final dueAt = await _store.nextDueAt(jobId);
          if (dueAt == null) break; // nothing pending — main loop done
          final wait = dueAt.difference(_now());
          if (wait > Duration.zero) await _delay(wait);
          continue;
        }

        await _processBatch(jobId, playlist, batch, present);
      }

      await _verify(jobId, playlist);

      // A second pass may have been queued by verification retries.
      if ((await _store.claimBatch(jobId, 1, _now())).isNotEmpty ||
          await _store.nextDueAt(jobId) != null) {
        return run(jobId);
      }

      return _finalize(jobId);
    } on AppError catch (e) {
      // Job-level pause conditions (auth, storage) surface here.
      await _store.setJobState(jobId, JobState.paused, error: e.message);
      return _requireJob(jobId);
    }
  }

  Future<void> _processBatch(
    String jobId,
    PlaylistRef playlist,
    List<ItemRecord> batch,
    Set<String> present,
  ) async {
    final updated = <ItemRecord>[];
    final toAdd = <ItemRecord>[];

    for (final item in batch) {
      try {
        final resolution = await _resolve(item.sourceTrack);
        switch (resolution) {
          case ResolvedTrack(:final dstTrackId):
            if (present.contains(dstTrackId.value)) {
              // Already at the destination (resume, or duplicate policy
              // "skip") — done without a write.
              updated.add(
                item.copyWith(
                  state: ItemState.transferred,
                  resolvedDstId: dstTrackId.value,
                ),
              );
            } else {
              toAdd.add(item.copyWith(resolvedDstId: dstTrackId.value));
            }
          case ResolutionNeedsReview(:final reason):
            updated.add(
              item.copyWith(state: ItemState.needsReview, lastError: reason),
            );
          case ResolutionNoMatch():
            updated.add(
              item.copyWith(
                state: ItemState.skipped,
                lastError: 'no match at destination',
              ),
            );
        }
      } on AppError catch (e) {
        final handled = _applyErrorDecision(item, e);
        if (handled == null) rethrow; // PauseJob → job level
        updated.add(handled);
      }
    }

    if (toAdd.isNotEmpty) {
      try {
        await _dst.addTracks(playlist, [
          for (final item in toAdd) ProviderTrackId(item.resolvedDstId!),
        ]);
        for (final item in toAdd) {
          present.add(item.resolvedDstId!);
          updated.add(item.copyWith(state: ItemState.transferred));
        }
      } on AppError catch (e) {
        // The whole add failed — defer/fail every item in it uniformly.
        for (final item in toAdd) {
          final handled = _applyErrorDecision(
            item.copyWith(attemptCount: item.attemptCount + 1),
            e,
          );
          if (handled == null) rethrow;
          updated.add(handled);
        }
      }
    }

    await _commit(jobId, updated);
  }

  /// Null return = the decision is job-level (pause) and must propagate.
  ItemRecord? _applyErrorDecision(ItemRecord item, AppError error) {
    final decision = _policy.decide(
      error,
      attempt: item.attemptCount + 1,
      now: _now(),
    );
    return switch (decision) {
      DeferItem(:final at) => item.copyWith(
        state: ItemState.pending,
        attemptCount: item.attemptCount + 1,
        nextRetryAt: at,
        lastError: error.message,
      ),
      FailItem(:final reason) => item.copyWith(
        state: ItemState.failed,
        lastError: '$reason: ${error.message}',
      ),
      PauseJob() => null,
    };
  }

  /// Post-transfer read-back (docs/07 §6): confirm every transferred item
  /// is really there; requeue one retry, then fail.
  Future<void> _verify(String jobId, PlaylistRef playlist) async {
    final transferred = await _store.itemsInStates(jobId, {
      ItemState.transferred,
    });
    if (transferred.isEmpty) return;
    final present = <String>{};
    await for (final track in _dst.getPlaylistTracks(playlist)) {
      present.add(track.id.value);
    }
    final updated = <ItemRecord>[
      for (final item in transferred)
        if (present.contains(item.resolvedDstId))
          item.copyWith(state: ItemState.verified)
        else
          _applyErrorDecision(
                item,
                const VerificationMismatch('read-back missing track'),
              ) ??
              item.copyWith(state: ItemState.failed),
    ];
    await _commit(jobId, updated);
  }

  Future<JobRecord> _ensureDestinationPlaylist(JobRecord job) async {
    if (job.spec.dstPlaylistId != null) return job;

    // Crash recovery for the create-then-checkpoint window: an existing
    // playlist with the exact spec name is ours from a previous attempt.
    await for (final existing in _dst.getPlaylists(job.dstAccount)) {
      if (existing.name == job.spec.playlistName) {
        final spec = job.spec.withDstPlaylist(existing.id.value);
        await _store.updateJobSpec(job.id, spec);
        return job.copyWith(spec: spec);
      }
    }

    final created = await _dst.createPlaylist(
      job.dstAccount,
      PlaylistSpec(
        name: job.spec.playlistName,
        description: job.spec.description,
        privacy: job.spec.privacy,
      ),
    );
    final spec = job.spec.withDstPlaylist(created.id.value);
    await _store.updateJobSpec(job.id, spec);
    return job.copyWith(spec: spec);
  }

  Future<void> _commit(String jobId, List<ItemRecord> updated) async {
    if (updated.isEmpty) return;
    final terminalNow = await _store.itemsInStates(jobId, {
      ItemState.verified,
      ItemState.failed,
      ItemState.skipped,
      ItemState.transferred,
      ItemState.needsReview,
    });
    final already = {for (final i in terminalNow) i.id};
    final progress =
        already.length +
        updated
            .where(
              (i) => !already.contains(i.id) && i.state != ItemState.pending,
            )
            .length;
    await _store.commitBatch(jobId, updated, progressDone: progress);
  }

  Future<JobRecord> _finalize(String jobId) async {
    final review = await _store.itemsInStates(jobId, {ItemState.needsReview});
    if (review.isNotEmpty) {
      await _store.setJobState(jobId, JobState.needsReview);
      return _requireJob(jobId);
    }
    await _store.setJobState(jobId, JobState.completed);
    return _requireJob(jobId);
  }

  Future<JobRecord> _requireJob(String id) async {
    final job = await _store.job(id);
    if (job == null) {
      throw StorageError('job $id not found');
    }
    return job;
  }
}
