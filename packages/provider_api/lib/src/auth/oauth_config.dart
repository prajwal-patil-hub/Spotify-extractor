import 'package:meta/meta.dart';

/// Static OAuth endpoints and client identity for one provider.
///
/// Public-client model only (docs/06 §2): there is no client-secret field on
/// purpose — a provider that requires a confidential client needs the
/// (future) backend token broker, not a secret in the binary.
@immutable
class OAuthConfig {
  const OAuthConfig({
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.clientId,
    required this.scopes,
    this.extraAuthorizationParameters = const {},
  });

  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;

  /// Public identifier — not a secret.
  final String clientId;

  /// Least-privilege scope set for the features actually enabled (docs/06).
  final List<String> scopes;

  /// Provider quirks (e.g. `show_dialog`, `access_type=offline`).
  final Map<String, String> extraAuthorizationParameters;
}
