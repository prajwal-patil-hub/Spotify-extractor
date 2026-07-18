import 'package:meta/meta.dart';

import 'state.dart';

/// Membership delta between two snapshots of one side.
@immutable
class SyncDiff {
  SyncDiff({required Set<SyncId> added, required Set<SyncId> removed})
    : added = Set.unmodifiable(added),
      removed = Set.unmodifiable(removed);

  final Set<SyncId> added;
  final Set<SyncId> removed;

  bool get isEmpty => added.isEmpty && removed.isEmpty;

  bool touches(SyncId id) => added.contains(id) || removed.contains(id);
}

/// Set-membership diff from [base] to [now]. Order changes are not deltas —
/// order authority belongs to the source side (docs/08 §5).
SyncDiff diffStates(PlaylistState base, PlaylistState now) => SyncDiff(
  added: now.asSet.difference(base.asSet),
  removed: base.asSet.difference(now.asSet),
);
