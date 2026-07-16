import 'dart:io';

import 'package:core_domain/core_domain.dart';
import 'package:data_local/data_local.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

const _spotify = ProviderId('spotify');
const _ytm = ProviderId('ytmusic');

Track _track(int i, {ProviderId provider = _spotify, String? isrc}) => Track(
  providerId: provider,
  id: ProviderTrackId('t$i'),
  title: 'Song $i',
  artists: [Artist(name: 'Artist ${i % 100}')],
  album: Album(title: 'Album ${i % 50}', releaseYear: 2000 + i % 20),
  duration: Duration(seconds: 180 + i % 120),
  isrc: isrc,
  explicit: i.isEven,
  popularity: i % 100,
);

void main() {
  late BridgetuneDatabase db;
  late SnapshotRepository snapshots;
  late AccountsRepository accounts;
  late MappingRepository mappings;
  late SettingsRepository settings;

  setUp(() {
    db = BridgetuneDatabase(NativeDatabase.memory());
    snapshots = SnapshotRepository(
      db,
      normalizer: (t) => t.toLowerCase().trim(),
    );
    accounts = AccountsRepository(db);
    mappings = MappingRepository(db);
    settings = SettingsRepository(db);
  });

  tearDown(() => db.close());

  Future<String> seedAccount({String user = 'user1'}) => accounts.upsert(
    provider: _spotify,
    account: AccountId(user),
    displayName: 'Test User',
    tokenRef: 'spotify/$user',
  );

  group('schema', () {
    test('all tables exist and foreign keys are enforced', () async {
      // An orphan playlist-track row must be rejected (FK pragma on).
      await expectLater(
        db
            .into(db.playlistTrackSnapshots)
            .insert(
              PlaylistTrackSnapshotsCompanion.insert(
                playlistId: 'ghost',
                trackId: 'ghost',
                position: 0,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('deleting an account cascades to its playlist snapshots', () async {
      final accountRow = await seedAccount();
      await snapshots.ingestTracks(Stream.fromIterable([_track(1)]));
      await snapshots.upsertPlaylist(
        accountRowId: accountRow,
        playlist: Playlist(
          providerId: _spotify,
          id: const ProviderPlaylistId('p1'),
          name: 'Mix',
          trackCount: 1,
        ),
        trackRowIds: [trackRowId(_spotify, const ProviderTrackId('t1'))],
      );
      await accounts.delete(accountRow);
      final rows = await db.select(db.playlistSnapshots).get();
      expect(rows, isEmpty);
      final trackRows = await db.select(db.playlistTrackSnapshots).get();
      expect(trackRows, isEmpty, reason: 'cascade reaches join rows');
      // Track snapshots and mappings survive account deletion by design.
      expect(await snapshots.trackCount(), 1);
    });
  });

  group('track ingestion', () {
    test('is idempotent: re-ingesting updates in place', () async {
      await snapshots.ingestTracks(
        Stream.fromIterable([for (var i = 0; i < 10; i++) _track(i)]),
      );
      await snapshots.ingestTracks(
        Stream.fromIterable([for (var i = 0; i < 10; i++) _track(i)]),
      );
      expect(await snapshots.trackCount(), 10);
    });

    test('stores normalized titles and ISRC lookups work', () async {
      await snapshots.ingestTracks(
        Stream.fromIterable([_track(1, isrc: 'USXXX0000001')]),
      );
      final row = await snapshots.trackByRowId(
        trackRowId(_spotify, const ProviderTrackId('t1')),
      );
      expect(row!.titleNorm, 'song 1');
      final byIsrc = await snapshots.tracksByIsrc('USXXX0000001');
      expect(byIsrc.single.id, row.id);
    });

    test(
      'EXIT GATE: 10k tracks ingest into a file-backed DB in < 30 s',
      () async {
        final dir = await Directory.systemTemp.createTemp('bridgetune-bench');
        final fileDb = BridgetuneDatabase(
          NativeDatabase(File('${dir.path}/bench.db')),
        );
        final repo = SnapshotRepository(
          fileDb,
          normalizer: (t) => t.toLowerCase().trim(),
        );
        final stopwatch = Stopwatch()..start();
        final written = await repo.ingestTracks(
          Stream.fromIterable([for (var i = 0; i < 10000; i++) _track(i)]),
        );
        stopwatch.stop();
        await fileDb.close();
        await dir.delete(recursive: true);
        expect(written, 10000);
        expect(
          stopwatch.elapsed,
          lessThan(const Duration(seconds: 30)),
          reason: 'took ${stopwatch.elapsedMilliseconds} ms',
        );
        // ignore: avoid_print
        print('10k-track ingestion: ${stopwatch.elapsedMilliseconds} ms');
      },
    );
  });

  group('playlist snapshots', () {
    test('content hash detects change and order changes', () async {
      final a = SnapshotRepository.contentHashOf(['x', 'y', 'z']);
      expect(SnapshotRepository.contentHashOf(['x', 'y', 'z']), a);
      expect(SnapshotRepository.contentHashOf(['z', 'y', 'x']), isNot(a));
    });

    test(
      'upsert replaces tracks atomically; unchanged detection works',
      () async {
        final accountRow = await seedAccount();
        await snapshots.ingestTracks(
          Stream.fromIterable([for (var i = 0; i < 5; i++) _track(i)]),
        );
        String rid(int i) => trackRowId(_spotify, ProviderTrackId('t$i'));
        final playlist = Playlist(
          providerId: _spotify,
          id: const ProviderPlaylistId('p1'),
          name: 'Mix',
          trackCount: 3,
          etag: 'snap-1',
        );
        await snapshots.upsertPlaylist(
          accountRowId: accountRow,
          playlist: playlist,
          trackRowIds: [rid(0), rid(1), rid(2)],
        );

        expect(
          await snapshots.isPlaylistUnchanged(
            accountRowId: accountRow,
            playlist: const ProviderPlaylistId('p1'),
            etag: 'snap-1',
          ),
          isTrue,
        );
        expect(
          await snapshots.isPlaylistUnchanged(
            accountRowId: accountRow,
            playlist: const ProviderPlaylistId('p1'),
            etag: 'snap-2',
          ),
          isFalse,
        );

        // Replace with a different order → new hash, positions rewritten.
        await snapshots.upsertPlaylist(
          accountRowId: accountRow,
          playlist: playlist,
          trackRowIds: [rid(2), rid(0)],
        );
        final tracks = await snapshots.playlistTracks(
          playlistRowId(accountRow, const ProviderPlaylistId('p1')),
        );
        expect(tracks.map((t) => t.providerTrackId), ['t2', 't0']);
      },
    );

    test('windowed playlistTracks respects limit/offset ordering', () async {
      final accountRow = await seedAccount();
      await snapshots.ingestTracks(
        Stream.fromIterable([for (var i = 0; i < 20; i++) _track(i)]),
      );
      await snapshots.upsertPlaylist(
        accountRowId: accountRow,
        playlist: Playlist(
          providerId: _spotify,
          id: const ProviderPlaylistId('p1'),
          name: 'Big',
          trackCount: 20,
        ),
        trackRowIds: [
          for (var i = 0; i < 20; i++)
            trackRowId(_spotify, ProviderTrackId('t$i')),
        ],
      );
      final window = await snapshots.playlistTracks(
        playlistRowId(accountRow, const ProviderPlaylistId('p1')),
        limit: 5,
        offset: 10,
      );
      expect(window.map((t) => t.providerTrackId), [
        't10',
        't11',
        't12',
        't13',
        't14',
      ]);
    });

    test('watchPlaylists is reactive', () async {
      final accountRow = await seedAccount();
      final futureLengths = snapshots
          .watchPlaylists(accountRow)
          .map((rows) => rows.length)
          .take(2)
          .toList();
      await snapshots.upsertPlaylist(
        accountRowId: accountRow,
        playlist: Playlist(
          providerId: _spotify,
          id: const ProviderPlaylistId('p1'),
          name: 'Mix',
          trackCount: 0,
        ),
        trackRowIds: const [],
      );
      expect(await futureLengths, [0, 1]);
    });
  });

  group('mapping cache', () {
    late String srcRowId;

    setUp(() async {
      await snapshots.ingestTracks(Stream.fromIterable([_track(1)]));
      srcRowId = trackRowId(_spotify, const ProviderTrackId('t1'));
    });

    test('miss → record hit → hit is returned without a search', () async {
      expect(
        await mappings.lookup(srcTrackRowId: srcRowId, dstProvider: _ytm),
        isA<MappingMiss>(),
      );
      await mappings.record(
        srcTrackRowId: srcRowId,
        dstProvider: _ytm,
        dstTrackId: const ProviderTrackId('yt-abc'),
        confidence: 0.97,
        method: 'fuzzy',
        decidedBy: 'auto',
      );
      final hit =
          await mappings.lookup(srcTrackRowId: srcRowId, dstProvider: _ytm)
              as MappingHit;
      expect(hit.dstTrackId.value, 'yt-abc');
      expect(hit.confidence, 0.97);
    });

    test('confirmed miss is memoized fresh, re-searched after TTL', () async {
      var now = DateTime.utc(2026, 7, 16);
      final repo = MappingRepository(db, clock: () => now);
      await repo.record(
        srcTrackRowId: srcRowId,
        dstProvider: _ytm,
        dstTrackId: null,
        confidence: 0,
        method: 'fuzzy',
        decidedBy: 'auto',
      );
      expect(
        await repo.lookup(srcTrackRowId: srcRowId, dstProvider: _ytm),
        isA<ConfirmedMiss>(),
      );
      now = now.add(const Duration(days: 31));
      expect(
        await repo.lookup(srcTrackRowId: srcRowId, dstProvider: _ytm),
        isA<MappingMiss>(),
        reason: 'stale confirmed miss must trigger a re-search',
      );
    });

    test('a user decision is never overwritten by an automatic one', () async {
      await mappings.record(
        srcTrackRowId: srcRowId,
        dstProvider: _ytm,
        dstTrackId: const ProviderTrackId('user-choice'),
        confidence: 1,
        method: 'manual',
        decidedBy: 'user',
      );
      await mappings.record(
        srcTrackRowId: srcRowId,
        dstProvider: _ytm,
        dstTrackId: const ProviderTrackId('robot-choice'),
        confidence: 0.9,
        method: 'fuzzy',
        decidedBy: 'auto',
      );
      final hit =
          await mappings.lookup(srcTrackRowId: srcRowId, dstProvider: _ytm)
              as MappingHit;
      expect(hit.dstTrackId.value, 'user-choice');
    });

    test('stats aggregates per destination provider', () async {
      await snapshots.ingestTracks(Stream.fromIterable([_track(2)]));
      await mappings.record(
        srcTrackRowId: srcRowId,
        dstProvider: _ytm,
        dstTrackId: const ProviderTrackId('y1'),
        confidence: 0.9,
        method: 'fuzzy',
        decidedBy: 'auto',
      );
      await mappings.record(
        srcTrackRowId: trackRowId(_spotify, const ProviderTrackId('t2')),
        dstProvider: _ytm,
        dstTrackId: null,
        confidence: 0,
        method: 'fuzzy',
        decidedBy: 'auto',
      );
      final stats = await mappings.stats(_ytm);
      expect(stats.total, 2);
      expect(stats.misses, 1);
      expect(stats.avgConfidence, closeTo(0.9, 1e-9));
    });
  });

  group('settings', () {
    test('round-trips arbitrary JSON shapes and watches changes', () async {
      await settings.set('matching.threshold', 'balanced');
      await settings.set('sync.intervalMinutes', 30);
      expect(await settings.get<String>('matching.threshold'), 'balanced');
      expect(await settings.get<int>('sync.intervalMinutes'), 30);
      expect(await settings.get<String>('missing'), isNull);

      final updates = settings.watch<String>('theme').take(2).toList();
      await settings.set('theme', 'old_money');
      expect(await updates, [null, 'old_money']);
    });
  });

  group('migration guard', () {
    test('a database from a newer schema refuses to open', () async {
      final dir = await Directory.systemTemp.createTemp('bridgetune-mig');
      final file = File('${dir.path}/future.db');
      // Create a v1 database, then stamp it as schema v99.
      final v1 = BridgetuneDatabase(NativeDatabase(file));
      await v1.customStatement('SELECT 1'); // force open
      await v1.customStatement('PRAGMA user_version = 99');
      await v1.close();

      final reopened = BridgetuneDatabase(NativeDatabase(file));
      await expectLater(reopened.customStatement('SELECT 1'), throwsStateError);
      await reopened.close();
      await dir.delete(recursive: true);
    });
  });
}
