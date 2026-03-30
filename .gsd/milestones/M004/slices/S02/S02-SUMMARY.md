---
id: S02
parent: M004
milestone: M004
provides:
  - Working display settings in preview and PPTX export
requires:
  - slice: S01
    provides: deck.show_pinyin and deck.lines_per_slide on Deck model
affects:
  []
key_files:
  - app/views/decks/_slide_preview.html.erb
  - lib/pptx_generator/generate.py
key_decisions:
  - Settings key in payload separate from theme key
  - chunk_idx * lines_per_slide for correct pinyin offset when lines repeat
patterns_established:
  - deck.settings object in PPTX payload for any future display settings additions
  - each_slice + chunk_idx pattern for splitting lyric sections across slides
observability_surfaces:
  - none
drill_down_paths:
  - milestones/M004/slices/S02/tasks/T01-SUMMARY.md
  - milestones/M004/slices/S02/tasks/T02-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-03-29T17:43:03.198Z
blocker_discovered: false
---

# S02: Preview & PPTX Respect Settings

**Preview and PPTX both respect show_pinyin and lines_per_slide — settings flow end-to-end**

## What Happened

Preview and PPTX now both faithfully reflect the show_pinyin and lines_per_slide deck settings. The two settings work independently and compose correctly — you can have pinyin on with 2-line splits, or pinyin off with 4-line splits, or any combination.

## Verification

Visual browser confirmation. PPTX slide count: 24 vs 14 default. rails test 72/186, 0 failures.

## Requirements Advanced

- R009 — show_pinyin and lines_per_slide affect both preview and PPTX output

## Requirements Validated

- R009 — Visual: show_pinyin=false removes ruby annotations; lines_per_slide=2 splits 4-line chorus into 2 cards. PPTX: 24 slides with split settings vs 14 defaults.

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

- `app/views/decks/_slide_preview.html.erb` — show_pinyin skips ruby annotations; each_slice chunks sections at lines_per_slide; (N/M) split labels
- `lib/pptx_generator/generate.py` — add_slide show_pinyin kwarg; main() reads settings; content chunked at lines_per_slide
- `app/jobs/generate_pptx_job.rb` — build_payload passes settings: {show_pinyin:, lines_per_slide:}
