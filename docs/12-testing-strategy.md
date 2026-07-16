# 12 — Comprehensive Testing Strategy

Philosophy: the architecture was shaped for testability — pure-Dart engines, one provider port,
typed errors, DB-checkpointed jobs. Tests concentrate where bugs cost most: **matching quality**,
**job durability**, **provider contract drift**.

## 1. Test Pyramid & Gates

| Layer | Scope | Runs | Gate |
|---|---|---|---|
| Unit (bulk) | engines, normalizers, scorers, DAOs, reducers | every PR, < 3 min | 100% pass; coverage ≥ 85% on engine packages |
| Contract | every provider vs the port | PR (fixtures) + nightly (live sandbox) | pass; live drift → alarm issue |
| Widget/golden | components × 3 themes, capability-driven UI | every PR | zero unapproved pixel diffs |
| Integration | wizard→job→report over fake providers + real Drift | every PR | pass |
| E2E | real app, 2 platforms/PR (Android emu + Linux), all 6 nightly | PR + nightly | pass |
| Perf | cold start, 10k-list jank, ingestion | nightly + release | budgets (docs/09 §4) |
| Security | secret scan, dep audit, redaction tests | every PR | zero criticals |

## 2. Unit Testing (highlights)

- Engines are pure Dart ⇒ VM-speed tests, no mocks of Flutter anything.
- Table-driven normalizer tests (one YAML row per rule: input → normalized + variant flags).
- Job state machine: exhaustive transition tests via sealed classes — illegal transitions are
  compile errors, the rest are asserted.
- DAO tests against in-memory SQLite incl. **migration tests**: fixture DB at schema v(n−1) must
  migrate forward losslessly.

## 3. Matching Golden Set (the quality ratchet)

≥ 500 curated cross-catalog pairs: mainstream hits, remaster-vs-original, live/acoustic/
instrumental traps, karaoke/cover imposters, Taylor's-Version-style re-recordings, K-pop/Bollywood
transliterations, feat.-notation variants, duration outliers. Metrics asserted per PR:
**precision ≥ 99% at auto-approve tiers, auto-match rate ≥ 95%, zero variant-flag violations**
(a live version must never auto-match a studio request). Any engine change that moves a metric
requires the golden-set report in the PR description. User corrections (opt-in) feed new cases.

## 4. Provider Contract Tests (drift alarm)

`testing_toolkit` ships one behavioral suite every adapter must pass: pagination exhaustion,
rate-limit surfacing as `RateLimited`, auth-expiry as `AuthExpired`, playlist CRUD round-trip,
order preservation, capability honesty ("declares artwork ⇒ upload works; doesn't ⇒ throws
`CapabilityUnsupported`"). Runs in two modes: **recorded fixtures** (PR, deterministic) and
**live sandbox accounts** (nightly) — a nightly failure with green fixtures = provider API drift,
auto-files an issue tagged to the plugin, never blocks unrelated PRs.

## 5. Integration & E2E

Integration: full transfer pipeline over `FakeProvider` (scriptable latency, 429s, pagination,
catalog) + real Drift — asserts checkpoints, reports, duplicate policies, review-queue routing.
E2E (integration_test + Patrol): onboarding→connect(fake OAuth server)→transfer→report; sync
convergence scenarios; reconnect flow. Live-account E2E against real Spotify/YTM test accounts
runs nightly only, quota-budgeted.

## 6. Durability / Chaos Suite (the Phase-5 exit gate)

Harness kills the app (SIGKILL / process restart) at randomized points during a scripted 1k-item
transfer, relaunches, and asserts: no lost items, no duplicated destination writes (idempotence),
progress monotonic, final state identical to uninterrupted run. Also: network flap injection,
clock skew, disk-full during checkpoint (must pause with `StorageError`, not corrupt).

## 7. Performance, Load & Security Tests

- Load: synthetic 10k-track/1k-playlist account fixtures; ingestion time, memory ceiling, UI
  frame stats (perf budgets in docs/09 §4 enforced as numeric CI gates on profile builds).
- Security: unit tests for the log-redaction sink (tokens injected → must not appear in export);
  gitleaks + `dart pub audit` per PR; PKCE flow tests incl. bad-`state` rejection; quarterly
  manual review against docs/06 threat table.
- A11y: automated contrast lint per theme + screen-reader label lint on key flows.

## 8. Manual QA Checklist (release gate, per platform × 6)

1. Fresh install → onboarding → connect both providers (real accounts) → 50-track transfer OK.
2. Revoke access at provider's site mid-transfer → job pauses with reconnect chip → reconnect →
   resumes.
3. Airplane mode mid-transfer → auto-pause → reconnect → completes; report accurate.
4. Force-quit mid-transfer → relaunch → resumes; destination has no duplicates.
5. Duplicate playlist name → all five collision options behave as labeled.
6. Match review: confirm, manual search, skip each work; corrections persist to mappings.
7. Two-way sync with edits on both sides → converges per chosen policy.
8. Theme trio + reduce-motion + 200% font + screen-reader spot pass.
9. Delete Everything → DB/keys verifiably gone; app returns to onboarding.
10. Kill switch flag off for a provider → provider disappears gracefully, jobs referencing it
    pause with explanation.
