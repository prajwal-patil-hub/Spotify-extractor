# 11 — Development Roadmap (Phase-by-Phase) & Future Expansion

Each phase follows the mandated loop: explain → justify → assumptions → risks → compare ≥3
approaches → implement → test → fix → commit small → summarize → **approval gate** before the
next phase. Every phase ends demoable and releasable-in-principle. Durations assume 1–2 engineers.

## Phase 0 — Foundations (1 wk)
Melos monorepo per docs/04 §6 · CI skeleton (analyze, format, test, dependency-boundary lint,
secret scan) · `core_domain` entities + capability model · ADR process (`docs/adr/`).
**Exit:** green CI on all packages; architecture lint fails a deliberate violation test.

## Phase 1 — Provider port + Spotify adapter (2 wk)
`provider_api` port + typed errors · `AuthBroker` PKCE flows (mobile scheme / desktop loopback /
web redirect) · secure token custody · `provider_spotify` reads+writes · contract-test kit +
recorded-fixture tests · rate governor v1. Apply for Spotify extended quota + Google quota
extension **now** (longest lead time in the project).
**Exit:** CLI-level demo: list & create playlists on a real Spotify account on all 6 platforms.

## Phase 2 — Data layer (1.5 wk)
Drift schema (docs/05) + DAOs + migration harness · snapshot ingestion (streamed, batched) ·
mapping cache · settings store.
**Exit:** 10k-track library ingests < 30 s; reactive queries drive a debug list at 60 fps.

## Phase 3 — Matching engine (2.5 wk) — *the quality-critical phase*
Normalizer (table-driven rules + variant flags) · query ladder · scorers · margin rule ·
confidence tiers · golden-set harness: ≥ 500 curated track pairs incl. adversarial cases (lives,
Taylor's Versions, karaoke covers, transliterations).
**Exit:** ≥ 95% auto-match precision on golden set; every miss triaged and documented.

## Phase 4 — YouTube Music adapter (2 wk) — *highest-risk phase, deliberately after the engine
so the fuzzy path is already proven*
Dual-path adapter (official API + consented session path) · consent UX + kill switch · unit-budget
ledger · same contract tests.
**Exit:** Spotify→YTM 100-track playlist transfers correctly end-to-end (manual invocation).

## Phase 5 — Job & transfer engine (2.5 wk)
Durable queue, checkpoint/resume, retry policy, pause/cancel, verification pass, duplicate
handling, platform executors (foreground service / BGTask / desktop isolate / web tab).
**Exit:** kill -9 mid-transfer at any point ⇒ relaunch resumes with zero loss or duplication
(automated chaos test, docs/12 §6).

## Phase 6 — MVP UI (3 wk)
Design system + three themes · onboarding · dashboard · transfer wizard · match review ·
activity/report · settings · a11y pass · golden tests.
**Exit:** a new user migrates a playlist in < 2 min without documentation; AA checks pass.

## Phase 7 — Sync engine (2 wk)
Snapshot 3-way diff · conflict policies · schedules + change detection · sync UI.
**Exit:** two-way sync torture suite (concurrent edits both sides) converges per policy.

## Phase 8 — Hardening & release (2 wk)
Perf gates (cold start, 10k-list jank) · security review vs docs/06 · store packaging (Play/
App Store/notarized dmg/msix/AppImage+flatpak/PWA) · beta program · docs (user guide,
troubleshooting).
**Exit:** MVP shipped: **Spotify ↔ YTM on all six platforms**.

## Phase 9+ — Expansion (each independently shippable)
1. Liked songs / albums / artists everywhere (engine supports it from Phase 5; UI surface).
2. **Apple Music provider** (validates the plugin claim with a hard-different API) → Deezer →
   Tidal → SoundCloud → JioSaavn (consent machinery) — one package each, zero core changes;
   Amazon/Pandora parked pending API access.
3. Optional cloud companion (Phase-9 backend, docs/03 §4): unattended scheduled sync, E2E-encrypted
   state sync between the user's devices.
4. **AI features** (roadmap order by value/effort): playlist-summary & naming suggestions →
   duplicate cleanup → missing-song replacement suggestions (matching telemetry makes this nearly
   free) → similarity/genre/mood analysis → artwork generation. All optional, all off-device
   calls behind explicit opt-in.

**Cut lines if schedule slips:** Old Money theme → post-MVP; web target → beta flag; sync (Phase
7) ships after MVP if needed — one-way transfer alone is a viable v1.0.

Full deliverable-to-document traceability: this roadmap + docs/01–13 cover all 30 master-prompt
output requirements; implementation begins only on approval of this package.
