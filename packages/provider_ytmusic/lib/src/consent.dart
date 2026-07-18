import 'package:meta/meta.dart';

/// The informed-consent text version for the session path. Bumping this
/// invalidates all stored consents — users see the updated terms and must
/// opt in again (docs/02 §2.2 item 6).
const int ytmSessionConsentVersion = 1;

@immutable
class ConsentRecord {
  const ConsentRecord({required this.version, required this.grantedAt});

  final int version;
  final DateTime grantedAt;

  Map<String, Object?> toJson() => {
    'version': version,
    'granted_at': grantedAt.toUtc().toIso8601String(),
  };

  factory ConsentRecord.fromJson(Map<String, Object?> json) => ConsentRecord(
    version: json['version']! as int,
    grantedAt: DateTime.parse(json['granted_at']! as String),
  );
}

/// Persistence seam for consent records (app: `data_local` settings).
abstract interface class ConsentStore {
  Future<ConsentRecord?> read(String key);

  Future<void> write(String key, ConsentRecord record);

  Future<void> delete(String key);
}

class InMemoryConsentStore implements ConsentStore {
  final Map<String, ConsentRecord> _records = {};

  @override
  Future<ConsentRecord?> read(String key) async => _records[key];

  @override
  Future<void> write(String key, ConsentRecord record) async {
    _records[key] = record;
  }

  @override
  Future<void> delete(String key) async {
    _records.remove(key);
  }
}

/// Gates the unofficial session path behind explicit, versioned, revocable
/// consent. The provider consults [isCurrent] before every session-path
/// capability declaration and operation.
class ConsentGate {
  ConsentGate({required this._store, DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  static const _key = 'ytmusic.session_path';

  final ConsentStore _store;
  final DateTime Function() _now;

  Future<bool> isCurrent() async {
    final record = await _store.read(_key);
    return record != null && record.version >= ytmSessionConsentVersion;
  }

  Future<void> grant() => _store.write(
    _key,
    ConsentRecord(version: ytmSessionConsentVersion, grantedAt: _now()),
  );

  Future<void> revoke() => _store.delete(_key);
}
