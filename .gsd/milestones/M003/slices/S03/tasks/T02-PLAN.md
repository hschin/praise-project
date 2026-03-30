---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T02: Song title slides in preview and PPTX

Add title slide card to _slide_preview.html.erb before each song's lyric slides. Add add_title_slide() to generate.py. Add artist to payload in GeneratePptxJob.

## Inputs

- None specified.

## Expected Output

- `app/views/decks/_slide_preview.html.erb`
- `lib/pptx_generator/generate.py`
- `app/jobs/generate_pptx_job.rb`

## Verification

bin/rails test && python3 lib/pptx_generator/generate.py test
