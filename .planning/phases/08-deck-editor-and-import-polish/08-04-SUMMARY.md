---
phase: 08-deck-editor-and-import-polish
plan: "04"
subsystem: ui
tags: [rails, erb, turbo, import, songs]

# Dependency graph
requires:
  - phase: 08-01
    provides: Test scaffolding with RED baseline tests for IMPORT-01/IMPORT-02

provides:
  - Processing spinner copy reads "Claude is structuring your lyrics..."
  - First step label reads "Searching for lyrics" (not "Searching web")
  - Song show page (done? state) displays "Add this song to a deck ->" link pointing to /decks

affects:
  - import flow UX
  - song library post-import CTA

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Conditional CTA block below title uses @song.done? guard — same pattern as status div conditionals

key-files:
  created: []
  modified:
    - app/views/songs/_processing.html.erb
    - app/views/songs/show.html.erb

key-decisions:
  - "Add-to-deck link placed below song title in header (not inside song_status div) so it survives Turbo Stream replacement of the status area"

patterns-established:
  - "Subtitle CTA pattern: wrap h1 in div, add conditional p.text-sm below; 'Back to Library' link stays as flex sibling at top-right"

requirements-completed:
  - IMPORT-01
  - IMPORT-02

# Metrics
duration: 5min
completed: 2026-03-16
---

# Phase 08 Plan 04: Import Processing Copy and Add-to-Deck CTA Summary

**Replaced "Importing song..." spinner with "Claude is structuring your lyrics..." and added conditional "Add this song to a deck ->" link below the title on done? song show pages**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-03-16T~14:30Z
- **Completed:** 2026-03-16T~14:35Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Processing partial now accurately describes what Claude is doing — copy matches the AI-driven nature of the import
- "Searching for lyrics" replaces the generic "Searching web" step label
- Song show page closes the import loop with a clear CTA linking to /decks, visible only when song is done? (not processing or failed)
- Both IMPORT-01 and IMPORT-02 controller tests pass; all 9 songs controller tests green

## Task Commits

Each task was committed atomically:

1. **Task 1: Update import processing copy (IMPORT-01)** - `db1e5d3` (feat)
2. **Task 2: Add post-import add-to-deck CTA to song show page (IMPORT-02)** - `54cbb09` (feat)

## Files Created/Modified

- `app/views/songs/_processing.html.erb` - Updated spinner label and first step label
- `app/views/songs/show.html.erb` - Wrapped title in div, added conditional add-to-deck sub-link

## Decisions Made

- Add-to-deck link placed below song title in the header section (outside `song_status` div) so it is not overwritten by Turbo Stream broadcasts from ImportSongJob. The `song_status_#{song.id}` div contract is preserved untouched.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

Pre-existing failures in `decks_controller_test.rb` (export button SVG icon assertions) unrelated to this plan's changes. Logged as out-of-scope; not fixed.

## Next Phase Readiness

- Phase 08 plans 01-04 complete. All import and deck editor UX polish requirements fulfilled.
- Remaining pre-existing test failures in decks controller are deferred for a future fix pass.

---
*Phase: 08-deck-editor-and-import-polish*
*Completed: 2026-03-16*
