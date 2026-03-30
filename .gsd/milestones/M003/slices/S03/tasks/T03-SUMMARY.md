---
id: T03
parent: S03
milestone: M003
provides: []
requires: []
affects: []
key_files: ["lib/pptx_generator/generate.py", "app/jobs/generate_pptx_job.rb"]
key_decisions: ["MSO_ANCHOR.MIDDLE on full-slide textbox matches CSS flex centering", "set_para_spacing helper uses lnSpc XML since python-pptx has no high-level line spacing API", "Unsplash URL fetched via URI.open and base64-encoded — matches PPTX preview appearance"]
patterns_established: []
drill_down_paths: []
observability_surfaces: []
duration: ""
verification_result: "python3 inspection confirms vertical_anchor=MIDDLE on all textboxes, 48pt Chinese + 29pt pinyin, correct alignment. Deck 24 export: 14 slides, 13.7MB with embedded Unsplash photo."
completed_at: 2026-03-29T17:13:55.507Z
blocker_discovered: false
---

# T03: PPTX text vertically centred with correct line spacing and Unsplash backgrounds embedded

> PPTX text vertically centred with correct line spacing and Unsplash backgrounds embedded

## What Happened
---
id: T03
parent: S03
milestone: M003
key_files:
  - lib/pptx_generator/generate.py
  - app/jobs/generate_pptx_job.rb
key_decisions:
  - MSO_ANCHOR.MIDDLE on full-slide textbox matches CSS flex centering
  - set_para_spacing helper uses lnSpc XML since python-pptx has no high-level line spacing API
  - Unsplash URL fetched via URI.open and base64-encoded — matches PPTX preview appearance
duration: ""
verification_result: passed
completed_at: 2026-03-29T17:13:55.507Z
blocker_discovered: false
---

# T03: PPTX text vertically centred with correct line spacing and Unsplash backgrounds embedded

**PPTX text vertically centred with correct line spacing and Unsplash backgrounds embedded**

## What Happened

Added set_para_spacing XML helper. Rewrote both add_title_slide and add_slide textboxes to use full-slide height with MSO_ANCHOR.MIDDLE. Replaced nested add_text_paragraph closure with explicit per-paragraph spacing control. GeneratePptxJob now fetches and base64-encodes Unsplash URL when no ActiveStorage file. Deck 24 export: 13.7MB, 14 slides, MSO_ANCHOR.MIDDLE confirmed on all textboxes.

## Verification

python3 inspection confirms vertical_anchor=MIDDLE on all textboxes, 48pt Chinese + 29pt pinyin, correct alignment. Deck 24 export: 14 slides, 13.7MB with embedded Unsplash photo.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bin/rails test` | 0 | ✅ pass — 72 tests, 186 assertions, 0 failures | 1142ms |
| 2 | `python3 slide inspection — vertical_anchor=MIDDLE, correct pt sizes` | 0 | ✅ pass | 500ms |


## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `lib/pptx_generator/generate.py`
- `app/jobs/generate_pptx_job.rb`


## Deviations
None.

## Known Issues
None.
