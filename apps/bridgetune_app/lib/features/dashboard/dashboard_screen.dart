import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_engine/job_engine.dart';

import '../../state/services.dart';
import '../transfer/wizard_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bridgetune')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const WizardScreen())),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('New transfer'),
      ),
      body: jobs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load jobs: $e')),
        data: (records) => records.isEmpty
            ? const _EmptyState()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _StatsRow(records: records),
                  const SizedBox(height: 16),
                  for (final job in records.reversed) ...[
                    _JobCard(job: job),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.library_music_outlined,
          size: 56,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          'Move your music between platforms',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Start a transfer — the playlist is created for real\n'
          'inside the destination service.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.records});

  final List<JobRecord> records;

  @override
  Widget build(BuildContext context) {
    final done = records.where((j) => j.state == JobState.completed).length;
    final transferred = records.fold<int>(0, (n, j) => n + j.progressDone);
    final review = records.where((j) => j.state == JobState.needsReview).length;
    Widget tile(String value, String label) => Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Row(
      children: [
        tile('$transferred', 'songs processed'),
        const SizedBox(width: 8),
        tile('$done', 'transfers completed'),
        const SizedBox(width: 8),
        tile('$review', 'awaiting review'),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});

  final JobRecord job;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = job.progressTotal == 0
        ? 0.0
        : job.progressDone / job.progressTotal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.spec.playlistName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StateChip(state: job.state),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: scheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 6),
            Text(
              '${job.progressDone} of ${job.progressTotal} songs',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.state});

  final JobState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (state) {
      JobState.completed => ('Completed', scheme.primary),
      JobState.needsReview => ('Needs review', scheme.error),
      JobState.running => ('Running', scheme.primary),
      JobState.paused => ('Paused', scheme.onSurfaceVariant),
      JobState.queued => ('Queued', scheme.onSurfaceVariant),
      JobState.failed => ('Failed', scheme.error),
      JobState.cancelled => ('Cancelled', scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
