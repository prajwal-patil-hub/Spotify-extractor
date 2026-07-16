import 'package:core_domain/core_domain.dart';
import 'package:dio/dio.dart';

import 'auth_broker.dart';
import 'auth_session.dart';
import 'oauth_config.dart';
import 'pkce.dart';

/// Executes the authorization-code + PKCE flow (docs/06 §2 sequence) and
/// refresh-token grants. Pure orchestration: the platform user agent lives
/// behind [AuthBroker]; HTTP is injected.
class PkceAuthorizer {
  PkceAuthorizer({
    required this.config,
    required this.provider,
    required Dio httpClient,
    DateTime Function()? clock,
  }) : _http = httpClient,
       _now = clock ?? DateTime.now;

  final OAuthConfig config;

  /// Used only to type errors correctly.
  final ProviderId provider;

  final Dio _http;
  final DateTime Function() _now;

  /// Runs the full interactive flow: browser consent → state check → code
  /// exchange. Throws [AuthExpired] on user denial or a state mismatch.
  Future<AuthSession> authorize(AuthBroker broker) async {
    final pkce = PkcePair.generate();
    final state = generateStateToken();
    final redirectUri = broker.redirectUri;

    final authorizationUrl = config.authorizationEndpoint.replace(
      queryParameters: {
        ...config.authorizationEndpoint.queryParameters,
        'response_type': 'code',
        'client_id': config.clientId,
        'redirect_uri': redirectUri.toString(),
        'scope': config.scopes.join(' '),
        'state': state,
        'code_challenge': pkce.challenge,
        'code_challenge_method': PkcePair.method,
        ...config.extraAuthorizationParameters,
      },
    );

    final callback = await broker.authorize(
      authorizationUrl,
      redirectUri: redirectUri,
    );

    final params = callback.queryParameters;
    if (params['error'] != null) {
      throw AuthExpired(provider, 'authorization denied: ${params['error']}');
    }
    if (params['state'] != state) {
      // A state mismatch is a possible CSRF/redirect-spoof attempt — the
      // code is never exchanged (docs/06 §4).
      throw AuthExpired(provider, 'authorization state mismatch');
    }
    final code = params['code'];
    if (code == null || code.isEmpty) {
      throw ProviderContractViolation(
        provider,
        'authorization callback missing code parameter',
      );
    }

    return _tokenRequest({
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUri.toString(),
      'code_verifier': pkce.verifier,
      'client_id': config.clientId,
    });
  }

  /// Refresh-token grant with rotation support (docs/06 §2): when the
  /// provider returns a new refresh token it replaces the old one; when it
  /// omits one, the previous refresh token is retained.
  Future<AuthSession> refresh(AuthSession session) async {
    final refreshToken = session.refreshToken;
    if (refreshToken == null) {
      throw AuthExpired(provider, 'no refresh token; reconnect required');
    }
    final refreshed = await _tokenRequest({
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
      'client_id': config.clientId,
    });
    return refreshed.refreshToken == null
        ? refreshed.copyWith(refreshToken: refreshToken)
        : refreshed;
  }

  Future<AuthSession> _tokenRequest(Map<String, String> body) async {
    Response<Map<String, Object?>> response;
    try {
      response = await _http.post<Map<String, Object?>>(
        config.tokenEndpoint.toString(),
        data: body,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          // 4xx handled below as typed errors, not thrown as DioException.
          validateStatus: (status) => status != null && status < 500,
        ),
      );
    } on DioException catch (e) {
      throw ProviderUnavailable(
        provider,
        'token endpoint unreachable',
        cause: e.type,
      );
    }

    final data = response.data;
    if (response.statusCode != 200 || data == null) {
      throw AuthExpired(
        provider,
        'token request failed (${response.statusCode}): '
        '${data?['error'] ?? 'unknown'}',
      );
    }

    final accessToken = data['access_token'];
    final expiresIn = data['expires_in'];
    if (accessToken is! String || expiresIn is! int) {
      throw ProviderContractViolation(
        provider,
        'token response missing access_token/expires_in',
      );
    }
    return AuthSession(
      accessToken: accessToken,
      refreshToken: data['refresh_token'] as String?,
      expiresAt: _now().add(Duration(seconds: expiresIn)),
      scopes: switch (data['scope']) {
        final String s when s.isNotEmpty => s.split(' '),
        _ => config.scopes,
      },
      tokenType: data['token_type'] as String? ?? 'Bearer',
    );
  }
}
