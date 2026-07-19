import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_engine/job_engine.dart';

import '../../state/services.dart';

/// The review queue: items the matching engine refused to auto-approve
/// (docs/10 §2). MVP scope: inspect and skip; side-by-side candidate
/// comparison lands with the full review UX.
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobsProvider);
    final services = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Match review')),
      body: jobs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (records) => FutureBuilder<List<(JobRecord, ItemRecord)>>(
          future: _reviewItems(services, records),
          builder: (context, snapshot) {
            final items = snapshot.data;
            if (items == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (items.isEmpty) {
              return Center(
                child: Text(
                  'Nothing needs your review.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final (job, item) = items[i];
                final track = item.sourceTrack;
                return Card(
                  child: ListTile(
                    title: Text(track.title),
                    subtitle: Text(
                      '${track.artists.map((a) => a.name).join(', ')} · '
                      'from "${job.spec.playlistName}"\n'
                      '${item.lastError ?? 'below confidence threshold'}',
                    ),
                    isThreeLine: true,
                    trailing: TextButton(
                      onPressed: () => _skip(ref, services, job, item),
                      child: const Text('Skip song'),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<(JobRecord, ItemRecord)>> _reviewItems(
    AppServices services,
    List<JobRecord> jobs,
  ) async => [
    for (final job in jobs)
      for (final item in await services.jobStore.itemsInStates(job.id, {
        ItemState.needsReview,
      }))
        (job, item),
  ];

  Future<void> _skip(
    WidgetRef ref,
    AppServices services,
    JobRecord job,
    ItemRecord item,
  ) async {
    await services.jobStore.commitBatch(job.id, [
      item.copyWith(state: ItemState.skipped, lastError: 'skipped by user'),
    ], progressDone: job.progressDone);
    // Job leaves needsReview once its queue is empty.
    final remaining = await services.jobStore.itemsInStates(job.id, {
      ItemState.needsReview,
    });
    if (remaining.isEmpty && job.state == JobState.needsReview) {
      await services.jobStore.setJobState(job.id, JobState.completed);
    }
    ref.read(jobsRevisionProvider.notifier).state++;
  }
}
