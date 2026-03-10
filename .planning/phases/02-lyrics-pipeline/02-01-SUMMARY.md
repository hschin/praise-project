---
phase: 02-lyrics-pipeline
plan: 01
subsystem: database
tags: [anthropic, serpapi, faraday, minitest, migration, enum, fixtures]

# Dependency graph
requires:
  - phase: 01-auth-foundation
    provides: Song model, Lyric model, Rails app foundation
provides:
  - anthropic ~> 1.23.0, serpapi ~> 1.0, faraday gems declared in Gemfile
  - import_status (pending/processing/done/failed enum) and import_step columns on songs table
  - Wave 0 RED test scaffold for ImportSongJob, ClaudeLyricsService, LyricsSearchService, LyricsScraperService
  - Realistic Chinese worship song fixture data in test/fixtures/lyrics.yml
affects: [02-02, 02-03, 02-04]

# Tech tracking
tech-stack:
  added: [anthropic 1.23.0, serpapi 1.0.3, faraday 2.14.1]
  patterns:
    - TDD RED scaffold — test files exist and fail before service implementation begins
    - Song import_status enum with string values (pending/processing/done/failed) for ActiveRecord serialization safety
    - Object#stub + Minitest::Mock backfilled in test_helper for minitest 6.0.2 compatibility

key-files:
  created:
    - db/migrate/20260310160503_add_import_columns_to_songs.rb
    - test/jobs/import_song_job_test.rb
    - test/services/claude_lyrics_service_test.rb
    - test/services/lyrics_search_service_test.rb
    - test/services/lyrics_scraper_service_test.rb
  modified:
    - Gemfile
    - Gemfile.lock
    - db/schema.rb
    - app/models/song.rb
    - test/test_helper.rb
    - test/models/lyric_test.rb
    - test/fixtures/lyrics.yml

key-decisions:
  - "minitest 6.0.2 (bundled with Ruby 4.0.1) removed Object#stub and Minitest::Mock — both restored in test_helper using minimal Ruby implementations to unblock Wave 0 scaffold"
  - "enum :import_status uses string values ('pending','processing','done','failed') not integer keys, for readability and safe column defaults"
  - "import_status column has default: 'pending' and null: false to ensure all songs have a valid status from creation"

patterns-established:
  - "Wave 0 pattern: test scaffold created before implementation, all service/job tests RED (NameError) until classes exist"
  - "Minitest compatibility shim: test_helper.rb provides Object#stub and Minitest::Mock for minitest 6 projects"

requirements-completed: [SONG-01, SONG-02, SONG-03, SONG-04, LIB-01]

# Metrics
duration: 8min
completed: 2026-03-11
---

# Phase 2 Plan 01: Gems, Migration, and Wave 0 Test Scaffold Summary

**anthropic/serpapi/faraday gems installed, songs.import_status enum migrated, and 5 RED test files scaffolded with minitest 6.0.2 compatibility shim**

## Performance

- **Duration:** 8 min
- **Started:** 2026-03-10T16:04:29Z
- **Completed:** 2026-03-10T16:12:37Z
- **Tasks:** 2
- **Files modified:** 11

## Accomplishments
- Installed anthropic 1.23.0, serpapi 1.0.3, and faraday 2.14.1 gems
- Added import_status (pending/processing/done/failed) enum and import_step column to songs table with migration
- Created Wave 0 RED scaffold: 5 test files covering ImportSongJob, ClaudeLyricsService, LyricsSearchService, LyricsScraperService, and Lyric model
- Updated lyrics.yml fixtures with realistic Chinese worship song data (宇宙之光, 我願意跟隨祢)
- Fixed minitest 6.0.2 incompatibility by restoring Object#stub and Minitest::Mock in test_helper

## Task Commits

Each task was committed atomically:

1. **Task 1: Install gems and run migration** - `05aed53` (feat)
2. **Task 2: Create Wave 0 test scaffold (RED)** - `d482763` (test)

**Plan metadata:** (docs commit — pending)

## Files Created/Modified
- `Gemfile` - Added anthropic, serpapi, faraday gems
- `Gemfile.lock` - Updated with new gem resolutions
- `db/migrate/20260310160503_add_import_columns_to_songs.rb` - import_status (default: "pending", null: false) and import_step columns
- `db/schema.rb` - Updated with new columns
- `app/models/song.rb` - enum :import_status with pending/processing/done/failed string values
- `test/test_helper.rb` - Object#stub and Minitest::Mock restored for minitest 6.0.2
- `test/fixtures/lyrics.yml` - Chinese worship song fixture data replacing MyString placeholders
- `test/jobs/import_song_job_test.rb` - 3 RED tests for ImportSongJob (search path, raw_lyrics path, replace-on-fail path)
- `test/services/claude_lyrics_service_test.rb` - 2 RED tests for ClaudeLyricsService with stubbed Anthropic client
- `test/services/lyrics_search_service_test.rb` - 2 RED tests for LyricsSearchService with stubbed SerpApi client
- `test/services/lyrics_scraper_service_test.rb` - 2 RED tests for LyricsScraperService with Faraday stub
- `test/models/lyric_test.rb` - section_type validation and pinyin field tests (GREEN — validations already present)

## Decisions Made
- minitest 6.0.2 (bundled with Ruby 4.0.1) removed `Object#stub` and `Minitest::Mock`. Both restored in test_helper using minimal Ruby implementations to unblock the scaffold pattern required by the plan.
- `enum :import_status` uses explicit string values (`"pending"`, `"processing"`, `"done"`, `"failed"`) rather than integer keys, ensuring the column default `"pending"` works correctly and values are human-readable in the database.
- `import_status` column declared with `default: "pending", null: false` to ensure all songs have a valid status from creation, preventing nil-check proliferation in service code.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Restored Object#stub and Minitest::Mock for minitest 6.0.2 compatibility**
- **Found during:** Task 2 (Wave 0 test scaffold)
- **Issue:** minitest 6.0.2 (Ruby 4.0.1 bundled gem) removed `Object#stub` and `Minitest::Mock`. The test scaffold specified in the plan uses both. Running the scaffold produced `NoMethodError: undefined method 'stub'` and `NameError: uninitialized constant Minitest::Mock`.
- **Fix:** Added minimal implementations of `Object#stub` (block-based method replacement with ensure restore) and `Minitest::Mock` (expect/verify pattern) directly in `test/test_helper.rb`.
- **Files modified:** `test/test_helper.rb`
- **Verification:** All 11 scaffold tests run without infrastructure errors; 9 fail with expected `NameError: uninitialized constant [ServiceClass]`, 2 lyric model tests pass (validations already present).
- **Committed in:** `d482763` (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Auto-fix necessary to unblock Wave 0 scaffold. The shim exactly replicates the minitest 5 behavior the plan's test patterns depend on. No scope creep — no new test patterns introduced.

## Issues Encountered
- Ruby 4.0.1 ships with minitest 6.0.2 which dropped `Minitest::Mock` and `Object#stub` entirely. The plan's test scaffold was authored for minitest 5.x patterns. Resolved by backfilling both in test_helper rather than downgrading minitest (which would risk Rails 8.1 incompatibility).

## User Setup Required
None - no external service configuration required at this stage. API keys (ANTHROPIC_API_KEY, SERPAPI_KEY) will be needed when services are implemented in Phase 2 Plans 02-03.

## Next Phase Readiness
- Foundation complete: gems installed, schema migrated, Song model has import_status enum
- Wave 0 RED scaffold in place: all 9 service/job tests fail with NameError ready to go GREEN
- Phase 2 Plans 02, 03, 04 can now proceed to implement ImportSongJob, ClaudeLyricsService, LyricsSearchService, LyricsScraperService

---
*Phase: 02-lyrics-pipeline*
*Completed: 2026-03-11*

## Self-Check: PASSED

- All files found: Gemfile, migration, song.rb, 5 test files, fixtures, SUMMARY.md
- Commits verified: 05aed53 (feat), d482763 (test)
