---
id: T02
parent: S08
milestone: M001
provides:
  - Color-coded chip badges per section type in slide arrangement items
  - Enhanced export button with icons for idle, ready, and error states
requires: []
affects: []
key_files:
  - app/views/deck_songs/_slide_item.html.erb
  - app/views/decks/_export_button.html.erb
key_decisions:
  - aria-label on SVG elements for test-friendly icon identification
  - button_to block form used for idle state icon+text layout
patterns_established:
  - ERB case on section_type.to_s.downcase for color-coded chip classes
  - Inline SVG with aria-label for Heroicon identification in tests
observability_surfaces: []
drill_down_paths: []
duration: 10min
verification_result: passed
completed_at: 2026-03-16
blocker_discovered: false
---
# T02: Slide Section Chips + Export Button States

**Color-coded section chip badges (verse=amber, chorus=rose, bridge=stone) and icon-enhanced export button**

## What Happened

Slide arrangement items now show color-coded pill chips per section type. Export idle button displays arrow-down-tray icon. Export ready state renders green button with check-circle icon. Export error state shows fallback copy. All Turbo Stream targets and sortable drag contracts preserved.

## Verification

- All target tests pass; full suite green (72/72)
- Commits: b36aeaf (feat: chips), 5bd4f92 (feat: export button)
