import 'capability.dart';
import 'ids.dart';

/// Typed error hierarchy (docs/09 §1). Sealed so the job engine's policy
/// table is compiler-checked for exhaustiveness: adding an error class
/// without deciding its retry policy becomes a compile error, not a
/// production surprise.
sealed class AppError implements Exception {
  const AppError(this.message);

  /// Human-readable, log-safe (never contains tokens or PII by
  /// construction — redaction happens at the sink regardless, docs/06 §4).
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

// ---------------------------------------------------------------------------
// Provider boundary — the ONLY error types a plugin may throw across the port.
// ---------------------------------------------------------------------------

sealed class ProviderError extends AppError {
  const ProviderError(this.provider, super.message);

  final ProviderId provider;
}

/// 429 or provider-specific throttling. [retryAfter] comes from the
/// Retry-After header when present; the rate governor honors it.
final class RateLimited extends ProviderError {
  const RateLimited(super.provider, super.message, {this.retryAfter});

  final Duration? retryAfter;
}

/// Token invalid and refresh failed. Pauses the job (never fails it) and
/// surfaces a reconnect prompt.
final class AuthExpired extends ProviderError {
  const AuthExpired(super.provider, super.message);
}

/// 5xx, DNS failure, timeout — the provider is having a bad day.
final class ProviderUnavailable extends ProviderError {
  const ProviderUnavailable(super.provider, super.message, {this.cause});

  final Object? cause;
}

/// The referenced entity does not exist (deleted playlist, dead track id).
final class NotFound extends ProviderError {
  const NotFound(super.provider, super.message);
}

/// A method was invoked that this provider's current capabilities exclude.
/// Reaching this at runtime is a UI bug — the UI renders from resolved
/// capabilities and should never have offered the action.
final class CapabilityUnsupported extends ProviderError {
  const CapabilityUnsupported(super.provider, super.message, this.capability);

  final Capability capability;
}

/// The provider returned something outside its expected schema — the
/// API-drift alarm (docs/12 §4). Never retried; always telemetered.
final class ProviderContractViolation extends ProviderError {
  const ProviderContractViolation(super.provider, super.message);
}

// ---------------------------------------------------------------------------
// Engine level
// ---------------------------------------------------------------------------

sealed class MatchError extends AppError {
  const MatchError(super.message);
}

/// Best candidate scored below the active threshold → review queue.
final class MatchBelowThreshold extends MatchError {
  const MatchBelowThreshold(super.message, {required this.confidence});

  final double confidence;
}

sealed class TransferError extends AppError {
  const TransferError(super.message);
}

/// Post-transfer read-back did not contain what we wrote (docs/07 §6).
final class VerificationMismatch extends TransferError {
  const VerificationMismatch(super.message);
}

// ---------------------------------------------------------------------------
// Local
// ---------------------------------------------------------------------------

/// Disk full, DB corruption, migration failure. Pauses affected jobs with a
/// blocking remediation dialog.
final class StorageError extends AppError {
  const StorageError(super.message, {this.cause});

  final Object? cause;
}
