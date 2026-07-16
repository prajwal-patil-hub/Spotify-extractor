import 'package:provider_api/provider_api.dart';
import 'package:test/test.dart';

/// Deterministic time: acquire() delays advance the fake clock instead of
/// sleeping, so timing behavior is asserted exactly and tests run instantly.
class _FakeTime {
  DateTime now = DateTime.utc(2026, 7, 16);
  final List<Duration> sleeps = [];

  DateTime clock() => now;

  Future<void> delay(Duration d) async {
    sleeps.add(d);
    now = now.add(d);
  }
}

void main() {
  test('burst up to capacity passes without waiting', () async {
    final time = _FakeTime();
    final governor = RateGovernor(
      capacity: 3,
      refillPerSecond: 1,
      clock: time.clock,
      delay: time.delay,
    );
    for (var i = 0; i < 3; i++) {
      await governor.acquire();
    }
    expect(time.sleeps, isEmpty);
  });

  test(
    'beyond capacity, callers wait for refill at the configured rate',
    () async {
      final time = _FakeTime();
      final governor = RateGovernor(
        capacity: 2,
        refillPerSecond: 2, // one token every 500 ms
        clock: time.clock,
        delay: time.delay,
      );
      await governor.acquire();
      await governor.acquire();
      await governor.acquire(); // third must wait ~500 ms
      expect(time.sleeps, hasLength(1));
      expect(time.sleeps.single.inMilliseconds, closeTo(500, 10));
    },
  );

  test('tokens replenish while idle, capped at capacity', () async {
    final time = _FakeTime();
    final governor = RateGovernor(
      capacity: 2,
      refillPerSecond: 1,
      clock: time.clock,
      delay: time.delay,
    );
    await governor.acquire();
    await governor.acquire();
    time.now = time.now.add(const Duration(seconds: 30)); // idle
    await governor.acquire();
    await governor.acquire(); // only 2 tokens despite 30 s — capacity cap
    await governor.acquire(); // this one waits
    expect(time.sleeps, hasLength(1));
  });

  test(
    'reportRateLimited pauses until Retry-After and halves throughput',
    () async {
      final time = _FakeTime();
      final governor = RateGovernor(
        capacity: 1,
        refillPerSecond: 2,
        clock: time.clock,
        delay: time.delay,
      );
      await governor.acquire();
      governor.reportRateLimited(retryAfter: const Duration(seconds: 30));

      await governor.acquire();
      // First wait: the hard pause. Second: refill at the HALVED rate
      // (1/s → 1000 ms), not the nominal 500 ms.
      expect(time.sleeps.first, const Duration(seconds: 30));
      expect(time.sleeps.last.inMilliseconds, closeTo(1000, 10));
    },
  );

  test('penalty rate recovers to nominal after the cool-down', () async {
    final time = _FakeTime();
    final governor = RateGovernor(
      capacity: 1,
      refillPerSecond: 2,
      clock: time.clock,
      delay: time.delay,
    );
    await governor.acquire();
    governor.reportRateLimited(retryAfter: const Duration(seconds: 1));
    await governor.acquire(); // consumes during penalty

    time.now = time.now.add(const Duration(minutes: 11)); // cool-down over
    await governor.acquire(); // bucket refilled at some rate; consume it
    await governor.acquire(); // must wait at NOMINAL rate again: 500 ms
    expect(time.sleeps.last.inMilliseconds, closeTo(500, 10));
  });

  test('FIFO fairness: concurrent acquirers are served in order', () async {
    final time = _FakeTime();
    final governor = RateGovernor(
      capacity: 1,
      refillPerSecond: 1,
      clock: time.clock,
      delay: time.delay,
    );
    final order = <int>[];
    await Future.wait([
      for (var i = 0; i < 4; i++) governor.acquire().then((_) => order.add(i)),
    ]);
    expect(order, [0, 1, 2, 3]);
  });
}
