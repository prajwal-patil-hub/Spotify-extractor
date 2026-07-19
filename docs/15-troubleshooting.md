# 15 — Troubleshooting

Keyed to the things you can actually observe: the **status chips** and **transfer-report
reasons** the app surfaces (which map 1:1 to the sealed error taxonomy in
[docs/09 §1](09-errors-observability-performance.md)), and the **build/CI** symptoms a
developer hits. Each entry names the underlying error class so a log line and a symptom line
up.

## 1. Transfer & sync symptoms

These reasons come straight from the error taxonomy (`core_domain/errors.dart`); the job
engine's single retry-policy table decides each one's fate, so behavior is uniform.

| What you see | Underlying error | Why | What to do |
|---|---|---|---|
| Transfer slows down, no error | `RateLimited` | The provider returned 429; the rate governor is honoring `Retry-After` and has halved its refill for 10 minutes (AIMD). | Nothing — it is transparent and recovers on its own. Dev mode shows governor stats. |
| Status chip: sustained "Running" with little progress | `ProviderUnavailable` | 5xx / DNS / timeout; the item is deferred with `30s·2ⁿ` backoff (max 5) while the job continues other items. | Wait; if it persists past ~2 min a status chip appears. Check your connection. |
| Action chip: **"Reconnect Spotify"**, job **Paused** | `AuthExpired` | The access/refresh token expired or was revoked. The job is *paused*, not failed. | Reconnect the account; the job resumes from its checkpoint. |
| Report: item **skipped**, reason "not found" / "unsupported" | `NotFound` / `CapabilityUnsupported` | The destination has no such track, or the requested feature isn't in its capability set. | Expected. Nothing to fix — it's recorded in the transfer report. |
| **Match Review** badge; item in review queue | `MatchBelowThreshold` | Confidence fell below the auto-approve threshold (docs/07). | Open Match review, inspect, and skip (or, with the full review UX, pick a candidate). |
| Report: item requeued then reviewed | `VerificationMismatch` | Post-add read-back didn't confirm the track; retried once, then sent to review. | Usually self-heals on the retry. If it reaches review, handle it there. |
| Report: item **failed**, "API drift" telemetry | `ProviderContractViolation` | The provider's API schema changed under us — the response no longer matches the adapter's contract. | This is our bug, not yours. The nightly live-contract job is designed to catch it first; file an issue tagged `provider-drift`. |
| Blocking dialog with remediation; job **Paused** | `StorageError` | Local disk full or a DB migration failure. | Follow the dialog (free space / retry). The job resumes from checkpoint once storage is healthy — crash-only design means restart *is* recovery. |

**No silent loss.** Every source track ends in exactly one terminal state, all of them shown
in the transfer report. A 500-track transfer with 3 failures still completes, with a one-tap
"Retry failed songs" job.

## 2. YouTube Music unit budget

YTM's official API is metered in **units** (10k/day, resetting at midnight Pacific), not raw
request count, and the ledger is persisted.

| What you see | Why | What to do |
|---|---|---|
| Wizard warns "this transfer needs ~N units; M remain today" | The unit ledger projected the plan's cost against your remaining daily budget. | If M < N, either trim the transfer or let it run — it pauses when the budget is exhausted and **resumes automatically tomorrow**. |
| A YTM transfer stalls near end of day | Daily unit budget exhausted. | Nothing — it resumes at the Pacific-midnight reset. |
| YTM has no ISRC matches | YouTube Music does not expose ISRC. | Expected: matching falls back to multi-signal fuzzy scoring for YTM. Not an error. |

## 3. Build & CI symptoms (developers)

| Symptom | Cause | Fix |
|---|---|---|
| `flutter`/`dart` not found in a script | PATH lost `/usr/bin`. | Export `PATH=/opt/flutter/bin:/opt/dart-sdk/bin:/usr/bin:/bin`. |
| `dart pub get` fails fetching `sqlite3` with a native-asset hash mismatch | sqlite3 3.x native-asset download fails its hash check behind the proxy. | Already pinned: `sqlite3: ^2.9.0` (which also pins drift to 2.31.0). Don't bump it without re-verifying the download. |
| Drift codegen silently drops `REFERENCES` clauses | A drift 2.31 codegen quirk in this toolchain: `references(...)` is dropped from generated SQL. | Foreign keys are written as verbatim `customConstraint('... REFERENCES ...')` strings. Keep them that way; the Phase-2 FK test guards this. |
| Boundary check fails: "package X imports Y (not allowed)" | An import or pubspec dependency crosses an architectural boundary. | Fix the dependency, or if it's legitimate, add it to `boundaries.yaml`. Never put provider-specific logic outside its adapter. |
| `dart analyze --fatal-infos` fails on a deprecation | e.g. `RadioListTile.groupValue/onChanged` deprecated in Flutter 3.44. | Use the current API (`RadioGroup<T>` ancestor). Analyzer runs with `--fatal-infos` in CI, so infos block the build by design. |
| `flutter build linux` fails on missing GTK | Linux toolchain deps absent. | `sudo apt-get install -y ninja-build libgtk-3-dev` (the release workflow does this). |
| gitleaks fails in PR CI | A secret-shaped string was committed. | Remove it. Secrets live only in GitHub environment secrets, never in the repo (docs/06). |

## 4. Where the logs are

Structured logs carry `event` codes plus JSON detail, redacted at the sink (docs/06 §4).
In dev they go to the console; in the app they land in the `job_logs` ring buffer (14-day
default) and are exportable via **Settings → Export Logs**. The dashboard runs a startup
self-check (DB `PRAGMA quick_check`, secure-storage probe, per-provider reachability) and
shows a health strip; a red strip there points at which subsystem failed the probe.
