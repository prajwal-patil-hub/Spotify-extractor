# Bridgetune — Cross-Platform Music Playlist Migration & Synchronization Platform

> **Status: MVP implemented, demo-runnable.** Roadmap phases 0–8 are complete: the provider
> substrate, matching engine, durable job engine, sync engine, and a Flutter app that runs the
> full pipeline in demo mode all exist and are tested. What remains before real-account use is
> configuration, not code — OAuth client IDs and per-platform secure storage (see
> [§ Running it](#running-it) and [docs/14](docs/14-user-guide.md)). The complete planning
> package that this implementation follows is in [`docs/`](#documentation-index).

Bridgetune migrates and synchronizes music libraries **between** streaming platforms. It is not a
music player and not a local playlist manager — it is an **orchestrator** that creates *real*
playlists inside the destination platform (e.g., a Spotify playlist becomes a genuine YouTube Music
playlist in the user's account). The destination platform always owns the result; users never need
to keep using Bridgetune after a migration.

**MVP scope:** Spotify ↔ YouTube Music, one shared codebase running on Android, iOS, Windows,
macOS, Linux, and the web.

## Documentation Index

| # | Document | Covers (master-prompt deliverables) |
|---|----------|-------------------------------------|
| 01 | [Executive Summary, Vision & Feasibility](docs/01-executive-summary-vision-feasibility.md) | Executive summary · Product vision · Feasibility analysis |
| 02 | [Provider Capability Matrix & Legal](docs/02-provider-capability-matrix-and-legal.md) | API capability matrix (all 8 providers) · Legal / ToS considerations |
| 03 | [Technology Stack & Framework Decision](docs/03-technology-stack.md) | Framework comparison (Flutter / RN / KMP / MAUI / Electron / Tauri) · Recommended stack · Database comparison & choice |
| 04 | [System Architecture](docs/04-architecture.md) | High-level & low-level architecture diagrams · Folder structure · Provider plugin architecture · Capability system design |
| 05 | [Data Model & Database Schema](docs/05-data-model.md) | Database schema · Local-storage policy |
| 06 | [Authentication & Security Architecture](docs/06-auth-and-security.md) | Auth flow diagram · OAuth/PKCE design · Token storage · Security architecture |
| 07 | [Song Matching Engine](docs/07-matching-engine.md) | Matching algorithm design · Confidence scoring · Normalization rules |
| 08 | [Transfer, Jobs & Synchronization](docs/08-transfer-jobs-sync.md) | Transfer sequence diagram · Job queue design · Sync engine design · Duplicate handling · Offline strategy |
| 09 | [Error Handling, Observability & Performance](docs/09-errors-observability-performance.md) | Error handling strategy · Observability · Performance optimization plan |
| 10 | [UI / UX & Design System](docs/10-ui-ux-design-system.md) | Wireframes · Design system specification · Settings & analytics surfaces |
| 11 | [Development Roadmap](docs/11-roadmap.md) | Phase-by-phase roadmap · Future expansion plan (incl. AI features) |
| 12 | [Testing Strategy](docs/12-testing-strategy.md) | Unit / integration / E2E / load / security testing · Manual QA checklist |
| 13 | [CI/CD, Deployment & Maintenance](docs/13-cicd-deployment-maintenance.md) | CI/CD design · Deployment strategy · Maintenance strategy · Git workflow |
| 14 | [User Guide](docs/14-user-guide.md) | Running the app · the screens · demo mode · going to real mode |
| 15 | [Troubleshooting](docs/15-troubleshooting.md) | Transfer/sync symptoms · YTM unit budget · build & CI symptoms · logs |

See also [CHANGELOG.md](CHANGELOG.md) for the phase-by-phase implementation history.

## The One-Paragraph Architecture

A **Flutter** application (single codebase, all six targets) built around four pure-Dart core
packages that know nothing about any specific streaming service: a **provider plugin system**
(every service implements the same `MusicProvider` interface and declares its `Capabilities`), a
**matching engine** (ISRC-first, multi-signal fuzzy scoring with confidence tiers and human
review), a **durable job engine** (checkpointed, resumable background transfers persisted in
**Drift/SQLite**), and a **sync engine** (snapshot-diff based one-way/two-way sync with
user-selectable conflict policies). The UI adapts automatically to each provider's declared
capabilities — no provider-specific logic exists outside its adapter.

## Running it

The project is a Dart pub-workspace monorepo (melos) with a Flutter app at
`apps/bridgetune_app`. You need the Flutter SDK 3.44+ (bundles Dart 3.12+).

```bash
# Run the demo app — the full pipeline over in-memory providers, no credentials needed
cd apps/bridgetune_app
flutter pub get
flutter run                     # choose Chrome, Linux, Android, …

# Run the tests
flutter pub get                 # from the repo root, resolves the whole workspace
for pkg in packages/* tools/*; do (cd "$pkg" && dart test); done
(cd apps/bridgetune_app && flutter test)

# Architecture boundary lint (also enforced in CI)
dart run repo_tools:check_boundaries
```

Demo mode boots two in-memory fake providers so every screen and flow is live before any
OAuth client IDs are configured. Switching to real accounts is a configuration step, not a
code change — see [docs/14 § Going to real mode](docs/14-user-guide.md#5-going-to-real-mode).

## Repository Layout

See [docs/04-architecture.md](docs/04-architecture.md#folder-structure) for the full monorepo
folder structure. The implemented tree: pure-Dart core packages under `packages/`
(`core_domain`, `provider_api`, `provider_spotify`, `provider_ytmusic`, `matching_engine`,
`job_engine`, `sync_engine`, `data_local`, `testing_toolkit`), the boundary-lint tool under
`tools/repo_tools`, and the Flutter app under `apps/bridgetune_app`.

## Contributing & Workflow

Feature branches, small semantic commits, PR review, and phase gates — see
[docs/13-cicd-deployment-maintenance.md](docs/13-cicd-deployment-maintenance.md#git-workflow).
