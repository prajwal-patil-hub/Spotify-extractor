import 'package:provider_api/provider_api.dart';
import 'package:test/test.dart';

void main() {
  group('PkcePair', () {
    test('matches the RFC 7636 appendix B test vector', () {
      final pair = PkcePair.fromVerifier(
        'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk',
      );
      expect(pair.challenge, 'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM');
    });

    test('rejects verifiers outside RFC length bounds', () {
      expect(() => PkcePair.fromVerifier('short'), throwsArgumentError);
      expect(() => PkcePair.fromVerifier('a' * 129), throwsArgumentError);
    });

    test('generates unique, well-formed pairs', () {
      final a = PkcePair.generate();
      final b = PkcePair.generate();
      expect(a.verifier, isNot(b.verifier));
      expect(a.verifier.length, 64);
      // Challenge is unpadded base64url of a SHA-256 digest: 43 chars.
      expect(a.challenge.length, 43);
      expect(a.challenge, isNot(contains('=')));
    });
  });

  group('AuthSession', () {
    final now = DateTime.utc(2026, 7, 16, 12);

    test('proactive expiry window is two minutes', () {
      final session = AuthSession(
        accessToken: 'tok',
        expiresAt: now.add(const Duration(minutes: 3)),
      );
      expect(session.isExpired(now), isFalse);
      expect(
        session.isExpired(now.add(const Duration(minutes: 1))),
        isTrue,
        reason: 'expires in 2 min → inside the proactive window',
      );
    });

    test('JSON round-trip preserves everything', () {
      final session = AuthSession(
        accessToken: 'access',
        refreshToken: 'refresh',
        expiresAt: now,
        scopes: const ['a', 'b'],
      );
      final restored = AuthSession.fromJson(session.toJson());
      expect(restored.accessToken, 'access');
      expect(restored.refreshToken, 'refresh');
      expect(restored.expiresAt, now);
      expect(restored.scopes, ['a', 'b']);
    });

    test('toString never contains token material', () {
      final session = AuthSession(
        accessToken: 'SECRET_ACCESS',
        refreshToken: 'SECRET_REFRESH',
        expiresAt: now,
      );
      expect('$session', isNot(contains('SECRET')));
    });
  });
}
