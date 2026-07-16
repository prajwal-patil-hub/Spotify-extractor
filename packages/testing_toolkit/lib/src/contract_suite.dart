import 'package:core_domain/core_domain.dart';
import 'package:provider_api/provider_api.dart';
import 'package:test/test.dart';

/// Everything the contract suite needs from a concrete provider setup.
class ProviderContractContext {
  ProviderContractContext({
    required this.provider,
    required this.account,
    required this.knownTrackIds,
  }) : assert(
         knownTrackIds.length >= 3,
         'contract suite needs at least three known catalog tracks',
       );

  final MusicProvider provider;

  /// A connected, authorized account (real sandbox or seeded fake).
  final AccountId account;

  /// Track ids that exist in the provider's catalog, addable to playlists.
  final List<ProviderTrackId> knownTrackIds;
}

/// The behavioral contract every `MusicProvider` implementation must pass
/// (docs/12 §4). Run it in each provider package:
///
/// ```dart
/// runMusicProviderContractTests('SpotifyProvider (fixtures)', () async => …);
/// ```
///
/// The same suite runs against recorded fixtures on PRs and live sandbox
/// accounts nightly — a nightly-only failure means provider API drift.
void runMusicProviderContractTests(
  String describe,
  Future<ProviderContractContext> Function() createContext,
) {
  group('MusicProvider contract — $describe', () {
    late ProviderContractContext ctx;
    late MusicProvider provider;
    late AccountId account;

    setUp(() async {
      ctx = await createContext();
      provider = ctx.provider;
      account = ctx.account;
    });

    Future<PlaylistRef> create(String name) async {
      final playlist = await provider.createPlaylist(
        account,
        PlaylistSpec(name: name),
      );
      return PlaylistRef(account: account, playlist: playlist.id);
    }

    test('created playlist appears in getPlaylists with its name', () async {
      await create('Contract A');
      final names = await provider
          .getPlaylists(account)
          .map((p) => p.name)
          .toList();
      expect(names, contains('Contract A'));
    });

    test(
      'addTracks preserves order and getPlaylistTracks returns them',
      () async {
        final ref = await create('Contract Order');
        await provider.addTracks(ref, ctx.knownTrackIds.take(3).toList());
        final ids = await provider
            .getPlaylistTracks(ref)
            .map((t) => t.id)
            .toList();
        expect(ids, ctx.knownTrackIds.take(3).toList());
      },
    );

    test('replaceTracks swaps content atomically', () async {
      final ref = await create('Contract Replace');
      await provider.addTracks(ref, [ctx.knownTrackIds[0]]);
      await provider.replaceTracks(ref, [
        ctx.knownTrackIds[1],
        ctx.knownTrackIds[2],
      ]);
      final ids = await provider
          .getPlaylistTracks(ref)
          .map((t) => t.id)
          .toList();
      expect(ids, [ctx.knownTrackIds[1], ctx.knownTrackIds[2]]);
    });

    test('removeTracks removes exactly the given tracks', () async {
      final ref = await create('Contract Remove');
      await provider.addTracks(ref, ctx.knownTrackIds.take(3).toList());
      await provider.removeTracks(ref, [ctx.knownTrackIds[1]]);
      final ids = await provider
          .getPlaylistTracks(ref)
          .map((t) => t.id)
          .toList();
      expect(ids, [ctx.knownTrackIds[0], ctx.knownTrackIds[2]]);
    });

    test('updatePlaylist renames without touching unset fields', () async {
      final ref = await create('Contract Rename');
      await provider.updatePlaylist(
        ref,
        const PlaylistPatch(name: Field.set('Renamed')),
      );
      final playlist = await provider
          .getPlaylists(account)
          .firstWhere((p) => p.id == ref.playlist);
      expect(playlist.name, 'Renamed');
    });

    test('deletePlaylist removes it from getPlaylists', () async {
      final ref = await create('Contract Delete');
      await provider.deletePlaylist(ref);
      final ids = await provider
          .getPlaylists(account)
          .map((p) => p.id)
          .toList();
      expect(ids, isNot(contains(ref.playlist)));
    });

    test('operations on a nonexistent playlist throw NotFound', () async {
      final ghost = PlaylistRef(
        account: account,
        playlist: const ProviderPlaylistId('does-not-exist'),
      );
      await expectLater(
        provider.getPlaylistTracks(ghost).toList(),
        throwsA(isA<NotFound>()),
      );
    });

    test('capability honesty: undeclared capabilities throw, declared ones '
        'do not throw CapabilityUnsupported', () async {
      final caps = provider.capabilities;
      if (!caps.supports(Capability.likedSongs)) {
        await expectLater(
          provider.getLikedSongs(account).toList(),
          throwsA(isA<CapabilityUnsupported>()),
        );
      } else {
        await provider.getLikedSongs(account).toList();
      }
      if (!caps.supports(Capability.savedAlbums)) {
        await expectLater(
          provider.getAlbums(account).toList(),
          throwsA(isA<CapabilityUnsupported>()),
        );
      }
      if (!caps.supports(Capability.followedArtists)) {
        await expectLater(
          provider.getArtists(account).toList(),
          throwsA(isA<CapabilityUnsupported>()),
        );
      }
    });

    test('search by known catalog content returns typed tracks', () async {
      if (!provider.capabilities.supports(Capability.catalogSearch)) return;
      final ref = await create('Contract Search Seed');
      await provider.addTracks(ref, [ctx.knownTrackIds.first]);
      final seeded = await provider.getPlaylistTracks(ref).first;
      final result = await provider.searchTrack(
        account,
        TrackQuery(title: seeded.title, artist: seeded.primaryArtist?.name),
      );
      expect(result.tracks, isNotEmpty);
      expect(result.tracks.map((t) => t.id), contains(seeded.id));
    });
  });
}
