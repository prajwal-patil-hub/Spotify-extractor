import 'package:core_domain/core_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_engine/job_engine.dart';
import 'package:provider_api/provider_api.dart';

import '../../state/services.dart';

/// The transfer wizard (docs/10 §2): pick a source playlist, review the
/// plan — including capability caveats computed from the pairwise
/// intersection, never hardcoded — then run.
class WizardScreen extends ConsumerStatefulWidget {
  const WizardScreen({super.key});

  @override
  ConsumerState<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends ConsumerState<WizardScreen> {
  Playlist? _selected;
  List<Playlist>? _playlists;
  bool _running = false;

  static const _srcId = ProviderId('spotify');
  static const _dstId = ProviderId('ytmusic');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final services = ref.read(servicesProvider);
    final source = services.registry.byId(_srcId);
    final playlists = await source
        .getPlaylists(services.accounts[_srcId]!)
        .toList();
    if (mounted) {
      setState(() {
        _playlists = playlists;
        _selected = playlists.firstOrNull;
      });
    }
  }

  Future<void> _start() async {
    final playlist = _selected;
    if (playlist == null || _running) return;
    setState(() => _running = true);

    final services = ref.read(servicesProvider);
    final source = services.registry.byId(_srcId);
    final destination = services.registry.byId(_dstId);
    final srcAccount = services.accounts[_srcId]!;
    final dstAccount = services.accounts[_dstId]!;

    final tracks = await source
        .getPlaylistTracks(
          PlaylistRef(account: srcAccount, playlist: playlist.id),
        )
        .toList();

    final engine = services.engineFor(destination, dstAccount);
    final jobId = 'job-${DateTime.now().microsecondsSinceEpoch}';
    await engine.planPlaylistTransfer(
      jobId: jobId,
      srcAccount: srcAccount,
      dstAccount: dstAccount,
      spec: TransferSpec(
        playlistName: playlist.name,
        description: playlist.description,
        privacy: playlist.privacy,
      ),
      sourceTracks: tracks,
    );
    final job = await engine.run(jobId);

    ref.read(jobsRevisionProvider.notifier).state++;
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(switch (job.state) {
          JobState.completed =>
            '"${playlist.name}" transferred: ${job.progressDone} of '
                '${job.progressTotal} songs.',
          JobState.needsReview =>
            '"${playlist.name}": ${job.progressDone} of ${job.progressTotal} '
                'done — some songs need your review.',
          _ => '"${playlist.name}": ${job.state.name}',
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(servicesProvider);
    final source = services.registry.byId(_srcId);
    final destination = services.registry.byId(_dstId);
    // The docs/04 §5 rule made visible: the UI renders from the pairwise
    // capability intersection.
    final effective = source.capabilities.intersect(destination.capabilities);
    final playlists = _playlists;

    return Scaffold(
      appBar: AppBar(title: const Text('New transfer')),
      body: playlists == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Spotify  →  YouTube Music',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Card(
                  child: RadioGroup<Playlist>(
                    groupValue: _selected,
                    onChanged: (v) => setState(() => _selected = v),
                    child: Column(
                      children: [
                        for (final playlist in playlists)
                          RadioListTile<Playlist>(
                            value: playlist,
                            title: Text(playlist.name),
                            subtitle: Text('${playlist.trackCount} songs'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selected != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plan',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Creates a real playlist "${_selected!.name}" in '
                            'the YouTube Music account and matches all '
                            '${_selected!.trackCount} songs.',
                          ),
                          if (!effective.supports(
                            Capability.playlistArtworkUpload,
                          )) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    "Artwork won't transfer — the destination "
                                    "doesn't accept custom playlist artwork.",
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _running ? null : _start,
                            icon: _running
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.play_arrow),
                            label: Text(
                              _running ? 'Transferring…' : 'Start transfer',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
