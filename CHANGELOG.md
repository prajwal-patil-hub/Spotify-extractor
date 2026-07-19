# Changelog

All notable changes to Bridgetune are recorded here. The project is pre-1.0; the format
follows [Keep a Changelog](https://keepachangelog.com/) loosely, grouped by the roadmap
phase (docs/11) that produced each block of work.

## [Unreleased]

Everything below is on the `claude/music-playlist-migration-4flmv8` branch and has not yet
been tagged for release.

### Phase 8 — Hardening & release scaffolding
- Added the `release` workflow: a `v*` tag builds the web PWA bundle, an unsigned Android
  APK, and a Linux bundle, each uploaded as a versioned artifact. Signing hooks are left for
  GitHub environment secrets — never the repo.
- Added the `nightly` workflow: full package + app test suite (chaos, torture, and golden
  sets included), an informational dependency-outdated report, and a commented live-contract
  placeholder that activates once sandbox-account secrets exist.
- Added the [user guide](docs/14-user-guide.md) and [troubleshooting guide](docs/15-troubleshooting.md);
  troubleshooting is keyed to the observable status chips and report reasons, each mapped to
  its underlying error class.
- Refreshed the README status from "planning" to reflect the implemented phases and how to
  run the demo app and the tests.

### Phase 6 — Flutter application shell
- Added the Bridgetune Flutter app: Riverpod composition root (`AppServices`) that boots in
  demo mode over in-memory fake providers, an adaptive rail/bottom-bar shell, and the
  dashboard, transfer wizard, review, and settings features.
- Added three complete Material 3 themes: Dark, Light, and Old Money.
- The transfer wizard renders only options the destination's capabilities support — the UI
  adapts to providers, never hardcodes them.
- Three full-flow widget tests cover the demo pipeline end to end.

### Phase 7 — Synchronization engine
- Added the sync engine: 3-way membership diff, one-way and two-way planners with a
  mode-aware next-base, and user-selectable conflict policies (manual, keep-both).
- Torture test: five seeds × four rounds × eight mode/policy combinations all converge, and
  a second sync of a converged pair is a no-op.

### Phase 5 — Durable job engine
- Added the checkpointed, resumable `TransferEngine` with a single retry-policy table, plus
  the Drift-backed `DriftJobStore`.
- Kill-anywhere chaos exit gate: crashing at any point across three seeds loses nothing,
  duplicates nothing, and preserves order — crash-only recovery is the normal startup path.

### Phase 4 — YouTube Music provider
- Added the hybrid YTM adapter: the official Data API v3 path metered by a persisted unit
  ledger (refuse-before-request against the daily budget) and a consented innertube session
  path behind a versioned consent gate with a kill switch.
- Contract-suite parity with the reference provider; ledger, consent, and dual-path coverage.

### Phase 3 — Matching engine
- Added the ISRC-first, multi-signal matching engine: table-driven normalizer with hard and
  soft variant flags, weighted signal fusion, confidence tiers, and a margin rule.
- Golden-set harness with adversarial cases; exit gate holds precision at 100%, auto-rate at
  100%, and zero hard-flag violations.

### Phase 2 — Local persistence
- Added the Drift/SQLite schema (deterministic row ids, foreign keys as verbatim constraints)
  and the accounts, snapshot, mapping-cache, and settings repositories.
- 10k-track ingest benchmarked well under the performance gate.

### Phase 1 — Provider substrate
- Added the `MusicProvider` port, the PKCE (RFC 7636 S256) auth substrate, and the FIFO-fair
  rate governor.
- Added the provider contract suite, an in-memory reference provider, and auth fakes.
- Added the Spotify Web API adapter with fixture-backed tests.

### Phase 0 — Foundations
- Scaffolded the Dart pub-workspace monorepo with melos scripts and strict lints.
- Added `core_domain`: entities, the capability model, confidence tiers, and typed errors.
- Added the architecture boundary lint enforcing the docs/04 dependency rules, wired into a
  PR pipeline (format, analyze, boundary lint, per-package tests, secret scan).
- Recorded Phase-0 decisions as ADRs (framework, persistence, plugins, monorepo, models).

### Planning
- Full 30-item planning package: executive summary, feasibility, provider capability matrix
  and legal review, technology-stack decision, architecture, data model, auth/security,
  matching engine, transfer/jobs/sync, error/observability/performance, UI/UX design system,
  roadmap, testing strategy, and CI/CD/deployment/maintenance (docs/01–13).
