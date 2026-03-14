---
phase: 02-lyrics-pipeline
plan: 02
subsystem: api
tags: [anthropic, serpapi, faraday, nokogiri, minitest, services]

# Dependency graph
requires:
  - phase: 02-lyrics-pipeline
    provides: anthropic/serpapi/faraday gems, Wave 0 RED test scaffold (02-01)
provides:
  - ClaudeLyricsService.call — Anthropic API wrapper with output_config JSON schema returning structured sections+pinyin hash
  - LyricsSearchService.call — SerpAPI wrapper returning array of up to 3 lyric page URLs
  - LyricsScraperService.call — Faraday+Nokogiri fetcher returning cleaned body text or nil on Faraday::Error
  - Lyric model: numericality validation on position (only_integer, greater_than: 0)
affects: [02-03, 02-04]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Service object pattern: class method .call delegates to instance #call, all dependencies injected via ENV.fetch(key, nil)
    - ENV.fetch with nil default for test compatibility — real env validation left to runtime, not service load
    - Faraday connection created inline in #call so Faraday.stub(:new, ...) intercepts in tests
    - output_config JSON schema passed to Anthropic messages.create for structured output enforcement

key-files:
  created:
    - app/services/claude_lyrics_service.rb
    - app/services/lyrics_search_service.rb
    - app/services/lyrics_scraper_service.rb
  modified:
    - app/models/lyric.rb

key-decisions:
  - "ENV.fetch with nil default (not raise) used in all services so Minitest stubs intercept Anthropic::Client.new and SerpApi::Client.new before the key is actually needed — avoids KeyError in test environment without requiring env vars in CI"
  - "Faraday.new called inline in LyricsScraperService#call (not as a class-level constant) so Faraday.stub(:new, ...) works correctly in tests"

patterns-established:
  - "Service ENV pattern: ENV.fetch(key, nil) so missing keys return nil rather than raising KeyError — tests can stub the client before the key is ever used"
  - "Inline Faraday connection: instantiate Faraday inside #call, not at class level, to keep it stubbable"

requirements-completed: [SONG-01, SONG-02, SONG-03]

# Metrics
duration: 5min
completed: 2026-03-11
---

# Phase 2 Plan 02: Lyrics Pipeline Service Objects Summary

**ClaudeLyricsService/LyricsSearchService/LyricsScraperService implemented as pure Ruby service objects with JSON schema output, all Wave 0 scaffold tests GREEN (8/8)**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-03-10T16:12:37Z
- **Completed:** 2026-03-10T16:17:46Z
- **Tasks:** 1
- **Files modified:** 4

## Accomplishments
- Implemented ClaudeLyricsService with Anthropic messages.create, output_config JSON schema enforcing chars[]/pinyin[] per-line structure
- Implemented LyricsSearchService wrapping SerpAPI client, returning up to 3 lyric page URLs, rescuing all errors to []
- Implemented LyricsScraperService using Faraday+Nokogiri to strip boilerplate (script/style/nav/header/footer/aside) and return body text, returning nil on Faraday::Error
- Added numericality validation on Lyric.position (only_integer: true, greater_than: 0)
- All 8 tests GREEN: 2 ClaudeLyricsService, 2 LyricsSearchService, 2 LyricsScraperService, 2 Lyric model

## Task Commits

Each task was committed atomically:

1. **Task 1: Implement service objects (GREEN)** - `74fbc72` (feat)

**Plan metadata:** (docs commit — pending)

## Files Created/Modified
- `app/services/claude_lyrics_service.rb` - Anthropic API wrapper with output_config JSON schema, MODEL constant set to claude-sonnet-4-5-20250929
- `app/services/lyrics_search_service.rb` - SerpAPI wrapper, MAX_RESULTS=3, rescue all errors to []
- `app/services/lyrics_scraper_service.rb` - Faraday+Nokogiri fetcher, TIMEOUT_SECONDS=10, Mozilla User-Agent, rescues Faraday::Error to nil
- `app/models/lyric.rb` - Added numericality: { only_integer: true, greater_than: 0 } to position validation

## Decisions Made
- Used `ENV.fetch("ANTHROPIC_API_KEY", nil)` and `ENV.fetch("SERPAPI_KEY", nil)` (with nil default) instead of raising KeyError. This allows Minitest stubs to intercept `Anthropic::Client.new` and `SerpApi::Client.new` before the key value is needed, so tests pass without setting env vars. Real production calls will still receive `nil` if keys are unset and fail naturally at the API level.
- Faraday connection instantiated inline in `LyricsScraperService#call` rather than as a class-level constant, preserving Faraday.stub compatibility.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] ENV.fetch with nil default to unblock stubbed tests**
- **Found during:** Task 1 (Implement service objects)
- **Issue:** `ENV.fetch("ANTHROPIC_API_KEY")` raises `KeyError` in test environment before `Anthropic::Client.stub(:new, ...)` has a chance to intercept. Same for `SERPAPI_KEY` — the rescue block in `LyricsSearchService#call` caught the `KeyError` and returned `[]`, causing `urls.first` to be `nil`.
- **Fix:** Changed both `ENV.fetch(key)` calls to `ENV.fetch(key, nil)` so the key lookup never raises, stubs intercept, and all 8 tests pass.
- **Files modified:** `app/services/claude_lyrics_service.rb`, `app/services/lyrics_search_service.rb`
- **Verification:** All 8 tests GREEN after fix; 3 errors before fix.
- **Committed in:** `74fbc72` (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Auto-fix essential for test correctness. No scope creep — ENV.fetch with nil default is an idiomatic pattern for test environments where env vars are not configured.

## Issues Encountered
- `ENV.fetch("ANTHROPIC_API_KEY")` raised `KeyError` in test environment before Anthropic stub could intercept. Same pattern in LyricsSearchService caused its rescue block to swallow the error and return `[]`. Both resolved by using `ENV.fetch(key, nil)`.

## User Setup Required
API keys are required for real usage but not for tests:
- `ANTHROPIC_API_KEY` — Anthropic API key for Claude calls
- `SERPAPI_KEY` — SerpAPI key for Google search results

Both are consumed by services implemented in this plan. Set in `.env` or production credentials before using the lyrics pipeline.

## Next Phase Readiness
- All three service contracts are stable and tested in isolation
- ImportSongJob (Plan 03) can call these services without ambiguity:
  - `ClaudeLyricsService.call(title:, raw_lyrics: nil)` → hash with "unknown" and "sections"
  - `LyricsSearchService.call(title)` → Array of URL strings (up to 3)
  - `LyricsScraperService.call(url)` → String or nil
- Lyric model validates section_type (presence) and position (presence + integer > 0)

---
*Phase: 02-lyrics-pipeline*
*Completed: 2026-03-11*

## Self-Check: PASSED

- All files found: claude_lyrics_service.rb, lyrics_search_service.rb, lyrics_scraper_service.rb, lyric.rb, 02-02-SUMMARY.md
- Commits verified: 74fbc72 (feat)
