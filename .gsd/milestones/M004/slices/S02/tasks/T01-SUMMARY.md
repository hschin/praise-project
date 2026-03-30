---
id: T01
parent: S02
milestone: M004
provides: []
requires: []
affects: []
key_files: ["app/views/decks/_slide_preview.html.erb"]
key_decisions: ["chunk_idx * lines_per_slide for reliable chunk_start offset regardless of duplicate line content", "Section label shows (1/N) / (2/N) suffix when a section is split across multiple slides"]
patterns_established: []
drill_down_paths: []
observability_surfaces: []
duration: ""
verification_result: "Visual: show_pinyin=false removes all ruby annotations; lines_per_slide=2 on a 4-line chorus produces 2 slide cards. Section labels show (1/2) and (2/2). rails test: 72/186, 0 failures."
completed_at: 2026-03-29T17:42:18.169Z
blocker_discovered: false
---

# T01: Slide preview hides pinyin and splits sections at lines_per_slide boundary

> Slide preview hides pinyin and splits sections at lines_per_slide boundary

## What Happened
---
id: T01
parent: S02
milestone: M004
key_files:
  - app/views/decks/_slide_preview.html.erb
key_decisions:
  - chunk_idx * lines_per_slide for reliable chunk_start offset regardless of duplicate line content
  - Section label shows (1/N) / (2/N) suffix when a section is split across multiple slides
duration: ""
verification_result: passed
completed_at: 2026-03-29T17:42:18.170Z
blocker_discovered: false
---

# T01: Slide preview hides pinyin and splits sections at lines_per_slide boundary

**Slide preview hides pinyin and splits sections at lines_per_slide boundary**

## What Happened

Preview updated to respect both settings. show_pinyin=false skips ruby annotations entirely and renders plain Chinese text. lines_per_slide splits content into chunks via each_slice, each rendered as a separate slide card. Verified visually: 4-line chorus splits into two 2-line cards, pinyin absent throughout.

## Verification

Visual: show_pinyin=false removes all ruby annotations; lines_per_slide=2 on a 4-line chorus produces 2 slide cards. Section labels show (1/2) and (2/2). rails test: 72/186, 0 failures.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bin/rails test` | 0 | ✅ pass — 72 tests, 186 assertions, 0 failures | 1138ms |


## Deviations

chunk_start calculation initially used content_lines.index(chunk.first) which would fail on duplicate lines — fixed to chunk_idx * lines_per_slide.

## Known Issues

None.

## Files Created/Modified

- `app/views/decks/_slide_preview.html.erb`


## Deviations
chunk_start calculation initially used content_lines.index(chunk.first) which would fail on duplicate lines — fixed to chunk_idx * lines_per_slide.

## Known Issues
None.
