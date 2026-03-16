---
phase: 08-deck-editor-and-import-polish
plan: "03"
subsystem: ui
tags: [stimulus, tailwind, hotwire, deck-editor]

# Dependency graph
requires:
  - phase: 08-01
    provides: test scaffolding for DECK-02/04/05/06 baseline RED tests

provides:
  - auto_save_controller.js Stimulus controller with show() and indicator target
  - Split "ARRANGEMENT" / "ADD SONGS" sub-labels in deck editor left panel
  - Artist secondary text in library song list items
  - Title pencil button hover-only with opacity-0 group-hover:opacity-100
  - Saved indicator wired via turbo:submit-end->auto-save#show

affects:
  - deck editor visual polish
  - DECK-02, DECK-04, DECK-05, DECK-06 requirements

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Auto-save indicator pattern: Stimulus controller with setTimeout + clearTimeout guard for transient badge display"
    - "Conditional artist display: song.artist.present? guard in ERB for optional secondary text"

key-files:
  created:
    - app/javascript/controllers/auto_save_controller.js
  modified:
    - app/views/decks/show.html.erb
    - test/controllers/decks_controller_test.rb

key-decisions:
  - "Label text written as uppercase literals (ADD SONGS, ARRANGEMENT) rather than relying on CSS text-transform — ensures test assertions with regex match the HTML response body"
  - "auto-save data-controller wraps only the arrangement sub-label row, not the entire left panel, to keep turbo:submit-end event scope tight"

patterns-established:
  - "Uppercase label literals: write h2 content in CAPS when Tailwind uppercase class is applied, so integration tests can assert the literal string"
  - "Inline Song.create!(import_status: 'done') for tests that need library panel items — fixture songs default to pending status"

requirements-completed:
  - DECK-02
  - DECK-04
  - DECK-05
  - DECK-06

# Metrics
duration: 15min
completed: 2026-03-16
---

# Phase 8 Plan 03: Deck Editor Polish Summary

**Deck editor left panel polished with split ARRANGEMENT/ADD SONGS labels, auto-save Stimulus controller, artist secondary text, and hover-only title pencil**

## Performance

- **Duration:** ~15 min
- **Started:** 2026-03-16T14:26:00Z
- **Completed:** 2026-03-16T14:30:37Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- New `auto_save_controller.js` Stimulus controller — shows "Saved" badge for 2s after arrangement changes, with clearTimeout guard for rapid submissions
- Left panel label split: "ARRANGEMENT" header above sortable list with auto-save indicator, "ADD SONGS" header above library search section
- Library song list items now show `song.artist` as muted secondary text when present
- Title pencil button transitions from hidden to visible on group hover (opacity-0 → group-hover:opacity-100); date/notes pencils unchanged per spec

## Task Commits

Each task was committed atomically:

1. **Task 1: Create auto_save_controller.js** - `7841e4f` (feat)
2. **Task 2: Update decks/show.html.erb** - `4bb858a` (feat)

## Files Created/Modified
- `app/javascript/controllers/auto_save_controller.js` - New Stimulus controller; auto-discovered by importmap as `auto-save`
- `app/views/decks/show.html.erb` - Four surgical changes: pencil hover, ARRANGEMENT label + auto-save wiring, ADD SONGS label, artist secondary text
- `test/controllers/decks_controller_test.rb` - Fixed DECK-02 test to inline-create a song with `import_status: 'done'`

## Decisions Made
- Label text written as uppercase literals ("ADD SONGS", "ARRANGEMENT") rather than relying on CSS `text-transform: uppercase` — required so Minitest integration tests asserting on response body match the literal string
- `auto-save` data-controller placed on the ARRANGEMENT header row div only (not the full left panel), scoping the `turbo:submit-end` event to arrangement mutations

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Uppercase label text required for test assertions**
- **Found during:** Task 2 (Update decks/show.html.erb)
- **Issue:** Plan specified "ARRANGEMENT" and "ADD SONGS" sub-labels, but initial implementation wrote "Arrangement" / "Add Songs" in title case with CSS `uppercase` class. Minitest asserts against raw HTML response body, not rendered text — CSS transforms are browser-side.
- **Fix:** Changed h2 content to literal uppercase "ARRANGEMENT" and "ADD SONGS"
- **Files modified:** app/views/decks/show.html.erb
- **Verification:** `deck show panel labels` test passes
- **Committed in:** 4bb858a (Task 2 commit)

**2. [Rule 1 - Bug] DECK-02 test needed song with import_status: 'done'**
- **Found during:** Task 2 verification
- **Issue:** Test asserted artist appears in library panel, but `Song.where(import_status: "done")` returns nothing when fixture songs default to `import_status: 'pending'`
- **Fix:** Added `Song.create!(title: "Grace Alone", artist: "Sovereign Grace Music", import_status: "done")` inline in the test setup
- **Files modified:** test/controllers/decks_controller_test.rb
- **Verification:** `deck show renders artist in library panel` test passes
- **Committed in:** 4bb858a (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (2 Rule 1 - Bug)
**Impact on plan:** Both fixes necessary for test correctness. No scope creep — view behavior matches spec exactly.

## Issues Encountered
- Pre-existing failure in `test_export_button_idle_renders_download_icon` (DECK-03 test) was present before this plan's changes — confirmed by checking out prior commit. Left as-is per scope boundary rules.

## Next Phase Readiness
- All 4 target DECK requirements (DECK-02, DECK-04, DECK-05, DECK-06) complete
- Full test suite green: 72 tests, 0 failures
- Phase 8 deck editor polish fully implemented

---
*Phase: 08-deck-editor-and-import-polish*
*Completed: 2026-03-16*
