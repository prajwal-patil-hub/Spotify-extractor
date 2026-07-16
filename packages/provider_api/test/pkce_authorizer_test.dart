import 'dart:typed_data';

import 'package:core_domain/core_domain.dart';
import 'package:dio/dio.dart';
import 'package:provider_api/provider_api.dart';
import 'package:test/test.dart';

const _provider = ProviderId('test_provider');

final _config = OAuthConfig(
  authorizationEndpoint: Uri.parse('https://auth.example/authorize'),
  tokenEndpoint: Uri.parse('https://auth.example/api/token'),
  clientId: 'client-123',
  scopes: const ['read', 'write'],
);

/// Broker that simulates the provider redirect. [transform] lets tests
/// tamper with the callback (wrong state, error, missing code).
class _ScriptedBroker implements AuthBroker {
  _ScriptedBroker({this.transform});

  final Map<String, String> Function(Map<String, String> params)? transform;
  Uri? capturedAuthorizationUrl;

  @override
  Uri get redirectUri => Uri.parse('http://127.0.0.1:8912/callback');

  @override
  Future<Uri> authorize(
    Uri authorizationUrl, {
    required Uri redirectUri,
  }) async {
    capturedAuthorizationUrl = authorizationUrl;
    final params = <String, String>{
      'code': 'auth-code-1',
      'state': authorizationUrl.queryParameters['state']!,
    };
    return redirectUri.replace(
      queryParameters: transform?.call(params) ?? params,
    );
  }
}

/// Dio adapter returning a canned token response and capturing the request
/// body, so the exchange can be asserted without a network.
class _TokenEndpointAdapter implements HttpClientAdapter {
  _TokenEndpointAdapter({this.status = 200, Map<String, Object?>? body})
    : body =
          body ??
          {
            'access_token': 'access-1',
            'token_type': 'Bearer',
            'expires_in': 3600,
            'refresh_token': 'refresh-1',
            'scope': 'read write',
          };

  final int status;
  final Map<String, Object?> body;
  String? capturedBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      capturedBody = String.fromCharCodes(chunks.expand((c) => c));
    }
    return ResponseBody.fromString(
      _encode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  String _encode(Map<String, Object?> map) {
    final buffer = StringBuffer('{');
    var first = true;
    map.forEach((k, v) {
      if (!first) buffer.write(',');
      first = false;
      buffer.write('"$k":');
      buffer.write(v is String ? '"$v"' : '$v');
    });
    buffer.write('}');
    return buffer.toString();
  }

  @override
  void close({bool force = false}) {}
}

PkceAuthorizer _authorizer(HttpClientAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return PkceAuthorizer(
    config: _config,
    provider: _provider,
    httpClient: dio,
    clock: () => DateTime.utc(2026, 7, 16, 12),
  );
}

void main() {
  group('authorize', () {
    test('happy path: builds a compliant URL and exchanges the code', () async {
      final broker = _ScriptedBroker();
      final adapter = _TokenEndpointAdapter();
      final session = await _authorizer(adapter).authorize(broker);

      final url = broker.capturedAuthorizationUrl!;
      final q = url.queryParameters;
      expect(q['response_type'], 'code');
      expect(q['client_id'], 'client-123');
      expect(q['code_challenge_method'], 'S256');
      expect(q['code_challenge'], isNotEmpty);
      expect(q['state'], isNotEmpty);
      expect(q['scope'], 'read write');
      expect(q['redirect_uri'], broker.redirectUri.toString());

      // Code exchange carried the verifier and no client secret.
      expect(adapter.capturedBody, contains('grant_type=authorization_code'));
      expect(adapter.capturedBody, contains('code=auth-code-1'));
      expect(adapter.capturedBody, contains('code_verifier='));
      expect(adapter.capturedBody, isNot(contains('client_secret')));

      expect(session.accessToken, 'access-1');
      expect(session.refreshToken, 'refresh-1');
      expect(session.expiresAt, DateTime.utc(2026, 7, 16, 13));
    });

    test('state mismatch is rejected without exchanging the code', () async {
      final adapter = _TokenEndpointAdapter();
      final broker = _ScriptedBroker(
        transform: (p) => {...p, 'state': 'forged'},
      );
      await expectLater(
        _authorizer(adapter).authorize(broker),
        throwsA(isA<AuthExpired>()),
      );
      expect(
        adapter.capturedBody,
        isNull,
        reason: 'code must never be exchanged after a state mismatch',
      );
    });

    test('user denial surfaces as AuthExpired', () async {
      final broker = _ScriptedBroker(
        transform: (p) => {'error': 'access_denied', 'state': p['state']!},
      );
      await expectLater(
        _authorizer(_TokenEndpointAdapter()).authorize(broker),
        throwsA(isA<AuthExpired>()),
      );
    });

    test('malformed token response is a contract violation', () async {
      final adapter = _TokenEndpointAdapter(body: {'unexpected': 'shape'});
      await expectLater(
        _authorizer(adapter).authorize(_ScriptedBroker()),
        throwsA(isA<ProviderContractViolation>()),
      );
    });
  });

  group('refresh', () {
    test(
      'rotates the refresh token when the provider returns a new one',
      () async {
        final adapter = _TokenEndpointAdapter();
        final session = AuthSession(
          accessToken: 'old',
          refreshToken: 'old-refresh',
          expiresAt: DateTime.utc(2026),
        );
        final refreshed = await _authorizer(adapter).refresh(session);
        expect(refreshed.refreshToken, 'refresh-1');
        expect(adapter.capturedBody, contains('grant_type=refresh_token'));
        expect(adapter.capturedBody, contains('refresh_token=old-refresh'));
      },
    );

    test('keeps the old refresh token when the provider omits one', () async {
      final adapter = _TokenEndpointAdapter(
        body: {
          'access_token': 'new-access',
          'token_type': 'Bearer',
          'expires_in': 3600,
        },
      );
      final session = AuthSession(
        accessToken: 'old',
        refreshToken: 'keep-me',
        expiresAt: DateTime.utc(2026),
      );
      final refreshed = await _authorizer(adapter).refresh(session);
      expect(refreshed.accessToken, 'new-access');
      expect(refreshed.refreshToken, 'keep-me');
    });

    test('missing refresh token means reconnect', () async {
      final session = AuthSession(
        accessToken: 'old',
        expiresAt: DateTime.utc(2026),
      );
      await expectLater(
        _authorizer(_TokenEndpointAdapter()).refresh(session),
        throwsA(isA<AuthExpired>()),
      );
    });

    test(
      'a 400 from the token endpoint is AuthExpired (revoked grant)',
      () async {
        final adapter = _TokenEndpointAdapter(
          status: 400,
          body: {'error': 'invalid_grant'},
        );
        final session = AuthSession(
          accessToken: 'old',
          refreshToken: 'revoked',
          expiresAt: DateTime.utc(2026),
        );
        await expectLater(
          _authorizer(adapter).refresh(session),
          throwsA(isA<AuthExpired>()),
        );
      },
    );
  });
}
