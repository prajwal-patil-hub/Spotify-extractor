import 'package:drift/drift.dart';

/// Schema per docs/05. Conventions:
/// - Primary keys are deterministic composite strings (`provider:trackId`,
///   `accountRow:playlistId`) so batch upserts never need a lookup first.
/// - Timestamps are UTC epoch-millis via Drift's dateTime.
/// - JSON payload columns end in `Json` and hold pre-encoded strings; the
///   repositories own encoding/decoding.

class ProviderAccounts extends Table {
  /// `provider:accountValue`.
  TextColumn get id => text()();
  TextColumn get providerId => text()();
  TextColumn get accountValue => text()();
  TextColumn get displayName => text()();
  TextColumn get avatarUrl => text().nullable()();

  /// Key into secure storage — tokens themselves NEVER live in this DB.
  TextColumn get tokenRef => text()();
  TextColumn get scopes => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('connected'))();
  DateTimeColumn get connectedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {providerId, accountValue},
  ];
}

@TableIndex(name: 'idx_tracks_isrc', columns: {#isrc})
@TableIndex(name: 'idx_tracks_norm', columns: {#titleNorm})
class TrackSnapshots extends Table {
  /// `provider:providerTrackId`.
  TextColumn get id => text()();
  TextColumn get providerId => text()();
  TextColumn get providerTrackId => text()();
  TextColumn get isrc => text().nullable()();
  TextColumn get title => text()();
  TextColumn get titleNorm => text()();

  /// Ordered JSON array of artist names.
  TextColumn get artistsJson => text()();
  TextColumn get album => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get releaseYear => integer().nullable()();
  BoolColumn get explicit => boolean().nullable()();
  IntColumn get popularity => integer().nullable()();

  /// Provider payload for re-scoring without refetch (docs/05 §4.3).
  TextColumn get rawJson => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {providerId, providerTrackId},
  ];
}

@TableIndex(name: 'idx_mappings_dst', columns: {#dstProviderId})
class TrackMappings extends Table {
  /// `srcTrackRowId->dstProviderId`.
  TextColumn get id => text()();
  TextColumn get srcTrackId => text().customConstraint(
    'NOT NULL REFERENCES track_snapshots (id) ON DELETE CASCADE',
  )();
  TextColumn get dstProviderId => text()();

  /// Null = confirmed miss (memoized "no match exists", docs/05 §4.2).
  TextColumn get dstProviderTrackId => text().nullable()();
  RealColumn get confidence => real()();
  TextColumn get matchMethod => text()(); // isrc|fuzzy|manual|cache
  TextColumn get signalsJson => text().withDefault(const Constant('{}'))();
  TextColumn get decidedBy => text()(); // auto|user
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {srcTrackId, dstProviderId},
  ];
}

class PlaylistSnapshots extends Table {
  /// `accountRowId:providerPlaylistId`.
  TextColumn get id => text()();
  TextColumn get accountId => text().customConstraint(
    'NOT NULL REFERENCES provider_accounts (id) ON DELETE CASCADE',
  )();
  TextColumn get providerPlaylistId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get privacy => text().nullable()();
  BoolColumn get collaborative =>
      boolean().withDefault(const Constant(false))();
  TextColumn get artworkUrl => text().nullable()();
  IntColumn get trackCount => integer().withDefault(const Constant(0))();

  /// Digest of the ordered track-id list → O(1) change detection.
  TextColumn get contentHash => text()();
  TextColumn get providerEtag => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {accountId, providerPlaylistId},
  ];
}

class PlaylistTrackSnapshots extends Table {
  TextColumn get playlistId => text().customConstraint(
    'NOT NULL REFERENCES playlist_snapshots (id) ON DELETE CASCADE',
  )();
  TextColumn get trackId =>
      text().customConstraint('NOT NULL REFERENCES track_snapshots (id)')();
  IntColumn get position => integer()();
  DateTimeColumn get addedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, position};
}

@TableIndex(name: 'idx_jobs_state', columns: {#state, #updatedAt})
class TransferJobs extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get srcAccountId =>
      text().customConstraint('NOT NULL REFERENCES provider_accounts (id)')();
  TextColumn get dstAccountId =>
      text().customConstraint('NOT NULL REFERENCES provider_accounts (id)')();
  TextColumn get specJson => text()();
  TextColumn get state => text()();
  IntColumn get progressDone => integer().withDefault(const Constant(0))();
  IntColumn get progressTotal => integer().withDefault(const Constant(0))();
  TextColumn get errorJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'idx_items_job_state', columns: {#jobId, #state})
@TableIndex(name: 'idx_items_retry', columns: {#state, #nextRetryAt})
class JobItems extends Table {
  TextColumn get id => text()();
  TextColumn get jobId => text().customConstraint(
    'NOT NULL REFERENCES transfer_jobs (id) ON DELETE CASCADE',
  )();
  IntColumn get seq => integer()();
  TextColumn get srcTrackId =>
      text().customConstraint('NOT NULL REFERENCES track_snapshots (id)')();
  TextColumn get mappingId => text().nullable().customConstraint(
    'NULL REFERENCES track_mappings (id)',
  )();
  TextColumn get state => text()();

  /// Destination track id once resolved — engine checkpoint state.
  TextColumn get resolvedDstId => text().nullable()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {jobId, seq},
  ];
}

class SyncPairs extends Table {
  TextColumn get id => text()();
  TextColumn get srcPlaylistId => text().customConstraint(
    'NOT NULL REFERENCES playlist_snapshots (id) ON DELETE CASCADE',
  )();
  TextColumn get dstPlaylistId => text().customConstraint(
    'NOT NULL REFERENCES playlist_snapshots (id) ON DELETE CASCADE',
  )();
  TextColumn get mode => text()(); // one_way|two_way
  TextColumn get conflictPolicy => text()();
  TextColumn get scheduleCron => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// Last agreed state — the 3-way diff anchor (docs/08 §5).
  TextColumn get baseStateJson => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncRuns extends Table {
  TextColumn get id => text()();
  TextColumn get pairId => text().customConstraint(
    'NOT NULL REFERENCES sync_pairs (id) ON DELETE CASCADE',
  )();
  TextColumn get trigger => text()(); // manual|scheduled|change_detected
  TextColumn get state => text()();
  TextColumn get diffJson => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'idx_logs_at', columns: {#at})
class JobLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get jobId => text().nullable()();
  TextColumn get level => text()();
  TextColumn get event => text()(); // machine-readable code (docs/09)
  TextColumn get detailJson => text().nullable()();
  DateTimeColumn get at => dateTime()();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get valueJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
