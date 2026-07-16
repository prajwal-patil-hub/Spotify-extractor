# 03 — Technology Stack: Framework Comparison, Database Comparison, Recommended Stack

## 1. Cross-Platform Framework Comparison

Hard requirement: **one shared codebase** targeting Android, iOS, Windows, macOS, Linux, and web.
That single constraint eliminates most candidates immediately, but each is evaluated honestly:

| Criterion | **Flutter** | React Native | Kotlin Multiplatform | .NET MAUI | Electron | Tauri |
|---|---|---|---|---|---|---|
| Android / iOS | ✅ first-class | ✅ first-class | ✅ (Compose MP UI: iOS stable 2025) | ✅ | ❌ | ⚠️ (Tauri 2 mobile, young) |
| Windows / macOS | ✅ stable | ⚠️ (separate community forks: RNW/macOS) | ⚠️ Compose desktop (JVM) | ✅ Win/mac only | ✅ | ✅ |
| **Linux** | ✅ stable | ❌ effectively none | ⚠️ JVM desktop | ❌ **no Linux target** | ✅ | ✅ |
| Web | ✅ (CanvasKit/WASM; fine for app-like UI, weak for SEO — we don't need SEO) | ⚠️ react-native-web (divergent) | ⚠️ Kotlin/WASM alpha-quality | ❌ | — (is web tech, not a web target) | ⚠️ needs separate web build |
| Single UI codebase, native feel | ✅ pixel-owned rendering, Material+Cupertino, custom design system easy | ⚠️ per-platform drift | ⚠️ two UI stacks in practice | ⚠️ | ⚠️ web UI in desktop shell | ⚠️ web UI |
| Background work / long-running jobs | ✅ isolates + WorkManager/BGTask bridges | ✅ (native modules) | ✅ | ✅ | ✅ desktop only | ✅ desktop; mobile young |
| Perf for our workload (I/O-bound API orchestration, 10k-item lists) | ✅ excellent (isolates, ListView virtualization) | ✅ adequate (Hermes) | ✅ | ✅ | ⚠️ RAM-heavy | ✅ lean |
| Ecosystem for our needs (OAuth, secure storage, SQLite, workmanager) | ✅ mature packages on all 6 targets | ✅ mobile-mature, desktop-poor | ⚠️ expect/actual glue per target | ⚠️ | ✅ (Node) desktop-only | ⚠️ Rust glue |
| Team-scaling / hiring | ✅ one language (Dart) | ✅ JS/TS | ⚠️ Kotlin+Swift boundary skills | ⚠️ C# | ✅ | ⚠️ Rust+JS |
| Longevity risk | Low (Google flagship; huge install base) | Low | Low | Medium | Low | Medium |

### Verdict — **Flutter**, decisively

It is the **only** framework where all six required targets are first-party and stable, from one
codebase, with one language and one rendering pipeline. The runner-ups fail the hard requirement,
not on taste:

- **.NET MAUI** — no Linux. Disqualified outright.
- **React Native** — Windows/macOS are community-maintained forks and Linux support is effectively
  absent. We'd ship three codebases pretending to be one.
- **Kotlin Multiplatform** — genuinely attractive for shared *logic*, but the UI story across six
  targets means Compose-JVM on Linux desktop + wasm-alpha web; too much frontier risk for a
  product whose value is reliability.
- **Electron / Tauri** — no (mature) mobile story ⇒ would force a second mobile codebase, the
  precise thing the requirement forbids.

Honest Flutter trade-offs we accept: web output is canvas-rendered (fine — this is a logged-in
tool, not a content site); desktop system-tray/background nuances need small platform channels;
Dart is a smaller talent pool than JS. All acceptable against the alternative of multiple
codebases.

## 2. Language & Core Libraries

| Concern | Choice | Rationale |
|---|---|---|
| Language | Dart 3 (sound null-safety, sealed classes, records, pattern matching) | Sealed classes model provider results/errors perfectly |
| State management | **Riverpod** (v2, codegen) | Compile-safe DI + reactive state; testable without widget tree; scales to modular packages |
| Immutable models / unions | freezed + json_serializable | Exhaustive pattern matching over sync/transfer states |
| HTTP | dio + interceptors | Per-provider interceptors: auth refresh, rate-limit governor, retry, logging |
| Persistence | **Drift** over SQLite (§3) | See database comparison |
| Secure storage | flutter_secure_storage (Keychain / Keystore / DPAPI / libsecret) + AES-GCM app-layer envelope for web | Token custody, docs/06 |
| OAuth | flutter_appauth (mobile) + loopback/custom-scheme flow (desktop) + oauth2 (web) | PKCE everywhere |
| Background execution | workmanager (Android), BGTaskScheduler bridge (iOS), long-lived isolate (desktop), foreground tab loop (web) | Job engine substrate, docs/08 |
| Navigation | go_router | Deep links (OAuth redirects) + declarative routing |
| Localization | ARB / intl | Settings requirement |
| Logging/metrics | structured logger → local ring buffer + optional Sentry crash reporting | docs/09 |
| Testing | flutter_test, mocktail, integration_test, golden_toolkit | docs/12 |

## 3. Database Comparison & Decision

Requirements: relational job/mapping queries, transactions, migrations, reactive queries into the
UI, **runs on all six targets**, handles 10k+ tracks × mapping cache × job checkpoints.

| Option | Type | All 6 targets? | Strengths | Disqualifiers / weaknesses |
|---|---|---|---|---|
| **Drift** | Type-safe reactive SQL over SQLite | ✅ (native FFI + WASM/OPFS on web) | Compile-time-checked SQL, migrations, streams, transactions, isolate-safe; SQLite's reliability | Codegen step (fine) |
| Raw SQLite (sqflite/sqlite3) | SQL | ⚠️ (sqflite is mobile-only; sqlite3 pkg covers more) | Full control | Hand-rolled mapping layer = Drift minus safety; no reactive queries |
| Isar | NoSQL object DB | ⚠️ web support weak; **maintenance stalled** (v3→v4 limbo since 2023) | Fast, nice API | Longevity risk is disqualifying for the system of record |
| Realm | Object DB + sync | ⚠️ | Mature mobile heritage | **MongoDB deprecated Atlas Device Sync (2024) and Realm SDK investment collapsed** — disqualified |
| Hive | Key-value boxes | ✅ | Tiny, fast | No queries/joins/transactions across boxes — wrong shape for jobs & mappings; fine as a cache, redundant next to SQLite |
| Supabase (Postgres) | Cloud BaaS | n/a (server) | Would give cloud sync | **Violates local-first requirement** as primary store; adds mandatory account + server cost to MVP. Reserved as an *optional* future sync backend |

### Verdict — **Drift (SQLite)**

The workload is relational (jobs ⟶ items ⟶ mappings ⟶ tracks), needs ACID checkpoints for
resumable transfers, and needs reactive queries for live progress UI. Drift is the only option
that delivers all of that with compile-time safety on every target including web (WASM + OPFS).
Schema in docs/05. Hive/Isar remain available later as ephemeral caches if profiling ever
justifies them; Supabase remains the candidate for the *optional* Phase-9 cloud-sync add-on.

## 4. Recommended Stack (one page)

```
UI          Flutter 3.x · Riverpod · go_router · custom design system (docs/10)
Domain      Pure-Dart packages: core_domain · matching_engine · sync_engine · job_engine
Providers   Plugin packages: provider_api (interface) · provider_spotify · provider_ytmusic · …
Data        Drift/SQLite (all targets) · flutter_secure_storage (+ AES-GCM envelope)
Network     dio · per-provider interceptor stack (auth / rate-limit / retry / telemetry)
Background  workmanager · BGTaskScheduler · desktop isolate service · web foreground loop
Auth        OAuth 2.0 + PKCE everywhere · flutter_appauth / loopback redirect
Backend     NONE for MVP (PKCE public clients). Optional later: serverless token broker +
            scheduled-sync workers (Cloudflare Workers/Fly.io + Supabase) — Phase 9
Quality     GitHub Actions CI · unit/widget/integration/E2E · golden tests · contract tests
Observability  structured local logs · Sentry (opt-in) · local metrics dashboard (docs/09)
```
