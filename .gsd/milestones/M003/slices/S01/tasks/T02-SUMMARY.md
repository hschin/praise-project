---
id: T02
parent: S01
milestone: M003
provides: []
requires: []
affects: []
key_files: ["app/javascript/controllers/song_order_controller.js", "app/javascript/controllers/sortable_controller.js"]
key_decisions: ["forceFallback:true on sortable_controller makes it immune to draggable attribute state", "song_order_controller walks up to direct [data-id] children only to avoid touching nested slide items"]
patterns_established: []
drill_down_paths: []
observability_surfaces: []
duration: ""
verification_result: "Verified via JS evaluation: pointerdown on slide handle no longer sets draggable attribute on slide item. PATCH to update_arrangement endpoint returns 200 and DB persists correctly."
completed_at: 2026-03-29T17:11:16.425Z
blocker_discovered: false
---

# T02: Fixed section drag broken by native drag interference from song-order controller

> Fixed section drag broken by native drag interference from song-order controller

## What Happened
---
id: T02
parent: S01
milestone: M003
key_files:
  - app/javascript/controllers/song_order_controller.js
  - app/javascript/controllers/sortable_controller.js
key_decisions:
  - forceFallback:true on sortable_controller makes it immune to draggable attribute state
  - song_order_controller walks up to direct [data-id] children only to avoid touching nested slide items
duration: ""
verification_result: passed
completed_at: 2026-03-29T17:11:16.426Z
blocker_discovered: false
---

# T02: Fixed section drag broken by native drag interference from song-order controller

**Fixed section drag broken by native drag interference from song-order controller**

## What Happened

Root cause: song_order_controller._onPointerdown called closest('[data-id]') which found nested slide items (also carry data-id) and set draggable=false on them on every pointerdown, permanently disabling SortableJS native drag. sortable_controller used native drag events (forceFallback:false) which respect the draggable attribute. Fixed _onPointerdown to walk up to direct children only; added forceFallback:true to sortable_controller.

## Verification

Verified via JS evaluation: pointerdown on slide handle no longer sets draggable attribute on slide item. PATCH to update_arrangement endpoint returns 200 and DB persists correctly.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bin/rails test` | 0 | ✅ pass — 72 tests, 184 assertions, 0 failures | 1151ms |


## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `app/javascript/controllers/song_order_controller.js`
- `app/javascript/controllers/sortable_controller.js`


## Deviations
None.

## Known Issues
None.
