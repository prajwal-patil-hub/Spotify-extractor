import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

void main() {
  const provider = ProviderId('test_provider');

  Track buildTrack({String title = 'Fast Car'}) => Track(
    providerId: provider,
    id: const ProviderTrackId('t1'),
    title: title,
    artists: const [Artist(name: 'Tracy Chapman')],
    album: const Album(title: 'Tracy Chapman', releaseYear: 1988),
    duration: const Duration(minutes: 4, seconds: 56),
    isrc: 'USEE10180355',
    explicit: false,
  );

  group('Track', () {
    test('value equality including artist list', () {
      expect(buildTrack(), buildTrack());
      expect(buildTrack().hashCode, buildTrack().hashCode);
      expect(buildTrack(), isNot(buildTrack(title: 'Fast Car (Live)')));
    });

    test('primaryArtist is the first listed artist, null when empty', () {
      expect(buildTrack().primaryArtist?.name, 'Tracy Chapman');
      const orphan = Track(
        providerId: provider,
        id: ProviderTrackId('t2'),
        title: 'Untitled',
        artists: [],
      );
      expect(orphan.primaryArtist, isNull);
    });

    test('unknown metadata stays unknown — no fabricated defaults', () {
      const sparse = Track(
        providerId: provider,
        id: ProviderTrackId('t3'),
        title: 'Mystery',
        artists: [Artist(name: 'Unknown')],
      );
      expect(sparse.isrc, isNull);
      expect(sparse.explicit, isNull);
      expect(sparse.duration, isNull);
    });
  });

  group('PlaylistPatch / Field', () {
    test('keep vs set vs clear are three distinct states', () {
      const untouched = PlaylistPatch();
      expect(untouched.isEmpty, isTrue);

      const renamed = PlaylistPatch(name: Field.set('New Name'));
      expect(renamed.isEmpty, isFalse);
      expect(renamed.name.resolve('Old Name'), 'New Name');
      expect(renamed.description.resolve('desc'), 'desc');

      const cleared = PlaylistPatch(description: Field.set(null));
      expect(cleared.description.isSet, isTrue);
      expect(cleared.description.resolve('old description'), isNull);
    });

    test('Field value equality', () {
      expect(const Field<String>.keep(), const Field<String>.keep());
      expect(const Field<String>.set('a'), const Field<String>.set('a'));
      expect(const Field<String>.set('a'), isNot(const Field<String>.set('b')));
      expect(const Field<String>.set('a'), isNot(const Field<String>.keep()));
    });
  });

  group('typed ids', () {
    test('extension types prevent cross-namespace mixups at compile time', () {
      // Runtime sanity only — the real guarantee is that
      // `ProviderTrackId('x') == ProviderPlaylistId('x')` fails to compile.
      const track = ProviderTrackId('abc');
      expect(track.value, 'abc');
      expect(const ProviderId('p').isValid, isTrue);
      expect(const ProviderId('').isValid, isFalse);
    });
  });

  group('errors', () {
    test('sealed hierarchy switches exhaustively over provider errors', () {
      String policy(ProviderError e) => switch (e) {
        RateLimited() => 'defer',
        AuthExpired() => 'pause-job',
        ProviderUnavailable() => 'backoff',
        NotFound() => 'fail-item',
        CapabilityUnsupported() => 'fail-item',
        ProviderContractViolation() => 'fail-item+alarm',
      };

      expect(
        policy(
          const RateLimited(
            provider,
            'slow down',
            retryAfter: Duration(seconds: 30),
          ),
        ),
        'defer',
      );
      expect(policy(const AuthExpired(provider, 'token dead')), 'pause-job');
      expect(
        policy(
          const CapabilityUnsupported(
            provider,
            'no artwork',
            Capability.playlistArtworkUpload,
          ),
        ),
        'fail-item',
      );
    });
  });
}
