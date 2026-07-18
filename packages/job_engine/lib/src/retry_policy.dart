import 'dart:math';

import 'package:core_domain/core_domain.dart';
import 'package:meta/meta.dart';

/// What to do with an item after a [ProviderError] — the single policy
/// table of docs/09 §1.2, exhaustively switched so a new error class
/// cannot ship without a decision here.
@immutable
sealed class ErrorDecision {
  const ErrorDecision();
}

/// Try the item again no earlier than [at].
final class DeferItem extends ErrorDecision {
  const DeferItem(this.at);

  final DateTime at;
}

/// Terminal failure for this item; the job continues.
final class FailItem extends ErrorDecision {
  const FailItem(this.reason);

  final String reason;
}

/// The whole job must pause (reconnect required, disk full…).
final class PauseJob extends ErrorDecision {
  const PauseJob(this.reason);

  final String reason;
}

class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 5,
    this.baseBackoff = const Duration(seconds: 30),
    this.backoffCap = const Duration(hours: 1),
  });

  final int maxAttempts;
  final Duration baseBackoff;
  final Duration backoffCap;

  ErrorDecision decide(
    AppError error, {
    required int attempt,
    required DateTime now,
  }) {
    switch (error) {
      case RateLimited(:final retryAfter):
        // Honors Retry-After verbatim; attempts don't count against the
        // budget — being throttled is not the item's fault.
        return DeferItem(now.add(retryAfter ?? _backoff(attempt)));
      case ProviderUnavailable():
        if (attempt >= maxAttempts) {
          return FailItem('provider unavailable after $attempt attempts');
        }
        return DeferItem(now.add(_backoff(attempt)));
      case AuthExpired():
        return const PauseJob('reconnect required');
      case NotFound():
        return const FailItem('not found at provider');
      case CapabilityUnsupported():
        return const FailItem('capability unsupported');
      case ProviderContractViolation():
        return const FailItem('provider API drift — reported');
      case MatchBelowThreshold():
        return const FailItem(
          'below match threshold',
        ); // routed to review upstream
      case VerificationMismatch():
        return attempt < 2
            ? DeferItem(now)
            : const FailItem('verification mismatch');
      case StorageError():
        return const PauseJob('local storage error');
    }
  }

  Duration _backoff(int attempt) {
    final exp = baseBackoff * pow(2, max(0, attempt - 1)).toInt();
    final capped = exp > backoffCap ? backoffCap : exp;
    // Full jitter keeps a burst of failures from re-synchronizing.
    final jitterMs = Random().nextInt(1000);
    return capped + Duration(milliseconds: jitterMs);
  }
}
