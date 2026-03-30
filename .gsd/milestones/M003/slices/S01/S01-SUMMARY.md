---
id: S01
parent: M003
milestone: M003
provides:
  - Correct toast design for all downstream views
  - Reliable section reordering
requires:
  []
affects:
  - S02
key_files:
  - app/views/shared/_flash_toast.html.erb
  - app/javascript/controllers/song_order_controller.js
  - app/javascript/controllers/sortable_controller.js
key_decisions:
  - forceFallback:true is the resilient fix — makes slide sortable immune to draggable attribute regardless of other controller behaviour
  - Stitch toast uses white card elevation rather than tonal background — meaningful UX upgrade
patterns_established:
  - forceFallback:true on nested SortableJS instances when outer container uses native HTML5 drag
  - Walk up to direct container children when setting draggable to avoid touching nested data-id elements
observability_surfaces:
  - none
drill_down_paths:
  - milestones/M003/slices/S01/tasks/T01-SUMMARY.md
  - milestones/M003/slices/S01/tasks/T02-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-03-29T17:11:40.384Z
blocker_discovered: false
---

# S01: Toast Redesign & Drag-and-Drop Fixes

**Toast redesigned to Stitch spec; section drag-and-drop fixed at root cause**

## What Happened

Two independent fixes delivered. Toast redesign matches Stitch reference exactly. Section drag-and-drop root cause found and fixed — two interacting bugs in the JS controller layer.

## Verification

rails test 72/72. Visual browser verification of both toast states. JS evaluation confirmed draggable attribute not set on slide items after pointerdown on slide handle.

## Requirements Advanced

- R012 — Toast redesigned to white card per Stitch spec
- R009 — Section drag-and-drop works reliably end-to-end

## Requirements Validated

- R012 — Visual inspection: toast shows white card, icon badge, Newsreader title, accent bar
- R009 — Section PATCH returns 200, DB persists, page reloads correctly

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Deviations

None.

## Known Limitations

None.

## Follow-ups

None.

## Files Created/Modified

- `app/views/shared/_flash_toast.html.erb` — White card toast with icon badge, Newsreader title, accent bar
- `app/javascript/controllers/song_order_controller.js` — _onPointerdown fixed to walk up to direct [data-id] children only
- `app/javascript/controllers/sortable_controller.js` — forceFallback:true added to prevent native drag interference
- `test/controllers/decks_controller_test.rb` — Tests updated to assert on new toast markers
