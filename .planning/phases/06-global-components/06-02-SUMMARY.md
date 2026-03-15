---
phase: 06-global-components
plan: "02"
subsystem: ui
tags: [devise, tailwind, forms, warm-palette, stone, rose]

# Dependency graph
requires:
  - phase: 05-design-foundation
    provides: Warm palette design system (stone/rose tokens, input/button patterns)
provides:
  - Devise account edit page restyled with warm palette inputs (stone-200 borders, rose-600 focus rings, rose-700 submit)
  - Inline red-50/red-200/red-700 error block in registrations/new.html.erb replacing partial render
  - Inline error block in registrations/edit.html.erb (no partial reference)
affects: [07, 08, any future Devise view restyling]

# Tech tracking
tech-stack:
  added: []
  patterns: [inline error block (red-50/red-200/red-700) in place of _error_messages partial render]

key-files:
  created: []
  modified:
    - app/views/devise/registrations/edit.html.erb
    - app/views/devise/registrations/new.html.erb
    - test/controllers/registrations_controller_test.rb

key-decisions:
  - "_error_messages.html.erb partial retained (not deleted) — 4 other Devise views still reference it: unlocks/new, passwords/edit, passwords/new, confirmations/new"
  - "Cancel account button de-emphasized with stone-500/hover:red-600 (destructive but available per research recommendation)"
  - "turbo_confirm retained on delete button — DOM contract preserved"

patterns-established:
  - "Inline error block: <% if resource.errors.any? %> <div class='bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg p-3'> — replaces bare Devise _error_messages partial"

requirements-completed: [FORM-01]

# Metrics
duration: 10min
completed: 2026-03-15
---

# Phase 6 Plan 02: Devise Forms Warm Palette + Inline Errors Summary

**Devise account edit page fully restyled with stone/rose warm palette; both registration views now use inline red-50 error blocks instead of bare scaffold partial render**

## Performance

- **Duration:** 10 min
- **Started:** 2026-03-15T00:00:00Z
- **Completed:** 2026-03-15T00:10:00Z
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments
- Restyled edit.html.erb from bare Devise scaffold HTML to warm palette matching new.html.erb exactly
- Replaced bare `render "devise/shared/error_messages"` call in new.html.erb with inline styled error block
- Added test verifying warm palette classes (focus:ring-rose-600, border-stone-200) appear on the edit page

## Task Commits

Each task was committed atomically:

1. **Task 1: Add Devise edit page test case (TDD RED)** - `ec7c25a` (test)
2. **Task 2: Restyle edit.html.erb (TDD GREEN)** - `afdfadf` (feat)
3. **Task 3: Replace _error_messages render in new.html.erb** - `01dd842` (feat)

## Files Created/Modified
- `app/views/devise/registrations/edit.html.erb` - Fully restyled: removed all div.field/div.actions/em/i/p-wrapper scaffold HTML; added inline error block, stone-200 borders, rose-600 focus rings, rose-700 submit button, stone-500 cancel button
- `app/views/devise/registrations/new.html.erb` - Replaced `render "devise/shared/error_messages"` with inline red-50/red-200/red-700 error block
- `test/controllers/registrations_controller_test.rb` - Added test verifying warm palette classes on edit page (TDD RED then GREEN)

## Decisions Made
- `_error_messages.html.erb` retained because 4 other Devise views (unlocks, passwords x2, confirmations) still reference it — deleting would cause ActionView::MissingTemplate errors. Future plan should restyle all Devise views and then delete the partial.
- Cancel account button styled as `text-stone-500 hover:text-red-600 bg-transparent border-none` — de-emphasized but visible.

## Deviations from Plan

### Auto-noted Issues (not auto-fixed — out of scope)

**1. [Scope Boundary] _error_messages.html.erb partial NOT deleted**
- **Found during:** Task 3 (pre-deletion grep check)
- **Issue:** Plan instructed deleting the partial, but grep revealed 4 other Devise views still render it: `unlocks/new`, `passwords/new`, `passwords/edit`, `confirmations/new`
- **Action:** Did NOT delete the partial. Updated only the two registration views as scoped. Logged to `deferred-items.md`.
- **Impact:** `grep -r "error_messages" app/views/` still shows results (for the 4 other views), but both registration views are clean.
- **Recommendation:** A future plan should inline error blocks across ALL Devise views then delete the partial.

**2. [Pre-existing] DecksControllerTest flash toast failures**
- **Found during:** Task 3 (full controllers test run)
- **Issue:** `test_flash_notice_renders_toast_with_green-50_class` and `test_flash_alert_renders_toast_with_red-50_class` fail — test expects green-50/red-50 but response uses rose-50
- **Action:** Logged to `deferred-items.md`, not fixed (pre-existing, out of scope for 06-02)

---

**Total deviations:** 1 scope-boundary decision (partial not deleted), 1 pre-existing failure logged
**Impact on plan:** Partial deletion deferred to protect other Devise views from breaking. Both registration views are fully updated per the must_haves truths.

## Issues Encountered
None in the planned work scope.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Both registration views (new + edit) use warm palette + inline error blocks
- `_error_messages.html.erb` still exists and serves unlocks, passwords, confirmations views
- Phase 06-03 can proceed; no blockers from this plan
- Future Devise view cleanup (passwords/unlocks/confirmations styling) should be planned as a follow-on

---
*Phase: 06-global-components*
*Completed: 2026-03-15*
