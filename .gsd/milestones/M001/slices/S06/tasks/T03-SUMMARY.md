---
id: T03
parent: S06
milestone: M001
provides:
  - Locked error copy "Export failed — click to try again." at all three broadcast_error call sites in GeneratePptxJob
  - Failed import partial with "Couldn't find lyrics for [title]. Try pasting them manually below." h3 copy
  - Heroicons exclamation-triangle SVG replacing bare ✗ character in failed partial
  - Export button error state styled text-sm text-red-600 (from text-xs text-red-500)
requires: []
affects: []
key_files: []
key_decisions: []
patterns_established: []
observability_surfaces: []
drill_down_paths: []
duration: 12min
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---
# T03: 06-global-components 03

**# Phase 06 Plan 03: Error Copy Update Summary**

## What Happened

# Phase 06 Plan 03: Error Copy Update Summary

**Locked actionable error copy propagated to PPTX export job (3 call sites), export button partial (styling uplift), and failed import partial (h3 copy + Heroicons SVG icon)**

## Performance

- **Duration:** ~12 min
- **Started:** 2026-03-15T~10:00Z
- **Completed:** 2026-03-15T~10:12Z
- **Tasks:** 3 (TDD: RED + GREEN + implementation)
- **Files modified:** 5

## Accomplishments
- All three `broadcast_error` call sites in `GeneratePptxJob` now use "Export failed — click to try again." — raw `e.message` no longer exposed to users
- Failed import partial h3 reads "Couldn't find lyrics for [title]. Try pasting them manually below." with title interpolated
- Heroicons exclamation-triangle SVG replaces bare ✗ character; export button error paragraph styled to text-sm text-red-600
- `songs_controller_test.rb` GREEN: 6/6 tests pass including new FORM-03 regression test

## Task Commits

Each task was committed atomically:

1. **Task 1: Add error copy test (RED)** - `3a42696` (test)
2. **Task 2: Update generate_pptx_job.rb broadcast_error call sites** - `395a8fe` (feat)
3. **Task 3: Update _export_button.html.erb and _failed.html.erb** - `4e5d1d1` (feat)

_Note: Task 1 used TDD RED phase (failing test committed before implementation)_

## Files Created/Modified
- `app/jobs/generate_pptx_job.rb` - All 3 broadcast_error calls updated to locked copy
- `app/views/decks/_export_button.html.erb` - Error paragraph: text-xs text-red-500 → text-sm text-red-600
- `app/views/songs/_failed.html.erb` - Updated h3 copy; SVG icon; removed redundant paragraph
- `app/views/songs/show.html.erb` - Fixed locals: song: @song → title: @song.title (bug fix)
- `test/controllers/songs_controller_test.rb` - Added FORM-03 regression test for failed partial copy

## Decisions Made
- Raw exception `e.message` replaced with locked human-readable copy; debugging context preserved via `Rails.logger.error` on line 43 (unchanged)
- Redundant Claude description paragraph removed from `_failed.html.erb` — the updated h3 already contains the complete actionable message
- `show.html.erb` locals fixed as Rule 1 auto-fix: partial expects `title` local but view was passing `song:` — would raise `undefined local variable 'title'` for any failed song viewed via show page

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed `show.html.erb` passing wrong local to `_failed` partial**
- **Found during:** Task 3 (running RED test for the failed partial)
- **Issue:** `render "songs/failed", song: @song` — partial uses `title` local variable, not `song`. Any GET /songs/:id for a failed song would raise `ActionView::Template::Error: undefined local variable or method 'title'`
- **Fix:** Changed to `render "songs/failed", title: @song.title` to match the partial's expected contract
- **Files modified:** `app/views/songs/show.html.erb`
- **Verification:** songs_controller_test.rb all 6 tests pass GREEN after fix
- **Committed in:** `4e5d1d1` (Task 3 commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 - Bug)
**Impact on plan:** Necessary correctness fix. The partial contract (title local) was already established by `ImportSongJob#broadcast_failed` — the show view was the outlier. No scope creep.

## Issues Encountered
- `decks_controller_test.rb` has 2 pre-existing FORM-02 failures (flash `green-50`/`red-50` class assertions) — these are from uncommitted work in a prior session and are out of scope for 06-03. Documented in `deferred-items.md`.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Error copy is consistent across all export and import failure surfaces
- All FORM-03 requirements satisfied
- Ready for Phase 07 work

---
*Phase: 06-global-components*
*Completed: 2026-03-15*
