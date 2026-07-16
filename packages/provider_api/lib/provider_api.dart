/// The provider port and shared plugin substrate.
///
/// Everything a streaming-service plugin needs to implement and nothing it
/// must not see: the [MusicProvider] interface, auth machinery, token
/// custody, and rate governance. Depends only on core_domain.
library;

export 'src/auth/auth_broker.dart';
export 'src/auth/auth_session.dart';
export 'src/auth/oauth_config.dart';
export 'src/auth/pkce.dart';
export 'src/auth/pkce_authorizer.dart';
export 'src/auth/token_store.dart';
export 'src/music_provider.dart';
export 'src/provider_registry.dart';
export 'src/rate_governor.dart';
