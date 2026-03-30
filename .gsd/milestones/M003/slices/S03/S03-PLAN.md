# S03: Import Status, Title Slides & PPTX Fidelity

**Goal:** Polished import progress UI, song title slides in preview and PPTX, vertically centred PPTX output with Unsplash backgrounds embedded
**Demo:** After this: Import a song → see step indicators animate. Open deck editor → title slides visible before lyric slides. Export PPTX → title and lyric slides centred with background photo.

## Tasks
- [x] **T01: Import status page polished with step indicators, progress bar, and contextual labels** — Rewrite processing.html.erb and _processing.html.erb with step indicators, progress bar, contextual labels. broadcast_done sends done step before redirect div.
  - Estimate: 30m
  - Files: app/views/songs/processing.html.erb, app/views/songs/_processing.html.erb, app/jobs/import_song_job.rb, test/controllers/songs_controller_test.rb
  - Verify: bin/rails test && echo PASS
- [x] **T02: Song title slides in both preview and PPTX export** — Add title slide card to _slide_preview.html.erb before each song's lyric slides. Add add_title_slide() to generate.py. Add artist to payload in GeneratePptxJob.
  - Estimate: 30m
  - Files: app/views/decks/_slide_preview.html.erb, lib/pptx_generator/generate.py, app/jobs/generate_pptx_job.rb
  - Verify: bin/rails test && python3 lib/pptx_generator/generate.py test
- [x] **T03: PPTX text vertically centred with correct line spacing and Unsplash backgrounds embedded** — Add set_para_spacing helper. Use MSO_ANCHOR.MIDDLE on full-height textboxes for all slides. Fetch Unsplash URL as base64 in GeneratePptxJob when no ActiveStorage file.
  - Estimate: 45m
  - Files: lib/pptx_generator/generate.py, app/jobs/generate_pptx_job.rb
  - Verify: bin/rails test && python3 -c 'from pptx import Presentation; prs = Presentation("/tmp/fidelity_deck24.pptx"); print(len(prs.slides))' && echo PASS
