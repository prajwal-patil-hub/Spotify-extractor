import 'package:core_domain/core_domain.dart';

import 'music_provider.dart';

/// Compile-time plugin registry (docs/04 §4.2). The app shell constructs it
/// with every enabled provider; core resolves providers only through here.
class ProviderRegistry {
  ProviderRegistry(List<MusicProvider> providers)
    : _providers = {for (final p in providers) p.id: p} {
    if (_providers.length != providers.length) {
      throw ArgumentError('duplicate provider ids in registry');
    }
  }

  final Map<ProviderId, MusicProvider> _providers;

  List<MusicProvider> get all => List.unmodifiable(_providers.values);

  MusicProvider byId(ProviderId id) {
    final provider = _providers[id];
    if (provider == null) {
      throw ArgumentError.value(id.value, 'id', 'no such provider registered');
    }
    return provider;
  }

  bool contains(ProviderId id) => _providers.containsKey(id);
}
