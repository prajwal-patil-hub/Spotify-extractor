import 'package:core_domain/core_domain.dart';
import 'package:dio/dio.dart';

/// The seam for the consented session path (YTM's internal "innertube"
/// API, exercised with the user's own session credential). Everything
/// behind this interface is formally unofficial (docs/02 §2.1): it may
/// drift without notice, which is why nightly live contract runs alarm on
/// it and the kill switch can disable it remotely.
abstract interface class YtmSessionClient {
  /// Music-scoped catalog search — the thing the official API cannot do.
  Future<List<Track>> searchTracks(String query, {int limit = 10});

  /// The user's liked-music library.
  Stream<Track> likedSongs();
}

/// HTTP implementation against `music.youtube.com/youtubei/v1`, parsing the
/// innertube `musicResponsiveListItemRenderer` shape. Session credential =
/// the user's own cookie header, held in secure storage, sent only to
/// YouTube itself, never logged (docs/06 §2).
class HttpYtmSessionClient implements YtmSessionClient {
  HttpYtmSessionClient({
    required Dio httpClient,
    required String cookieHeader,
    this.providerId = const ProviderId('ytmusic'),
  }) : _http = httpClient,
       _cookie = cookieHeader;

  static const _base = 'https://music.youtube.com/youtubei/v1';

  final Dio _http;
  final String _cookie;
  final ProviderId providerId;

  Future<Map<String, Object?>> _post(
    String path,
    Map<String, Object?> body,
  ) async {
    Response<Map<String, Object?>> response;
    try {
      response = await _http.post<Map<String, Object?>>(
        '$_base/$path',
        data: {
          'context': {
            'client': {
              'clientName': 'WEB_REMIX',
              'clientVersion': '1.20240101',
            },
          },
          ...body,
        },
        options: Options(
          headers: {'Cookie': _cookie, 'Origin': 'https://music.youtube.com'},
          validateStatus: (s) => s != null && s < 500,
        ),
      );
    } on DioException catch (e) {
      throw ProviderUnavailable(
        providerId,
        'session path unreachable: ${e.type.name}',
      );
    }
    final data = response.data;
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw AuthExpired(providerId, 'session credential rejected');
    }
    if (response.statusCode != 200 || data == null) {
      throw ProviderContractViolation(
        providerId,
        'session path HTTP ${response.statusCode}',
      );
    }
    return data;
  }

  @override
  Future<List<Track>> searchTracks(String query, {int limit = 10}) async {
    final data = await _post('search', {
      'query': query,
      // Music-songs filter param (the documented innertube constant).
      'params': 'EgWKAQIIAWoKEAkQBRAKEAMQBA%3D%3D',
    });
    final tracks = <Track>[];
    for (final item in _findRenderers(data)) {
      final track = _parseItem(item);
      if (track != null) tracks.add(track);
      if (tracks.length >= limit) break;
    }
    return tracks;
  }

  @override
  Stream<Track> likedSongs() async* {
    final data = await _post('browse', {'browseId': 'VLLM'});
    for (final item in _findRenderers(data)) {
      final track = _parseItem(item);
      if (track != null) yield track;
    }
  }

  /// Depth-first hunt for `musicResponsiveListItemRenderer` nodes — the
  /// innertube envelope varies wildly; the item shape is the stable part.
  Iterable<Map<String, Object?>> _findRenderers(Object? node) sync* {
    if (node is Map) {
      final renderer = node['musicResponsiveListItemRenderer'];
      if (renderer is Map) yield renderer.cast<String, Object?>();
      for (final value in node.values) {
        yield* _findRenderers(value);
      }
    } else if (node is List) {
      for (final value in node) {
        yield* _findRenderers(value);
      }
    }
  }

  Track? _parseItem(Map<String, Object?> renderer) {
    try {
      final columns = (renderer['flexColumns'] as List? ?? const [])
          .map(
            (c) =>
                ((c as Map)['musicResponsiveListItemFlexColumnRenderer']
                        as Map?)
                    ?.cast<String, Object?>(),
          )
          .nonNulls
          .toList();
      if (columns.isEmpty) return null;

      List<Map<String, Object?>> runsOf(Map<String, Object?> column) =>
          (((column['text'] as Map?)?['runs']) as List? ?? const [])
              .map((r) => (r as Map).cast<String, Object?>())
              .toList();

      final titleRuns = runsOf(columns.first);
      if (titleRuns.isEmpty) return null;
      final title = titleRuns.first['text']! as String;
      final videoId =
          ((titleRuns.first['navigationEndpoint'] as Map?)?['watchEndpoint']
                  as Map?)?['videoId']
              as String?;
      if (videoId == null) return null;

      final artists = <Artist>[];
      String? album;
      Duration? duration;
      if (columns.length > 1) {
        for (final run in runsOf(columns[1])) {
          final text = run['text']! as String;
          if (text.trim() == '•' || text.trim().isEmpty) continue;
          final endpoint =
              ((run['navigationEndpoint'] as Map?)?['browseEndpoint'] as Map?)
                  ?.cast<String, Object?>();
          final pageType =
              ((endpoint?['browseEndpointContextSupportedConfigs']
                          as Map?)?['browseEndpointContextMusicConfig']
                      as Map?)?['pageType']
                  as String?;
          if (pageType == 'MUSIC_PAGE_TYPE_ALBUM') {
            album = text;
          } else if (RegExp(r'^\d+:\d{2}(:\d{2})?$').hasMatch(text.trim())) {
            duration = _parseDuration(text.trim());
          } else {
            artists.add(Artist(name: text));
          }
        }
      }

      return Track(
        providerId: providerId,
        id: ProviderTrackId(videoId),
        title: title,
        artists: artists,
        album: album == null ? null : Album(title: album),
        duration: duration,
      );
    } catch (_) {
      // One malformed item must not poison the page — skip it; the
      // nightly contract run alarms on systematic drift (docs/12 §4).
      return null;
    }
  }

  Duration _parseDuration(String text) {
    final parts = text.split(':').map(int.parse).toList();
    return switch (parts.length) {
      2 => Duration(minutes: parts[0], seconds: parts[1]),
      3 => Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]),
      _ => Duration.zero,
    };
  }
}
