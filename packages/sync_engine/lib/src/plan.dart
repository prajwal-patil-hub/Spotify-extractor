import 'package:meta/meta.dart';

import 'diff.dart';
import 'state.dart';

enum SyncMode { oneWay, twoWay }

enum ConflictPolicy { mirrorSource, merge, keepBoth, manual }

/// Opposing concurrent edits on one track — surfaced only under
/// [ConflictPolicy.manual]; other policies resolve silently per docs/08 §5.2.
@immutable
class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.inSourceNow,
    required this.inDestNow,
  });

  final SyncId id;
  final bool inSourceNow;
  final bool inDestNow;
}

/// The computed outcome of one sync cycle: target states per side plus the
/// operations that get each side there. [agreedBase] becomes the pair's new
/// Base after a successful apply.
@immutable
class SyncPlan {
  const SyncPlan({
    required this.finalSource,
    required this.finalDest,
    required this.addToSource,
    required this.removeFromSource,
    required this.addToDest,
    required this.removeFromDest,
    required this.conflicts,
    required this.nextBase,
  });

  final PlaylistState finalSource;
  final PlaylistState finalDest;
  final List<SyncId> addToSource;
  final List<SyncId> removeFromSource;
  final List<SyncId> addToDest;
  final List<SyncId> removeFromDest;
  final List<SyncConflict> conflicts;

  /// The 3-way anchor for the next cycle — mode-aware (see SyncPlanner).
  final PlaylistState nextBase;

  bool get isNoOp =>
      addToSource.isEmpty &&
      removeFromSource.isEmpty &&
      addToDest.isEmpty &&
      removeFromDest.isEmpty;
}

/// The 3-way planner (docs/08 §5.1). Pure: states in, plan out.
class SyncPlanner {
  const SyncPlanner();

  SyncPlan plan({
    required PlaylistState base,
    required PlaylistState sourceNow,
    required PlaylistState destNow,
    required SyncMode mode,
    required ConflictPolicy policy,
  }) {
    final deltaS = diffStates(base, sourceNow);
    final deltaD = diffStates(base, destNow);
    final universe = <SyncId>{
      ...base.asSet,
      ...sourceNow.asSet,
      ...destNow.asSet,
    };

    final inFinalSource = <SyncId>{};
    final inFinalDest = <SyncId>{};
    final conflicts = <SyncConflict>[];

    for (final id in universe) {
      final inS = sourceNow.contains(id);
      final inD = destNow.contains(id);
      final touchedS = deltaS.touches(id);
      final touchedD = deltaD.touches(id);

      final (srcKeeps, dstKeeps) = switch (mode) {
        SyncMode.oneWay => _resolveOneWay(
          policy,
          inS: inS,
          inD: inD,
          touchedS: touchedS,
          touchedD: touchedD,
          conflicts: conflicts,
          id: id,
        ),
        SyncMode.twoWay => _resolveTwoWay(
          policy,
          inS: inS,
          inD: inD,
          touchedS: touchedS,
          touchedD: touchedD,
          conflicts: conflicts,
          id: id,
        ),
      };
      if (srcKeeps) inFinalSource.add(id);
      if (dstKeeps) inFinalDest.add(id);
    }

    // Order: source order is authoritative; tracks only the destination
    // holds keep destination-relative order, appended after (docs/08 §5).
    List<SyncId> ordered(Set<SyncId> members) => [
      for (final id in sourceNow.tracks)
        if (members.contains(id)) id,
      for (final id in destNow.tracks)
        if (members.contains(id) && !sourceNow.contains(id)) id,
      for (final id in members)
        if (!sourceNow.contains(id) && !destNow.contains(id)) id,
    ];

    final finalSource = PlaylistState(ordered(inFinalSource));
    final finalDest = PlaylistState(ordered(inFinalDest));

    // Next-cycle base, mode-aware:
    // - one-way: anchor to the SOURCE state — destination divergence under
    //   merge/keepBoth is permanently tolerated, and must not read as a
    //   fresh source add next cycle (the re-add loop).
    // - two-way: the intersection both sides agree on.
    // Either way, manual-held conflict tracks stay in the base so the SAME
    // pending deletion re-surfaces until a human resolves it — never
    // laundered into an add.
    final conflicted = {for (final c in conflicts) c.id};
    final nextBase = switch (mode) {
      SyncMode.oneWay => PlaylistState([
        ...finalSource.tracks,
        for (final id in finalDest.tracks)
          if (conflicted.contains(id) && !finalSource.contains(id)) id,
      ]),
      SyncMode.twoWay => PlaylistState([
        for (final id in finalSource.tracks)
          if (finalDest.contains(id) || conflicted.contains(id)) id,
        for (final id in finalDest.tracks)
          if (!finalSource.contains(id) && conflicted.contains(id)) id,
      ]),
    };

    return SyncPlan(
      finalSource: finalSource,
      finalDest: finalDest,
      addToSource: [
        for (final id in finalSource.tracks)
          if (!sourceNow.contains(id)) id,
      ],
      removeFromSource: [
        for (final id in sourceNow.tracks)
          if (!finalSource.contains(id)) id,
      ],
      addToDest: [
        for (final id in finalDest.tracks)
          if (!destNow.contains(id)) id,
      ],
      removeFromDest: [
        for (final id in destNow.tracks)
          if (!finalDest.contains(id)) id,
      ],
      conflicts: conflicts,
      nextBase: nextBase,
    );
  }

  // NOTE on "conflicts": in a pure membership model, both sides touching
  // the same track always agree (both added it or both removed it), so the
  // opposing-edit case cannot occur. The genuinely reviewable event is a
  // DELETION about to propagate — that is what [ConflictPolicy.manual]
  // holds for a human (docs/08 §5.2 "conflicting ops queue in a review UI").

  /// One-way S→D: the source is never modified; the destination follows.
  (bool, bool) _resolveOneWay(
    ConflictPolicy policy, {
    required bool inS,
    required bool inD,
    required bool touchedS,
    required bool touchedD,
    required List<SyncConflict> conflicts,
    required SyncId id,
  }) {
    final dstKeeps = switch (policy) {
      // Destination is a replica — source membership, always.
      ConflictPolicy.mirrorSource => inS,
      // Source changes apply (adds AND removals); untouched-by-source
      // destination extras survive.
      ConflictPolicy.merge => touchedS ? inS : inD,
      // Union: nothing is ever deleted, adds flow S→D.
      ConflictPolicy.keepBoth => inS || inD,
      ConflictPolicy.manual => () {
        if (touchedS && !inS && inD) {
          // A source deletion would remove content from the destination —
          // hold it for review.
          conflicts.add(SyncConflict(id: id, inSourceNow: inS, inDestNow: inD));
          return inD;
        }
        return touchedS ? inS : inD;
      }(),
    };
    return (inS, dstKeeps);
  }

  (bool, bool) _resolveTwoWay(
    ConflictPolicy policy, {
    required bool inS,
    required bool inD,
    required bool touchedS,
    required bool touchedD,
    required List<SyncConflict> conflicts,
    required SyncId id,
  }) {
    // Agreement (including both-touched, which always agrees — see NOTE).
    if (inS == inD) return (inS, inD);

    // Single-sided change: which side moved, and was it an add or removal?
    final changedHas = touchedS ? inS : inD;
    switch (policy) {
      case ConflictPolicy.mirrorSource:
        return (inS, inS); // source wins every divergence
      case ConflictPolicy.merge:
        return (changedHas, changedHas); // the editing side's intent wins
      case ConflictPolicy.keepBoth:
        return (true, true); // union — deletions never propagate
      case ConflictPolicy.manual:
        if (!changedHas) {
          // A deletion would propagate — hold both sides for review.
          conflicts.add(SyncConflict(id: id, inSourceNow: inS, inDestNow: inD));
          return (inS, inD);
        }
        return (true, true); // adds flow freely
    }
  }
}
