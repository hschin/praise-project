---
id: S05
parent: M001
milestone: M001
provides:
  - POST /decks/quick_create route that creates a deck with upcoming Sunday title and redirects to deck editor
  - DecksController#quick_create action with upcoming_sunday_date/title helpers
  - DecksController#update JSON response branch (head :ok) for inline-edit Stimulus PATCH
  - decks/index.html.erb New Deck button wired to quick_create_decks_path via button_to
  - Stimulus inline_edit_controller.js with configurable field, date formatting, allow-empty for notes
  - Inline-editable deck title, date, and notes in editor header with pencil-icon hover affordance
  - Playfair Display wordmark in rose-700 (nav)
  - Complete amber-to-rose color unification across all views and CSS tokens
  - Deck title incrementor in quick_create (clean base title first, (2)+ for duplicates)
requires: []
affects: []
key_files: []
key_decisions:
  - quick_create excludes set_deck before_action since it creates a new deck, not looking up an existing one
  - update action extended with respond_to JSON branch to unblock Plan 04 inline-edit Stimulus without a separate plan
  - Both New Deck buttons in index (header and empty-state) replaced with button_to quick_create_decks_path
  - eagerLoadControllersFrom auto-discovers inline_edit_controller.js as 'inline-edit' — no manual index.js entry needed
  - font-semibold (not font-bold) used for deck title per VIS-03 typography contract (worship tool aesthetic decision)
  - Configurable field attribute allows inline_edit_controller reuse across title, date, and notes without forking
  - Wordmark changed to rose-700 (from amber-800) per visual review approval
  - Title deduplication: clean base title for first deck; (2)+ numeric suffix only when conflict exists
patterns_established:
  - Collection POST route for zero-form creation: POST /resource/quick_create -> redirect to resource
  - respond_to with format.html + format.json in update enables Stimulus fetch without separate API endpoint
  - Inline-edit pattern: group wrapper + display span + hidden input + hover button; applicable to other editable fields
  - Heroicons inline SVG (no npm package) for icon-in-button patterns
  - Color palette: rose for brand/accent, stone for neutrals — amber removed entirely
observability_surfaces: []
drill_down_paths: []
duration: 45min
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---
# S05: Design Foundation

**# Plan 05-01: Design Token Foundation + Palette Replacement — Summary**

## What Happened

# Plan 05-01: Design Token Foundation + Palette Replacement — Summary

## What Was Built

Established the Tailwind v4 `@theme` design token foundation and replaced all `indigo-*` / `gray-*` Tailwind classes with warm amber/stone equivalents across 21 non-layout ERB view files.

## Key Files

### Created/Modified
- `app/assets/tailwind/application.css` — added `@theme` block with 7 `--color-worship-*` tokens
- 21 ERB view files — replaced all indigo/gray utility classes with amber/stone equivalents

## Decisions Made

- Used `var(--color-amber-800)` CSS variable aliasing in `@theme` (Tailwind v4 exposes palette as CSS custom properties — aliasing worked correctly)
- All DOM contracts preserved: Turbo Stream IDs, `data-drag-handle`, `data-id`, `data: { turbo: false }`, `content_for(:main_class)`
- Note: view file commits landed in `c905a91` (05-03 metadata) due to git staging timing — content is correct

## Verification

- `grep -rn "indigo" app/views/ --include="*.erb" | grep -v layouts/` → 0 results ✓
- `grep -rn "bg-gray\|text-gray\|border-gray" app/views/ --include="*.erb" | grep -v layouts/` → 0 results ✓

## Self-Check: PASSED

Requirements addressed: VIS-01 (palette), VIS-02 (component language)

# Phase 5 Plan 02: Global Layout Warm Palette and Nav Restructure Summary

Replaced legacy gray/indigo palette and nav structure with warm stone palette, font-serif wordmark, and restructured nav (Decks primary / New Deck amber CTA / Songs + Logout utility area) in a single layout file that every page inherits.

## Tasks Completed

| # | Task | Commit | Files |
|---|------|--------|-------|
| 1 | Apply warm palette to body, nav, and flash messages | 4d5d1f7 | app/views/layouts/application.html.erb |
| 2 | Styled wordmark and restructured nav with New Deck CTA | 641b185 | app/views/layouts/application.html.erb |

## What Was Built

**Task 1 — Warm palette foundation:**
- `<body>`: `bg-gray-50 text-gray-900` → `bg-stone-50 text-stone-900`
- `<nav>`: `bg-white border-gray-200` → `bg-stone-100 border-stone-200`
- Flash notice: bare `bg-green-50` div → `bg-amber-50 border-amber-200 text-amber-900 rounded-lg mx-6 mt-3` card
- Flash alert: bare `bg-red-50` div → `bg-red-50 rounded-lg mx-6 mt-3` card with spacing

**Task 2 — Wordmark and nav restructure:**
- Wordmark: `font-bold text-indigo-600` → `font-serif text-amber-800 tracking-wide`
- Decks moved to primary left-side nav area with `text-stone-700 font-medium`
- New Deck `button_to` added as amber-800 primary CTA (`quick_create_decks_path`)
- Songs moved to right utility area as de-emphasized `text-stone-500`
- Email and Logout updated to stone palette (`text-stone-400`, `text-stone-600`)

## Verification Results

1. `grep "bg-stone-50 text-stone-900"` — PASS
2. `grep "font-serif text-amber-800"` — PASS
3. `grep "quick_create_decks_path"` — PASS
4. `grep "bg-gray|text-gray|border-gray|indigo|bg-white"` — PASS (no legacy classes)
5. `grep "content_for.*main_class"` — PASS (DOM contract preserved)
6. `rails test test/controllers/decks_controller_test.rb` — 9/9 PASS

## Deviations from Plan

None - plan executed exactly as written.

Note: During Task 1 test run, 2 errors appeared for `quick_create_decks_url` not found. By Task 2 completion all 9 tests passed — the route was already present (likely from Plan 03 running in parallel Wave 1). No action was needed.

## Requirements Delivered

- VIS-01: Warm palette applied globally (body, nav, flash)
- VIS-02: Component language established (rounded-lg, px-4 py-2 baseline for buttons)
- VIS-03: Font-serif wordmark with tracking-wide
- VIS-04: Warm amber tones for CTA and wordmark
- NAV-01: Restructured nav — Decks primary, New Deck CTA, Songs utility

## Self-Check

- [x] app/views/layouts/application.html.erb modified (verified above)
- [x] Commit 4d5d1f7 exists (Task 1)
- [x] Commit 641b185 exists (Task 2)
- [x] All 5 grep verification checks pass
- [x] Test suite 9/9 green

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

# Phase 5 Plan 04: Inline-Edit and Design Completion Summary

**Stimulus inline_edit_controller with configurable field saves title/date/notes in-place via PATCH, Playfair Display rose wordmark, and complete amber-to-rose unification completing Phase 5 Design Foundation**

## Performance

- **Duration:** ~45 min
- **Started:** 2026-03-15T13:39:18Z
- **Completed:** 2026-03-15
- **Tasks:** 3 of 3 (human-verify approved)
- **Files modified:** 23

## Accomplishments

- Created `inline_edit_controller.js` with edit/save/cancel Stimulus actions; configurable field, date formatting, allow-empty for notes
- Wired inline-edit into deck editor header for title, date, and notes fields with pencil-icon hover affordance
- Playfair Display wordmark in rose-700 applied to nav; complete amber-to-rose replacement across all views and CSS tokens
- Deck title incrementor in quick_create: clean base title for first deck, (2)+ numeric suffix for duplicates
- All DOM contracts preserved (content_for, Turbo Stream IDs, sortable data-*, import form turbo:false)
- Full test suite green: 52 tests, 114 assertions, 0 failures
- Human visual review completed and approved

## Task Commits

Each task was committed atomically:

1. **Task 1: Create inline_edit_controller.js and register it** - `40fd2f7` (feat)
2. **Task 2: Wire inline-edit into deck show header** - `d1a861e` (feat)
3. **Task 3: Visual review approved — post-checkpoint refinements** - `c33fd1c` (feat)

**Plan metadata:** `e8e1626` (docs: complete inline-edit deck title plan)

## Files Created/Modified

- `app/javascript/controllers/inline_edit_controller.js` - Stimulus controller with configurable field, date formatting, allow-empty for notes, fetch PATCH with CSRF token
- `app/views/decks/show.html.erb` - Inline-edit wired for title, date, and notes; VIS-03 typography (text-2xl font-semibold leading-snug)
- `app/views/layouts/application.html.erb` - Playfair Display wordmark in rose-700
- `app/views/decks/index.html.erb` - Edit link removed; Delete styled stone-500
- `app/controllers/decks_controller.rb` - upcoming_sunday_title deduplication logic
- `app/assets/tailwind/application.css` - CSS tokens unified to rose palette
- All song, deck_song, theme, and devise views - amber classes replaced with rose

## Decisions Made

- `eagerLoadControllersFrom` auto-discovers all `*_controller.js` files — no manual index.js registration needed (plan assumed manual style but auto-discovery is idiomatic for this project)
- `font-semibold` (not `font-bold`) per VIS-03 typography contract established in Phase 5 planning
- Configurable field attribute (`data-inline-edit-field-value`) added so inline_edit_controller works for title, date, and notes without forking
- Wordmark color rose-700 chosen over amber-800 per visual review — rose is warmer and more cohesive with the palette
- Title incrementor returns plain base title for first deck; only appends (2)+ when a conflict exists — matches test contract and natural UX expectation

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed upcoming_sunday_title always appending (n) suffix**
- **Found during:** Post-checkpoint changes, surfaced by test suite run before final commit
- **Issue:** `upcoming_sunday_title` started counter at n=1 and always returned "Sunday 15 March (1)" — even for the first deck. Test `POST quick_create title matches upcoming Sunday format` asserts `/\ASunday \d{1,2} \w+\z/` (no parenthetical suffix).
- **Fix:** Return base title immediately if no conflict; start duplicate counter at 2 for subsequent conflicts
- **Files modified:** `app/controllers/decks_controller.rb`
- **Verification:** 9/9 deck controller tests green; 52/52 full suite green
- **Committed in:** `c33fd1c` (post-checkpoint commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 - Bug)
**Impact on plan:** Fix restores correct title format matching test contract. No scope creep.

## Issues Encountered

None beyond the auto-fixed bug above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 5 Design Foundation fully complete and visually approved
- All DOM contracts preserved — Phase 6, 7, 8 safe to proceed
- inline_edit_controller.js pattern available for reuse in later phases
- Phase 6 (Song Management) is unblocked

---
*Phase: 05-design-foundation*
*Completed: 2026-03-15*
