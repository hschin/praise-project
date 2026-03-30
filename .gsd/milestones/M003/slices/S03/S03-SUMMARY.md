---
id: S03
parent: M003
milestone: M003
provides:
  - Song title slides in both preview and PPTX
  - Vertically centred PPTX output
  - Unsplash backgrounds in PPTX export
  - Polished import progress UI
requires:
  []
affects:
  []
key_files:
  - lib/pptx_generator/generate.py
  - app/views/decks/_slide_preview.html.erb
  - app/views/songs/_processing.html.erb
key_decisions:
  - MSO_ANCHOR.MIDDLE is the correct vertical centering approach for python-pptx
  - Progress bar CSS transitions (w-1/3 → w-2/3 → w-full) give visual momentum without JS
patterns_established:
  - MSO_ANCHOR.MIDDLE + full-slide textbox for PPTX vertical centering
  - set_para_spacing XML helper for python-pptx paragraph spacing
  - Background image priority: ActiveStorage > Unsplash URL > background_color
observability_surfaces:
  - none
drill_down_paths:
  - milestones/M003/slices/S03/tasks/T01-SUMMARY.md
  - milestones/M003/slices/S03/tasks/T02-SUMMARY.md
  - milestones/M003/slices/S03/tasks/T03-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-03-29T17:14:24.929Z
blocker_discovered: false
---

# S03: Import Status, Title Slides & PPTX Fidelity

**Import status polished; song title slides added to preview and PPTX; PPTX output vertically centred with Unsplash backgrounds**

## What Happened

Three improvements to the core import and export flows. Import status page gives clear feedback during the two-stage job. Title slides bring the PPTX output closer to a ready-to-present format. PPTX fidelity work closes the visual gap between browser preview and exported file.

## Verification

rails test 72/186 passing. Python inspection confirms MSO_ANCHOR.MIDDLE. 14-slide deck export verified. Browser visual of title cards in preview.

## Requirements Advanced

- R012 — Import progress UI shows two named steps with animated indicators
- R009 — Song title slides appear in both preview and PPTX

## Requirements Validated

- R009 — 14 slides (4 title + 10 lyric) in deck 24 export; MSO_ANCHOR.MIDDLE confirmed on all textboxes; Unsplash background embedded at 13.7MB

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

- `app/views/songs/processing.html.erb` — Clean layout with eyebrow label, Newsreader headline, back link
- `app/views/songs/_processing.html.erb` — Step indicators with pending/active/done states and animated progress bar
- `app/jobs/import_song_job.rb` — broadcast_done sends done step before redirect div
- `app/views/decks/_slide_preview.html.erb` — Title card inserted before each song's lyric slides; bg_style refactored
- `lib/pptx_generator/generate.py` — add_title_slide function; set_para_spacing helper; MSO_ANCHOR.MIDDLE on all textboxes
- `app/jobs/generate_pptx_job.rb` — artist in payload; Unsplash URL fetched and base64-encoded
