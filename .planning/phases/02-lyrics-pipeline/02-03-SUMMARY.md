---
phase: 02-lyrics-pipeline
plan: 03
subsystem: api
tags: [rails, active-job, solid-queue, turbo-streams, claude-ai, serpapi, nokogiri]

# Dependency graph
requires:
  - phase: 02-02
    provides: ClaudeLyricsService, LyricsSearchService, LyricsScraperService implementations
provides:
  - ImportSongJob with 3-stage Claude-first/scraper-fallback pipeline
  - songs#import controller action that creates Song and enqueues job
  - POST /songs/import route
  - Turbo Stream partials for import status (processing, lyrics, failed)
affects:
  - 02-04 (song show page UI with Turbo Stream status target)
  - 02-05 (search/import form on songs index)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "ImportSongJob: Claude-first recall -> SerpAPI search -> Nokogiri scrape with Turbo broadcast at each stage"
    - "update_column for import_step skips callbacks/validations to avoid triggering model Turbo callbacks during broadcast"
    - "Manual paste path: raw_lyrics param bypasses search/scrape, runs Claude only"
    - "Failed song re-import: find_by(title, import_status: failed) reuses same record — no duplicate created"

key-files:
  created:
    - app/jobs/import_song_job.rb
    - app/views/songs/_processing.html.erb
    - app/views/songs/_lyrics.html.erb
    - app/views/songs/_failed.html.erb
  modified:
    - app/controllers/songs_controller.rb
    - config/routes.rb
    - app/models/song.rb
    - test/controllers/songs_controller_test.rb

key-decisions:
  - "Turbo broadcast partials (_processing, _lyrics, _failed) created in Task 1 as Rule 3 fix — Turbo::StreamsChannel.broadcast_replace_to raises ActionView::MissingTemplate without them"
  - "update_column used for import_step updates during broadcast steps to avoid triggering Turbo model callbacks"
  - "accepts_nested_attributes_for :lyrics added to Song model to enable nested lyric edit form in future plans"

patterns-established:
  - "ImportSongJob pattern: update status -> broadcast -> work -> broadcast result"
  - "Controller import pattern: find failed or create new, then perform_later"

requirements-completed: [SONG-01, SONG-04, LIB-01]

# Metrics
duration: 15min
completed: 2026-03-11
---

# Phase 2 Plan 3: Import Job and Controller Summary

**3-stage ImportSongJob (Claude recall -> SerpAPI search -> Nokogiri scrape) with Turbo Stream broadcasts and songs#import controller action wired to POST /songs/import**

## Performance

- **Duration:** ~15 min
- **Started:** 2026-03-11T00:00:00Z
- **Completed:** 2026-03-11T00:15:00Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- ImportSongJob with full Claude-first/scraper-fallback pipeline and Turbo broadcast at each step
- POST /songs/import creates Song record, enqueues job, redirects to show page
- Manual paste path (raw_lyrics) bypasses search/scrape, runs only Claude
- Failed song re-import reuses same Song record (no duplicate created)
- All 7 job + controller tests GREEN; full suite 23/23 passing

## Task Commits

Each task was committed atomically:

1. **Task 1: Implement ImportSongJob** - `db4d98a` (feat)
2. **Task 2: Add songs#import action and route** - `e748eea` (feat)

_Note: Task 1 included Rule 3 auto-fix for missing Turbo broadcast partials._

## Files Created/Modified
- `app/jobs/import_song_job.rb` - 3-stage import pipeline with Turbo broadcast; Claude-first with scraper fallback
- `app/views/songs/_processing.html.erb` - Status target partial for in-progress import
- `app/views/songs/_lyrics.html.erb` - Status target partial showing completed lyrics
- `app/views/songs/_failed.html.erb` - Status target partial for failed import with paste prompt
- `app/controllers/songs_controller.rb` - Added #import action, updated #index with sanitize_sql_like, updated song_params
- `config/routes.rb` - Added POST /songs/import route as collection action
- `app/models/song.rb` - Added accepts_nested_attributes_for :lyrics
- `test/controllers/songs_controller_test.rb` - Added POST import and GET ?q= filter tests

## Decisions Made
- Created Turbo broadcast partials during Task 1 (not Task 2 as UI plans would normally do) because Turbo::StreamsChannel.broadcast_replace_to requires the partials to exist at job run time — tests fail with ActionView::MissingTemplate otherwise
- Used `update_column` for import_step updates to skip ActiveRecord callbacks, preventing model Turbo callbacks from firing during job broadcast steps

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Created missing Turbo broadcast partials**
- **Found during:** Task 1 (Implement ImportSongJob)
- **Issue:** `Turbo::StreamsChannel.broadcast_replace_to` with `partial: "songs/processing"`, `"songs/lyrics"`, and `"songs/failed"` raised `ActionView::MissingTemplate` — these partials did not exist
- **Fix:** Created `_processing.html.erb`, `_lyrics.html.erb`, and `_failed.html.erb` with minimal but functional markup using `song_status_<%= song.id %>` as the id target
- **Files modified:** app/views/songs/_processing.html.erb, _lyrics.html.erb, _failed.html.erb
- **Verification:** All 3 job tests passed GREEN after creating partials
- **Committed in:** db4d98a (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Auto-fix essential for job tests to pass. Partials were planned for UI plans 04/05 but needed immediately for the broadcast calls in the job. Created minimal functional versions that UI plans can refine.

## Issues Encountered
None beyond the missing partials deviation above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- ImportSongJob fully operational — broadcasts to `song_status_{id}` Turbo Stream target
- songs#import creates Song and enqueues job — ready for UI plans to wire search form
- Turbo broadcast partials exist as stubs — Plans 04/05 can enhance them with full UI
- Full test suite clean (23/23 tests passing)

---
*Phase: 02-lyrics-pipeline*
*Completed: 2026-03-11*
