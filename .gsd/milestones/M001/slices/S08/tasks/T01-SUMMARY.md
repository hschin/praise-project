---
id: T01
parent: S08
milestone: M001
provides:
  - 9 failing test methods (RED baseline) for all Phase 8 requirements
requires: []
affects: []
key_files:
  - test/controllers/decks_controller_test.rb
  - test/controllers/songs_controller_test.rb
key_decisions:
  - Used ApplicationController.render for export_button ready-state test to isolate partial without triggering a job
  - DECK-02 artist test uses multiline assert_match on data-song-search-target='item' context
  - Created inline done song via Song.create! for IMPORT-02 since songs(:one) fixture has default pending status
patterns_established:
  - TDD RED baseline pattern for Phase 8
observability_surfaces: []
drill_down_paths: []
duration: 12min
verification_result: passed
completed_at: 2026-03-16
blocker_discovered: false
---
# T01: Wave 0 Test Scaffolding

**9 failing TDD scaffolding tests across 2 controller test files, covering all Phase 8 DECK and IMPORT requirements as RED baseline for Wave 1 implementation**

## What Happened

Added 7 failing test methods for DECK-01 through DECK-06 in decks_controller_test.rb and 2 failing test methods for IMPORT-01 and IMPORT-02 in songs_controller_test.rb. All 9 new tests fail with assertion failures (not errors) — valid RED baseline. All 22 pre-existing tests continue to pass.

## Verification

- All 9 RED tests fail with assertion failures (not errors)
- All pre-existing tests continue to pass
- Commits: c3438af (test: deck), 2567383 (test: import)
