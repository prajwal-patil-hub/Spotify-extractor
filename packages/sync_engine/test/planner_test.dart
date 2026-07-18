import 'package:sync_engine/sync_engine.dart';
import 'package:test/test.dart';

PlaylistState _s(List<String> ids) => PlaylistState(ids);

void main() {
  const planner = SyncPlanner();

  SyncPlan plan({
    required List<String> base,
    required List<String> src,
    required List<String> dst,
    required SyncMode mode,
    required ConflictPolicy policy,
  }) => planner.plan(
    base: _s(base),
    sourceNow: _s(src),
    destNow: _s(dst),
    mode: mode,
    policy: policy,
  );

  group('no changes → no-op', () {
    for (final mode in SyncMode.values) {
      for (final policy in ConflictPolicy.values) {
        test('$mode/$policy', () {
          final p = plan(
            base: ['a', 'b'],
            src: ['a', 'b'],
            dst: ['a', 'b'],
            mode: mode,
            policy: policy,
          );
          expect(p.isNoOp, isTrue);
          expect(p.conflicts, isEmpty);
        });
      }
    }
  });

  group('one-way S→D', () {
    test('source add propagates under every policy', () {
      for (final policy in ConflictPolicy.values) {
        final p = plan(
          base: ['a'],
          src: ['a', 'x'],
          dst: ['a'],
          mode: SyncMode.oneWay,
          policy: policy,
        );
        expect(p.addToDest, ['x'], reason: '$policy');
        expect(p.addToSource, isEmpty);
        expect(
          p.removeFromSource,
          isEmpty,
          reason: 'one-way never edits the source',
        );
      }
    });

    test('source removal: mirror & merge remove; keepBoth keeps; manual '
        'holds as a conflict', () {
      SyncPlan run(ConflictPolicy policy) => plan(
        base: ['a', 'b'],
        src: ['a'],
        dst: ['a', 'b'],
        mode: SyncMode.oneWay,
        policy: policy,
      );
      expect(run(ConflictPolicy.mirrorSource).removeFromDest, ['b']);
      expect(run(ConflictPolicy.merge).removeFromDest, ['b']);
      expect(run(ConflictPolicy.keepBoth).removeFromDest, isEmpty);
      final manual = run(ConflictPolicy.manual);
      expect(manual.removeFromDest, isEmpty);
      expect(manual.conflicts.single.id, 'b');
    });

    test('destination extras: mirror reverts them; merge/keepBoth leave '
        'them', () {
      SyncPlan run(ConflictPolicy policy) => plan(
        base: ['a'],
        src: ['a'],
        dst: ['a', 'extra'],
        mode: SyncMode.oneWay,
        policy: policy,
      );
      expect(run(ConflictPolicy.mirrorSource).removeFromDest, ['extra']);
      expect(run(ConflictPolicy.merge).isNoOp, isTrue);
      expect(run(ConflictPolicy.keepBoth).isNoOp, isTrue);
    });

    test('mirror restores a destination-side deletion', () {
      final p = plan(
        base: ['a', 'b'],
        src: ['a', 'b'],
        dst: ['a'],
        mode: SyncMode.oneWay,
        policy: ConflictPolicy.mirrorSource,
      );
      expect(p.addToDest, ['b']);
    });

    test('order authority: destination follows source order under mirror', () {
      final p = plan(
        base: ['a', 'b', 'c'],
        src: ['c', 'a', 'b'],
        dst: ['a', 'b', 'c'],
        mode: SyncMode.oneWay,
        policy: ConflictPolicy.mirrorSource,
      );
      expect(p.finalDest.tracks, ['c', 'a', 'b']);
    });
  });

  group('two-way', () {
    test('adds propagate both directions under merge', () {
      final p = plan(
        base: ['a'],
        src: ['a', 's1'],
        dst: ['a', 'd1'],
        mode: SyncMode.twoWay,
        policy: ConflictPolicy.merge,
      );
      expect(p.addToDest, contains('s1'));
      expect(p.addToSource, contains('d1'));
      expect(p.finalSource.asSet, p.finalDest.asSet);
    });

    test('single-sided removal propagates under merge', () {
      final p = plan(
        base: ['a', 'b'],
        src: ['a'],
        dst: ['a', 'b'],
        mode: SyncMode.twoWay,
        policy: ConflictPolicy.merge,
      );
      expect(p.removeFromDest, ['b']);
      expect(p.finalSource.asSet, p.finalDest.asSet);
    });

    test('mirrorSource wipes destination-only adds', () {
      final p = plan(
        base: ['a'],
        src: ['a'],
        dst: ['a', 'd1'],
        mode: SyncMode.twoWay,
        policy: ConflictPolicy.mirrorSource,
      );
      expect(p.removeFromDest, ['d1']);
    });

    test('keepBoth is a convergent union — deletions never propagate, the '
        'deleted track is restored', () {
      final p = plan(
        base: ['a', 'b'],
        src: ['a'], // user deleted b on source
        dst: ['a', 'b', 'd1'],
        mode: SyncMode.twoWay,
        policy: ConflictPolicy.keepBoth,
      );
      expect(p.finalSource.asSet, {'a', 'b', 'd1'});
      expect(p.finalDest.asSet, {'a', 'b', 'd1'});
    });

    test('manual: adds flow, deletions become conflicts and hold state', () {
      final p = plan(
        base: ['a', 'b'],
        src: ['a', 's1'], // removed b, added s1
        dst: ['a', 'b'],
        mode: SyncMode.twoWay,
        policy: ConflictPolicy.manual,
      );
      expect(p.addToDest, contains('s1'));
      expect(p.conflicts.single.id, 'b');
      expect(p.removeFromDest, isEmpty);
      // The held track stays in the agreed base, so the SAME pending
      // deletion resurfaces next cycle — it is never laundered into an add.
      expect(p.nextBase.contains('b'), isTrue);
    });
  });
}
