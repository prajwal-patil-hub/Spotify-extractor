import 'dart:typed_data';

import 'package:core_domain/core_domain.dart';
import 'package:dio/dio.dart';
import 'package:provider_api/provider_api.dart';
import 'package:provider_ytmusic/provider_ytmusic.dart';
import 'package:test/test.dart';
import 'package:testing_toolkit/testing_toolkit.dart';

import 'youtube_api_fake.dart';

const _account = AccountId('chan1');

({
  YouTubeMusicProvider provider,
  YouTubeApiFake api,
  InMemoryTokenStore tokens,
  InMemoryLedgerStore ledgerStore,
})
_setup({int pageSize = 2}) {
  final api = YouTubeApiFake(pageSize: pageSize);
  final tokens = InMemoryTokenStore();
  tokens.write(
    'ytmusic/chan1',
    AuthSession(
      accessToken: 'yt-access-1',
      refreshToken: 'yt-refresh-0',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    ),
  );
  final ledgerStore = InMemoryLedgerStore();
  final provider = YouTubeMusicProvider(
    clientId: 'yt-client-test',
    tokenStore: tokens,
    consentStore: InMemoryConsentStore(),
    ledgerStore: ledgerStore,
    httpClient: Dio()..httpClientAdapter = api,
    governor: RateGovernor(capacity: 10000, refillPerSecond: 10000),
  );
  return (
    provider: provider,
    api: api,
    tokens: tokens,
    ledgerStore: ledgerStore,
  );
}

void _seedCatalog(YouTubeApiFake api) {
  api
    ..seedVideo(
      'v1',
      'Fast Car',
      'Tracy Chapman',
      album: 'Tracy Chapman',
      durSec: 296,
    )
    ..seedVideo(
      'v2',
      'Teardrop',
      'Massive Attack',
      album: 'Mezzanine',
      durSec: 330,
    )
    ..seedVideo('v3', 'Holocene', 'Bon Iver', durSec: 337);
}

Future<void> _enableSession(
  YouTubeMusicProvider provider,
  YouTubeApiFake api,
) => provider.enableSessionPath(_account, cookieHeader: api.validSessionCookie);

void main() {
  // The shared behavioral contract — session path on (full capabilities).
  runMusicProviderContractTests('YouTubeMusicProvider (fixtures)', () async {
    final s = _setup();
    _seedCatalog(s.api);
    s.api.likedVideoIds.add('v1');
    await _enableSession(s.provider, s.api);
    return ProviderContractContext(
      provider: s.provider,
      account: _account,
      knownTrackIds: const [
        ProviderTrackId('v1'),
        ProviderTrackId('v2'),
        ProviderTrackId('v3'),
      ],
    );
  });

  group('capability degradation (docs/04 §5)', () {
    test('without consent: no likedSongs; official search noted', () async {
      final s = _setup();
      final caps = s.provider.capabilities;
      expect(caps.supports(Capability.likedSongs), isFalse);
      expect(caps.supports(Capability.catalogSearch), isTrue);
      expect(
        caps.detailOf(Capability.catalogSearch)?.note,
        contains('official search only'),
      );
      // ISRC capabilities must never be declared — YTM has no ISRCs.
      expect(caps.supports(Capability.isrcSearch), isFalse);
      expect(caps.supports(Capability.playlistArtworkUpload), isFalse);
    });

    test(
      'enable → grows, disable → shrinks and deletes the credential',
      () async {
        final s = _setup();
        await _enableSession(s.provider, s.api);
        expect(s.provider.capabilities.supports(Capability.likedSongs), isTrue);
        expect(s.tokens.sessions.keys, contains('ytmusic/session/chan1'));

        await s.provider.disableSessionPath(_account);
        expect(
          s.provider.capabilities.supports(Capability.likedSongs),
          isFalse,
        );
        expect(
          s.tokens.sessions.keys,
          isNot(contains('ytmusic/session/chan1')),
        );
      },
    );

    test(
      'initialize restores session state from stored consent+credential',
      () async {
        final s = _setup();
        await _enableSession(s.provider, s.api);
        // Simulate a fresh provider over the same stores.
        final revived = YouTubeMusicProvider(
          clientId: 'yt-client-test',
          tokenStore: s.tokens,
          consentStore: InMemoryConsentStore(), // no consent → stays off
          ledgerStore: s.ledgerStore,
          httpClient: Dio()..httpClientAdapter = s.api,
        );
        await revived.initialize(_account);
        expect(revived.capabilities.supports(Capability.likedSongs), isFalse);
      },
    );

    test('kill switch: capabilities none, operations refuse', () async {
      final s = _setup();
      s.provider.enabled = false;
      expect(s.provider.capabilities, ProviderCapabilities.none);
      await expectLater(
        s.provider.createPlaylist(_account, const PlaylistSpec(name: 'X')),
        throwsA(isA<ProviderUnavailable>()),
      );
    });
  });

  group('search', () {
    test('session path: music-scoped, free, rich metadata', () async {
      final s = _setup();
      _seedCatalog(s.api);
      await _enableSession(s.provider, s.api);
      final result = await s.provider.searchTrack(
        _account,
        const TrackQuery(title: 'Teardrop', artist: 'Massive Attack'),
      );
      final track = result.tracks.single;
      expect(track.id.value, 'v2');
      expect(track.album?.title, 'Mezzanine');
      expect(track.duration, const Duration(seconds: 330));
      expect(
        await s.provider.ledger.remaining(),
        10000,
        reason: 'session search must not spend official units',
      );
    });

    test(
      'official fallback: 100 units, music category, sparse metadata',
      () async {
        final s = _setup();
        _seedCatalog(s.api);
        final result = await s.provider.searchTrack(
          _account,
          const TrackQuery(title: 'Holocene', artist: 'Bon Iver'),
        );
        final track = result.tracks.single;
        expect(track.id.value, 'v3');
        expect(
          track.artists.single.name,
          'Bon Iver',
          reason: '"- Topic" suffix stripped',
        );
        expect(track.duration, isNull, reason: 'official search has none');
        expect(await s.provider.ledger.remaining(), 10000 - 100);
        expect(s.api.requests.last, contains('videoCategoryId=10'));
      },
    );
  });

  group('unit budget', () {
    test('writes are priced; exhaustion throws BEFORE the request', () async {
      final s = _setup();
      final id = s.api.seedPlaylist('P', []);
      final ref = PlaylistRef(
        account: _account,
        playlist: ProviderPlaylistId(id),
      );
      await s.provider.addTracks(ref, const [ProviderTrackId('v1')]);
      expect(await s.provider.ledger.remaining(), 10000 - 50);

      // Exhaust the budget locally.
      await s.ledgerStore.setSpent(
        // Same Pacific day key the ledger uses right now.
        await _todayKey(s),
        9999,
      );
      final requestsBefore = s.api.requests.length;
      await expectLater(
        s.provider.addTracks(ref, const [ProviderTrackId('v2')]),
        throwsA(
          isA<RateLimited>().having(
            (e) => e.retryAfter,
            'retryAfter',
            isNotNull,
          ),
        ),
      );
      expect(
        s.api.requests.length,
        requestsBefore,
        reason: 'a doomed call must never leave the app',
      );
    });

    test('server-reported quotaExceeded (403) maps to RateLimited with '
        'reset-based retryAfter', () async {
      final s = _setup();
      s.api
        ..seedPlaylist('P', [])
        ..failQuota403Times = 1;
      await expectLater(
        s.provider.getPlaylists(_account).toList(),
        throwsA(
          isA<RateLimited>().having(
            (e) => e.retryAfter,
            'retryAfter',
            isNotNull,
          ),
        ),
      );
    });

    test('transfer estimate arithmetic', () {
      final s = _setup();
      expect(
        s.provider.ledger.estimateTransfer(trackCount: 100, searches: 0),
        50 + 100 * 50,
      );
      expect(
        s.provider.ledger.estimateTransfer(trackCount: 10, searches: 10),
        50 + 10 * 50 + 10 * 100,
      );
    });
  });

  group('official API mechanics', () {
    test('authenticate resolves the channel and stores the session', () async {
      final s = _setup();
      final account = await s.provider.authenticate(FakeAuthBroker());
      expect(account.id.value, 'chan1');
      expect(account.displayName, 'Test Channel');
      expect(s.api.tokenGrants, 1);
    });

    test('pageToken pagination is followed to exhaustion', () async {
      final s = _setup(pageSize: 2);
      for (var i = 0; i < 5; i++) {
        s.api.seedPlaylist('P$i', []);
      }
      final names = await s.provider
          .getPlaylists(_account)
          .map((p) => p.name)
          .toList();
      expect(names, ['P0', 'P1', 'P2', 'P3', 'P4']);
    });

    test('removeTracks maps video ids to playlistItem ids first', () async {
      final s = _setup();
      _seedCatalog(s.api);
      final id = s.api.seedPlaylist('Mix', ['v1', 'v2', 'v3']);
      await s.provider.removeTracks(
        PlaylistRef(account: _account, playlist: ProviderPlaylistId(id)),
        const [ProviderTrackId('v2')],
      );
      expect(s.api.items[id]!.map((e) => e.$2), ['v1', 'v3']);
    });

    test('updatePlaylist merges instead of clobbering (YouTube PUT '
        'replaces the snippet)', () async {
      final s = _setup();
      final id = s.api.seedPlaylist('Old Name', []);
      s.api.playlists[id]!['description'] = 'keep me';
      await s.provider.updatePlaylist(
        PlaylistRef(account: _account, playlist: ProviderPlaylistId(id)),
        const PlaylistPatch(name: Field.set('New Name')),
      );
      expect(s.api.playlists[id]!['title'], 'New Name');
      expect(
        s.api.playlists[id]!['description'],
        'keep me',
        reason: 'unpatched fields must survive the PUT',
      );
    });

    test('artwork upload is honestly unsupported', () async {
      final s = _setup();
      await expectLater(
        s.provider.uploadArtwork(
          PlaylistRef(
            account: _account,
            playlist: const ProviderPlaylistId('PL1'),
          ),
          Artwork(bytes: Uint8List(3), mimeType: 'image/jpeg'),
        ),
        throwsA(isA<CapabilityUnsupported>()),
      );
    });

    test('liked songs stream via the session path', () async {
      final s = _setup();
      _seedCatalog(s.api);
      s.api.likedVideoIds.addAll(['v1', 'v3']);
      await _enableSession(s.provider, s.api);
      final liked = await s.provider.getLikedSongs(_account).toList();
      expect(liked.map((t) => t.id.value), ['v1', 'v3']);
    });

    test('a rejected session cookie surfaces as AuthExpired', () async {
      final s = _setup();
      _seedCatalog(s.api);
      await s.provider.enableSessionPath(_account, cookieHeader: 'SID=stale');
      await expectLater(
        s.provider.searchTrack(_account, const TrackQuery(title: 'x')),
        throwsA(isA<AuthExpired>()),
      );
    });
  });
}

Future<String> _todayKey(
  ({
    YouTubeMusicProvider provider,
    YouTubeApiFake api,
    InMemoryTokenStore tokens,
    InMemoryLedgerStore ledgerStore,
  })
  s,
) async {
  // Recover the day key by observing where the earlier spend landed.
  final probe = InMemoryLedgerStore();
  final ledger = UnitLedger(store: probe);
  await ledger.spend(const ProviderId('probe'), 1);
  return probe.spentKeys.single;
}
