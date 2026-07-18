import 'package:core_domain/core_domain.dart';
import 'package:provider_ytmusic/provider_ytmusic.dart';
import 'package:test/test.dart';

const _provider = ProviderId('ytmusic');

void main() {
  test(
    'spend accumulates within a Pacific day and persists via the store',
    () async {
      final store = InMemoryLedgerStore();
      var now = DateTime.utc(2026, 7, 16, 20); // 12:00 PT
      final ledger = UnitLedger(store: store, clock: () => now);

      await ledger.spend(_provider, 100);
      await ledger.spend(_provider, 50);
      expect(await ledger.remaining(), 10000 - 150);

      // A second ledger over the same store sees the same state (restart).
      final revived = UnitLedger(store: store, clock: () => now);
      expect(await revived.remaining(), 10000 - 150);

      // Next Pacific day: budget resets, old key untouched.
      now = now.add(const Duration(hours: 13));
      expect(await ledger.remaining(), 10000);
    },
  );

  test('exhaustion throws RateLimited with retryAfter until Pacific '
      'midnight', () async {
    final now = DateTime.utc(2026, 7, 16, 20); // 12:00 PT (UTC-8 model)
    final ledger = UnitLedger(store: InMemoryLedgerStore(), clock: () => now);
    await ledger.spend(_provider, 9990);
    await expectLater(
      ledger.spend(_provider, 50),
      throwsA(
        isA<RateLimited>().having(
          (e) => e.retryAfter,
          'retryAfter',
          const Duration(hours: 12), // 12:00 PT → next midnight PT
        ),
      ),
    );
    // The failed spend must not have been recorded.
    expect(await ledger.remaining(), 10);
  });

  test('day key boundary sits at midnight Pacific, not UTC', () async {
    final store = InMemoryLedgerStore();
    // 03:00 UTC = 19:00 PT previous day — both must land on the same key.
    final ledgerLate = UnitLedger(
      store: store,
      clock: () => DateTime.utc(2026, 7, 17, 3),
    );
    final ledgerEarly = UnitLedger(
      store: store,
      clock: () => DateTime.utc(2026, 7, 16, 20),
    );
    await ledgerLate.spend(_provider, 10);
    await ledgerEarly.spend(_provider, 10);
    expect(store.spentKeys.single, '2026-07-16');
  });
}
