import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

const _unreserved =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

/// RFC 7636 PKCE verifier/challenge pair (S256 only — plain is forbidden by
/// docs/06 and by every provider we target).
@immutable
class PkcePair {
  const PkcePair._(this.verifier, this.challenge);

  /// Computes the S256 challenge for a given verifier. Public for tests
  /// (RFC 7636 appendix B vector) and for resuming persisted flows.
  factory PkcePair.fromVerifier(String verifier) {
    if (verifier.length < 43 || verifier.length > 128) {
      throw ArgumentError.value(
        verifier.length,
        'verifier',
        'RFC 7636 requires 43–128 characters',
      );
    }
    final digest = sha256.convert(ascii.encode(verifier));
    final challenge = base64UrlEncode(digest.bytes).replaceAll('=', '');
    return PkcePair._(verifier, challenge);
  }

  /// Generates a fresh cryptographically random pair.
  factory PkcePair.generate({Random? random}) {
    final rng = random ?? Random.secure();
    final verifier = String.fromCharCodes(
      Iterable.generate(
        64,
        (_) => _unreserved.codeUnitAt(rng.nextInt(_unreserved.length)),
      ),
    );
    return PkcePair.fromVerifier(verifier);
  }

  final String verifier;
  final String challenge;

  static const String method = 'S256';
}

/// Cryptographically random URL-safe state token (CSRF binding).
String generateStateToken({Random? random}) {
  final rng = random ?? Random.secure();
  final bytes = List<int>.generate(24, (_) => rng.nextInt(256));
  return base64UrlEncode(bytes).replaceAll('=', '');
}
