# 02 — Provider API Capability Matrix & Legal / ToS Considerations

## 1. API Capability Matrix

Legend: ✅ supported by API · ⚠️ partial / constrained · 🔶 unofficial path only · ❌ not possible · — not applicable

| Capability | Spotify | YouTube Music | Apple Music | Deezer | Tidal | SoundCloud | JioSaavn | Amazon Music |
|---|---|---|---|---|---|---|---|---|
| **Auth** | OAuth2 + PKCE | Google OAuth2 (official) / session 🔶 | Developer token + Music-User-Token | OAuth2 | OAuth2 + PKCE | OAuth2 | 🔶 none official | Partner-gated |
| Read playlists | ✅ | ✅ official | ✅ | ✅ | ✅ | ✅ | 🔶 | ⚠️ |
| Create playlist | ✅ | ✅ official (quota-priced) | ✅ | ✅ | ✅ | ✅ | 🔶 | ⚠️ |
| Update playlist (name/desc) | ✅ | ✅ official | ⚠️ name only | ✅ | ✅ | ✅ | 🔶 | ⚠️ |
| Delete playlist | ✅ (unfollow) | ✅ official | ⚠️ | ✅ | ✅ | ✅ | 🔶 | ⚠️ |
| Add/remove/replace tracks | ✅ | ✅ official (50 units/insert) | ✅ add; ⚠️ remove | ✅ | ✅ | ✅ | 🔶 | ⚠️ |
| Reorder tracks / preserve order | ✅ | ✅ | ⚠️ | ✅ | ✅ | ⚠️ | 🔶 | ⚠️ |
| Playlist artwork upload | ✅ (JPEG ≤256 KB) | ❌ (thumbnail auto-generated) | ❌ | ✅ | ⚠️ | ✅ | ❌ | ❌ |
| Playlist description | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 🔶 | ⚠️ |
| Playlist privacy (public/private) | ✅ | ✅ (public/unlisted/private) | ⚠️ | ✅ | ✅ | ✅ | 🔶 | ⚠️ |
| Collaborative playlists | ✅ read flag; ⚠️ member mgmt | ❌ via API | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Liked / saved songs read+write | ✅ | 🔶 (official API: video ratings only) | ✅ | ✅ | ✅ | ✅ likes | 🔶 | ⚠️ |
| Saved albums read+write | ✅ | 🔶 | ✅ | ✅ | ✅ | — | 🔶 | ⚠️ |
| Followed artists read+write | ✅ | 🔶 (channel subs ⚠️) | ⚠️ | ✅ | ✅ | ✅ follows | 🔶 | ⚠️ |
| Catalog search (music-scoped) | ✅ | 🔶 (official search is all-YouTube, 100 units/call) | ✅ | ✅ | ✅ | ✅ | 🔶 | ⚠️ |
| **ISRC exposed on tracks** | ✅ | ❌ | ✅ | ✅ | ✅ | ⚠️ sometimes | ❌ | ⚠️ |
| ISRC-filtered search | ✅ (`isrc:` filter) | ❌ | ✅ (filter[isrc]) | ⚠️ | ✅ | ❌ | ❌ | ❌ |
| UPC on albums | ✅ | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ | ⚠️ |
| Listening history | ⚠️ recent 50 only | 🔶 | ⚠️ heavy rotation only | ✅ history | ⚠️ | — | 🔶 | ❌ |
| Queue | ⚠️ read/modify active queue | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Podcasts | ✅ shows/episodes | ❌ (separate product) | ❌ (separate API) | ✅ | ❌ | ❌ | ❌ | ❌ |
| Smart playlists | ❌ (not exposed) | ❌ | ⚠️ Genius/Station not exposed | ❌ | ❌ | ❌ | ❌ | ❌ |
| Folders | ❌ (not in API) | ❌ | ⚠️ read-only | ✅ | ✅ | — | ❌ | ❌ |
| Rate limits (practical) | Rolling 30-s window (~180 req/min typical) | 10,000 units/day default | ~heavy but generous | 50 req/5 s | documented per-app | per-app | n/a | n/a |
| Pagination max page | 50 (100 playlist items) | 50 | 100 | 100 (variable) | 50–100 | 200 | n/a | n/a |

**Direct consequences for design:**

- **ISRC is the matching backbone** for Spotify ↔ Apple/Deezer/Tidal, but **never available for
  YouTube Music** — the YTM matching path is always fuzzy (docs/07 §4). Cache every confirmed
  Spotify↔YTM track mapping globally (locally) so each pair is matched at most once.
- Capabilities differ so widely that a **runtime capability system is mandatory**, not an
  abstraction nicety (docs/04 §5). E.g., "Transfer artwork" simply doesn't render as an option for
  a YTM destination.
- Several columns marked ⚠️/🔶 must be **re-verified during the phase that implements that
  provider** — streaming APIs change quarterly; the matrix is a snapshot, and CI includes contract
  tests per provider to detect drift (docs/12 §4).

## 2. Legal & Terms-of-Service Considerations

> This section is engineering-level risk analysis, not legal advice. Retain counsel before public
> launch.

### 2.1 Per-provider ToS posture

| Provider | Key terms affecting us | Risk level | Mitigation |
|---|---|---|---|
| **Spotify** | Developer Policy: no transferring Spotify Content *out* for playback elsewhere — but **metadata-based playlist recreation is the established, tolerated pattern** (Soundiiz et al. operate publicly with extended quota). Prohibits caching content beyond documented periods; requires visible attribution & logout | Low–Medium | Store only metadata + mappings; honor 30-day cache guidance for catalog metadata; show Spotify attribution; apply for extended quota before launch |
| **YouTube / YTM** | Official API ToS prohibits circumventing quotas; scraping/automated access outside the API violates YouTube ToS. Internal-API path is formally a ToS breach (borne broadly by the whole competitor field) | **High** (for the session path) | Hybrid adapter (docs/01 §3.2); explicit informed consent screen before enabling the session path; feature-flag to disable remotely; capability degradation keeps app functional without it |
| **Apple Music** | MusicKit terms are permissive for library management apps; requires Apple Developer Program membership; no artwork upload | Low | Straightforward compliance |
| **Deezer / Tidal / SoundCloud** | Standard OAuth API terms; attribution requirements | Low | Standard compliance checklist per provider before enabling plugin |
| **JioSaavn** | No API ⇒ any integration is unofficial | High | Ship only behind the same informed-consent + kill-switch machinery as YTM |
| **Amazon Music** | API is partner-only | Blocking | Do not implement until partnership |

### 2.2 Cross-cutting legal principles baked into the architecture

1. **Metadata only, ever.** No audio bytes are ever downloaded, cached, or transcoded. This keeps
   us out of DRM/copyright territory entirely; playlist *structure* (title lists) is user data.
2. **User-initiated, user-scoped.** Every operation acts on the authenticated user's own library
   at their explicit request — no crawling, no bulk catalog harvesting, no other-user data.
3. **GDPR / privacy by design** (see docs/06 §6): local-first storage; no server-side library copy
   in MVP; export-logs and delete-everything are first-class settings; PII minimization (we never
   need the user's real name or email for core function).
4. **Attribution & branding compliance** per provider brand guidelines (Spotify logo rules,
   "Listen on…" linkouts) tracked as a per-provider launch checklist item.
5. **Kill switches.** Every provider plugin can be remotely disabled (config flag fetched at
   startup, cached offline) so a ToS dispute or API shutdown degrades that one provider instead of
   bricking the app.
6. **Informed-consent UX for unofficial paths.** Before enabling a session-based provider path the
   user sees: what it does, that it is unofficial, the account risk, and must opt in explicitly.
   Consent is versioned and revocable.
