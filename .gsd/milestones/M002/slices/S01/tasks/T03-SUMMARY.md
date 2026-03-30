---
id: T03
parent: S01
milestone: M002
provides: []
requires: []
affects: []
key_files: ["app/views/shared/_flash_toast.html.erb", "app/views/shared/_auth_errors.html.erb", "app/views/decks/show.html.erb", "app/views/decks/index.html.erb", "app/views/decks/_song_list.html.erb", "app/views/decks/_export_button.html.erb", "app/views/songs/index.html.erb", "app/views/songs/_failed.html.erb"]
key_decisions: ["Replaced all 16 inline Heroicon SVGs across 8 view files with Material Symbols span elements", "Flash and auth error partials lost border classes; tonal background alone provides visual distinction per no-line rule"]
patterns_established: []
drill_down_paths: []
observability_surfaces: []
duration: ""
verification_result: "grep -rn '&lt;svg' app/views/ returns 0 results. Material Symbols confirmed in flash_toast, decks/show, songs/index. No border-green-200 or border-red-200 in flash/auth partials. rails test: 72 tests, 180 assertions, 0 failures."
completed_at: 2026-03-28T15:28:23.396Z
blocker_discovered: false
---

# T03: Replaced all 16 inline Heroicon SVGs with Material Symbols spans and removed 1px borders from flash/auth partials

> Replaced all 16 inline Heroicon SVGs with Material Symbols spans and removed 1px borders from flash/auth partials

## What Happened
---
id: T03
parent: S01
milestone: M002
key_files:
  - app/views/shared/_flash_toast.html.erb
  - app/views/shared/_auth_errors.html.erb
  - app/views/decks/show.html.erb
  - app/views/decks/index.html.erb
  - app/views/decks/_song_list.html.erb
  - app/views/decks/_export_button.html.erb
  - app/views/songs/index.html.erb
  - app/views/songs/_failed.html.erb
key_decisions:
  - Replaced all 16 inline Heroicon SVGs across 8 view files with Material Symbols span elements
  - Flash and auth error partials lost border classes; tonal background alone provides visual distinction per no-line rule
duration: ""
verification_result: passed
completed_at: 2026-03-28T15:28:23.396Z
blocker_discovered: false
---

# T03: Replaced all 16 inline Heroicon SVGs with Material Symbols spans and removed 1px borders from flash/auth partials

**Replaced all 16 inline Heroicon SVGs with Material Symbols spans and removed 1px borders from flash/auth partials**

## What Happened

Replaced all inline Heroicon SVGs with Material Symbols span elements across 8 view files: check_circle, warning, close, edit, delete, music_note, download, search icons mapped to their Heroicon equivalents. Removed 1px solid border classes from flash toast and auth error partials, leaving tonal backgrounds as the sole visual separator. Implemented as part of the single comprehensive M002 commit.

## Verification

grep -rn '&lt;svg' app/views/ returns 0 results. Material Symbols confirmed in flash_toast, decks/show, songs/index. No border-green-200 or border-red-200 in flash/auth partials. rails test: 72 tests, 180 assertions, 0 failures.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `test $(grep -rn '<svg' app/views/ | wc -l) -eq 0 && echo PASS` | 0 | ✅ pass | 50ms |
| 2 | `bin/rails test` | 0 | ✅ pass — 72 tests, 180 assertions, 0 failures | 936ms |


## Deviations

Delivered as part of the single comprehensive M002 commit. Toast border removal applied; tonal background retained without line borders.

## Known Issues

None.

## Files Created/Modified

- `app/views/shared/_flash_toast.html.erb`
- `app/views/shared/_auth_errors.html.erb`
- `app/views/decks/show.html.erb`
- `app/views/decks/index.html.erb`
- `app/views/decks/_song_list.html.erb`
- `app/views/decks/_export_button.html.erb`
- `app/views/songs/index.html.erb`
- `app/views/songs/_failed.html.erb`


## Deviations
Delivered as part of the single comprehensive M002 commit. Toast border removal applied; tonal background retained without line borders.

## Known Issues
None.
