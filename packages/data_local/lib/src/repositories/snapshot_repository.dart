import 'dart:convert';

import 'package:core_domain/core_domain.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../database.dart';
import '../ids.dart';

/// Library snapshots: streamed, batched ingestion and change detection.
///
/// The normalizer is injected because title normalization is the matching
/// engine's domain (docs/07 §2) and `data_local` may not depend on it —
/// the composition root wires the real one in.
class SnapshotRepository {
  SnapshotRepository(
    this._db, {
    required String Function(String title) normalizer,
    DateTime Function()? clock,
    this.batchSize = 500,
  }) : _normalize = normalizer,
       _now = clock ?? DateTime.now;

  final BridgetuneDatabase _db;
  final String Function(String) _normalize;
  final DateTime Function() _now;
  final int batchSize;

  // -- tracks -----------------------------------------------------------------

  /// Ingests a stream of tracks in [batchSize]-row transactions
  /// (docs/09 §4.2). Idempotent: re-ingesting updates rows in place.
  /// Returns the number of rows written.
  Future<int> ingestTracks(Stream<Track> tracks) async {
    var written = 0;
    final buffer = <TrackSnapshotsCompanion>[];
    await for (final track in tracks) {
      buffer.add(_trackCompanion(track));
      if (buffer.length >= batchSize) {
        written += await _flushTracks(buffer);
      }
    }
    written += await _flushTracks(buffer);
    return written;
  }

  Future<int> _flushTracks(List<TrackSnapshotsCompanion> buffer) async {
    if (buffer.isEmpty) return 0;
    final rows = List.of(buffer);
    buffer.clear();
    await _db.batch(
      (b) => b.insertAllOnConflictUpdate(_db.trackSnapshots, rows),
    );
    return rows.length;
  }

  TrackSnapshotsCompanion _trackCompanion(Track track) =>
      TrackSnapshotsCompanion.insert(
        id: trackRowId(track.providerId, track.id),
        providerId: track.providerId.value,
        providerTrackId: track.id.value,
        title: track.title,
        titleNorm: _normalize(track.title),
        artistsJson: jsonEncode([for (final a in track.artists) a.name]),
        isrc: Value(track.isrc),
        album: Value(track.album?.title),
        durationMs: Value(track.duration?.inMilliseconds),
        releaseYear: Value(track.releaseYear ?? track.album?.releaseYear),
        explicit: Value(track.explicit),
        popularity: Value(track.popularity),
        fetchedAt: _now(),
      );

  Future<TrackSnapshot?> trackByRowId(String rowId) => (_db.select(
    _db.trackSnapshots,
  )..where((t) => t.id.equals(rowId))).getSingleOrNull();

  Future<List<TrackSnapshot>> tracksByIsrc(String isrc) =>
      (_db.select(_db.trackSnapshots)..where((t) => t.isrc.equals(isrc))).get();

  Future<int> trackCount() async {
    final count = _db.trackSnapshots.id.count();
    final row = await (_db.selectOnly(
      _db.trackSnapshots,
    )..addColumns([count])).getSingle();
    return row.read(count)!;
  }

  // -- playlists ---------------------------------------------------------------

  /// Upserts a playlist snapshot and atomically replaces its track list
  /// (tracks must already be ingested). Computes [contentHash] over the
  /// ordered row-ids — the O(1) change-detection anchor (docs/05 §4.4).
  Future<void> upsertPlaylist({
    required String accountRowId,
    required Playlist playlist,
    required List<String> trackRowIds,
  }) async {
    final rowId = playlistRowId(accountRowId, playlist.id);
    await _db.transaction(() async {
      await _db
          .into(_db.playlistSnapshots)
          .insertOnConflictUpdate(
            PlaylistSnapshotsCompanion.insert(
              id: rowId,
              accountId: accountRowId,
              providerPlaylistId: playlist.id.value,
              name: playlist.name,
              description: Value(playlist.description),
              privacy: Value(playlist.privacy?.name),
              collaborative: Value(playlist.collaborative),
              artworkUrl: Value(playlist.artworkUrl?.toString()),
              trackCount: Value(trackRowIds.length),
              contentHash: contentHashOf(trackRowIds),
              providerEtag: Value(playlist.etag),
              fetchedAt: _now(),
            ),
          );
      await (_db.delete(
        _db.playlistTrackSnapshots,
      )..where((t) => t.playlistId.equals(rowId))).go();
      await _db.batch(
        (b) => b.insertAll(_db.playlistTrackSnapshots, [
          for (var i = 0; i < trackRowIds.length; i++)
            PlaylistTrackSnapshotsCompanion.insert(
              playlistId: rowId,
              trackId: trackRowIds[i],
              position: i,
            ),
        ]),
      );
    });
  }

  /// True when the stored snapshot already matches ([etag] first, then
  /// content hash) — callers skip the full refetch on a hit (docs/08 §5).
  Future<bool> isPlaylistUnchanged({
    required String accountRowId,
    required ProviderPlaylistId playlist,
    String? etag,
    List<String>? trackRowIds,
  }) async {
    final row =
        await (_db.select(
              _db.playlistSnapshots,
            )..where((p) => p.id.equals(playlistRowId(accountRowId, playlist))))
            .getSingleOrNull();
    if (row == null) return false;
    if (etag != null && row.providerEtag != null) {
      return row.providerEtag == etag;
    }
    if (trackRowIds != null) {
      return row.contentHash == contentHashOf(trackRowIds);
    }
    return false;
  }

  Stream<List<PlaylistSnapshot>> watchPlaylists(String accountRowId) =>
      (_db.select(_db.playlistSnapshots)
            ..where((p) => p.accountId.equals(accountRowId))
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .watch();

  /// Ordered track rows of a playlist, windowed for virtualized UIs
  /// (memory stays O(viewport), docs/09 §4.2).
  Future<List<TrackSnapshot>> playlistTracks(
    String playlistRowId, {
    int limit = 200,
    int offset = 0,
  }) {
    final query =
        (_db.select(_db.playlistTrackSnapshots).join([
            innerJoin(
              _db.trackSnapshots,
              _db.trackSnapshots.id.equalsExp(
                _db.playlistTrackSnapshots.trackId,
              ),
            ),
          ])
          ..where(_db.playlistTrackSnapshots.playlistId.equals(playlistRowId))
          ..orderBy([OrderingTerm.asc(_db.playlistTrackSnapshots.position)])
          ..limit(limit, offset: offset));
    return query.map((row) => row.readTable(_db.trackSnapshots)).get();
  }

  static String contentHashOf(List<String> orderedTrackRowIds) =>
      sha1.convert(utf8.encode(orderedTrackRowIds.join('\n'))).toString();
}
