---
estimated_steps: 1
estimated_files: 2
skills_used: []
---

# T03: PPTX fidelity — vertical centering, line spacing, Unsplash backgrounds

Add set_para_spacing helper. Use MSO_ANCHOR.MIDDLE on full-height textboxes for all slides. Fetch Unsplash URL as base64 in GeneratePptxJob when no ActiveStorage file.

## Inputs

- None specified.

## Expected Output

- `lib/pptx_generator/generate.py`
- `app/jobs/generate_pptx_job.rb`

## Verification

bin/rails test && python3 -c 'from pptx import Presentation; prs = Presentation("/tmp/fidelity_deck24.pptx"); print(len(prs.slides))' && echo PASS
