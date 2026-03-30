# S02: Preview & PPTX Respect Settings

**Goal:** Slide preview and PPTX generator both respect show_pinyin and lines_per_slide from the deck
**Demo:** After this: Toggle Show Pinyin off → slide preview hides pinyin instantly. Set Lines per Slide to 2 → a 4-line chorus splits into 2 preview cards. Export PPTX → same split and pinyin setting in file.

## Tasks
- [x] **T01: Slide preview hides pinyin and splits sections at lines_per_slide boundary** — Update _slide_preview.html.erb to: (1) skip ruby annotation rendering when deck.show_pinyin is false, (2) chunk each lyric's content lines into groups of lines_per_slide and render each chunk as a separate slide card.
  - Estimate: 30m
  - Files: app/views/decks/_slide_preview.html.erb
  - Verify: bin/rails test && echo PASS
- [x] **T02: PPTX generator skips pinyin and splits sections at lines_per_slide** — Update generate.py to skip pinyin paragraphs when show_pinyin is false, and chunk content_lines into lines_per_slide groups, calling add_slide once per chunk. Update GeneratePptxJob#build_payload to pass both settings.
  - Estimate: 25m
  - Files: lib/pptx_generator/generate.py, app/jobs/generate_pptx_job.rb
  - Verify: bin/rails test && bin/rails runner 'GeneratePptxJob.new.send(:build_payload, Deck.find(24), "/tmp/t.pptx")' && echo PASS
