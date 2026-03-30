# S04: Song Library & Song Views

**Goal:** Song library and all song views render with Sanctuary Stone tokens — editorial search panel, lyric preview rows, song show/edit/processing/failed pages
**Demo:** After this: After this: Song library has editorial search panel, lyric preview snippets, serif headlines, and scriptural footer; song show/edit/processing/failed pages use Sanctuary Stone tokens

## Tasks
- [x] **T01: All song views reskinned with editorial search panel, lyric preview rows, and Sanctuary Stone tokens** — Reskin songs/index, songs/show, songs/edit, songs/_form, songs/_lyrics, songs/_processing, songs/processing, songs/_failed. Unified search panel (search + import on no-match). Editorial rows with lyric snippets. Delivered as part of single M002 commit.
  - Estimate: 50m
  - Files: app/views/songs/index.html.erb, app/views/songs/show.html.erb, app/views/songs/edit.html.erb, app/views/songs/_form.html.erb, app/views/songs/_lyrics.html.erb, app/views/songs/_processing.html.erb, app/views/songs/processing.html.erb, app/views/songs/_failed.html.erb
  - Verify: bin/rails test && echo PASS
