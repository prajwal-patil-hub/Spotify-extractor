import 'dart:typed_data';

import 'package:core_domain/core_domain.dart';
import 'package:dio/dio.dart';
import 'package:provider_api/provider_api.dart';
import 'package:provider_spotify/provider_spotify.dart';
import 'package:test/test.dart';
import 'package:testing_toolkit/testing_toolkit.dart';

import 'spotify_api_fake.dart';

const _account = AccountId('user1');

({SpotifyProvider provider, SpotifyApiFake api, InMemoryTokenStore tokens})
_setup({bool sessionExpired = false, int pageSize = 2}) {
  final api = SpotifyApiFake(pageSize: pageSize);
  final tokens = InMemoryTokenStore();
  tokens.write(
    'spotify/user1',
    AuthSession(
      accessToken: 'access-1',
      refreshToken: 'refresh-0',
      expiresAt: sessionExpired
          ? DateTime.now().subtract(const Duration(hours: 1))
          : DateTime.now().add(const Duration(hours: 1)),
    ),
  );
  final provider = SpotifyProvider(
    clientId: 'client-test',
    tokenStore: tokens,
    httpClient: Dio()..httpClientAdapter = api,
    // Generous bucket: tests must never sleep on the governor.
    governor: RateGovernor(capacity: 10000, refillPerSecond: 10000),
  );
  return (provider: provider, api: api, tokens: tokens);
}

void _seedCatalog(SpotifyApiFake api) {
  api
    ..seedTrack('t1', 'Fast Car', 'Tracy Chapman', isrc: 'USEE10180355')
    ..seedTrack('t2', 'Teardrop', 'Massive Attack', isrc: 'GBAAA9800303')
    ..seedTrack('t3', 'Holocene', 'Bon Iver');
}

void main() {
  // The shared behavioral contract, over recorded-style fixtures (docs/12 §4).
  runMusicProviderContractTests('SpotifyProvider (fixtures)', () async {
    final s = _setup();
    _seedCatalog(s.api);
    return ProviderContractContext(
      provider: s.provider,
      account: _account,
      knownTrackIds: const [
        ProviderTrackId('t1'),
        ProviderTrackId('t2'),
        ProviderTrackId('t3'),
      ],
    );
  });

  group('authenticate', () {
    test(
      'full PKCE flow: exchanges code, fetches profile, stores session',
      () async {
        final s = _setup();
        final account = await s.provider.authenticate(FakeAuthBroker());
        expect(account.id, _account);
        expect(account.displayName, 'Test User');
        expect(account.provider.value, 'spotify');
        expect(s.api.tokenGrants, 1);
        final stored = s.tokens.sessions['spotify/user1'];
        expect(stored, isNotNull);
        expect(stored!.accessToken, s.api.validAccessToken);
      },
    );
  });

  group('token lifecycle', () {
    test(
      'expired session is refreshed proactively before the request',
      () async {
        final s = _setup(sessionExpired: true);
        _seedCatalog(s.api);
        s.api.seedPlaylist('A', ['t1']);
        final playlists = await s.provider.getPlaylists(_account).toList();
        expect(playlists, hasLength(1));
        expect(s.api.tokenGrants, 1, reason: 'exactly one refresh');
        expect(
          s.tokens.sessions['spotify/user1']!.accessToken,
          s.api.validAccessToken,
          reason: 'rotated token persisted',
        );
      },
    );

    test('a surprise 401 triggers one refresh and a retry', () async {
      final s = _setup();
      _seedCatalog(s.api);
      s.api
        ..seedPlaylist('A', [])
        ..fail401Times = 1;
      final playlists = await s.provider.getPlaylists(_account).toList();
      expect(playlists, hasLength(1));
      expect(s.api.tokenGrants, 1);
    });

    test('no stored session is AuthExpired', () async {
      final s = _setup();
      await expectLater(
        s.provider.getPlaylists(const AccountId('stranger')).toList(),
        throwsA(isA<AuthExpired>()),
      );
    });

    test('disconnect deletes custody', () async {
      final s = _setup();
      await s.provider.disconnect(_account);
      expect(s.tokens.sessions, isEmpty);
    });
  });

  group('pagination', () {
    test('getPlaylists follows next links across pages', () async {
      final s = _setup(pageSize: 2);
      for (var i = 0; i < 5; i++) {
        s.api.seedPlaylist('P$i', []);
      }
      final names = await s.provider
          .getPlaylists(_account)
          .map((p) => p.name)
          .toList();
      expect(names, ['P0', 'P1', 'P2', 'P3', 'P4']);
      expect(
        s.api.requests.where((r) => r.contains('/v1/me/playlists')).length,
        3,
        reason: '5 items at page size 2 = 3 requests',
      );
    });

    test(
      'getPlaylistTracks parses the items[].track envelope with ISRC',
      () async {
        final s = _setup();
        _seedCatalog(s.api);
        final id = s.api.seedPlaylist('Mix', ['t1', 't2', 't3']);
        final tracks = await s.provider
            .getPlaylistTracks(
              PlaylistRef(account: _account, playlist: ProviderPlaylistId(id)),
            )
            .toList();
        expect(tracks.map((t) => t.title), [
          'Fast Car',
          'Teardrop',
          'Holocene',
        ]);
        expect(tracks.first.isrc, 'USEE10180355');
        expect(tracks.first.album?.title, isNotEmpty);
        expect(tracks.first.duration, const Duration(milliseconds: 200000));
      },
    );
  });

  group('error mapping', () {
    test('429 surfaces as RateLimited with Retry-After', () async {
      final s = _setup();
      s.api
        ..seedPlaylist('A', [])
        ..fail429Times = 1
        ..retryAfterSeconds = 7;
      await expectLater(
        s.provider.getPlaylists(_account).toList(),
        throwsA(
          isA<RateLimited>().having(
            (e) => e.retryAfter,
            'retryAfter',
            const Duration(seconds: 7),
          ),
        ),
      );
    });

    test('5xx surfaces as ProviderUnavailable', () async {
      final s = _setup();
      s.api.fail500Times = 1;
      await expectLater(
        s.provider.getPlaylists(_account).toList(),
        throwsA(isA<ProviderUnavailable>()),
      );
    });
  });

  group('writes', () {
    test('addTracks chunks at 100 and preserves order', () async {
      final s = _setup();
      final id = s.api.seedPlaylist('Big', []);
      final ref = PlaylistRef(
        account: _account,
        playlist: ProviderPlaylistId(id),
      );
      final ids = [for (var i = 0; i < 250; i++) ProviderTrackId('x$i')];
      await s.provider.addTracks(ref, ids);
      final posts = s.api.requests
          .where((r) => r.startsWith('POST /v1/playlists/$id/tracks'))
          .length;
      expect(posts, 3);
      expect(s.api.playlistTracks[id], [for (var i = 0; i < 250; i++) 'x$i']);
    });

    test('replaceTracks over 100 replaces then appends', () async {
      final s = _setup();
      final id = s.api.seedPlaylist('Big', ['old1', 'old2']);
      final ref = PlaylistRef(
        account: _account,
        playlist: ProviderPlaylistId(id),
      );
      await s.provider.replaceTracks(ref, [
        for (var i = 0; i < 150; i++) ProviderTrackId('n$i'),
      ]);
      expect(s.api.playlistTracks[id]!.length, 150);
      expect(s.api.playlistTracks[id]!.first, 'n0');
      expect(s.api.playlistTracks[id]!.last, 'n149');
    });

    test('update maps privacy to the public flag and clears description '
        'with an empty string', () async {
      final s = _setup();
      final id = s.api.seedPlaylist('P', []);
      await s.provider.updatePlaylist(
        PlaylistRef(account: _account, playlist: ProviderPlaylistId(id)),
        const PlaylistPatch(
          privacy: Field.set(PlaylistPrivacy.public),
          description: Field.set(null),
        ),
      );
      expect(s.api.playlists[id]!['public'], true);
      expect(s.api.playlists[id]!['description'], '');
    });
  });

  group('artwork', () {
    final ref = PlaylistRef(
      account: _account,
      playlist: const ProviderPlaylistId('pl1'),
    );

    test('valid JPEG uploads as base64', () async {
      final s = _setup();
      s.api.seedPlaylist('Art', []);
      await s.provider.uploadArtwork(
        ref,
        Artwork(bytes: Uint8List.fromList([1, 2, 3]), mimeType: 'image/jpeg'),
      );
      expect(s.api.writeBodies.last, 'AQID'); // base64 of [1,2,3]
    });

    test('non-JPEG and oversize are rejected locally as '
        'CapabilityUnsupported, no request made', () async {
      final s = _setup();
      s.api.seedPlaylist('Art', []);
      for (final artwork in [
        Artwork(bytes: Uint8List(10), mimeType: 'image/png'),
        Artwork(
          bytes: Uint8List(SpotifyProvider.artworkMaxBytes + 1),
          mimeType: 'image/jpeg',
        ),
      ]) {
        await expectLater(
          s.provider.uploadArtwork(ref, artwork),
          throwsA(isA<CapabilityUnsupported>()),
        );
      }
      expect(s.api.requests.where((r) => r.contains('images')), isEmpty);
    });
  });

  group('search', () {
    test('ISRC queries use the isrc filter and win over text fields', () async {
      final s = _setup();
      _seedCatalog(s.api);
      final result = await s.provider.searchTrack(
        _account,
        const TrackQuery(title: 'Wrong Title', isrc: 'GBAAA9800303'),
      );
      expect(result.tracks.single.title, 'Teardrop');
      expect(s.api.requests.last, contains('isrc%3AGBAAA9800303'));
    });

    test('fielded queries quote title and artist', () async {
      final s = _setup();
      _seedCatalog(s.api);
      final result = await s.provider.searchTrack(
        _account,
        const TrackQuery(title: 'Fast Car', artist: 'Tracy Chapman'),
      );
      expect(result.tracks.single.id.value, 't1');
      expect(s.api.requests.last, contains('track%3A%22Fast+Car%22'));
    });
  });
}
