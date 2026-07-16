import 'package:meta/meta.dart';

/// An OAuth token set for one connected account.
///
/// Lives only in a [TokenStore] (platform secure storage in production) —
/// never in the operational database and never in logs (docs/06).
@immutable
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.expiresAt,
    this.refreshToken,
    this.scopes = const [],
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final DateTime expiresAt;
  final String? refreshToken;
  final List<String> scopes;
  final String tokenType;

  /// Proactive-refresh window (docs/06 §2): treat as expired two minutes
  /// early so a token never dies mid-request.
  bool isExpired(DateTime now) =>
      !now.add(const Duration(minutes: 2)).isBefore(expiresAt);

  AuthSession copyWith({
    String? accessToken,
    DateTime? expiresAt,
    String? refreshToken,
    List<String>? scopes,
  }) => AuthSession(
    accessToken: accessToken ?? this.accessToken,
    expiresAt: expiresAt ?? this.expiresAt,
    refreshToken: refreshToken ?? this.refreshToken,
    scopes: scopes ?? this.scopes,
    tokenType: tokenType,
  );

  Map<String, Object?> toJson() => {
    'access_token': accessToken,
    'expires_at': expiresAt.toUtc().toIso8601String(),
    if (refreshToken != null) 'refresh_token': refreshToken,
    'scopes': scopes,
    'token_type': tokenType,
  };

  factory AuthSession.fromJson(Map<String, Object?> json) => AuthSession(
    accessToken: json['access_token']! as String,
    expiresAt: DateTime.parse(json['expires_at']! as String),
    refreshToken: json['refresh_token'] as String?,
    scopes: [...(json['scopes'] as List? ?? const []).cast<String>()],
    tokenType: json['token_type'] as String? ?? 'Bearer',
  );

  /// Deliberately redacted — an AuthSession must never leak tokens via
  /// interpolation into logs or error messages.
  @override
  String toString() =>
      'AuthSession(expiresAt: $expiresAt, scopes: ${scopes.length})';
}
