---
phase: 07-content-pages
plan: "02"
subsystem: ui
tags: [erb, tailwind, card-grid, empty-state, hotwire]

requires:
  - phase: 07-01
    provides: [NAV-02-tests, EMPTY-01-tests, failing RED tests for index view]
provides:
  - 3-column card grid for decks index with date as dominant heading
  - hover-reveal trash icon using group/opacity Tailwind pattern
  - illustrated empty state with micro-workflow explainer for EMPTY-01
affects: [07-03-PLAN, 07-04-PLAN]

tech-stack:
  added: []
  patterns:
    - "relative group wrapper with absolute opacity-0 group-hover:opacity-100 child for hover-reveal delete button"
    - "button_to as sibling of link_to inside card wrapper (not nested) per HTML spec"

key-files:
  created: []
  modified:
    - app/views/decks/index.html.erb

key-decisions:
  - "button_to delete is a sibling div of link_to, not nested inside it — HTML spec prohibits interactive elements inside anchor"
  - "Verification tests run from main repo path (/Users/hschin/Dev/praise-project) where compiled assets exist; worktree path lacks asset pipeline compilation"

patterns-established:
  - "Card grid: grid grid-cols-3 gap-4 with each card as relative group bg-white rounded-xl shadow-sm border border-stone-200"
  - "Hover-reveal: parent has group class; reveal target has opacity-0 group-hover:opacity-100 transition-opacity"
  - "Date format: deck.date.strftime('%A %-d %B') → 'Sunday 16 March' as text-lg font-semibold"

requirements-completed: [NAV-02, EMPTY-01]

duration: 8min
completed: "2026-03-16"
---

# Phase 7 Plan 02: Deck Index Card Grid Summary

**3-column date-first card grid with hover-reveal trash icon and illustrated empty state using Tailwind group/opacity pattern**

## Performance

- **Duration:** 8 min
- **Started:** 2026-03-16T00:00:00Z
- **Completed:** 2026-03-16T00:08:00Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments

- Replaced divide-y list layout with `grid grid-cols-3 gap-4` card grid (NAV-02)
- Date is now the dominant heading on each card (`text-lg font-semibold`) with title below in `text-sm`
- Trash delete icon revealed on hover via `opacity-0 group-hover:opacity-100 transition-opacity` — sibling of `link_to`, not nested inside it
- `data-turbo-confirm` attribute preserved on delete `button_to`
- Illustrated empty state with presentation-chart-bar SVG, "Build worship slide decks in minutes" headline, 3-step workflow list, and New Deck button (EMPTY-01)

## Task Commits

Each task was committed atomically:

1. **Task 1: Replace deck list with 3-column card grid** - `dcd7b46` (feat)

**Plan metadata:** (docs commit — pending)

## Files Created/Modified

- `app/views/decks/index.html.erb` - Replaced divide-y list with card grid and illustrated empty state

## Decisions Made

- `button_to` delete is a sibling `div` of `link_to` card link, not nested inside the anchor — HTML spec prohibits interactive elements inside `<a>`. Both are children of the `relative group` wrapper div.
- Test verification runs from `/Users/hschin/Dev/praise-project` (main repo with compiled assets) since the worktree lacks the asset pipeline outputs needed for Rails integration tests.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Worktree environment lacks compiled Tailwind assets, causing `ActionView::Template::Error: The asset 'tailwind.css' was not found` when running `rails test` from the worktree path. Resolved by running the verification command from the main repo path as specified in the plan (`cd /Users/hschin/Dev/praise-project && rails test`).

## Self-Check

- [x] `app/views/decks/index.html.erb` modified (both worktree and main repo paths)
- [x] Commit `dcd7b46`: feat(07-02) card grid and empty state
- [x] NAV-02 grid test: PASS (response.body includes "grid")
- [x] NAV-02 turbo-confirm test: PASS (response.body includes "data-turbo-confirm")
- [x] EMPTY-01 test: PASS (response.body includes "Build worship slide decks in minutes")
- [x] 14/15 tests pass; 1 pre-existing RED failure (EMPTY-02, deck show page, not in scope of this plan)

## Next Phase Readiness

- Decks index now shows card grid with date-first layout and empty state
- Plan 07-03 can now address the EMPTY-02 requirement (deck show page empty arrangement state)
- Plan 07-04 covers auth page styling (AUTH-01)

---
*Phase: 07-content-pages*
*Completed: 2026-03-16*
