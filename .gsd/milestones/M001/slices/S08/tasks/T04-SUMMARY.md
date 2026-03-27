---
id: T04
parent: S08
milestone: M001
provides:
  - Processing spinner copy reads "Claude is structuring your lyrics..."
  - Post-import add-to-deck link on done song show pages
requires: []
affects: []
key_files:
  - app/views/songs/_processing.html.erb
  - app/views/songs/show.html.erb
key_decisions:
  - Add-to-deck link placed below song title in header (outside song_status div) to survive Turbo Stream replacement
patterns_established:
  - Subtitle CTA pattern below h1 with conditional guard
observability_surfaces: []
drill_down_paths: []
duration: 5min
verification_result: passed
completed_at: 2026-03-16
blocker_discovered: false
---
# T04: Import Processing Copy + Add-to-Deck CTA

**Updated spinner copy to "Claude is structuring your lyrics..." and added conditional add-to-deck link**

## What Happened

Processing partial now shows "Claude is structuring your lyrics..." as spinner label and "Searching for lyrics" as first step. Song show page displays "Add this song to a deck →" link when song is done, placed outside song_status div to survive Turbo Stream replacement. Both IMPORT-01 and IMPORT-02 requirements complete.

## Verification

- Both IMPORT-01 and IMPORT-02 controller tests pass
- All 9 songs controller tests green
- Commits: db1e5d3 (feat: processing copy), 54cbb09 (feat: add-to-deck CTA)
