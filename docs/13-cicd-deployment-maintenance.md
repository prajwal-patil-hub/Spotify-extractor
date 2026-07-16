# 13 — CI/CD, Deployment, Maintenance & Git Workflow

## 1. CI/CD (GitHub Actions)

```
.github/workflows/
├── pr.yml         # every PR: format check · analyze (fatal-infos) · dependency-boundary
│                  # lint · secret scan (gitleaks) · unit+widget+golden · contract (fixtures)
│                  # · integration · E2E (Android emu + Linux) · coverage gate
├── nightly.yml    # live contract tests (sandbox accounts, secrets in GH env) · full 6-platform
│                  # E2E matrix · perf budgets · golden-set matching report · dep audit
├── release.yml    # tag v* → 6-platform build matrix → sign → store/channel upload
└── quota-watch.yml# daily: YTM unit-ledger sanity + provider reachability probes
```

- **Melos-aware:** only affected packages test on PR (engines change → engine + dependents).
- **Versioning:** SemVer, single app version via melos; **Conventional Commits** feed
  `semantic-release`-style automation: version bump + CHANGELOG.md + tag on merge to `main`.
- Build matrix: `ubuntu` (Linux, web, Android), `macos` (iOS, macOS), `windows` (msix).
- Code signing in CI: Play App Signing · Apple certs via fastlane match (encrypted repo) ·
  Windows Authenticode (Azure Trusted Signing) · macOS notarization — all secrets in GitHub
  encrypted environments, never in the repo (docs/06).

## 2. Deployment Strategy

| Target | Channel | Notes |
|---|---|---|
| Android | Play internal → closed beta → staged prod (10→50→100%) | foreground-service transfer notification reviewed against Play policy |
| iOS | TestFlight → App Store | background-modes justification prepared (BGProcessingTask) |
| macOS | notarized .dmg (site) + optional MAS later | hardened runtime |
| Windows | .msix via site + winget manifest; MS Store later | |
| Linux | Flatpak (Flathub) primary + AppImage | secret-service portal permission |
| Web | PWA on Cloudflare Pages | immutable asset hashes; release-pinned service worker |

Rollout order mirrors risk: desktop/web first (no store review latency), mobile staged.
**Rollback:** staged-rollout halt + previous artifact re-promotion; DB migrations are
forward-only with a startup "too-new schema" guard, so a downgraded binary fails safe.
Remote config (static JSON on CDN, signed, cached offline) carries provider kill switches and
matching-rule data updates — no code release needed for either.

## 3. Maintenance Strategy

- **Provider drift is the steady-state workload:** nightly live contract tests auto-file tagged
  issues (docs/12 §4); each provider package has a CODEOWNER; kill switch buys triage time; SLA:
  drift acknowledged < 48 h, fixed or switched off < 1 wk.
- **Dependencies:** Dependabot weekly, grouped; Flutter SDK pinned per release train, upgraded on
  a 6-week cadence behind a full-matrix branch.
- **Match-quality flywheel:** opt-in correction telemetry → monthly golden-set additions →
  rule-data updates via remote config.
- **Support surface:** in-app Export Logs (redacted) is the support bundle; troubleshooting guide
  keyed by `event` codes from docs/09.
- **Issue triage labels:** `provider-drift` / `match-quality` / `durability` / `platform-{os}` —
  the four failure domains the architecture isolates.

## 4. Git Workflow

- **Trunk-based:** short-lived feature branches off `main`; `main` is always releasable; releases
  are tags (`v1.4.0`), no long-lived release branches until a store forces one.
- **Branch naming:** `feat/…` `fix/…` `docs/…` `chore/…` `provider/{id}/…`.
- **Conventional Commits, small and atomic** (one logical change; generated code committed
  separately as `chore(codegen):`). Examples:
  - `feat(matching): add variant-flag penalty for live/instrumental mismatch`
  - `fix(provider-spotify): honor Retry-After on 429 during playlist read`
- **PRs:** required review; CI green; template sections (intent / approach considered / risk /
  test evidence); golden-set report attached for engine changes. Squash-merge with the PR title
  as the conventional commit.
- **ADRs:** every decision of the shape documented in docs/01–13 gets an `docs/adr/NNNN-*.md`
  entry when made or changed during implementation — the planning docs stay the map, ADRs record
  the journey.
