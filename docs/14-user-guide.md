# 14 — User Guide

This guide covers the Bridgetune app as it ships today: the demo build, the transfer
wizard, the review queue, and settings. It is written for someone using the app, not
building it — for architecture see [docs/04](04-architecture.md), for the roadmap see
[docs/11](11-roadmap.md).

## 1. What Bridgetune does

Bridgetune moves and keeps in sync your playlists and liked songs **between** streaming
platforms. It creates *real* playlists inside the destination service — a Spotify playlist
becomes a genuine YouTube Music playlist in your own account. The destination platform owns
the result; you never have to keep using Bridgetune after a migration.

It is **not** a music player and **not** a local playlist manager.

## 2. Running the app

The MVP runs from source. You need the Flutter SDK (3.44+, which bundles Dart 3.12+).

```bash
cd apps/bridgetune_app
flutter pub get
flutter run          # pick a device: Chrome, Linux, Android, etc.
```

To produce a release build for a target, e.g. the web PWA:

```bash
flutter build web --release          # output in build/web
```

Android, Linux, macOS, Windows, and iOS builds use the corresponding
`flutter build <target>` commands; the [release workflow](../.github/workflows/release.yml)
builds web, Android, and Linux automatically from a `v*` tag.

### 2.1 Demo mode

The app currently boots in **demo mode**. Two in-memory providers (a Spotify-shaped one and
a YouTube-Music-shaped one) are pre-seeded with catalogs, so every screen and every flow is
fully live — you can run a real transfer end to end, watch the job engine checkpoint, and
work the review queue — without any OAuth client IDs configured. Demo mode is the same code
path as real mode: only the two provider constructions and the job store are swapped when
real credentials are wired in (see `AppServices` in `lib/state/services.dart`).

## 3. The screens

### 3.1 Dashboard

The landing screen. It shows three headline stats (songs processed, transfers completed,
awaiting review) and a card per transfer with a live progress bar and a status chip. The
chip reflects the job's real state: **Queued**, **Running**, **Needs review**, **Paused**,
**Completed**, **Failed**, or **Cancelled**. Start a new transfer with the **New transfer**
button.

### 3.2 Transfer wizard

A short guided flow:

1. **Source & destination** — choose which platform to copy from and which to copy into.
2. **What to move** — pick a playlist (or your liked songs).
3. **Options** — the wizard only shows options the destination actually supports. If the
   destination cannot set a playlist description or privacy, or cannot upload artwork, those
   controls simply aren't offered. This is the capability system at work: the UI adapts to
   each provider's declared capabilities, never hardcodes them.
4. **Confirm** — Bridgetune creates the destination playlist for real and begins matching
   and adding tracks. Progress streams back to the dashboard.

Every source track ends in exactly one terminal state — added, skipped, or sent to review —
and nothing is silently lost.

### 3.3 Match review

Not every song matches with enough confidence to add automatically. Tracks the matching
engine could not confidently place land here (docs/07 covers the confidence tiers). For each
one you see the source song, which transfer it came from, and why it needs attention. In the
MVP you can inspect and **skip** an item; side-by-side candidate comparison with per-signal
explanations is the next review-UX increment. When a job's review queue is emptied, the job
moves on to **Completed** on its own.

### 3.4 Settings

Theme selection (Dark, Light, and the **Old Money** theme), and the surfaces described in
docs/10 §4. Secure-storage-backed account connections appear here once OAuth client IDs are
configured for real mode.

## 4. Themes

Three complete Material 3 color schemes ship: **Dark** (default), **Light**, and **Old
Money** — a muted, cream-and-forest-green palette with a warm gold outline. Switch themes in
Settings; the choice applies instantly across the app.

## 5. Going to real mode

Real mode is a configuration step, not a code change. It needs, from you:

- A **Spotify** application (client ID) registered in the Spotify Developer Dashboard, with
  the redirect URI Bridgetune uses. For non-trivial volume, apply for Spotify's extended
  quota.
- A **Google Cloud** project with the YouTube Data API v3 enabled and an OAuth client ID.
  For non-trivial volume, apply for a YouTube API quota extension.

Once those exist, the two provider constructions and the job store in `AppServices` swap to
their production implementations; secure token storage is provided per platform. No other UI
or engine code changes — that is the point of the plugin boundary.

See [docs/06](06-auth-and-security.md) for the auth and token-storage design and
[docs/02](02-provider-capability-matrix-and-legal.md) for the per-provider quota and ToS
notes.
