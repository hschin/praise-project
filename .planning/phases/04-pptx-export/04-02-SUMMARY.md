---
phase: 04-pptx-export
plan: 02
subsystem: api
tags: [turbo-stream, solid-queue, open3, python-pptx, rails-cache, send_file]

# Dependency graph
requires:
  - phase: 04-pptx-export-01
    provides: generate.py Python script that accepts JSON via stdin and writes .pptx

provides:
  - GeneratePptxJob: serialises deck to JSON, calls generate.py via Open3.capture3, caches output path, broadcasts download link via Turbo Stream
  - DecksController#export: enqueues job, returns Turbo Stream :generating state immediately
  - DecksController#download_export: reads token from Rails.cache, serves .pptx with send_file
  - decks/_export_button.html.erb: reusable partial handling :idle/:generating/:ready/:error states

affects: [phase-05, ui, export-flow]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Token-based temp-file download: cache file path with SecureRandom token, serve via dedicated GET route with send_file
    - Turbo Stream export state machine: controller returns :generating immediately, job broadcasts :ready or :error
    - Open3.capture3 for Python subprocess: pass JSON payload via stdin_data, check status.success? and File.exist?

key-files:
  created:
    - app/jobs/generate_pptx_job.rb
    - app/views/decks/_export_button.html.erb
  modified:
    - app/controllers/decks_controller.rb
    - app/views/decks/show.html.erb
    - config/routes.rb

key-decisions:
  - "Rails.cache with 10-minute TTL used to bridge async job output path to synchronous download request — avoids ActiveStorage for ephemeral temp files"
  - "SecureRandom.urlsafe_base64(24) token sanitised with regex strip in download_export to prevent path traversal via token param"
  - "turbo_stream_from deck_export_{id} placed in theme section alongside deck_themes channel — both live-update targets co-located on show page"

patterns-established:
  - "Export state machine: controller returns :generating via Turbo Stream immediately, job later broadcasts :ready/:error — never block controller waiting for job"
  - "Broadcast partials receive all required locals explicitly (deck:, state:, token:) so partial never depends on instance variables"

requirements-completed: [EXPORT-01, EXPORT-02, EXPORT-03]

# Metrics
duration: 10min
completed: 2026-03-14
---

# Phase 04 Plan 02: PPTX Export Pipeline Summary

**GeneratePptxJob wires deck-to-pptx via Open3 subprocess with token-cached download served by DecksController#download_export and real-time Turbo Stream state updates.**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-03-14T07:00:00Z
- **Completed:** 2026-03-14T07:10:00Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- GeneratePptxJob serialises deck (songs, lyrics, theme, background image as base64) to JSON, calls generate.py via Open3.capture3, and caches the output .pptx path keyed by a SecureRandom token
- DecksController#export enqueues the job and immediately returns a Turbo Stream response setting the export button to :generating state
- DecksController#download_export reads the cached path and serves the file with correct Content-Disposition: attachment MIME type
- _export_button partial handles four states (:idle, :generating, :ready, :error) with re-export capability at all post-generate states
- show.html.erb gains turbo_stream_from "deck_export_{id}" channel and renders the partial instead of an inline button

## Task Commits

1. **Task 1: Create GeneratePptxJob and export button partial** - `de15494` (feat)
2. **Task 2: Wire DecksController#export, download action, show view, route** - `abe2305` (feat)

## Files Created/Modified
- `app/jobs/generate_pptx_job.rb` - Background job: build_payload, Open3.capture3, broadcast_error helper
- `app/views/decks/_export_button.html.erb` - Reusable export button partial with 4 state variants
- `app/controllers/decks_controller.rb` - export action (enqueue + Turbo Stream), download_export action (token lookup + send_file)
- `app/views/decks/show.html.erb` - Added turbo_stream_from export channel, replaced inline button with partial
- `config/routes.rb` - Added GET download_export member route

## Decisions Made
- Rails.cache with 10-minute TTL used for temp file path storage — avoids ActiveStorage overhead for ephemeral export files
- Token sanitised with regex in download_export controller to strip non-alphanumeric characters and prevent path traversal
- turbo_stream_from for export channel placed in the theme column where turbo_stream_from for themes already lives

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None — all 50 tests pass green after both tasks.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Full PPTX export pipeline is complete: user clicks Export PPTX, button enters Generating... state, background job runs Python script, Turbo Stream updates button to Download link
- Phase 04 (PPTX Export) is now complete — both plans executed

---
*Phase: 04-pptx-export*
*Completed: 2026-03-14*
