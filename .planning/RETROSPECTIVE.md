# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v1.0 — MVP

**Shipped:** 2026-03-15
**Phases:** 4 | **Plans:** 17 | **Timeline:** 8 days (2026-03-07 → 2026-03-15)

### What Was Built
- Devise auth with email/password, session persistence, and password reset
- 3-stage AI lyrics import: Claude recall → SerpAPI → Nokogiri scrape, with Turbo Stream live status
- Chinese lyrics with auto-generated tone-marked pinyin, structured into verse/chorus/bridge sections
- Interactive deck editor with SortableJS drag-and-drop song and slide arrangement, repeat/delete actions
- AI theme suggestions (5 themes + Unsplash photos) and custom theme form with background image upload
- Python PPTX generator with embedded Noto Sans SC CJK font — Chinese renders on Windows without font install

### What Worked
- Sequential phase dependencies enforced a clean build order — no backtracking across phase boundaries
- Solid Queue + Turbo Stream pattern worked well for long-running AI jobs (lyrics import, theme suggestions, PPTX export) — controller immediately returns; job broadcasts updates
- python-pptx via subprocess was the right call — Ruby gems were all dead ends for CJK; discovered early in Phase 4 research
- Font embedding via ZIP post-processing was simpler and more reliable than fighting python-pptx's font API
- DeckSong.arrangement as JSONB array (not a join-table sort column) made slide repeat/reorder simple with no schema changes

### What Was Inefficient
- Phase 2 (Lyrics Pipeline) was the longest (6 plans) but didn't get a formal VERIFICATION.md — had to be noted as tech debt in the audit
- LyricsSearchService and LyricsScraperService were fully built and tested but never wired into ImportSongJob — approximately a day of work sitting unused; Claude web_search substituted instead
- ThemesController source regression (commit 9b2744f overwrote fix from ae25ffc) required an extra fix commit at milestone close — would have been caught by a code review gate
- Nyquist wave-0 tests were planned for all phases but only partially implemented — test coverage is light, especially for Phase 4

### Patterns Established
- All AI/PPTX work runs in Solid Queue background jobs — never inline in controllers (Thruster timeout risk)
- Turbo Stream 4-state machine for async jobs: pending → generating → ready/error
- Rails.cache with short TTL (10 min) bridges job output to sync download — no ActiveStorage for ephemeral files
- minitest 6.0.2 (Ruby 4.0.1) removed Object#stub and Minitest::Mock — restore as shims in test_helper
- East Asian font slot (a:ea XML element) required on every run rPr for Windows PowerPoint CJK routing

### Key Lessons
1. **Stub at the client boundary, not the service boundary** — ENV.fetch with nil default + stub-in-test-setup avoids KeyError without coupling tests to internal state
2. **Build Turbo broadcast partials in the same plan that creates the job** — Turbo raises MissingTemplate at runtime without them; don't defer to a later plan
3. **JSONB arrangement array beats sort column** — handles duplicates (repeat), arbitrary ordering, and zero-migration slide reordering in one model field
4. **Verify the fix landed in the right commit** — source regression (9b2744f) happened because a merge overwrote an earlier fix; check `git log` after significant PRs

### Cost Observations
- Sessions: ~8-10 across 8 days
- Notable: Phase 2 was the most expensive phase (Claude API calls + SerpAPI + multiple service objects); Phase 4 had the highest per-plan debug time (CJK font embedding required several iterations)

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Phases | Plans | Key Change |
|-----------|--------|-------|------------|
| v1.0 | 4 | 17 | First milestone — baseline established |

### Cumulative Quality

| Milestone | Tests | Coverage | Notes |
|-----------|-------|----------|-------|
| v1.0 | ~50 | Partial | Wave-0 tests planned but not fully executed; Nyquist partial |

### Top Lessons (Verified Across Milestones)

1. Sequential phase gates (no parallelism in v1) eliminated integration surprises — cost: slower throughput
2. Solid Queue + Turbo Stream is the right pattern for any operation > 1s; don't shortcut it
