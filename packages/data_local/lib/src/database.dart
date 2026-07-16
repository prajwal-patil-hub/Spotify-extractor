import 'package:drift/drift.dart';

import 'tables.dart';

part 'database.g.dart';

/// The operational database (docs/05). One instance per app, opened lazily;
/// tests use an in-memory executor.
@DriftDatabase(
  tables: [
    ProviderAccounts,
    TrackSnapshots,
    TrackMappings,
    PlaylistSnapshots,
    PlaylistTrackSnapshots,
    TransferJobs,
    JobItems,
    SyncPairs,
    SyncRuns,
    JobLogs,
    AppSettings,
  ],
)
class BridgetuneDatabase extends _$BridgetuneDatabase {
  BridgetuneDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  /// Migration policy (docs/05 §4.6): forward-only, one migrator step per
  /// version bump, each shipped with a fixture-DB upgrade test. A database
  /// newer than the binary refuses to open (fail-safe for downgrades).
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v1 is the initial schema — future steps land here as
      // `if (from < 2) { ... }` blocks, never edited retroactively.
    },
    beforeOpen: (details) async {
      final before = details.versionBefore;
      if (before != null && before > details.versionNow) {
        throw StateError(
          'database schema $before is newer than this build supports '
          '($schemaVersion) — refusing to open',
        );
      }
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
