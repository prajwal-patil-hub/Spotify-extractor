import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_engine/job_engine.dart';
import 'package:matching_engine/matching_engine.dart';
import 'package:provider_api/provider_api.dart';
import 'package:testing_toolkit/testing_toolkit.dart';

import '../design_system/themes.dart';

/// The composition root (docs/04 §6): the ONE place providers, engines,
/// and stores meet. Today it boots in demo mode — the full pipeline over
/// in-memory fake providers — so every flow is real and testable before
/// OAuth client IDs are configured. Real mode swaps the two provider
/// constructions and the JobStore for their production implementations;
/// nothing else changes.
class AppServices {
  AppServices._({
    required this.registry,
    required this.accounts,
    required this.jobStore,
    required this.matcher,
  });

  factory AppServices.demo() {
    const spotifyId = ProviderId('spotify');
    const ytmId = ProviderId('ytmusic');

    Track track(ProviderId p, String prefix, int i, {String? qualifier}) =>
        Track(
          providerId: p,
          id: ProviderTrackId('$prefix$i'),
          title: 'Song $i${qualifier ?? ''}',
          artists: [Artist(name: 'Artist ${i % 7}')],
          album: Album(title: 'Album ${i % 4}'),
          duration: Duration(seconds: 180 + i * 3),
        );

    final spotify = FakeMusicProvider(id: spotifyId)
      ..seedCatalog([for (var i = 0; i < 40; i++) track(spotifyId, 's', i)]);
    final ytm =
        FakeMusicProvider(
          id: ytmId,
          capabilities: ProviderCapabilities(
            // YTM-shaped: no artwork upload — the wizard must adapt.
            supported: {
              Capability.catalogSearch,
              Capability.likedSongs,
              Capability.playlistDescription,
              Capability.playlistPrivacy,
            },
          ),
        )..seedCatalog([
          for (var i = 0; i < 34; i++) track(ytmId, 'd', i),
          // A couple of traps so the review queue has real content.
          track(ytmId, 'live', 35, qualifier: ' (Live)'),
          track(ytmId, 'live', 36, qualifier: ' (Live)'),
        ]);

    final spAccount = spotify.seedAccount('demo');
    final ytAccount = ytm.seedAccount('demo');

    return AppServices._(
      registry: ProviderRegistry([spotify, ytm]),
      accounts: {spotifyId: spAccount, ytmId: ytAccount},
      jobStore: InMemoryJobStore(),
      matcher: MatchEngine(),
    );
  }

  final ProviderRegistry registry;
  final Map<ProviderId, AccountId> accounts;
  final JobStore jobStore;
  final MatchEngine matcher;

  /// Wires the matching engine over the destination's search — the same
  /// resolver shape the engine tests rehearse (docs/04 §3).
  TrackResolver resolverFor(MusicProvider destination, AccountId account) =>
      (Track source) async {
        final outcome = await matcher.match(
          source,
          threshold: MatchThreshold.balanced,
          isrcSearchSupported: destination.capabilities.supports(
            Capability.isrcSearch,
          ),
          search: (q) =>
              destination.searchTrack(account, q).then((r) => r.tracks),
        );
        return switch (outcome.decision) {
          MatchDecision.autoApproved => ResolvedTrack(
            outcome.best!.candidate.id,
            confidence: outcome.best!.score,
          ),
          MatchDecision.needsReview => const ResolutionNeedsReview(),
          MatchDecision.noCandidates => const ResolutionNoMatch(),
        };
      };

  TransferEngine engineFor(MusicProvider destination, AccountId account) =>
      TransferEngine(
        store: jobStore,
        destination: destination,
        resolver: resolverFor(destination, account),
      );
}

final servicesProvider = Provider<AppServices>((ref) => AppServices.demo());

final themeProvider = StateProvider<BridgetuneTheme>(
  (ref) => BridgetuneTheme.dark,
);

/// Bumped after every job mutation so job-reading widgets refresh.
final jobsRevisionProvider = StateProvider<int>((ref) => 0);

final jobsProvider = FutureProvider<List<JobRecord>>((ref) async {
  ref.watch(jobsRevisionProvider);
  return ref
      .watch(servicesProvider)
      .jobStore
      .jobsInStates(JobState.values.toSet());
});
