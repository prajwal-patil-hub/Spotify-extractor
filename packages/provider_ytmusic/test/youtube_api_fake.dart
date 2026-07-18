import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Stateful in-memory YouTube: the Data API v3 (googleapis.com), Google's
/// token endpoint, and the innertube session endpoints
/// (music.youtube.com), mounted as one dio adapter. Mimics the behaviors
/// the adapter must survive: pageToken pagination, playlistItem-id-based
/// deletion, snippet-replacing updates, quota 403s, and innertube's
/// renderer nesting.
class YouTubeApiFake implements HttpClientAdapter {
  YouTubeApiFake({this.pageSize = 2});

  final int pageSize;

  // -- scriptable ---------------------------------------------------------------
  String validAccessToken = 'yt-access-1';
  String validSessionCookie = 'SID=session-cookie';
  int failQuota403Times = 0;

  // -- observability -------------------------------------------------------------
  final List<String> requests = []; // "METHOD host path?query"
  int tokenGrants = 0;

  // -- state ---------------------------------------------------------------------
  final Map<String, Map<String, Object?>> playlists = {};
  final Map<String, List<(String itemId, String videoId)>> items = {};
  final Map<String, Map<String, Object?>> catalog = {};
  final List<String> likedVideoIds = [];
  int _nextId = 1;

  void seedVideo(
    String videoId,
    String title,
    String artist, {
    String? album,
    int durSec = 200,
  }) {
    catalog[videoId] = {
      'title': title,
      'artist': artist,
      'album': album,
      'durSec': durSec,
    };
  }

  String seedPlaylist(String name, List<String> videoIds) {
    final id = 'PL${_nextId++}';
    playlists[id] = {
      'title': name,
      'description': '',
      'privacyStatus': 'private',
    };
    items[id] = [for (final v in videoIds) ('PLI${_nextId++}', v)];
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
    requests.add(
      '$method ${uri.host}${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}',
    );

    Object? body;
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      final text = utf8.decode([for (final c in chunks) ...c]);
      if (text.isNotEmpty) {
        body =
            options.headers[Headers.contentTypeHeader]?.toString().contains(
                  'json',
                ) ??
                false
            ? jsonDecode(text)
            : text;
      }
    }

    if (uri.host == 'oauth2.googleapis.com') {
      tokenGrants++;
      validAccessToken = 'yt-access-${tokenGrants + 1}';
      return _json(200, {
        'access_token': validAccessToken,
        'token_type': 'Bearer',
        'expires_in': 3600,
        'refresh_token': 'yt-refresh-$tokenGrants',
      });
    }

    if (uri.host == 'music.youtube.com') {
      return _innertube(uri, options, body);
    }

    // Data API: auth + scripted quota failures.
    if (failQuota403Times > 0) {
      failQuota403Times--;
      return _json(403, {
        'error': {
          'code': 403,
          'errors': [
            {'reason': 'quotaExceeded'},
          ],
        },
      });
    }
    final auth = options.headers['Authorization'] as String?;
    if (auth != 'Bearer $validAccessToken') {
      return _json(401, {
        'error': {'code': 401},
      });
    }
    return _dataApi(method, uri, body);
  }

  // -- Data API v3 ---------------------------------------------------------------

  ResponseBody _dataApi(String method, Uri uri, Object? body) {
    final q = uri.queryParameters;
    switch ((method, uri.path)) {
      case ('GET', '/youtube/v3/channels'):
        return _json(200, {
          'items': [
            {
              'id': 'chan1',
              'snippet': {'title': 'Test Channel'},
            },
          ],
        });

      case ('GET', '/youtube/v3/playlists') when q.containsKey('id'):
        final playlist = playlists[q['id']];
        return _json(200, {
          'items': [if (playlist != null) _playlistJson(q['id']!)],
        });

      case ('GET', '/youtube/v3/playlists'):
        return _page(q, [for (final id in playlists.keys) _playlistJson(id)]);

      case ('POST', '/youtube/v3/playlists'):
        final map = (body! as Map).cast<String, Object?>();
        final snippet = (map['snippet']! as Map).cast<String, Object?>();
        final status = (map['status'] as Map?)?.cast<String, Object?>();
        final id = seedPlaylist(snippet['title']! as String, []);
        playlists[id]!['description'] = snippet['description'] ?? '';
        playlists[id]!['privacyStatus'] = status?['privacyStatus'] ?? 'private';
        return _json(200, _playlistJson(id));

      case ('PUT', '/youtube/v3/playlists'):
        final map = (body! as Map).cast<String, Object?>();
        final id = map['id']! as String;
        if (!playlists.containsKey(id)) return _notFound();
        // Faithful to YouTube: PUT REPLACES the snippet wholesale.
        final snippet = (map['snippet']! as Map).cast<String, Object?>();
        final status = (map['status'] as Map?)?.cast<String, Object?>();
        playlists[id] = {
          'title': snippet['title'] ?? '',
          'description': snippet['description'] ?? '',
          'privacyStatus':
              status?['privacyStatus'] ?? playlists[id]!['privacyStatus'],
        };
        return _json(200, _playlistJson(id));

      case ('DELETE', '/youtube/v3/playlists'):
        if (playlists.remove(q['id']) == null) return _notFound();
        items.remove(q['id']);
        return ResponseBody.fromString('', 204);

      case ('GET', '/youtube/v3/playlistItems'):
        final list = items[q['playlistId']];
        if (list == null) return _notFound();
        return _page(q, [
          for (final (itemId, videoId) in list)
            {
              'id': itemId,
              'snippet': {
                'title': catalog[videoId]?['title'] ?? 'video $videoId',
                'videoOwnerChannelTitle':
                    '${catalog[videoId]?['artist'] ?? 'Unknown'} - Topic',
                'resourceId': {'kind': 'youtube#video', 'videoId': videoId},
              },
              'contentDetails': {'videoId': videoId},
            },
        ]);

      case ('POST', '/youtube/v3/playlistItems'):
        final snippet = ((body! as Map)['snippet']! as Map)
            .cast<String, Object?>();
        final playlistId = snippet['playlistId']! as String;
        final list = items[playlistId];
        if (list == null) return _notFound();
        final videoId = ((snippet['resourceId']! as Map)['videoId'])! as String;
        final entry = ('PLI${_nextId++}', videoId);
        final position = snippet['position'] as int?;
        list.insert(position ?? list.length, entry);
        return _json(200, {'id': entry.$1});

      case ('DELETE', '/youtube/v3/playlistItems'):
        final itemId = q['id'];
        for (final list in items.values) {
          final before = list.length;
          list.removeWhere((e) => e.$1 == itemId);
          if (list.length != before) return ResponseBody.fromString('', 204);
        }
        return _notFound();

      case ('GET', '/youtube/v3/search'):
        final needle = (q['q'] ?? '').toLowerCase();
        final tokens = needle.split(RegExp(r'\s+'))
          ..removeWhere((t) => t.isEmpty);
        return _json(200, {
          'items': [
            for (final entry in catalog.entries)
              if (tokens.every(
                (t) => '${entry.value['title']} ${entry.value['artist']}'
                    .toLowerCase()
                    .contains(t),
              ))
                {
                  'id': {'kind': 'youtube#video', 'videoId': entry.key},
                  'snippet': {
                    'title': entry.value['title'],
                    'channelTitle': '${entry.value['artist']} - Topic',
                  },
                },
          ],
        });
    }
    return _json(404, {'error': 'no route $method ${uri.path}'});
  }

  // -- innertube session endpoints ------------------------------------------------

  ResponseBody _innertube(Uri uri, RequestOptions options, Object? body) {
    final cookie = options.headers['Cookie'] as String?;
    if (cookie != validSessionCookie) {
      return _json(401, {'error': 'bad session'});
    }
    final map = (body! as Map).cast<String, Object?>();
    if (uri.path.endsWith('/search')) {
      final needle = (map['query']! as String).toLowerCase();
      final tokens = needle.split(RegExp(r'\s+'))
        ..removeWhere((t) => t.isEmpty);
      final hits = [
        for (final entry in catalog.entries)
          if (tokens.every(
            (t) => '${entry.value['title']} ${entry.value['artist']}'
                .toLowerCase()
                .contains(t),
          ))
            _renderer(entry.key, entry.value),
      ];
      return _json(200, _shelf(hits));
    }
    if (uri.path.endsWith('/browse') && map['browseId'] == 'VLLM') {
      return _json(
        200,
        _shelf([for (final v in likedVideoIds) _renderer(v, catalog[v]!)]),
      );
    }
    return _json(404, {'error': 'no innertube route ${uri.path}'});
  }

  Map<String, Object?> _shelf(List<Map<String, Object?>> renderers) => {
    'contents': {
      'sectionList': [
        {
          'musicShelfRenderer': {
            'contents': [
              for (final r in renderers) {'musicResponsiveListItemRenderer': r},
            ],
          },
        },
      ],
    },
  };

  Map<String, Object?> _renderer(String videoId, Map<String, Object?> v) {
    final durSec = v['durSec']! as int;
    return {
      'flexColumns': [
        {
          'musicResponsiveListItemFlexColumnRenderer': {
            'text': {
              'runs': [
                {
                  'text': v['title'],
                  'navigationEndpoint': {
                    'watchEndpoint': {'videoId': videoId},
                  },
                },
              ],
            },
          },
        },
        {
          'musicResponsiveListItemFlexColumnRenderer': {
            'text': {
              'runs': [
                {'text': v['artist']},
                {'text': ' • '},
                if (v['album'] != null) ...[
                  {
                    'text': v['album'],
                    'navigationEndpoint': {
                      'browseEndpoint': {
                        'browseId': 'MPRE_x',
                        'browseEndpointContextSupportedConfigs': {
                          'browseEndpointContextMusicConfig': {
                            'pageType': 'MUSIC_PAGE_TYPE_ALBUM',
                          },
                        },
                      },
                    },
                  },
                  {'text': ' • '},
                ],
                {
                  'text':
                      '${durSec ~/ 60}:${(durSec % 60).toString().padLeft(2, '0')}',
                },
              ],
            },
          },
        },
      ],
    };
  }

  // -- helpers -------------------------------------------------------------------

  ResponseBody _page(Map<String, String> q, List<Object?> all) {
    final offset = int.tryParse(q['pageToken'] ?? '') ?? 0;
    final slice = all.skip(offset).take(pageSize).toList();
    final next = offset + pageSize < all.length ? '${offset + pageSize}' : null;
    return _json(200, {'items': slice, 'nextPageToken': ?next});
  }

  Map<String, Object?> _playlistJson(String id) => {
    'id': id,
    'etag': 'etag-$id-${playlists[id].hashCode}',
    'snippet': {
      'title': playlists[id]!['title'],
      'description': playlists[id]!['description'],
    },
    'status': {'privacyStatus': playlists[id]!['privacyStatus']},
    'contentDetails': {'itemCount': items[id]?.length ?? 0},
  };

  ResponseBody _notFound() => _json(404, {
    'error': {'code': 404},
  });

  ResponseBody _json(int status, Map<String, Object?> body) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}
