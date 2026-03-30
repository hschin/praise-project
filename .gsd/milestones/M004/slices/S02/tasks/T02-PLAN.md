---
estimated_steps: 1
estimated_files: 2
skills_used: []
---

# T02: PPTX generator respects show_pinyin and lines_per_slide

Update generate.py to skip pinyin paragraphs when show_pinyin is false, and chunk content_lines into lines_per_slide groups, calling add_slide once per chunk. Update GeneratePptxJob#build_payload to pass both settings.

## Inputs

- `app/models/deck.rb`

## Expected Output

- `lib/pptx_generator/generate.py`
- `app/jobs/generate_pptx_job.rb`

## Verification

bin/rails test && bin/rails runner 'GeneratePptxJob.new.send(:build_payload, Deck.find(24), "/tmp/t.pptx")' && echo PASS
