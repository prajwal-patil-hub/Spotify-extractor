import 'package:meta/meta.dart';

import '../ids.dart';

/// An artist as seen at one provider.
@immutable
class Artist {
  const Artist({required this.name, this.id});

  /// Display name exactly as the provider returned it. Normalization is the
  /// matching engine's job, not the entity's.
  final String name;

  /// Provider-namespaced id; absent when the provider returns artists as
  /// plain strings (common in search results).
  final ProviderArtistId? id;

  @override
  bool operator ==(Object other) =>
      other is Artist && other.name == name && other.id == id;

  @override
  int get hashCode => Object.hash(name, id);

  @override
  String toString() => 'Artist($name)';
}
