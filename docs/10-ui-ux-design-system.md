# 10 — UI / UX: Wireframes & Design System Specification

Design intent: the calm confidence of Linear/Notion, the content-forward density of Spotify, the
keyboard-fast utility of Raycast — plus a signature **Old Money** theme that gives the product a
memorable identity. Premium is restraint: one accent, generous whitespace, motion that explains
rather than decorates.

## 1. Information Architecture

```
Onboarding ─ connect first two providers → first transfer in under 2 minutes
Dashboard  ─ sync-pair status · active jobs · recent history · health strip
Transfer   ─ wizard: Source → Select → Destination & options → Review plan → Run
Library    ─ browse any connected account (playlists/likes/albums/artists) + Global Search
Matches    ─ review queue (low-confidence + conflicts) — badge-driven
Activity   ─ job history, reports, audit log, logs export
Settings   ─ accounts · appearance · matching · sync · notifications · privacy · developer
```

Navigation adapts by form factor from one route table: bottom tabs (mobile) · leansail rail
(tablet) · sidebar + command palette `⌘K` (desktop/web).

## 2. Key Wireframes (annotated)

### Dashboard (desktop)

```
┌────────┬──────────────────────────────────────────────────────────────┐
│        │  Good evening, Prajwal            ⌘K Search      ● all OK    │
│  ◈ Home│                                                              │
│  ⇄ Trans│  ┌ Active ────────────────────────────────────────────────┐ │
│  ♫ Libr │  │ ▶ "Liked Songs → YTM"   ▓▓▓▓▓▓▓░░ 71% · ~12 min       │ │
│  ✓ Match│  │   842/1,180 · 3 need review        [Pause] [Details]  │ │
│  ⏱ Activ│  └────────────────────────────────────────────────────────┘ │
│  ⚙ Sett │  ┌ Sync pairs ────────────┐  ┌ Stats (30d) ──────────────┐ │
│        │  │ Gym ⇄ Gym (YTM)   ✓ 2h │  │ 3,412 songs · 97.2% match │ │
│  ────── │  │ Chill → Chill     ⚠ ▸ │  │ avg conf 0.94 · 12 failed │ │
│  Spotify│  └────────────────────────┘  └───────────────────────────┘ │
│  ● YTM  │  Recent: ✓ "Road Trip" → YTM · 64/64 · yesterday          │
└────────┴──────────────────────────────────────────────────────────────┘
```

### Transfer Wizard — step 4 "Review plan" (the trust moment)

```
┌ Review plan ────────────────────────────────────────────────┐
│ Spotify ▸ YouTube Music        3 playlists · 412 tracks    │
│                                                            │
│  ✓ 371 exact/very-high matches      auto                   │
│  ◐  28 high (0.85–0.94)             auto, flagged          │
│  ?  13 need your review             [Review now]           │
│                                                            │
│  ⚠ "Workout" already exists on YTM:  (•) Merge ( ) Skip    │
│      ( ) Replace ( ) Keep both                             │
│  ℹ Artwork won't transfer — YTM doesn't accept custom art  │
│  ◷ Estimated: ~18 min · uses ~2,900 of 6,200 API units     │
│                                    [Back]  [Start transfer]│
└────────────────────────────────────────────────────────────┘
```

### Match Review (side-by-side, explainable)

```
┌ 13 to review ── 4 of 13 ───────────────────────────────────┐
│ SOURCE  Spotify                 CANDIDATES  YouTube Music  │
│ ♪ Fast Car — Tracy Chapman     ◉ Fast Car — Tracy Chapman │
│   Tracy Chapman (1988) · 4:56  │   4:57 · title✓ artist✓  │
│                                 │   duration✓ year✓  0.97  │
│                                 ○ Fast Car — Luke Combs    │
│                                 │   4:25 · artist✗   0.61  │
│                                 ○ Fast Car (Live) …  0.58  │
│  [Search manually] [Skip song]        [Confirm & next ▸]   │
└────────────────────────────────────────────────────────────┘
```

Every candidate shows *why* (per-signal ticks from `signals_json`) — explainability is the
product's trust currency. Mobile variants stack these layouts single-column; the wizard becomes
full-screen steps; review becomes swipeable cards.

## 3. Design System — "Heirloom"

### 3.1 Foundations

- **Type:** Inter (UI) + a serif display face (e.g. Fraunces) reserved for the Old Money theme's
  headings and big numerals. Scale 12/14/16/20/24/32 (1.25 ratio), tabular figures for stats.
- **Spacing:** 4-pt grid; radii 8 (controls) / 12 (cards) / 999 (chips); 1 px hairline borders
  preferred over shadows; elevation ≤ 2 levels.
- **Color:** semantic tokens only (`surface`, `surfaceRaised`, `ink`, `inkMuted`, `accent`,
  `positive`, `caution`, `danger`, `providerBadge/*`) — components never reference raw hex.

| Token | Dark | Light | **Old Money** |
|---|---|---|---|
| surface | #0E1113 | #FAFAF8 | #F5F1E8 (aged ivory) |
| surfaceRaised | #16191C | #FFFFFF | #EDE7D9 |
| ink | #E8EAED | #1A1C1E | #2C2A25 (soft black) |
| accent | #6FD3A6 | #1F7A5C | **#1F4D3A (hunter green)** |
| accent-2 / lines | #3A3F44 | #E4E2DD | #B49A5E (antique gold, hairlines & focus rings) |
| danger | #E5726B | #B3261E | #8C3A2E (oxblood) |

Old Money theme: serif headings, gold hairlines, slightly warm neutrals, denser letter-spacing on
overlines — luxury through typography and restraint, not ornament.

- **Glassmorphism:** subtle and bounded — blur(20) at 70–80% opacity on **overlays only** (command
  palette, sheets, progress HUD), never on content surfaces; auto-disabled on low-end devices and
  when "reduce transparency" is set.
- **Motion:** 150 ms (state) / 250 ms (navigation, shared-axis) / spring for progress bar;
  progress numbers roll; **all motion respects `reduce-motion`**. Nothing bounces.

### 3.2 Accessibility (WCAG 2.1 AA — gating, not aspirational)

Contrast ≥ 4.5:1 body / 3:1 large text verified per theme in CI (golden + contrast lint); full
keyboard navigation + visible focus rings (desktop/web); screen-reader labels with live-region
announcements for job progress ("Transfer 71 percent, 3 songs need review"); touch targets
≥ 44 pt; color never the sole signal (icons + text accompany all status colors); dynamic type up
to 200% without truncation on key flows.

### 3.3 Component inventory (Flutter, in `design_system/`)

Buttons (primary/secondary/ghost/destructive) · provider badge · account chip · playlist card ·
track row (art, title, artists, duration, confidence pip) · confidence meter · progress card
(pause/resume/cancel) · step indicator · comparison panel · empty states · toast/banner system ·
command palette · stat tile · sparkline · themed dialogs/sheets. Each ships with golden tests in
all three themes × light/dark-relevant states.

## 4. Settings & Analytics surfaces (requirement mapping)

**Settings:** Appearance (theme trio, density, language) · Accounts (connect/disconnect,
scopes, YTM-consent management) · Matching (threshold strict/balanced/relaxed, review-always
toggle) · Transfers (duplicate default, order preservation, allow-duplicates) · Sync (schedules,
conflict defaults, notifications) · Privacy (crash-reporting opt-in, export logs, export history,
**Delete Everything**) · Developer mode (API metrics panel, unit ledger, raw logs, contract-drift
alarms).

**Analytics dashboard (local data only):** songs transferred · success rate · failed songs (tap →
retry job) · avg confidence · most-used provider · transfer speed · API p50/p95 + unit spend ·
history timeline · storage usage · sync status board. Rendered with the stat-tile/sparkline
components; no third-party analytics SDK.
