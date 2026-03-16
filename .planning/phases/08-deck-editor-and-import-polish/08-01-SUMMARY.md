---
phase: 08-deck-editor-and-import-polish
plan: "01"
subsystem: testing
tags: [minitest, tdd, rails-test, assert-select, assert-match]

# Dependency graph
requires:
  - phase: 07-content-pages
    provides: existing DecksControllerTest and SongsControllerTest with working setup/fixtures
provides:
  - 9 failing test methods (RED baseline) for all Phase 8 requirements
  - DECK-01 through DECK-06 coverage in decks_controller_test.rb
  - IMPORT-01 and IMPORT-02 coverage in songs_controller_test.rb
affects: [08-02, 08-03, 08-04]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "ApplicationController.render(partial:, locals:) for testing partial in isolation within IntegrationTest"
    - "assert_match with multiline regex for HTML structure checks spanning tag boundaries"

key-files:
  created: []
  modified:
    - test/controllers/decks_controller_test.rb
    - test/controllers/songs_controller_test.rb

key-decisions:
  - "Used ApplicationController.render for export_button ready-state test to isolate partial without triggering a job"
  - "DECK-02 artist test uses multiline assert_match on data-song-search-target='item' context rather than assert_select (selector can't enforce text proximity without nested assertion)"
  - "Created inline done song via Song.create! for IMPORT-02 since songs(:one) fixture has default pending status"

patterns-established:
  - "TDD RED baseline: all 9 new tests fail with assertion failures (not exceptions), giving Wave 1 a clean starting point"

requirements-completed: [DECK-01, DECK-02, DECK-03, DECK-04, DECK-05, DECK-06, IMPORT-01, IMPORT-02]

# Metrics
duration: 12min
completed: 2026-03-16
---

# Phase 8 Plan 01: Deck Editor and Import Polish — Test Scaffolding Summary

**9 failing TDD scaffolding tests across 2 controller test files, covering all Phase 8 DECK and IMPORT requirements as RED baseline for Wave 1 implementation**

## Performance

- **Duration:** ~12 min
- **Started:** 2026-03-16T~14:00Z
- **Completed:** 2026-03-16T~14:12Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- Added 7 failing test methods for DECK-01 through DECK-06 in decks_controller_test.rb
- Added 2 failing test methods for IMPORT-01 and IMPORT-02 in songs_controller_test.rb
- All 9 new tests fail with assertion failures (not errors) — valid RED baseline
- All 22 pre-existing tests continue to pass

## Task Commits

Each task was committed atomically:

1. **Task 1: Add deck editor test scaffolding (DECK-01 through DECK-06)** - `c3438af` (test)
2. **Task 2: Add import flow test scaffolding (IMPORT-01, IMPORT-02)** - `2567383` (test)

**Plan metadata:** _(final docs commit below)_

_Note: TDD tasks have a single RED commit per task — no GREEN commit until Wave 1 implements the features._

## Files Created/Modified
- `test/controllers/decks_controller_test.rb` - 7 new test methods for DECK-01 through DECK-06
- `test/controllers/songs_controller_test.rb` - 2 new test methods for IMPORT-01 and IMPORT-02

## Decisions Made
- Used `ApplicationController.render(partial:, locals:)` for the export_button ready-state test to render the partial with `state: :ready` without requiring an actual job run; simpler than mocking turbo stream state
- DECK-02 artist test uses a multiline `assert_match` on the full response body rather than a nested `assert_select` — CSS selectors cannot enforce that artist text is a descendant of a specific `data-song-search-target="item"` element without brittle multi-level assertions
- Created `Song.create!(import_status: "done")` inline for IMPORT-02 since `songs(:one)` fixture defaults to `import_status: "pending"` (Rails default column value)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- All 9 RED tests ready for Wave 1 plans (08-02 through 08-05) to turn GREEN
- Wave 1 plans implement: section chips, artist in library, export button icons, panel labels, pencil hover, auto-save indicator, processing copy, add-to-deck CTA
- No blockers

---
*Phase: 08-deck-editor-and-import-polish*
*Completed: 2026-03-16*
