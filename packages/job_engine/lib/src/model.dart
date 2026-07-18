import 'package:core_domain/core_domain.dart';
import 'package:meta/meta.dart';

/// Job lifecycle (docs/08 §1). `needsReview` is non-terminal: the job
/// resumes when the review queue for it is cleared.
enum JobState {
  queued,
  running,
  paused,
  needsReview,
  completed,
  failed,
  cancelled;

  bool get isTerminal =>
      this == completed || this == failed || this == cancelled;
}

/// Item lifecycle — the checkpoint unit (docs/05 §4.1).
enum ItemState {
  pending,
  needsReview,
  transferred,
  verified,
  failed,
  skipped;

  bool get isTerminal => this == verified || this == failed || this == skipped;
}

/// What a transfer job is asked to do. Serialized into the job row;
/// [dstPlaylistId] is written back as a checkpoint once the destination
/// playlist exists, making playlist creation resumable.
@immutable
class TransferSpec {
  const TransferSpec({
    required this.playlistName,
    this.description,
    this.privacy,
    this.dstPlaylistId,
  });

  final String playlistName;
  final String? description;
  final PlaylistPrivacy? privacy;
  final String? dstPlaylistId;

  TransferSpec withDstPlaylist(String id) => TransferSpec(
    playlistName: playlistName,
    description: description,
    privacy: privacy,
    dstPlaylistId: id,
  );

  Map<String, Object?> toJson() => {
    'playlist_name': playlistName,
    'description': description,
    'privacy': privacy?.name,
    'dst_playlist_id': dstPlaylistId,
  };

  factory TransferSpec.fromJson(Map<String, Object?> json) => TransferSpec(
    playlistName: json['playlist_name']! as String,
    description: json['description'] as String?,
    privacy: switch (json['privacy']) {
      final String name => PlaylistPrivacy.values.byName(name),
      _ => null,
    },
    dstPlaylistId: json['dst_playlist_id'] as String?,
  );
}

@immutable
class JobRecord {
  const JobRecord({
    required this.id,
    required this.kind,
    required this.srcAccount,
    required this.dstAccount,
    required this.spec,
    required this.state,
    this.progressDone = 0,
    this.progressTotal = 0,
    this.error,
  });

  final String id;
  final String kind; // playlist_transfer | liked_songs | …
  final AccountId srcAccount;
  final AccountId dstAccount;
  final TransferSpec spec;
  final JobState state;
  final int progressDone;
  final int progressTotal;
  final String? error;

  JobRecord copyWith({
    TransferSpec? spec,
    JobState? state,
    int? progressDone,
    String? error,
  }) => JobRecord(
    id: id,
    kind: kind,
    srcAccount: srcAccount,
    dstAccount: dstAccount,
    spec: spec ?? this.spec,
    state: state ?? this.state,
    progressDone: progressDone ?? this.progressDone,
    progressTotal: progressTotal,
    error: error ?? this.error,
  );
}

@immutable
class ItemRecord {
  const ItemRecord({
    required this.id,
    required this.jobId,
    required this.seq,
    required this.sourceTrack,
    this.state = ItemState.pending,
    this.resolvedDstId,
    this.attemptCount = 0,
    this.nextRetryAt,
    this.lastError,
  });

  final String id;
  final String jobId;

  /// Source playlist position — the order-preservation anchor.
  final int seq;

  final Track sourceTrack;
  final ItemState state;

  /// Destination track id once resolved (mapping cache or match engine).
  final String? resolvedDstId;

  final int attemptCount;
  final DateTime? nextRetryAt;
  final String? lastError;

  ItemRecord copyWith({
    ItemState? state,
    String? resolvedDstId,
    int? attemptCount,
    DateTime? nextRetryAt,
    String? lastError,
  }) => ItemRecord(
    id: id,
    jobId: jobId,
    seq: seq,
    sourceTrack: sourceTrack,
    state: state ?? this.state,
    resolvedDstId: resolvedDstId ?? this.resolvedDstId,
    attemptCount: attemptCount ?? this.attemptCount,
    nextRetryAt: nextRetryAt,
    lastError: lastError ?? this.lastError,
  );
}
