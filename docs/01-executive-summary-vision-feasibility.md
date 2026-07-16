# 01 — Executive Summary, Product Vision & Feasibility Analysis

## 1. Executive Summary

Bridgetune is a cross-platform playlist **migration and synchronization orchestrator**. Users
connect two or more streaming accounts; Bridgetune reads playlists, liked songs, albums, and
followed artists from a source platform, matches every track against the destination platform's
catalog using a multi-signal matching engine, and creates **real, native playlists** in the
destination account. After migration the destination platform owns everything — Bridgetune keeps
only operational metadata (tokens, mappings, job state, logs), never the music library itself.

**MVP:** Spotify ↔ YouTube Music, bidirectional, on Android, iOS, Windows, macOS, Linux, and web,
from a single Flutter codebase. Every additional service (Apple Music, Deezer, Tidal, JioSaavn,
Amazon Music, SoundCloud, Pandora) ships later as a self-contained provider plugin with zero
changes to core business logic.

**The three hard problems**, in order of difficulty:

1. **Track matching across catalogs.** Catalogs disagree on titles, artists, remasters, regional
   variants, and IDs. We solve this with an ISRC-first pipeline backed by weighted fuzzy scoring
   (title/artist/album/duration/year/explicit-flag), normalization rules, and confidence tiers
   with optional human review below 70% confidence. Match quality is the product; everything else
   is plumbing.
2. **YouTube Music has no official API.** This is the single largest feasibility risk (§3.2). We
   mitigate with a dual-path adapter: the official YouTube Data API v3 where it suffices, and an
   explicitly user-consented session-based path for music-specific operations, isolated entirely
   inside the YouTube provider plugin so a policy change never touches core code.
3. **Durable long-running transfers under rate limits.** A 10,000-song library at real-world API
   quotas takes minutes to hours. We solve this with a checkpointed, resumable job engine that
   survives app restarts, network loss, and sleep, with adaptive batching and per-provider rate
   governors.

## 2. Product Vision

### 2.1 Positioning

"Switch streaming services without losing a decade of curation." The competitive field
(SongShift, Soundiiz, TuneMyMusic, FreeYourMusic) proves demand; Bridgetune differentiates on:

- **True cross-platform reach** — the only serious player targeting all six form factors from one
  codebase (SongShift is iOS-only; Soundiiz is web-only; FreeYourMusic's desktop apps are Electron
  wrappers).
- **Transparent matching** — users see *why* a track matched (signals + confidence), can review
  low-confidence matches before transfer, and can fix mismatches after.
- **Real synchronization** — not just one-shot copy: scheduled, incremental, bidirectional sync
  with explicit conflict policies (Mirror / Merge / Keep Both / Manual).
- **Local-first privacy** — libraries are never stored server-side as a source of truth. The MVP
  requires no backend account at all.

### 2.2 Non-Goals (explicit)

- Not a music player. No playback, no downloads, no audio handling of any kind.
- Not a local playlist manager. The local DB is an operational cache, never the canonical library.
- Not a music discovery product (AI recommendations are a far-future roadmap item, §docs/11).
- No circumvention of DRM, no downloading of audio content, ever.

### 2.3 Success Metrics

| Metric | Target |
|---|---|
| Track match rate (auto, ≥85% confidence) | ≥ 95% on mainstream catalogs |
| False-positive match rate (user-reported) | < 0.5% |
| Transfer completion rate (started → finished) | ≥ 98% (with resume) |
| Cold start | < 2 s on mid-range hardware |
| Library scale | 10,000+ songs, 1,000+ playlists without degradation |

## 3. Feasibility Analysis

### 3.1 What is straightforwardly feasible

| Area | Verdict | Basis |
|---|---|---|
| Spotify read/write (playlists, likes, albums, artists) | ✅ Fully supported | Official Web API, OAuth 2.0 + PKCE, ISRC exposed on tracks, playlist CRUD, image upload |
| One codebase → 6 platforms | ✅ Feasible | Flutter ships stable support for all six targets (see docs/03) |
| Durable background jobs on desktop | ✅ Feasible | Long-lived process; trivial |
| Durable background jobs on mobile | ⚠️ Constrained | iOS gives ~30 s of background time (BGTaskScheduler is opportunistic); Android WorkManager is reliable. Design: checkpoint aggressively, resume on foreground; set user expectations honestly (see docs/08 §7) |
| Matching engine | ✅ Feasible, hard to do *well* | ISRC coverage is high for mainstream music; fuzzy fallback needed for the tail |
| Local-first storage across all 6 targets | ✅ Feasible | Drift/SQLite incl. WASM on web (see docs/03 §3) |

### 3.2 The YouTube Music problem (highest risk in the project)

YouTube Music has **no official public API**. The realistic options:

| Path | What it gives | Cost / risk |
|---|---|---|
| **YouTube Data API v3** (official) | Playlist CRUD, playlist items, search — against *YouTube* (videos), not the Music catalog specifically | Default quota **10,000 units/day**; `search.list` costs **100 units** ⇒ ~100 searches/day/project by default; `playlistItems.insert` costs 50 units ⇒ ~200 track-adds/day. Quota extension requires an audit but is attainable. Search results include non-music videos; matching layer must filter |
| **Unofficial internal API** (the `ytmusicapi` approach: user's own session credentials calling YouTube Music's internal endpoints) | Full music-catalog search (returns songs with album/duration metadata), library access, likes, playlist CRUD — with **no quota** | Violates YouTube ToS if characterized as automated access; endpoints can change without notice; account-risk borne by the user. Precedent: every competitor in this space (Soundiiz, TuneMyMusic, FreeYourMusic) supports YTM this way |
| Hybrid (recommended) | Official API for playlist CRUD (durable, sanctioned, cheap in quota); internal API only where the official one is blind (music-catalog search & likes), with explicit informed user consent | Best durability/function trade-off; risk isolated inside the YTM plugin |

**Decision:** Hybrid path, fully encapsulated in `YouTubeMusicProvider`. The provider's
`Capabilities` object degrades gracefully: if the session path is unavailable or the user declines
it, YTM capabilities shrink to what the official API allows, and the UI adapts automatically
(capability system, docs/04 §5). Quota-extension application to Google is a Phase-1 action item.

### 3.3 Feasibility by future provider (summary — full matrix in docs/02)

| Provider | API status | Verdict |
|---|---|---|
| Apple Music | Official (MusicKit); library write supported; **user playlists created via API are visible but API cannot edit artwork; requires paid Apple Developer account + MusicKit token** | ✅ Feasible |
| Deezer | Official API, OAuth; playlist CRUD | ✅ Feasible (API access requests have been restricted at times — verify at build time) |
| Tidal | Official API (opened up in 2023–24); playlist read/write | ✅ Feasible |
| SoundCloud | Official API; new app registrations historically gated | ⚠️ Feasible, access risk |
| JioSaavn | No official public API | ⚠️ Unofficial only — same treatment as YTM |
| Amazon Music | Official API is invite/partner-gated | ⚠️ Blocked until partnership |
| Pandora | No public API | ❌ Deferred indefinitely |

### 3.4 Cost model

MVP has **zero mandatory server cost**: OAuth PKCE flows need no secret-holding backend for
Spotify; Google OAuth for installed apps likewise. A tiny stateless backend (serverless) is
introduced only when a provider *requires* a confidential client or for optional features
(scheduled cloud sync while devices are offline). This keeps the MVP shippable by a small team and
maximizes privacy.

### 3.5 Overall verdict

**Feasible.** The MVP (Spotify ↔ YTM) is buildable with known techniques; the dominant risks are
(a) YTM API policy volatility — mitigated by plugin isolation + capability degradation, and
(b) matching quality on long-tail catalogs — mitigated by the review UI and continuous
match-telemetry. No identified blocker invalidates the architecture.
