import 'dart:io';
import 'dart:math';

import 'package:core_domain/core_domain.dart';
import 'package:data_local/data_local.dart';
import 'package:drift/native.dart';
import 'package:job_engine/job_engine.dart';
import 'package:provider_api/provider_api.dart';
import 'package:test/test.dart';
import 'package:testing_toolkit/testing_toolkit.dart';

/// The Phase-5 exit gate (docs/11, docs/12 §6): kill the process at ANY
/// point during a transfer — including the nastiest windows immediately
/// before and after a destination mutation — relaunch from the on-disk
/// database, and the job must finish with zero lost tracks, zero
/// duplicates, and source order intact.
///
/// "Process death" = a non-AppError thrown at the injection point plus
/// discarding every in-memory object (engine, store, DB connection). The
/// destination provider's memory persists across crashes — it plays the
/// remote service.
class SimulatedProcessDeath implements Exception {}

/// Wraps the destination, crashing before or after mutating calls once a
/// fuse burns down.
class _CrashingDst implements MusicProvider {
  _CrashingDst(this.inner);

  final FakeMusicProvider inner;
  int fuse = -1; // -1 = disarmed
  bool crashAfter = false;

  void _tick() {
    if (fuse < 0) return;
    if (!crashAfter && --fuse < 0) throw SimulatedProcessDeath();
  }

  void _tock() {
    if (fuse < 0) return;
    if (crashAfter && --fuse < 0) throw SimulatedProcessDeath();
  }

  @override
  Future<Playlist> createPlaylist(AccountId account, PlaylistSpec spec) async {
    _tick();
    final result = await inner.createPlaylist(account, spec);
    _tock();
    return result;
  }

  @override
  Future<void> addTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds, {
    int? position,
  }) async {
    _tick();
    await inner.addTracks(playlist, trackIds, position: position);
    _tock();
  }

  @override
  Stream<Playlist> getPlaylists(AccountId account) =>
      inner.getPlaylists(account);
  @override
  Stream<Track> getPlaylistTracks(PlaylistRef playlist) =>
      inner.getPlaylistTracks(playlist);
  @override
  ProviderId get id => inner.id;
  @override
  String get displayName => inner.displayName;
  @override
  ProviderCapabilities get capabilities => inner.capabilities;
  @override
  Future<ConnectedAccount> authenticate(AuthBroker broker) =>
      inner.authenticate(broker);
  @override
  Future<void> refreshSession(AccountId account) =>
      inner.refreshSession(account);
  @override
  Future<void> disconnect(AccountId account) => inner.disconnect(account);
  @override
  Future<SearchResult> searchTrack(AccountId account, TrackQuery query) =>
      inner.searchTrack(account, query);
  @override
  Stream<Track> getLikedSongs(AccountId account) =>
      inner.getLikedSongs(account);
  @override
  Stream<Album> getAlbums(AccountId account) => inner.getAlbums(account);
  @override
  Stream<Artist> getArtists(AccountId account) => inner.getArtists(account);
  @override
  Future<void> updatePlaylist(PlaylistRef playlist, PlaylistPatch patch) =>
      inner.updatePlaylist(playlist, patch);
  @override
  Future<void> deletePlaylist(PlaylistRef playlist) =>
      inner.deletePlaylist(playlist);
  @override
  Future<void> removeTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds,
  ) => inner.removeTracks(playlist, trackIds);
  @override
  Future<void> replaceTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds,
  ) => inner.replaceTracks(playlist, trackIds);
  @override
  Future<void> uploadArtwork(PlaylistRef playlist, Artwork artwork) =>
      inner.uploadArtwork(playlist, artwork);
  @override
  Future<void> updateDescription(PlaylistRef playlist, String description) =>
      inner.updateDescription(playlist, description);
}

void main() {
  test('EXIT GATE: kill-anywhere chaos — resume from disk with zero loss, '
      'zero duplication, order intact', () async {
    const trackCount = 60;
    const seeds = [7, 42, 1337];

    for (final seed in seeds) {
      final rng = Random(seed);
      final dir = await Directory.systemTemp.createTemp('bridgetune-chaos');
      final dbFile = File('${dir.path}/chaos.db');

      // The "remote" destination survives every crash.
      final remote = FakeMusicProvider(id: const ProviderId('ytmusic'))
        ..seedCatalog([
          for (var i = 0; i < trackCount; i++)
            Track(
              providerId: const ProviderId('ytmusic'),
              id: ProviderTrackId('d$i'),
              title: 'Song $i',
              artists: [Artist(name: 'Artist $i')],
            ),
        ]);
      final dstAccount = remote.seedAccount('user');
      final dst = _CrashingDst(remote);

      Future<TrackResolution> resolve(Track source) async =>
          ResolvedTrack(ProviderTrackId('d${source.id.value.substring(1)}'));

      TransferEngine boot(BridgetuneDatabase db) => TransferEngine(
        store: DriftJobStore(db),
        destination: dst,
        resolver: resolve,
        batchSize: 7,
        delay: (d) async {},
      );

      // Plan once against the on-disk DB (accounts registered first —
      // transfer_jobs carries real FKs to provider_accounts).
      {
        final db = BridgetuneDatabase(NativeDatabase(dbFile));
        for (final (provider, account) in [
          ('spotify', 'spotify:user'),
          ('ytmusic', dstAccount.value),
        ]) {
          await db
              .into(db.providerAccounts)
              .insertOnConflictUpdate(
                ProviderAccountsCompanion.insert(
                  id: account,
                  providerId: provider,
                  accountValue: account,
                  displayName: account,
                  tokenRef: 'test/$account',
                  connectedAt: DateTime.now(),
                ),
              );
        }
        await boot(db).planPlaylistTransfer(
          jobId: 'chaos-$seed',
          srcAccount: const AccountId('spotify:user'),
          dstAccount: dstAccount,
          spec: const TransferSpec(playlistName: 'Chaos Mix'),
          sourceTracks: [
            for (var i = 0; i < trackCount; i++)
              Track(
                providerId: const ProviderId('spotify'),
                id: ProviderTrackId('s$i'),
                title: 'Song $i',
                artists: [Artist(name: 'Artist $i')],
              ),
          ],
        );
        await db.close();
      }

      // Crash-and-relaunch loop until the job completes.
      var crashes = 0;
      JobRecord? finished;
      while (finished == null) {
        final db = BridgetuneDatabase(NativeDatabase(dbFile));
        final engine = boot(db);
        dst
          ..fuse =
              1 +
              rng.nextInt(4) // die after 1–4 mutating calls
          ..crashAfter = rng.nextBool(); // pre- or post-mutation window
        try {
          final job = await engine.run('chaos-$seed');
          if (job.state == JobState.completed) finished = job;
        } on SimulatedProcessDeath {
          crashes++; // everything in memory is discarded below
        } finally {
          await db.close();
        }
        expect(crashes, lessThan(200), reason: 'no forward progress');
      }
      dst.fuse = -1;

      expect(crashes, greaterThan(0), reason: 'the chaos must actually bite');

      // The destination playlist: every track exactly once, in order.
      final playlists = await remote.getPlaylists(dstAccount).toList();
      expect(playlists, hasLength(1), reason: 'playlist created exactly once');
      final tracks = await remote
          .getPlaylistTracks(
            PlaylistRef(account: dstAccount, playlist: playlists.single.id),
          )
          .map((t) => t.id.value)
          .toList();
      expect(tracks, [for (var i = 0; i < trackCount; i++) 'd$i']);

      // The ledger agrees: everything verified, progress complete.
      final db = BridgetuneDatabase(NativeDatabase(dbFile));
      final store = DriftJobStore(db);
      expect(finished.progressDone, trackCount);
      expect(
        await store.itemsInStates('chaos-$seed', {ItemState.verified}),
        hasLength(trackCount),
      );
      await db.close();
      await dir.delete(recursive: true);

      // ignore: avoid_print
      print('chaos seed $seed: survived $crashes crashes');
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}
