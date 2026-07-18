import 'package:core_domain/core_domain.dart';
import 'package:meta/meta.dart';
import 'package:provider_api/provider_api.dart';

import 'plan.dart';
import 'state.dart';

/// Maps between provider track ids and the pair's canonical [SyncId]s —
/// wired from the mapping cache by the composition root. A null return
/// means "no mapping yet": the track needs the matching/transfer machinery
/// before sync can move it (docs/08 §5.1).
abstract interface class SyncIdMapper {
  SyncId? toSyncId(ProviderId provider, ProviderTrackId track);

  ProviderTrackId? toProviderTrack(ProviderId provider, SyncId id);
}

/// What one sync cycle did.
@immutable
class SyncOutcome {
  const SyncOutcome({
    required this.plan,
    required this.newBase,
    required this.needsMatchingToDest,
    required this.needsMatchingToSource,
  });

  final SyncPlan plan;

  /// Persist as the pair's Base for the next cycle.
  final PlaylistState newBase;

  /// Sync ids that should exist on a side but have no provider mapping
  /// there yet — the caller funnels these through transfer jobs.
  final List<SyncId> needsMatchingToDest;
  final List<SyncId> needsMatchingToSource;
}

/// Runs one full cycle for a pair: read both sides → plan → apply → return
/// the new Base. Pure orchestration over the port; persistence of Base and
/// run records belongs to the caller (docs/08 §5.2).
class SyncOrchestrator {
  SyncOrchestrator({
    required this._source,
    required this._dest,
    required this._mapper,
    this._planner = const SyncPlanner(),
  });

  final MusicProvider _source;
  final MusicProvider _dest;
  final SyncIdMapper _mapper;
  final SyncPlanner _planner;

  Future<SyncOutcome> syncPair({
    required PlaylistRef sourcePlaylist,
    required PlaylistRef destPlaylist,
    required PlaylistState base,
    required SyncMode mode,
    required ConflictPolicy policy,
  }) async {
    final sourceNow = await _readState(_source, sourcePlaylist);
    final destNow = await _readState(_dest, destPlaylist);

    final plan = _planner.plan(
      base: base,
      sourceNow: sourceNow,
      destNow: destNow,
      mode: mode,
      policy: policy,
    );

    final needsMatchingToDest = <SyncId>[];
    final needsMatchingToSource = <SyncId>[];

    await _applySide(
      provider: _dest,
      playlist: destPlaylist,
      adds: plan.addToDest,
      removes: plan.removeFromDest,
      unmapped: needsMatchingToDest,
    );
    if (mode == SyncMode.twoWay) {
      await _applySide(
        provider: _source,
        playlist: sourcePlaylist,
        adds: plan.addToSource,
        removes: plan.removeFromSource,
        unmapped: needsMatchingToSource,
      );
    }

    // Unmapped tracks did not actually land — exclude them from the agreed
    // base so the next cycle picks them up again after matching.
    final unresolved = {...needsMatchingToDest, ...needsMatchingToSource};
    final newBase = PlaylistState([
      for (final id in plan.nextBase.tracks)
        if (!unresolved.contains(id)) id,
    ]);

    return SyncOutcome(
      plan: plan,
      newBase: newBase,
      needsMatchingToDest: needsMatchingToDest,
      needsMatchingToSource: needsMatchingToSource,
    );
  }

  Future<PlaylistState> _readState(
    MusicProvider provider,
    PlaylistRef playlist,
  ) async {
    final ids = <SyncId>[];
    await for (final track in provider.getPlaylistTracks(playlist)) {
      final syncId = _mapper.toSyncId(provider.id, track.id);
      // Unmapped destination-side tracks are invisible to sync until the
      // matching machinery names them — never guessed at inline.
      if (syncId != null) ids.add(syncId);
    }
    return PlaylistState(ids);
  }

  Future<void> _applySide({
    required MusicProvider provider,
    required PlaylistRef playlist,
    required List<SyncId> adds,
    required List<SyncId> removes,
    required List<SyncId> unmapped,
  }) async {
    final removeIds = <ProviderTrackId>[];
    for (final id in removes) {
      final trackId = _mapper.toProviderTrack(provider.id, id);
      if (trackId != null) removeIds.add(trackId);
    }
    if (removeIds.isNotEmpty) {
      await provider.removeTracks(playlist, removeIds);
    }

    final addIds = <ProviderTrackId>[];
    for (final id in adds) {
      final trackId = _mapper.toProviderTrack(provider.id, id);
      if (trackId == null) {
        unmapped.add(id);
      } else {
        addIds.add(trackId);
      }
    }
    if (addIds.isNotEmpty) {
      await provider.addTracks(playlist, addIds);
    }
  }
}
