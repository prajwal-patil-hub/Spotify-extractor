import 'package:provider_api/provider_api.dart';

/// Token custody backed by a map — the TokenStore for every VM test.
class InMemoryTokenStore implements TokenStore {
  final Map<String, AuthSession> _sessions = {};

  @override
  Future<AuthSession?> read(String tokenRef) async => _sessions[tokenRef];

  @override
  Future<void> write(String tokenRef, AuthSession session) async {
    _sessions[tokenRef] = session;
  }

  @override
  Future<void> delete(String tokenRef) async {
    _sessions.remove(tokenRef);
  }

  /// Test-only inspection.
  Map<String, AuthSession> get sessions => Map.unmodifiable(_sessions);
}

/// An [AuthBroker] that "consents" instantly, echoing back the state and a
/// fixed code — the happy-path user for provider auth tests.
class FakeAuthBroker implements AuthBroker {
  FakeAuthBroker({this.code = 'fake-auth-code'});

  final String code;
  Uri? lastAuthorizationUrl;

  @override
  Uri get redirectUri => Uri.parse('http://127.0.0.1:9999/callback');

  @override
  Future<Uri> authorize(
    Uri authorizationUrl, {
    required Uri redirectUri,
  }) async {
    lastAuthorizationUrl = authorizationUrl;
    return redirectUri.replace(
      queryParameters: {
        'code': code,
        'state': authorizationUrl.queryParameters['state'] ?? '',
      },
    );
  }
}
