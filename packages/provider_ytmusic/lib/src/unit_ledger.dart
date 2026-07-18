import 'package:core_domain/core_domain.dart';

/// Persistence seam for the ledger — backed by `data_local` settings in the
/// app, by memory in tests. Keyed by Pacific-time day string (YYYY-MM-DD).
abstract interface class LedgerStore {
  Future<int> spentOn(String dayKey);

  Future<void> setSpent(String dayKey, int units);
}

class InMemoryLedgerStore implements LedgerStore {
  final Map<String, int> _spent = {};

  @override
  Future<int> spentOn(String dayKey) async => _spent[dayKey] ?? 0;

  @override
  Future<void> setSpent(String dayKey, int units) async {
    _spent[dayKey] = units;
  }

  /// Test-only inspection of which day keys have been written.
  Iterable<String> get spentKeys => _spent.keys;
}

/// YouTube Data API v3 quota costs per operation (docs/02 matrix). These
/// are Google's published unit prices — the scarce resource the whole
/// adapter is designed around.
abstract final class YouTubeUnitCosts {
  static const int search = 100;
  static const int playlistInsert = 50;
  static const int playlistUpdate = 50;
  static const int playlistDelete = 50;
  static const int playlistItemInsert = 50;
  static const int playlistItemDelete = 50;
  static const int list = 1;
}

/// The persisted daily unit budget (default quota: 10,000/day, resetting at
/// midnight Pacific). A first-class product feature, not plumbing — it
/// powers honest UX ("this transfer needs ~3,400 units; 6,200 remain
/// today") and keeps us provably inside Google's quota terms (docs/09 §2).
class UnitLedger {
  UnitLedger({
    required this._store,
    this.dailyBudget = 10000,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final LedgerStore _store;
  final int dailyBudget;
  final DateTime Function() _now;

  /// Google resets quota at midnight Pacific. A fixed UTC-8 offset is used
  /// deliberately: during daylight saving it under-estimates the budget
  /// window by an hour, which errs on the safe side of the quota.
  static const _pacificOffset = Duration(hours: -8);

  String _dayKey([DateTime? at]) {
    final pacific = (at ?? _now()).toUtc().add(_pacificOffset);
    return '${pacific.year.toString().padLeft(4, '0')}-'
        '${pacific.month.toString().padLeft(2, '0')}-'
        '${pacific.day.toString().padLeft(2, '0')}';
  }

  Duration untilReset() {
    final nowPacific = _now().toUtc().add(_pacificOffset);
    final nextMidnight = DateTime.utc(
      nowPacific.year,
      nowPacific.month,
      nowPacific.day,
    ).add(const Duration(days: 1));
    return nextMidnight.difference(nowPacific);
  }

  Future<int> remaining() async =>
      dailyBudget - await _store.spentOn(_dayKey());

  /// Records [units] against today. Throws [RateLimited] with a
  /// retry-after of the next Pacific midnight when the budget is exhausted
  /// — BEFORE the request is made, so a doomed call never leaves the app.
  Future<void> spend(ProviderId provider, int units) async {
    final day = _dayKey();
    final spent = await _store.spentOn(day);
    if (spent + units > dailyBudget) {
      throw RateLimited(
        provider,
        'YouTube daily unit budget exhausted '
        '($spent/$dailyBudget spent; $units requested)',
        retryAfter: untilReset(),
      );
    }
    await _store.setSpent(day, spent + units);
  }

  /// Plan-time estimate for the transfer wizard: creating one playlist and
  /// inserting [trackCount] tracks, plus [searches] official searches
  /// (zero when the session path handles search).
  int estimateTransfer({required int trackCount, required int searches}) =>
      YouTubeUnitCosts.playlistInsert +
      trackCount * YouTubeUnitCosts.playlistItemInsert +
      searches * YouTubeUnitCosts.search;
}
