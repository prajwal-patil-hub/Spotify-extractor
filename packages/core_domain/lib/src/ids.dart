/// Strongly typed identifiers.
///
/// Extension types make these zero-cost at runtime while preventing the
/// classic bug of passing a playlist id where a track id is expected, or a
/// Spotify id to a YouTube Music call. Core never defines id *values* for
/// concrete providers — each plugin declares its own [ProviderId].
library;

/// Identifies a streaming provider plugin (e.g. declared by the plugin as
/// `ProviderId('spotify')`). Core treats it as opaque.
extension type const ProviderId(String value) {
  bool get isValid => value.isNotEmpty;
}

/// Identifies one connected account at one provider. A user may connect
/// multiple accounts per provider; there is no "current account" global.
extension type const AccountId(String value) {}

/// A track id in a provider's namespace. Only meaningful together with the
/// [ProviderId] it came from.
extension type const ProviderTrackId(String value) {}

/// A playlist id in a provider's namespace.
extension type const ProviderPlaylistId(String value) {}

/// An album id in a provider's namespace.
extension type const ProviderAlbumId(String value) {}

/// An artist id in a provider's namespace.
extension type const ProviderArtistId(String value) {}
