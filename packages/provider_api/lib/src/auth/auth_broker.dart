/// Platform-specific user-agent handling for OAuth, abstracted so the PKCE
/// flow itself stays pure and testable.
///
/// Implementations (arriving with the app shell, docs/06 §2):
/// - mobile: system browser + custom-scheme/app-link redirect
/// - desktop: system browser + loopback `http://127.0.0.1:{port}/callback`
/// - web: full-page redirect
/// - tests: `FakeAuthBroker` in testing_toolkit
abstract interface class AuthBroker {
  /// Opens [authorizationUrl] in the platform user agent and completes with
  /// the full redirect URI (including query parameters) once the provider
  /// redirects back to [redirectUri].
  ///
  /// Implementations must never use an embedded WebView.
  Future<Uri> authorize(Uri authorizationUrl, {required Uri redirectUri});

  /// The redirect URI this platform can receive (scheme/loopback/route).
  Uri get redirectUri;
}
