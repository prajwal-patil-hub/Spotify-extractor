import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A stateful in-memory Spotify Web API, mounted as a dio
/// [HttpClientAdapter]. Production code is untouched — the fake sits at the
/// socket boundary, exactly where the real network would be.
///
/// Deliberately mimics real Spotify behaviors the adapter must handle:
/// paginated envelopes with `next` links, `items[].track` wrapping,
/// snapshot ids, unfollow-as-delete, and token grants.
class SpotifyApiFake implements HttpClientAdapter {
  SpotifyApiFake({this.pageSize = 2});

  final int pageSize;

  // -- scriptable behavior ------------------------------------------------------
  String validAccessToken = 'access-1';
  int fail401Times = 0;
  int fail429Times = 0;
  int retryAfterSeconds = 7;
  int fail500Times = 0;

  // -- observability --------------------------------------------------------------
  final List<String> requests = []; // "METHOD path?query"
  final List<Object?> writeBodies = [];
  int tokenGrants = 0;

  // -- state ----------------------------------------------------------------------
  final Map<String, Map<String, Object?>> playlists = {};
  final Map<String, List<String>> playlistTracks = {};
  final Map<String, Map<String, Object?>> catalog = {};
  final List<String> likedTrackIds = [];
  int _nextPlaylist = 1;
  int _snapshot = 1;

  void seedTrack(
    String id,
    String title,
    String artist, {
    String? album,
    String? isrc,
    int durationMs = 200000,
  }) {
    catalog[id] = {
      'id': id,
      'name': title,
      'artists': [
        {'id': 'a-$id', 'name': artist},
      ],
      'album': {
        'id': 'al-$id',
        'name': album ?? 'Album of $title',
        'release_date': '2020-01-01',
      },
      'duration_ms': durationMs,
      'explicit': false,
      'popularity': 50,
      if (isrc != null) 'external_ids': {'isrc': isrc},
    };
  }

  String seedPlaylist(String name, List<String> trackIds) {
    final id = 'pl${_nextPlaylist++}';
    playlists[id] = {
      'id': id,
      'name': name,
      'description': '',
      'public': false,
      'collaborative': false,
      'snapshot_id': 'snap${_snapshot++}',
    };
    playlistTracks[id] = [...trackIds];
    return id;
  }

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final uri = options.uri;
    final method = options.method.toUpperCase();
    requests.add('$method ${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}');

    String? bodyString;
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      bodyString = utf8.decode([for (final c in chunks) ...c]);
    }

    // Token endpoint (auth + refresh) needs no bearer.
    if (uri.host == 'accounts.spotify.com' && uri.path == '/api/token') {
      tokenGrants++;
      validAccessToken = 'access-${tokenGrants + 1}';
      return _json(200, {
        'access_token': validAccessToken,
        'token_type': 'Bearer',
        'expires_in': 3600,
        'refresh_token': 'refresh-$tokenGrants',
        'scope': 'playlist-read-private',
      });
    }

    // Scripted failures fire before auth so retry paths can be exercised.
    if (fail500Times > 0) {
      fail500Times--;
      return _json(500, {'error': 'server exploded'});
    }
    if (fail429Times > 0) {
      fail429Times--;
      return ResponseBody.fromString(
        '{"error":{"status":429}}',
        429,
        headers: {
          'retry-after': ['$retryAfterSeconds'],
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    final auth = options.headers['Authorization'] as String?;
    if (fail401Times > 0 || auth != 'Bearer $validAccessToken') {
      if (fail401Times > 0) fail401Times--;
      return _json(401, {
        'error': {'status': 401, 'message': 'The access token expired'},
      });
    }

    if (bodyString != null && bodyString.isNotEmpty && method != 'GET') {
      writeBodies.add(
        options.headers[Headers.contentTypeHeader] == 'image/jpeg'
            ? bodyString
            : jsonDecode(bodyString),
      );
    }

    return _route(method, uri, bodyString);
  }

  ResponseBody _route(String method, Uri uri, String? body) {
    final path = uri.path;
    final decoded = body != null && body.isNotEmpty && !_isArtwork(uri)
        ? jsonDecode(body)
        : null;

    switch ((method, path)) {
      case ('GET', '/v1/me'):
        return _json(200, {'id': 'user1', 'display_name': 'Test User'});

      case ('GET', '/v1/me/playlists'):
        return _page(uri, [...playlists.values]);

      case ('GET', '/v1/me/tracks'):
        return _page(uri, [
          for (final id in likedTrackIds) {'track': catalog[id]},
        ]);

      case ('GET', '/v1/search'):
        return _search(uri);

      case ('POST', _) when _isUserPlaylists(path):
        final spec = decoded as Map<String, Object?>;
        final id = seedPlaylist(spec['name']! as String, []);
        playlists[id]!['public'] = spec['public'] ?? false;
        playlists[id]!['description'] = spec['description'] ?? '';
        return _json(201, _playlistJson(id));

      case (_, _) when path.startsWith('/v1/playlists/'):
        return _playlistRoutes(method, uri, decoded, body);
    }
    return _json(404, {'error': 'no such route $method $path'});
  }

  ResponseBody _playlistRoutes(
    String method,
    Uri uri,
    Object? decoded,
    String? rawBody,
  ) {
    final segments = uri.pathSegments; // v1, playlists, {id}, [rest]
    final id = segments[2];
    final rest = segments.length > 3 ? segments[3] : null;
    if (!playlists.containsKey(id)) {
      return _json(404, {
        'error': {'status': 404, 'message': 'Not found'},
      });
    }
    final tracks = playlistTracks[id]!;

    switch ((method, rest)) {
      case ('GET', 'tracks'):
        return _page(uri, [
          for (final t in tracks) {'track': catalog[t]},
        ]);
      case ('POST', 'tracks'):
        final map = decoded as Map<String, Object?>;
        final uris = (map['uris']! as List).cast<String>();
        final ids = [for (final u in uris) u.split(':').last];
        final position = map['position'] as int?;
        tracks.insertAll(position ?? tracks.length, ids);
        return _snap();
      case ('PUT', 'tracks'):
        final map = decoded as Map<String, Object?>;
        final uris = (map['uris']! as List).cast<String>();
        tracks
          ..clear()
          ..addAll([for (final u in uris) u.split(':').last]);
        return _snap();
      case ('DELETE', 'tracks'):
        final map = decoded as Map<String, Object?>;
        final removed = [
          for (final t in (map['tracks']! as List))
            ((t as Map)['uri']! as String).split(':').last,
        ];
        tracks.removeWhere(removed.contains);
        return _snap();
      case ('PUT', 'images'):
        if (rawBody == null || rawBody.isEmpty) {
          return _json(400, {'error': 'missing image body'});
        }
        return ResponseBody.fromString('', 202);
      case ('PUT', null):
        final map = decoded as Map<String, Object?>;
        playlists[id]!.addAll({
          if (map.containsKey('name')) 'name': map['name'],
          if (map.containsKey('description')) 'description': map['description'],
          if (map.containsKey('public')) 'public': map['public'],
        });
        return ResponseBody.fromString('', 200);
      case ('DELETE', 'followers'):
        playlists.remove(id);
        playlistTracks.remove(id);
        return ResponseBody.fromString('', 200);
    }
    return _json(404, {'error': 'no such playlist route'});
  }

  ResponseBody _search(Uri uri) {
    final q = uri.queryParameters['q'] ?? '';
    List<Map<String, Object?>> hits;
    if (q.startsWith('isrc:')) {
      final isrc = q.substring(5);
      hits = [
        for (final t in catalog.values)
          if ((t['external_ids'] as Map?)?['isrc'] == isrc) t,
      ];
    } else {
      final needle = q
          .replaceAll(RegExp('(track|artist|album):'), '')
          .replaceAll('"', '')
          .toLowerCase();
      final tokens = needle.split(RegExp(r'\s+'))
        ..removeWhere((t) => t.isEmpty);
      hits = [
        for (final t in catalog.values)
          if (tokens.every(
            (tok) =>
                '${t['name']} ${(t['artists'] as List).map((a) => (a as Map)['name']).join(' ')}'
                    .toLowerCase()
                    .contains(tok),
          ))
            t,
      ];
    }
    final limit = int.tryParse(uri.queryParameters['limit'] ?? '') ?? 20;
    return _json(200, {
      'tracks': {'items': hits.take(limit).toList(), 'next': null},
    });
  }

  /// Spotify-style offset pagination with absolute `next` URLs.
  ResponseBody _page(Uri uri, List<Object?> all) {
    final offset = int.tryParse(uri.queryParameters['offset'] ?? '') ?? 0;
    final slice = all.skip(offset).take(pageSize).toList();
    final nextOffset = offset + pageSize;
    final next = nextOffset < all.length
        ? uri
              .replace(
                queryParameters: {
                  ...uri.queryParameters,
                  'offset': '$nextOffset',
                },
              )
              .toString()
        : null;
    return _json(200, {'items': slice, 'next': next, 'total': all.length});
  }

  Map<String, Object?> _playlistJson(String id) => {
    ...playlists[id]!,
    'tracks': {'total': playlistTracks[id]!.length},
  };

  ResponseBody _snap() {
    return _json(201, {'snapshot_id': 'snap${_snapshot++}'});
  }

  bool _isArtwork(Uri uri) => uri.pathSegments.lastOrNull == 'images';

  bool _isUserPlaylists(String path) =>
      RegExp(r'^/v1/users/[^/]+/playlists$').hasMatch(path);

  ResponseBody _json(int status, Map<String, Object?> body) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}
