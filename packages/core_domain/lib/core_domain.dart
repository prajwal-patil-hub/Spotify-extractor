/// Bridgetune domain core.
///
/// Pure-Dart entities and value objects shared by every engine and provider
/// plugin. The dependency rule (docs/04): this package imports nothing from
/// the rest of the workspace, and nothing here may ever name a specific
/// streaming provider.
library;

export 'src/capability.dart';
export 'src/confidence.dart';
export 'src/entities/album.dart';
export 'src/entities/artist.dart';
export 'src/entities/playlist.dart';
export 'src/entities/track.dart';
export 'src/errors.dart';
export 'src/field.dart';
export 'src/ids.dart';
