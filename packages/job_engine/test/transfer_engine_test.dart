import 'package:core_domain/core_domain.dart';
import 'package:job_engine/job_engine.dart';
import 'package:provider_api/provider_api.dart';
import 'package:test/test.dart';
import 'package:testing_toolkit/testing_toolkit.dart';

const _src = ProviderId('spotify');

Track _srcTrack(int i) => Track(
  providerId: _src,
  id: ProviderTrackId('s$i'),
  title: 'Song $i',
  artists: [Artist(name: 'Artist $i')],
);

/// Deterministic resolver: source `s<i>` → destination `d<i>`.
Future<TrackResolution> _mapResolver(Track source) async =>
    ResolvedTrack(ProviderTrackId('d${source.id.value.substring(1)}'));

/// Wraps the fake destination to inject typed failures per call-site.
class _FlakyDst implements MusicProvider {
  _FlakyDst(this.inner);

  final FakeMusicProvider inner;
  int failAddTimes = 0;
  AppError Function()? addError;

  /// Video ids the destination silently drops (verification-lie scenario).
  final Set<String> silentlyDrop = {};

  @override
  Future<void> addTracks(
    PlaylistRef playlist,
    List<ProviderTrackId> trackIds, {
    int? position,
  }) async {
    if (failAddTimes > 0) {
      failAddTimes--;
      throw addError!();
    }
    final kept = [
      for (final t in trackIds)
        if (!silentlyDrop.contains(t.value)) t,
    ];
    await inner.addTracks(playlist, kept, position: position);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();

  // Delegate the rest.
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
  Stream<Playlist> getPlaylists(AccountId account) =>
      inner.getPlaylists(account);
  @override
  Stream<Track> getPlaylistTracks(PlaylistRef playlist) =>
      inner.getPlaylistTracks(playlist);
  @override
  Stream<Track> getLikedSongs(AccountId account) =>
      inner.getLikedSongs(account);
  @override
  Stream<Album> getAlbums(AccountId account) => inner.getAlbums(account);
  @override
  Stream<Artist> getArtists(AccountId account) => inner.getArtists(account);
  @override
  Future<Playlist> createPlaylist(AccountId account, PlaylistSpec spec) =>
      inner.createPlaylist(account, spec);
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

class _Fixture {
  _Fixture({TrackResolver? resolver, int batchSize = 50}) {
    fakeDst = FakeMusicProvider(id: const ProviderId('ytmusic'))
      ..seedCatalog([
        for (var i = 0; i < 100; i++)
          Track(
            providerId: const ProviderId('ytmusic'),
            id: ProviderTrackId('d$i'),
            title: 'Song $i',
            artists: [Artist(name: 'Artist $i')],
          ),
      ]);
    dstAccount = fakeDst.seedAccount('dst');
    dst = _FlakyDst(fakeDst);
    store = InMemoryJobStore();
    engine = TransferEngine(
      store: store,
      destination: dst,
      resolver: resolver ?? _mapResolver,
      batchSize: batchSize,
      clock: () => now,
      delay: (d) async => now = now.add(d),
    );
  }

  late final FakeMusicProvider fakeDst;
  late final _FlakyDst dst;
  late final AccountId dstAccount;
  late final InMemoryJobStore store;
  late final TransferEngine engine;
  DateTime now = DateTime.utc(2026, 7, 16);

  Future<String> plan({int tracks = 5, String name = 'Road Trip'}) =>
      engine.planPlaylistTransfer(
        jobId: 'job1',
        srcAccount: const AccountId('src'),
        dstAccount: dstAccount,
        spec: TransferSpec(playlistName: name),
        sourceTracks: [for (var i = 0; i < tracks; i++) _srcTrack(i)],
      );

  Future<List<String>> dstTrackIds() async {
    final job = (await store.job('job1'))!;
    return fakeDst
        .getPlaylistTracks(
          PlaylistRef(
            account: dstAccount,
            playlist: ProviderPlaylistId(job.spec.dstPlaylistId!),
          ),
        )
        .map((t) => t.id.value)
        .toList();
  }
}

void main() {
  test('happy path: plan → run → completed, ordered, verified', () async {
    final f = _Fixture();
    await f.plan(tracks: 5);
    final job = await f.engine.run('job1');
    expect(job.state, JobState.completed);
    expect(job.progressDone, 5);
    expect(await f.dstTrackIds(), ['d0', 'd1', 'd2', 'd3', 'd4']);
    final verified = await f.store.itemsInStates('job1', {ItemState.verified});
    expect(verified, hasLength(5));
  });

  test(
    'review and no-match items route correctly; job ends needsReview',
    () async {
      final f = _Fixture(
        resolver: (source) async => switch (source.id.value) {
          's1' => const ResolutionNeedsReview(),
          's3' => const ResolutionNoMatch(),
          final v => ResolvedTrack(ProviderTrackId('d${v.substring(1)}')),
        },
      );
      await f.plan(tracks: 5);
      final job = await f.engine.run('job1');
      expect(job.state, JobState.needsReview);
      expect(await f.dstTrackIds(), ['d0', 'd2', 'd4']);
      expect(
        (await f.store.itemsInStates('job1', {ItemState.skipped})).single.seq,
        3,
      );
      expect(
        (await f.store.itemsInStates('job1', {
          ItemState.needsReview,
        })).single.seq,
        1,
      );
    },
  );

  test('RateLimited defers the batch and retries after Retry-After', () async {
    final f = _Fixture();
    await f.plan(tracks: 3);
    f.dst
      ..failAddTimes = 1
      ..addError = () => const RateLimited(
        ProviderId('ytmusic'),
        'slow down',
        retryAfter: Duration(seconds: 30),
      );
    final started = f.now;
    final job = await f.engine.run('job1');
    expect(job.state, JobState.completed);
    expect(await f.dstTrackIds(), ['d0', 'd1', 'd2']);
    expect(
      f.now.isAfter(started.add(const Duration(seconds: 29))),
      isTrue,
      reason: 'engine must have waited out the Retry-After',
    );
  });

  test(
    'AuthExpired pauses the job; resume after reconnect completes it',
    () async {
      final f = _Fixture();
      await f.plan(tracks: 3);
      f.dst
        ..failAddTimes = 1
        ..addError = () =>
            const AuthExpired(ProviderId('ytmusic'), 'token dead');
      var job = await f.engine.run('job1');
      expect(job.state, JobState.paused);
      expect(job.error, contains('token dead'));

      await f.engine.resume('job1');
      job = await f.engine.run('job1');
      expect(job.state, JobState.completed);
      expect(await f.dstTrackIds(), ['d0', 'd1', 'd2']);
    },
  );

  test('cancelled job refuses to run further', () async {
    final f = _Fixture();
    await f.plan();
    await f.engine.cancel('job1');
    final job = await f.engine.run('job1');
    expect(job.state, JobState.cancelled);
    final items = await f.store.itemsInStates('job1', {ItemState.pending});
    expect(items, hasLength(5), reason: 'nothing was processed');
  });

  test('pause between batches stops promptly and resume picks up exactly '
      'where it left off', () async {
    final f = _Fixture(batchSize: 2);
    await f.plan(tracks: 6);
    // Pause the job from inside the third resolution — takes effect at the
    // next between-batch control check.
    var resolved = 0;
    final engine = TransferEngine(
      store: f.store,
      destination: f.dst,
      resolver: (t) async {
        if (++resolved == 3) await f.store.setJobState('job1', JobState.paused);
        return _mapResolver(t);
      },
      batchSize: 2,
      clock: () => f.now,
      delay: (d) async {},
    );
    var job = await engine.run('job1');
    expect(job.state, JobState.paused);
    expect((await f.dstTrackIds()).length, lessThan(6));

    await engine.resume('job1');
    job = await engine.run('job1');
    expect(job.state, JobState.completed);
    expect(await f.dstTrackIds(), ['d0', 'd1', 'd2', 'd3', 'd4', 'd5']);
  });

  test('verification catches silently dropped tracks: one retry, then '
      'failed — partial success is success', () async {
    final f = _Fixture();
    f.dst.silentlyDrop.add('d2');
    await f.plan(tracks: 4);
    final job = await f.engine.run('job1');
    expect(job.state, JobState.completed);
    expect(await f.dstTrackIds(), ['d0', 'd1', 'd3']);
    final failed = await f.store.itemsInStates('job1', {ItemState.failed});
    expect(failed.single.seq, 2);
    expect(failed.single.lastError, contains('verification'));
    expect(
      await f.store.itemsInStates('job1', {ItemState.verified}),
      hasLength(3),
    );
  });

  test('an existing same-name playlist is reused, never duplicated '
      '(create-checkpoint crash recovery)', () async {
    final f = _Fixture();
    final existing = await f.fakeDst.createPlaylist(
      f.dstAccount,
      const PlaylistSpec(name: 'Road Trip'),
    );
    await f.plan(tracks: 2);
    final job = await f.engine.run('job1');
    expect(job.state, JobState.completed);
    expect(job.spec.dstPlaylistId, existing.id.value);
    final playlists = await f.fakeDst.getPlaylists(f.dstAccount).toList();
    expect(playlists, hasLength(1));
  });

  test('resume after a hard crash mid-batch causes no duplicates', () async {
    final f = _Fixture(batchSize: 2);
    await f.plan(tracks: 6);
    // Crash (non-AppError, i.e. process death) on the third resolution:
    // batch 1 (items 0–1) is added AND committed; batch 2 dies mid-flight.
    var calls = 0;
    final engine = TransferEngine(
      store: f.store,
      destination: f.dst,
      resolver: (t) async {
        if (++calls == 3) throw StateError('simulated process death');
        return _mapResolver(t);
      },
      batchSize: 2,
      clock: () => f.now,
      delay: (d) async {},
    );
    await expectLater(engine.run('job1'), throwsStateError);

    // "Relaunch": fresh engine over the same store and destination state.
    final revived = TransferEngine(
      store: f.store,
      destination: f.dst,
      resolver: _mapResolver,
      batchSize: 2,
      clock: () => f.now,
      delay: (d) async {},
    );
    final job = await revived.run('job1');
    expect(job.state, JobState.completed);
    expect(await f.dstTrackIds(), [
      'd0',
      'd1',
      'd2',
      'd3',
      'd4',
      'd5',
    ], reason: 'exactly once each, in order');
  });
}
