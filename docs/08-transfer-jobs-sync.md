# 08 — Transfer Engine, Background Job Engine & Synchronization Engine

## 1. Job Engine — design

Requirements: jobs survive restart / network loss / sleep; pausable, resumable, cancellable;
progress + ETA; retry with backoff; UI-independent.

**Chosen design: DB-backed durable queue** (`transfer_jobs` + `job_items`, docs/05) executed by a
platform-appropriate runner. Alternatives rejected: in-memory queue with periodic persistence
(loses the crash-consistency guarantee that *is* the requirement) and OS-scheduler-as-queue
(WorkManager/BGTask as the source of truth — non-portable semantics across six platforms; instead
the OS schedulers merely *wake* our portable runner).

```mermaid
flowchart LR
    subgraph Durable state (Drift)
        Q[(transfer_jobs)] --- I[(job_items)]
    end
    subgraph Runner (background isolate)
        S[Scheduler\npriority + fairness] --> W1[Worker: match]
        S --> W2[Worker: write batch]
        S --> W3[Worker: verify]
        G[Rate governor\nper provider] -.throttles.- W1 & W2 & W3
    end
    OS[WorkManager / BGTask / desktop service / web tab] -- wakes --> S
    Q <--> S
    I <--> W1 & W2 & W3
    UI[UI streams] <-. reactive queries .-> Q
```

- **Checkpoint unit = a batch of `job_items` in one SQLite transaction.** Resume is a query, not a
  recovery procedure. Batch size adapts: default 50 (Spotify add-tracks page = 100, YTM inserts
  priced per item), halved on rate-limit pressure.
- **State machine (job):** `queued → running ⇄ paused → completed | failed | cancelled`, plus
  `needs_review` (non-terminal; resumes when the user clears the review queue). Item states in
  docs/05. Illegal transitions are unrepresentable (sealed classes).
- **Retry policy:** per-item exponential backoff with jitter (30 s · 2ⁿ, cap 1 h, max 5 attempts)
  for retryable errors (`RateLimited` honors `Retry-After` instead); non-retryable errors
  (`NotFound`, `CapabilityUnsupported`) fail the item immediately into the report. `AuthExpired`
  **pauses the job** (not fails) and surfaces a reconnect prompt.
- **Priorities & fairness:** interactive transfers > scheduled syncs > metadata refresh; round-robin
  across jobs sharing a provider so one giant library sync can't starve a small playlist transfer.
- **ETA:** rolling throughput (items/min over last 5 min) × remaining items, damped; displayed
  with honest uncertainty ("~12 min").

### Platform execution matrix

| Platform | Mechanism | Honest behavior promise shown to user |
|---|---|---|
| Desktop (Win/mac/Linux) | Long-lived background isolate; optional close-to-tray | Runs to completion while app is open/in tray |
| Android | Foreground service (user-visible progress notification) via workmanager for active transfers; WorkManager for scheduled syncs | Survives screen-off; Doze-safe |
| iOS | Runs while foregrounded + ~30 s grace on background; `BGProcessingTask` opportunistically continues; checkpoint every batch | "Keep the app open for large transfers — we'll resume exactly where you left off otherwise" |
| Web | Foreground tab execution + Page Visibility handling; checkpoint every batch | "Keep this tab open" banner |

**We do not pretend iOS/web can do unattended background work** — instead the checkpoint design
makes interruption a non-event, and scheduled sync on those platforms runs on app-open
(catch-up semantics). True unattended scheduled sync is the Phase-9 optional cloud worker.

## 2. Transfer Engine — playlist transfer sequence

The full sequence diagram is in docs/04 §3. Supplementary semantics:

- **Parallelism:** across providers, unlimited by design (source reads ∥ destination writes);
  within a provider, governed by the rate governor (Spotify ~4 concurrent, YTM sequential).
  Matching is CPU-cheap and I/O-bound → worker pool sized by provider budget, not cores.
- **Order preservation:** `job_items.seq` mirrors source position; destination adds are issued in
  seq order per batch; a final reorder pass runs where the destination API required
  append-then-move.
- **Verification pass** per playlist: read back, diff against expectation, requeue misses.
- **Pause/Resume/Cancel:** flags on the job row; workers observe between batches (≤ seconds of
  latency). Cancel leaves the destination playlist as-is (partial), clearly labeled in history —
  destructive rollback is never automatic.
- **Detailed logs:** every item's journey (`job_logs`) is inspectable from the report screen.

## 3. Duplicate Handling

Detection happens at plan time (before any write), against destination snapshots refreshed at
that moment:

- **Playlist-level:** name-collision (normalized) → user chooses per playlist or globally:
  **Skip / Replace / Merge / Rename ("Imported – {name}") / Create Copy**. "Replace" is the only
  destructive option and requires explicit confirmation listing what will be overwritten.
- **Track-level (within merge/sync):** destination track IDs + mapping table identify tracks
  already present → default Skip (idempotence), optional "allow duplicates" toggle for playlists
  where repetition is intentional.
- **Idempotence rule:** re-running any completed transfer is a no-op. Guaranteed by plan-time
  dedup against the refreshed destination + mapping cache — this is what makes retries and
  resumes safe.
- Low-confidence situations (e.g. fuzzy name collision "Workout" vs "workout 2024") always ask.

## 4. Global Search (unified)

`searchAll(query)` fans out to every *connected* provider's `searchTrack` in parallel, normalizes
results into `core_domain` types, groups near-identical tracks via the same scoring machinery
(a track that appears on N providers renders as one row with N provider badges), ranks by
(text relevance, popularity prior). Per-provider failures degrade to a badge, never an error page.

## 5. Synchronization Engine

### 5.1 Model: snapshot 3-way diff (chosen over event-log CRDT — providers give us no events;
polled state is the only truth available, so the design embraces it)

For a sync pair, three states exist: **Base** (last agreed state, `base_state_json`),
**Source now**, **Destination now** (fetched via cheap change detection: compare
`provider_etag`/`content_hash` first; full refetch only on change).

```
ΔS = diff(Base, SourceNow)      ΔD = diff(Base, DestNow)
```

| Case | One-way (S→D) | Two-way |
|---|---|---|
| ΔS only | apply ΔS to D | apply ΔS to D |
| ΔD only | policy: mirror ⇒ revert D; merge/keep ⇒ leave | apply ΔD to S |
| Both, disjoint tracks | apply ΔS | apply both |
| Both, same track (conflict) | source wins | **conflict policy** |

Diffs are computed as add/remove/move sets over mapped track identities (mappings make the two
playlists comparable at all). New unmapped tracks flow through the matching engine exactly like a
transfer — sync is a thin orchestration over the same job machinery (`kind=library_sync` jobs).

### 5.2 Conflict policies (user-selected per pair)

- **Mirror Source** — destination is a replica; destination-side edits are reverted (stated
  clearly at setup).
- **Merge** — union of adds; deletions propagate only if the track is deleted on the side that
  originally contributed it (prevents delete-echo wars).
- **Keep Both** — no deletions ever propagate; adds propagate both ways.
- **Manual** — conflicting ops queue in a review UI (same component as match review); run state
  `conflicts_pending`.

After a successful run, Base := the new agreed state (atomically with the run record).
**Version tracking** = retained `sync_runs.diff_json` history, giving the user an auditable
change log per pair.

### 5.3 Triggers

Manual · Scheduled (`schedule_cron`, executed by the platform scheduler where real, on-app-open
catch-up otherwise) · Change-detected (opportunistic etag polling with adaptive interval,
15 min–24 h by observed playlist volatility). Deleted-song and new-song propagation are just diff
entries — no special path.

## 6. Offline Strategy

- **Reads:** all library browsing serves from snapshots instantly (stale-while-revalidate;
  staleness badge after 24 h).
- **Writes/jobs:** enqueue offline freely; scheduler gates on connectivity (connectivity_plus),
  auto-resumes on reconnect — mid-transfer network loss is just a pause (checkpoints, §1).
- **Never queued offline:** auth flows and destructive confirmations (need live provider truth).
- **Sync while offline:** skipped, logged, caught up on next opportunity; conflict window widens
  gracefully because 3-way diff doesn't care *when* Base diverged.
