import 'dart:convert';

import '../database.dart';

/// Typed key-value settings with reactive reads. Values are JSON so any
/// serializable shape works; well-known keys get typed helpers at the app
/// layer, not here.
class SettingsRepository {
  SettingsRepository(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final BridgetuneDatabase _db;
  final DateTime Function() _now;

  Future<void> set(String key, Object? value) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          key: key,
          valueJson: jsonEncode(value),
          updatedAt: _now(),
        ),
      );

  Future<T?> get<T>(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row == null ? null : jsonDecode(row.valueJson) as T?;
  }

  Stream<T?> watch<T>(String key) =>
      (_db.select(_db.appSettings)..where((s) => s.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row == null ? null : jsonDecode(row.valueJson) as T?);

  Future<void> remove(String key) =>
      (_db.delete(_db.appSettings)..where((s) => s.key.equals(key))).go();
}
