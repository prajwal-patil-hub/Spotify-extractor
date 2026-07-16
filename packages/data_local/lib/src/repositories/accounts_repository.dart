import 'package:core_domain/core_domain.dart';
import 'package:drift/drift.dart';

import '../database.dart';
import '../ids.dart';

/// Connected-account rows. Token material lives in secure storage under
/// [ProviderAccount.tokenRef] — this table only points at it.
class AccountsRepository {
  AccountsRepository(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final BridgetuneDatabase _db;
  final DateTime Function() _now;

  Future<String> upsert({
    required ProviderId provider,
    required AccountId account,
    required String displayName,
    required String tokenRef,
    Uri? avatarUrl,
    String scopes = '',
  }) async {
    final rowId = accountRowId(provider, account);
    await _db
        .into(_db.providerAccounts)
        .insertOnConflictUpdate(
          ProviderAccountsCompanion.insert(
            id: rowId,
            providerId: provider.value,
            accountValue: account.value,
            displayName: displayName,
            tokenRef: tokenRef,
            avatarUrl: Value(avatarUrl?.toString()),
            scopes: Value(scopes),
            connectedAt: _now(),
          ),
        );
    return rowId;
  }

  Future<void> setStatus(String rowId, String status) =>
      (_db.update(_db.providerAccounts)..where((a) => a.id.equals(rowId)))
          .write(ProviderAccountsCompanion(status: Value(status)));

  /// Cascade-deletes the account's playlist snapshots (schema FK); mappings
  /// survive by design — they are provider-pair-scoped, not account-scoped.
  Future<void> delete(String rowId) =>
      (_db.delete(_db.providerAccounts)..where((a) => a.id.equals(rowId))).go();

  Stream<List<ProviderAccount>> watchAll() => (_db.select(
    _db.providerAccounts,
  )..orderBy([(a) => OrderingTerm.asc(a.connectedAt)])).watch();

  Future<ProviderAccount?> byId(String rowId) => (_db.select(
    _db.providerAccounts,
  )..where((a) => a.id.equals(rowId))).getSingleOrNull();
}
