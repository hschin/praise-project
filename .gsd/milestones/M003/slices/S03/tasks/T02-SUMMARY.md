---
id: T02
parent: S03
milestone: M003
provides: []
requires: []
affects: []
key_files: ["app/views/decks/_slide_preview.html.erb", "lib/pptx_generator/generate.py", "app/jobs/generate_pptx_job.rb"]
key_decisions: ["Title slide shows song name bold + artist at 55% size below, matching preview proportions", "TITLE badge in top-right of preview card distinguishes title from lyric slides", "bg_style variable extracted to avoid 3x repetition in preview partial"]
patterns_established: []
drill_down_paths: []
observability_surfaces: []
duration: ""
verification_result: "rails test 72/72. python3 test confirms 14 slides for deck 24. Visual: preview shows title card before each song's lyric slides."
completed_at: 2026-03-29T17:13:40.709Z
blocker_discovered: false
---

# T02: Song title slides in both preview and PPTX export

> Song title slides in both preview and PPTX export

## What Happened
---
id: T02
parent: S03
milestone: M003
key_files:
  - app/views/decks/_slide_preview.html.erb
  - lib/pptx_generator/generate.py
  - app/jobs/generate_pptx_job.rb
key_decisions:
  - Title slide shows song name bold + artist at 55% size below, matching preview proportions
  - TITLE badge in top-right of preview card distinguishes title from lyric slides
  - bg_style variable extracted to avoid 3x repetition in preview partial
duration: ""
verification_result: passed
completed_at: 2026-03-29T17:13:40.710Z
blocker_discovered: false
---

# T02: Song title slides in both preview and PPTX export

**Song title slides in both preview and PPTX export**

## What Happened

Title slide added to both preview (before each song's lyric slides) and PPTX generator (add_title_slide function called before each song). Artist field added to payload. Deck 24 test confirmed 14 slides (4 title + 10 lyric) correct.

## Verification

rails test 72/72. python3 test confirms 14 slides for deck 24. Visual: preview shows title card before each song's lyric slides.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bin/rails test` | 0 | ✅ pass | 1130ms |
| 2 | `bin/rails runner + python3 slide count check` | 0 | ✅ pass — 14 slides (4 title + 10 lyric) | 5300ms |


## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `app/views/decks/_slide_preview.html.erb`
- `lib/pptx_generator/generate.py`
- `app/jobs/generate_pptx_job.rb`


## Deviations
None.

## Known Issues
None.
