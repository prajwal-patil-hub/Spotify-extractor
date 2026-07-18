import 'package:core_domain/core_domain.dart';
import 'package:provider_api/provider_api.dart';
import 'package:sync_engine/sync_engine.dart';
import 'package:test/test.dart';
import 'package:testing_toolkit/testing_toolkit.dart';

const _sp = ProviderId('spotify');
const _yt = ProviderId('ytmusic');

/// Fixture mapping: sync id `t<i>` ↔ spotify `s<i>` ↔ ytmusic `d<i>`,
/// except ids listed in [unmappedOnYt] which have no YTM mapping yet.
class _Mapper implements SyncIdMapper {
  _Mapper({this.unmappedOnYt = const {}});

  final Set<SyncId> unmappedOnYt;

  @override
  SyncId? toSyncId(ProviderId provider, ProviderTrackId track) =>
      't${track.value.substring(1)}';

  @override
  ProviderTrackId? toProviderTrack(ProviderId provider, SyncId id) {
    final n = id.substring(1);
    if (provider == _yt && unmappedOnYt.contains(id)) return null;
    return ProviderTrackId(provider == _sp ? 's$n' : 'd$n');
  }
}

void main() {
  late FakeMusicProvider spotify;
  late FakeMusicProvider ytmusic;
  late AccountId spAccount;
  late AccountId ytAccount;
  late PlaylistRef spRef;
  late PlaylistRef ytRef;

  Future<void> seed({
    required List<int> spotifyTracks,
    required List<int> ytmusicTracks,
  }) async {
    spotify = FakeMusicProvider(id: _sp)
      ..seedCatalog([
        for (var i = 0; i < 50; i++)
          Track(
            providerId: _sp,
            id: ProviderTrackId('s$i'),
            title: 'Song $i',
            artists: [Artist(name: 'Artist $i')],
          ),
      ]);
    ytmusic = FakeMusicProvider(id: _yt)
      ..seedCatalog([
        for (var i = 0; i < 50; i++)
          Track(
            providerId: _yt,
            id: ProviderTrackId('d$i'),
            title: 'Song $i',
            artists: [Artist(name: 'Artist $i')],
          ),
      ]);
    spAccount = spotify.seedAccount('u');
    ytAccount = ytmusic.seedAccount('u');
    final spPl = await spotify.createPlaylist(
      spAccount,
      const PlaylistSpec(name: 'Pair'),
    );
    final ytPl = await ytmusic.createPlaylist(
      ytAccount,
      const PlaylistSpec(name: 'Pair'),
    );
    spRef = PlaylistRef(account: spAccount, playlist: spPl.id);
    ytRef = PlaylistRef(account: ytAccount, playlist: ytPl.id);
    await spotify.addTracks(spRef, [
      for (final i in spotifyTracks) ProviderTrackId('s$i'),
    ]);
    await ytmusic.addTracks(ytRef, [
      for (final i in ytmusicTracks) ProviderTrackId('d$i'),
    ]);
  }

  Future<List<String>> tracksOf(FakeMusicProvider p, PlaylistRef ref) =>
      p.getPlaylistTracks(ref).map((t) => t.id.value).toList();

  test('two-way merge cycle applies both directions and returns the agreed '
      'base', () async {
    await seed(spotifyTracks: [0, 1, 2], ytmusicTracks: [0, 1, 3]);
    final orchestrator = SyncOrchestrator(
      source: spotify,
      dest: ytmusic,
      mapper: _Mapper(),
    );
    final outcome = await orchestrator.syncPair(
      sourcePlaylist: spRef,
      destPlaylist: ytRef,
      base: PlaylistState(const ['t0', 't1']),
      mode: SyncMode.twoWay,
      policy: ConflictPolicy.merge,
    );

    expect(
      await tracksOf(spotify, spRef),
      containsAll(['s0', 's1', 's2', 's3']),
    );
    expect(
      await tracksOf(ytmusic, ytRef),
      containsAll(['d0', 'd1', 'd2', 'd3']),
    );
    expect(outcome.newBase.asSet, {'t0', 't1', 't2', 't3'});
    expect(outcome.needsMatchingToDest, isEmpty);

    // Second cycle over the new base with no edits: a genuine no-op.
    final again = await orchestrator.syncPair(
      sourcePlaylist: spRef,
      destPlaylist: ytRef,
      base: outcome.newBase,
      mode: SyncMode.twoWay,
      policy: ConflictPolicy.merge,
    );
    expect(again.plan.isNoOp, isTrue);
  });

  test('one-way mirror reverts destination drift', () async {
    await seed(spotifyTracks: [0, 1], ytmusicTracks: [0, 5]);
    final orchestrator = SyncOrchestrator(
      source: spotify,
      dest: ytmusic,
      mapper: _Mapper(),
    );
    await orchestrator.syncPair(
      sourcePlaylist: spRef,
      destPlaylist: ytRef,
      base: PlaylistState(const ['t0']),
      mode: SyncMode.oneWay,
      policy: ConflictPolicy.mirrorSource,
    );
    expect(await tracksOf(ytmusic, ytRef), ['d0', 'd1']);
    expect(await tracksOf(spotify, spRef), [
      's0',
      's1',
    ], reason: 'one-way must not edit the source');
  });

  test('unmapped tracks are surfaced for matching, excluded from the base, '
      'and picked up next cycle once mapped', () async {
    await seed(spotifyTracks: [0, 7], ytmusicTracks: [0]);
    final orchestrator = SyncOrchestrator(
      source: spotify,
      dest: ytmusic,
      mapper: _Mapper(unmappedOnYt: {'t7'}),
    );
    final outcome = await orchestrator.syncPair(
      sourcePlaylist: spRef,
      destPlaylist: ytRef,
      base: PlaylistState(const ['t0']),
      mode: SyncMode.oneWay,
      policy: ConflictPolicy.merge,
    );
    expect(outcome.needsMatchingToDest, ['t7']);
    expect(
      await tracksOf(ytmusic, ytRef),
      ['d0'],
      reason: 'nothing guessed at — the transfer machinery owns matching',
    );
    expect(outcome.newBase.contains('t7'), isFalse);

    // The mapping cache now knows t7 (transfer happened out of band):
    final second =
        await SyncOrchestrator(
          source: spotify,
          dest: ytmusic,
          mapper: _Mapper(), // fully mapped now
        ).syncPair(
          sourcePlaylist: spRef,
          destPlaylist: ytRef,
          base: outcome.newBase,
          mode: SyncMode.oneWay,
          policy: ConflictPolicy.merge,
        );
    expect(second.needsMatchingToDest, isEmpty);
    expect(await tracksOf(ytmusic, ytRef), ['d0', 'd7']);
  });
}
