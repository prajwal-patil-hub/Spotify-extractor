import 'package:core_domain/core_domain.dart';
import 'package:provider_api/provider_api.dart';

import 'services.dart';

/// Seeds the demo library: two Spotify-side playlists whose tracks mostly
/// exist at the YTM-side destination (plus a few that only match traps or
/// nothing at all — so transfers produce a real review queue and report).
Future<void> seedDemoLibrary(AppServices services) async {
  const spotifyId = ProviderId('spotify');
  final spotify = services.registry.byId(spotifyId);
  final account = services.accounts[spotifyId]!;

  final existing = await spotify.getPlaylists(account).toList();
  if (existing.isNotEmpty) return;

  Future<void> playlist(String name, List<int> trackNumbers) async {
    final created = await spotify.createPlaylist(
      account,
      PlaylistSpec(name: name),
    );
    await spotify.addTracks(
      PlaylistRef(account: account, playlist: created.id),
      [for (final i in trackNumbers) ProviderTrackId('s$i')],
    );
  }

  // 35–39 exist only as live versions / not at all on the destination.
  await playlist('Road Trip', [for (var i = 0; i < 15; i++) i]);
  await playlist('Focus Flow', [for (var i = 15; i < 40; i++) i]);
}
