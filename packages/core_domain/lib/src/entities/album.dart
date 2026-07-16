import 'package:meta/meta.dart';

import '../ids.dart';

/// An album as seen at one provider.
@immutable
class Album {
  const Album({required this.title, this.id, this.upc, this.releaseYear});

  final String title;
  final ProviderAlbumId? id;

  /// Universal Product Code — a cross-catalog album identity signal when
  /// both providers expose it (docs/02 matrix).
  final String? upc;

  final int? releaseYear;

  @override
  bool operator ==(Object other) =>
      other is Album &&
      other.title == title &&
      other.id == id &&
      other.upc == upc &&
      other.releaseYear == releaseYear;

  @override
  int get hashCode => Object.hash(title, id, upc, releaseYear);

  @override
  String toString() => 'Album($title)';
}
