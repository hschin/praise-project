---
phase: 05-design-foundation
plan: 03
subsystem: ui
tags: [rails, routes, controller, stimulus, hotwire, tdd]

# Dependency graph
requires: []
provides:
  - POST /decks/quick_create route that creates a deck with upcoming Sunday title and redirects to deck editor
  - DecksController#quick_create action with upcoming_sunday_date/title helpers
  - DecksController#update JSON response branch (head :ok) for inline-edit Stimulus PATCH
  - decks/index.html.erb New Deck button wired to quick_create_decks_path via button_to
affects:
  - 05-04 (inline-edit Stimulus controller uses JSON update response)
  - Any plan touching decks/index.html.erb or deck creation flow

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Collection route with quick_create bypasses new/create form flow
    - respond_to format.json pattern for Stimulus AJAX PATCH
    - TDD RED-GREEN cycle for route + controller changes

key-files:
  created:
    - test/controllers/decks_controller_test.rb (added 2 new tests)
  modified:
    - config/routes.rb
    - app/controllers/decks_controller.rb
    - app/views/decks/index.html.erb

key-decisions:
  - "quick_create excludes set_deck before_action since it creates a new deck, not looking up an existing one"
  - "update action extended with respond_to JSON branch to unblock Plan 04 inline-edit Stimulus without a separate plan"
  - "Both New Deck buttons in index (header and empty-state) replaced with button_to quick_create_decks_path"

patterns-established:
  - "Collection POST route for zero-form creation: POST /resource/quick_create -> redirect to resource"
  - "respond_to with format.html + format.json in update enables Stimulus fetch without separate API endpoint"

requirements-completed:
  - NAV-03
  - NAV-04

# Metrics
duration: 8min
completed: 2026-03-15
---

# Phase 5 Plan 03: Quick-Create Deck Flow Summary

**POST /decks/quick_create route and controller action that skips form entry and drops users directly into the deck editor with an auto-titled Sunday deck, plus JSON update response enabling Plan 04 inline-edit Stimulus**

## Performance

- **Duration:** 8 min
- **Started:** 2026-03-15T13:25:56Z
- **Completed:** 2026-03-15T13:33:00Z
- **Tasks:** 2
- **Files modified:** 4 (routes.rb, decks_controller.rb, decks/index.html.erb, decks_controller_test.rb)

## Accomplishments

- TDD RED: Added two failing test stubs (NAV-03 redirect test, NAV-04 title format test) — confirmed routing error
- TDD GREEN: Implemented quick_create route, controller action with upcoming_sunday_date/title helpers, and JSON update branch — all 9 tests pass
- Replaced both `link_to "New Deck"` instances in index view with `button_to quick_create_decks_path`
- Full test suite passes (52 runs, 0 failures)

## Task Commits

Each task was committed atomically:

1. **Task 1: Wave 0 test stubs (RED)** - `69b6fe3` (test)
2. **Task 2: quick_create route, action, JSON update (GREEN)** - `8e04251` (feat)

_Note: TDD tasks have separate test and feat commits_

## Files Created/Modified

- `config/routes.rb` - Added collection POST :quick_create inside resources :decks
- `app/controllers/decks_controller.rb` - Added quick_create action, upcoming_sunday_date/title helpers, JSON branch in update
- `app/views/decks/index.html.erb` - Replaced both link_to New Deck with button_to quick_create_decks_path (amber-800 classes)
- `test/controllers/decks_controller_test.rb` - Added NAV-03 redirect test and NAV-04 title format test

## Decisions Made

- `quick_create` is excluded from `before_action :set_deck` since it creates a new deck rather than looking up existing one
- Added JSON response branch to `update` now (not deferred to Plan 04) since it's a one-line change and Plan 04 depends on it
- Both "New Deck" buttons (header + empty-state) updated to button_to — consistent quick-create entry point throughout the page

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None - TDD cycle executed cleanly. RED confirmed routing error, GREEN passed all tests first try.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 04 (inline-edit Stimulus) can now send PATCH requests to update action and receive `head :ok` JSON response
- quick_create_decks_path is live and tested — layout nav button from Plan 02 can be wired to it

---
*Phase: 05-design-foundation*
*Completed: 2026-03-15*
