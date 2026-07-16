import 'dart:async';
import 'dart:math';

/// Token-bucket rate governor, one instance per (provider, account)
/// (docs/09 §2). Callers `acquire()` before every request; 429 handling
/// feeds back through [reportRateLimited], which pauses the bucket and
/// halves throughput for a cool-down (AIMD).
class RateGovernor {
  RateGovernor({
    required this.capacity,
    required double refillPerSecond,
    DateTime Function()? clock,
    Future<void> Function(Duration)? delay,
  }) : _nominalRefill = refillPerSecond,
       _refillPerSecond = refillPerSecond,
       _now = clock ?? DateTime.now,
       _delay = delay ?? ((d) => Future<void>.delayed(d)) {
    if (capacity < 1 || refillPerSecond <= 0) {
      throw ArgumentError('capacity ≥ 1 and refillPerSecond > 0 required');
    }
    _available = capacity.toDouble();
    _lastRefill = _now();
  }

  final int capacity;
  final double _nominalRefill;
  final DateTime Function() _now;
  final Future<void> Function(Duration) _delay;

  double _refillPerSecond;
  late double _available;
  late DateTime _lastRefill;
  DateTime? _pausedUntil;
  DateTime? _penaltyUntil;
  Future<void> _queue = Future<void>.value();

  /// Completes when a token is available. FIFO-fair: concurrent callers are
  /// chained so a burst can't starve earlier waiters.
  Future<void> acquire() {
    final turn = _queue.then((_) => _acquireNext());
    // Errors cannot originate here, but keep the chain unbreakable anyway.
    _queue = turn.catchError((_) {});
    return turn;
  }

  Future<void> _acquireNext() async {
    final paused = _pausedUntil;
    if (paused != null) {
      final wait = paused.difference(_now());
      if (wait > Duration.zero) await _delay(wait);
      _pausedUntil = null;
    }
    _refill();
    if (_available < 1) {
      final deficit = 1 - _available;
      final wait = Duration(
        milliseconds: (deficit / _currentRefill() * 1000).ceil(),
      );
      await _delay(wait);
      _refill();
    }
    _available = max(0, _available - 1);
  }

  /// Honor a 429: hard-pause until [retryAfter] (or a jittered default) and
  /// halve the refill rate for the next ten minutes (docs/09 §2).
  void reportRateLimited({Duration? retryAfter}) {
    final now = _now();
    final pause = retryAfter ?? const Duration(seconds: 5);
    _pausedUntil = now.add(pause);
    _penaltyUntil = now.add(const Duration(minutes: 10));
    _refillPerSecond = _nominalRefill / 2;
    _available = 0;
    // Resume gently: tokens start accruing only once the pause ends, so a
    // long Retry-After never banks a full burst.
    _lastRefill = _pausedUntil!;
  }

  double _currentRefill() {
    final penalty = _penaltyUntil;
    if (penalty != null && _now().isAfter(penalty)) {
      _refillPerSecond = _nominalRefill;
      _penaltyUntil = null;
    }
    return _refillPerSecond;
  }

  void _refill() {
    final now = _now();
    final elapsed = now.difference(_lastRefill).inMicroseconds / 1e6;
    if (elapsed <= 0) return;
    _available = min(
      capacity.toDouble(),
      _available + elapsed * _currentRefill(),
    );
    _lastRefill = now;
  }
}
