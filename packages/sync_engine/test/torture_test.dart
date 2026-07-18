import 'dart:math';

import 'package:sync_engine/sync_engine.dart';
import 'package:test/test.dart';

/// The Phase-7 exit gate (docs/11): seeded random concurrent edits on both
/// sides, multiple rounds — every policy must converge, and a second plan
/// over the agreed state must always be a no-op.
void main() {
  const planner = SyncPlanner();
  const seeds = [3, 21, 99, 424, 2026];

  (PlaylistState, PlaylistState) randomEdits(
    Random rng,
    PlaylistState base,
    int round,
    String side,
  ) {
    final tracks = [...base.tracks];
    // Remove up to 4 random tracks.
    final removals = min(rng.nextInt(5), tracks.length);
    for (var i = 0; i < removals; i++) {
      tracks.removeAt(rng.nextInt(tracks.length));
    }
    // Add up to 4 fresh tracks (globally unique per side/round).
    final adds = rng.nextInt(5);
    for (var i = 0; i < adds; i++) {
      tracks.insert(rng.nextInt(tracks.length + 1), '$side-r$round-$i');
    }
    return (base, PlaylistState(tracks));
  }

  for (final policy in ConflictPolicy.values) {
    for (final mode in SyncMode.values) {
      test('torture $mode/$policy: 5 seeds × 4 rounds converge, second '
          'plan is a no-op', () {
        for (final seed in seeds) {
          final rng = Random(seed);
          var base = PlaylistState([for (var i = 0; i < 30; i++) 'base-$i']);
          var src = base;
          var dst = base;

          for (var round = 0; round < 4; round++) {
            (_, src) = randomEdits(rng, src, round, 's');
            (_, dst) = randomEdits(rng, dst, round, 'd');

            final plan = planner.plan(
              base: base,
              sourceNow: src,
              destNow: dst,
              mode: mode,
              policy: policy,
            );

            // Invariants that hold for every policy/mode:
            if (mode == SyncMode.oneWay) {
              expect(
                plan.finalSource.tracks,
                src.tracks,
                reason: 'one-way must never edit the source',
              );
            }
            if (policy == ConflictPolicy.keepBoth) {
              expect(
                plan.finalDest.asSet.containsAll(dst.asSet),
                isTrue,
                reason: 'keepBoth never deletes from the destination',
              );
            }
            if (policy == ConflictPolicy.mirrorSource) {
              expect(
                plan.finalDest.tracks,
                plan.finalSource.tracks,
                reason: 'mirror: destination replicates the source',
              );
            }
            if (mode == SyncMode.twoWay && policy != ConflictPolicy.manual) {
              expect(
                plan.finalSource.asSet,
                plan.finalDest.asSet,
                reason: 'two-way non-manual must converge to one set',
              );
            }
            if (policy != ConflictPolicy.manual) {
              expect(plan.conflicts, isEmpty);
            }

            // "Apply" the plan and advance the base.
            src = plan.finalSource;
            dst = plan.finalDest;
            base = plan.nextBase;

            // Idempotence: sync again with no edits → nothing to do.
            final again = planner.plan(
              base: base,
              sourceNow: src,
              destNow: dst,
              mode: mode,
              policy: policy,
            );
            expect(
              again.isNoOp,
              isTrue,
              reason:
                  'seed $seed round $round $mode/$policy: second sync must '
                  'be a no-op (adds S→${again.addToSource} '
                  'D→${again.addToDest} removes S→${again.removeFromSource} '
                  'D→${again.removeFromDest})',
            );
          }
        }
      });
    }
  }
}
