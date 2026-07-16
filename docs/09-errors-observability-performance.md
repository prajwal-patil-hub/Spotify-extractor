# 09 — Error Handling, Observability & Performance

## 1. Error Handling Strategy

### 1.1 Taxonomy (sealed classes in `core_domain` — exhaustiveness checked by the compiler)

```dart
sealed class AppError {}
// Provider boundary (thrown only by plugins, typed at the port)
class RateLimited extends ProviderError { final Duration? retryAfter; }
class AuthExpired extends ProviderError {}
class ProviderUnavailable extends ProviderError {}   // 5xx, DNS, timeout
class NotFound extends ProviderError {}
class CapabilityUnsupported extends ProviderError {}
class ProviderContractViolation extends ProviderError {} // schema drift — page us
// Engine level
class MatchBelowThreshold extends MatchError { final double confidence; }
class VerificationMismatch extends TransferError {}
// Local
class StorageError extends AppError {}   // disk full, migration failure
```

### 1.2 Policy per class (single table drives the job engine — no scattered try/catch decisions)

| Error | Retryable | Job effect | User surface |
|---|---|---|---|
| RateLimited | ✅ honor Retry-After (+ governor slowdown) | item deferred | none (transparent), governor stats in dev mode |
| ProviderUnavailable | ✅ backoff 30s·2ⁿ, max 5 | item deferred; job continues others | status chip if sustained > 2 min |
| AuthExpired | after reconnect | **job paused** (not failed) | "Reconnect Spotify" action chip |
| NotFound / CapabilityUnsupported | ❌ | item failed/skipped with reason | listed in transfer report |
| MatchBelowThreshold | via human | item → review queue | Match Review badge |
| VerificationMismatch | ✅ once, then review | requeue | report |
| ProviderContractViolation | ❌ | item failed | report + telemetry event (API drift alarm) |
| StorageError | ❌ | job paused | blocking dialog with remediation |

Principles: **errors are data, not control flow** (Result-style returns inside engines; exceptions
only cross the provider boundary); **partial success is success** — a 500-track transfer with 3
failures completes with a report and a one-tap "Retry failed songs" job; **no silent loss** —
every source track ends in exactly one terminal state shown in the report; **crash-only design** —
because resume-from-checkpoint always works, the recovery path from *any* unexpected crash is the
normal startup path.

## 2. Rate-Limit Governance (the detailed policy)

Token-bucket per (provider, account) with provider profiles:

| | capacity | refill | concurrency | notes |
|---|---|---|---|---|
| Spotify | 24 | 8/s | 4 | rolling-window observed; back off on 429 |
| YTM official | daily 10k **units** (weighted per endpoint) | midnight PT | 2 | unit ledger persisted; wizard warns when a plan exceeds remaining budget ("resumes tomorrow automatically") |
| YTM session | conservative 1/s | — | 1 | politeness rate; jittered |

429 ⇒ honor `Retry-After`, halve refill for 10 min (AIMD). The **unit-budget ledger** for YTM is a
first-class feature, not plumbing: it powers honest UX ("This transfer needs ~3,400 units; 6,200
remain today").

## 3. Observability

Local-first like everything else; cloud reporting strictly opt-in.

| Layer | Implementation |
|---|---|
| Structured logs | `event` codes + JSON detail → console (dev) + `job_logs` ring buffer (14 d default); redaction at sink (docs/06 §4); Settings → Export Logs |
| Crash reporting | Sentry, **opt-in**, PII-scrubbed, release-health only |
| Transfer metrics | per job: items ok/failed/review, duration, throughput, confidence histogram → powers the Analytics dashboard (docs/10 §4) |
| API metrics | per provider: request count, p50/p95 latency, 429 rate, unit spend → dev-mode panel + drift alarms |
| Match telemetry | per-signal score distributions, correction rate (docs/07 §6) |
| Audit log | every write to a provider (what, where, when, job id) — user-visible; the trust feature |
| Health | startup self-check: DB integrity (`PRAGMA quick_check`), secure-storage probe, per-provider reachability → status strip on dashboard |

## 4. Performance Optimization Plan

Targets: cold start < 2 s · 10k+ songs, 1k+ playlists fluid · minimal memory · parallel API usage.

### 4.1 Cold start (< 2 s)

Defer everything: first frame needs settings + account list + last-jobs summary only (3 tiny
queries). Drift opens lazily per isolate; provider clients construct on first use; no network on
the startup path (dashboard hydrates from snapshots, refreshes after first frame). Measured in CI
on a mid-range Android profile build with a 2 s regression gate (docs/12 §7).

### 4.2 Scale (10k songs / 1k playlists)

- All list UIs virtualized (`ListView.builder`) over **paged Drift queries** (`LIMIT/OFFSET`
  windows, indexed sorts) — memory is O(viewport), not O(library).
- Matching runs in a worker isolate; normalization is precomputed at snapshot-write time
  (`title_norm` column), so scoring never re-normalizes.
- Bulk snapshot writes: batched inserts, 500/transaction, `INSERT OR REPLACE`.
- Search-candidate pool capped (25); mapping cache turns the second occurrence of any track
  into a DB hit.

### 4.3 Network efficiency

Max page sizes everywhere; fields-filtering where supported (Spotify `fields=`, YouTube `part=`);
etag/`snapshot_id` conditional refresh (docs/08 §5); adaptive batch sizing under rate pressure;
parallelism per the governor. Estimated MVP quota math: 100-track playlist Spotify→YTM ≈ 100
search-equivalents + 2 playlist ops + inserts — the mapping cache and query ladder exist precisely
because this is the scarce resource.

### 4.4 Memory & jank budget

Track snapshot rows stream through the pipeline (never "load the library into a List");
images via `cached_network_image` with byte-capped cache; 16 ms frame budget enforced by
`flutter_driver` perf tests on the heaviest screens (10k-row library, live progress).

### 4.5 Caching summary

| Cache | Where | TTL/eviction |
|---|---|---|
| Track mappings | DB | permanent (user-erasable); confirmed-miss rows re-checked after 30 d |
| Library snapshots | DB | stale-after-24 h refresh; LRU size budget |
| Search results | memory (per session) | session |
| Artwork | disk image cache | 100 MB LRU |
| Provider metadata (market, profile) | DB | 7 d |
