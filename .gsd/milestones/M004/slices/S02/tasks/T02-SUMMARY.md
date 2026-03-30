---
id: T02
parent: S02
milestone: M004
provides: []
requires: []
affects: []
key_files: ["lib/pptx_generator/generate.py", "app/jobs/generate_pptx_job.rb"]
key_decisions: ["Settings passed as deck.settings object in payload to keep theme and settings clearly separated", "add_slide show_pinyin kwarg defaults True for backwards compatibility with direct script calls"]
patterns_established: []
drill_down_paths: []
observability_surfaces: []
duration: ""
verification_result: "bin/rails runner: payload has settings={show_pinyin: false, lines_per_slide: 2}. Python generates 24 slides for deck 24 (vs 14 default). rails test: 72/186, 0 failures."
completed_at: 2026-03-29T17:42:34.034Z
blocker_discovered: false
---

# T02: PPTX generator skips pinyin and splits sections at lines_per_slide

> PPTX generator skips pinyin and splits sections at lines_per_slide

## What Happened
---
id: T02
parent: S02
milestone: M004
key_files:
  - lib/pptx_generator/generate.py
  - app/jobs/generate_pptx_job.rb
key_decisions:
  - Settings passed as deck.settings object in payload to keep theme and settings clearly separated
  - add_slide show_pinyin kwarg defaults True for backwards compatibility with direct script calls
duration: ""
verification_result: passed
completed_at: 2026-03-29T17:42:34.035Z
blocker_discovered: false
---

# T02: PPTX generator skips pinyin and splits sections at lines_per_slide

**PPTX generator skips pinyin and splits sections at lines_per_slide**

## What Happened

generate.py updated: add_slide accepts show_pinyin kwarg, main() reads settings from payload, chunks content at lines_per_slide. GeneratePptxJob passes both settings. Verified: deck 24 with show_pinyin=false, lines_per_slide=2 produces 24 slides (vs 14 with defaults).

## Verification

bin/rails runner: payload has settings={show_pinyin: false, lines_per_slide: 2}. Python generates 24 slides for deck 24 (vs 14 default). rails test: 72/186, 0 failures.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bin/rails runner — slide count check` | 0 | ✅ pass — 24 slides with lines_per_slide=2 vs 14 default | 5000ms |
| 2 | `bin/rails test` | 0 | ✅ pass | 1138ms |


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
