import 'package:core_domain/core_domain.dart';
import 'package:provider_api/provider_api.dart';
import 'package:test/test.dart';
import 'package:testing_toolkit/testing_toolkit.dart';

const _ids = [
  ProviderTrackId('t1'),
  ProviderTrackId('t2'),
  ProviderTrackId('t3'),
];

Track _track(String id, String title, String artist) => Track(
  providerId: const ProviderId('fake'),
  id: ProviderTrackId(id),
  title: title,
  artists: [Artist(name: artist)],
);

void main() {
  // The reference implementation must pass its own contract — this validates
  // the suite itself before any real provider runs it.
  runMusicProviderContractTests('FakeMusicProvider', () async {
    final provider = FakeMusicProvider()
      ..seedCatalog([
        _track('t1', 'Fast Car', 'Tracy Chapman'),
        _track('t2', 'Teardrop', 'Massive Attack'),
        _track('t3', 'Holocene', 'Bon Iver'),
      ]);
    return ProviderContractContext(
      provider: provider,
      account: provider.seedAccount('contract'),
      knownTrackIds: _ids,
    );
  });

  test(
    'a provider with no declared capabilities fails capability calls',
    () async {
      final bare = FakeMusicProvider(
        capabilities: ProviderCapabilities(supported: const {}),
      );
      final account = bare.seedAccount('bare');
      await expectLater(
        bare.getLikedSongs(account).toList(),
        throwsA(isA<CapabilityUnsupported>()),
      );
      await expectLater(
        bare.searchTrack(account, const TrackQuery(title: 'x')),
        throwsA(isA<CapabilityUnsupported>()),
      );
    },
  );
}
