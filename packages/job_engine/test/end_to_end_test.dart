import 'package:core_domain/core_domain.dart';
import 'package:job_engine/job_engine.dart';
import 'package:matching_engine/matching_engine.dart';
import 'package:provider_api/provider_api.dart';
import 'package:test/test.dart';
import 'package:testing_toolkit/testing_toolkit.dart';

/// The docs/04 §3 loop end to end: source tracks → REAL matching engine
/// over the destination's search → transfer → verification. This is the
/// composition-root wiring the app will use, minus the database.
void main() {
  test('Spotify-shaped source transfers through the matching engine into a '
      'YTM-shaped destination', () async {
    const src = ProviderId('spotify');
    final dst = FakeMusicProvider(id: const ProviderId('ytmusic'))
      ..seedCatalog([
        // YTM-typical: no ISRCs, sparse albums.
        Track(
          providerId: const ProviderId('ytmusic'),
          id: const ProviderTrackId('yt-fastcar'),
          title: 'Fast Car',
          artists: const [Artist(name: 'Tracy Chapman')],
          duration: const Duration(seconds: 297),
        ),
        Track(
          providerId: const ProviderId('ytmusic'),
          id: const ProviderTrackId('yt-fastcar-live'),
          title: 'Fast Car (Live)',
          artists: const [Artist(name: 'Tracy Chapman')],
          duration: const Duration(seconds: 312),
        ),
        Track(
          providerId: const ProviderId('ytmusic'),
          id: const ProviderTrackId('yt-teardrop'),
          title: 'Teardrop',
          artists: const [Artist(name: 'Massive Attack')],
          duration: const Duration(seconds: 330),
        ),
        Track(
          providerId: const ProviderId('ytmusic'),
          id: const ProviderTrackId('yt-holocene-cover'),
          title: 'Holocene (Piano Cover)',
          artists: const [Artist(name: 'Cover Kings')],
          duration: const Duration(seconds: 300),
        ),
      ]);
    final dstAccount = dst.seedAccount('user');

    final sourceTracks = [
      Track(
        providerId: src,
        id: const ProviderTrackId('sp1'),
        title: 'Fast Car',
        artists: const [Artist(name: 'Tracy Chapman')],
        duration: const Duration(seconds: 296),
      ),
      Track(
        providerId: src,
        id: const ProviderTrackId('sp2'),
        title: 'Teardrop',
        artists: const [Artist(name: 'Massive Attack')],
        duration: const Duration(seconds: 330),
      ),
      // Only a cover exists at the destination → must NOT auto-transfer.
      Track(
        providerId: src,
        id: const ProviderTrackId('sp3'),
        title: 'Holocene',
        artists: const [Artist(name: 'Bon Iver')],
        duration: const Duration(seconds: 337),
      ),
      // Nothing remotely similar exists → confirmed miss.
      Track(
        providerId: src,
        id: const ProviderTrackId('sp4'),
        title: 'Ultra Obscure Bootleg',
        artists: const [Artist(name: 'Nobody')],
      ),
    ];

    // Composition-root resolver: matching engine over destination search.
    final matcher = MatchEngine();
    Future<TrackResolution> resolve(Track source) async {
      final outcome = await matcher.match(
        source,
        threshold: MatchThreshold.balanced,
        search: (q) => dst.searchTrack(dstAccount, q).then((r) => r.tracks),
      );
      return switch (outcome.decision) {
        MatchDecision.autoApproved => ResolvedTrack(
          outcome.best!.candidate.id,
          confidence: outcome.best!.score,
        ),
        MatchDecision.needsReview => const ResolutionNeedsReview(),
        MatchDecision.noCandidates => const ResolutionNoMatch(),
      };
    }

    final store = InMemoryJobStore();
    final engine = TransferEngine(
      store: store,
      destination: dst,
      resolver: resolve,
    );
    await engine.planPlaylistTransfer(
      jobId: 'e2e',
      srcAccount: const AccountId('spotify-user'),
      dstAccount: dstAccount,
      spec: const TransferSpec(playlistName: 'Migrated Mix'),
      sourceTracks: sourceTracks,
    );

    final job = await engine.run('e2e');

    // Two clean matches transferred; the cover-only case waits for a
    // human; the bootleg is a confirmed miss.
    expect(job.state, JobState.needsReview);
    final playlistId = job.spec.dstPlaylistId!;
    final transferred = await dst
        .getPlaylistTracks(
          PlaylistRef(
            account: dstAccount,
            playlist: ProviderPlaylistId(playlistId),
          ),
        )
        .map((t) => t.id.value)
        .toList();
    expect(transferred, ['yt-fastcar', 'yt-teardrop']);
    expect(
      transferred,
      isNot(contains('yt-fastcar-live')),
      reason: 'the live trap must lose to the studio recording',
    );
    expect(
      (await store.itemsInStates('e2e', {ItemState.needsReview})).single.seq,
      2,
    );
    expect(
      (await store.itemsInStates('e2e', {ItemState.skipped})).single.seq,
      3,
    );
  });
}
