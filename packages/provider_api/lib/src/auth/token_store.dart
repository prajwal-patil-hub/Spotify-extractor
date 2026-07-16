import 'auth_session.dart';

/// Custody interface for [AuthSession]s, keyed by an opaque `tokenRef`
/// (the `provider_accounts.token_ref` column, docs/05).
///
/// Production implementations wrap platform secure storage (Keychain,
/// Keystore, DPAPI, libsecret — docs/06 §3) and live in the app shell.
/// Engines and plugins only ever see this interface.
abstract interface class TokenStore {
  Future<AuthSession?> read(String tokenRef);

  Future<void> write(String tokenRef, AuthSession session);

  Future<void> delete(String tokenRef);
}
