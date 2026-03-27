---
id: T03
parent: S08
milestone: M001
provides:
  - auto_save_controller.js Stimulus controller
  - Split ARRANGEMENT / ADD SONGS sub-labels
  - Artist secondary text in library song list items
  - Title pencil button hover-only visibility
requires: []
affects: []
key_files:
  - app/javascript/controllers/auto_save_controller.js
  - app/views/decks/show.html.erb
key_decisions:
  - Label text written as uppercase literals (ADD SONGS, ARRANGEMENT) for test assertions
  - auto-save data-controller wraps only the arrangement sub-label row
patterns_established:
  - Uppercase label literals for Minitest response body assertions
  - Inline Song.create!(import_status done) for tests needing library panel items
observability_surfaces: []
drill_down_paths: []
duration: 15min
verification_result: passed
completed_at: 2026-03-16
blocker_discovered: false
---
# T03: Deck Editor Show Page Polish

**Panel labels, auto-save controller, artist text, and hover-only pencil for deck editor**

## What Happened

Created auto_save_controller.js showing "Saved" badge for 2s after arrangement changes. Split left panel into ARRANGEMENT and ADD SONGS sections. Library song items show artist as muted secondary text. Title pencil transitions from hidden to visible on group hover. All 4 target DECK requirements complete.

## Verification

- Full test suite green: 72 tests, 0 failures
- Commits: 7841e4f (feat: auto-save), 4bb858a (feat: show page)
