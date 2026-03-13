# Phase 4: PPTX Export - Context

**Gathered:** 2026-03-14
**Status:** Ready for planning

<domain>
## Phase Boundary

Generate a downloadable .pptx file from a deck's songs, slide arrangement, and theme. Export runs as a background job with real-time status feedback via Turbo Streams. CJK font rendering must work correctly on Windows PowerPoint/projectors.

</domain>

<decisions>
## Implementation Decisions

### Export button UX
- Clicking "Export PPTX" disables the button and changes label to "Generating…" (with visual indicator)
- Turbo Stream updates the button in-place when job completes → becomes "Download .pptx →" link
- On failure: button resets to "Export PPTX" with an inline error message (user can retry immediately)
- Button always available — re-export is just clicking Export again

### File delivery
- Generate each time, no stored file — do not attach .pptx to Deck via ActiveStorage
- Job generates file, sends it as a direct download response (or signed temporary URL)
- Simpler: no stale file invalidation needed when slides/theme change
- Re-export behaviour (EXPORT-03) is satisfied by the button always being available

### Pinyin layout in PPTX
- Pinyin rendered as a **separate plain text line above the Chinese text** (not ruby/OpenXML markup)
- Pinyin font size ≈ 60% of the Chinese text font size
- Pinyin line omitted entirely when a slide has no pinyin content
- Matches the browser preview intent (pinyin above, Chinese below) without complex OpenXML

### CJK font handling
- Must bundle a CJK-capable font (e.g. Noto Sans CJK SC) with the Python script
- Font must be embedded in the .pptx so it renders on Windows projectors without the font installed
- This is the primary technical risk — must be validated as part of this phase

### Claude's Discretion
- Exact python-pptx slide layout dimensions and text box positioning
- Font size scaling logic (how theme small/medium/large maps to pt values)
- Background image scaling/cropping in PPTX
- Turbo Stream channel naming for export job status
- Temporary file handling and cleanup after generation

</decisions>

<specifics>
## Specific Ideas

- The "Generating…" → "Download .pptx →" transition should feel like the existing theme suggestion flow (Turbo Stream update to a target div/button)
- Pinyin layout: two stacked lines per slide — pinyin (smaller) on top, Chinese (larger) below, centred
- Export is a before-Sunday action for a small team — 5–10 second generation time is acceptable

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `DecksController#export`: stubbed with `head :ok` — ready to wire up job enqueue
- `ApplicationJob` + Solid Queue: established pattern for background jobs (`perform_later`)
- Turbo Streams: `turbo_stream_from` already used on deck show page for theme suggestions — same pattern for export status
- `DeckSong.arrangement` JSONB: authoritative slide order — Python script reads this to build slide sequence
- `Theme` model: `background_color`, `text_color`, `font_size`, `background_image` (ActiveStorage) — all available for export

### Established Patterns
- Background job flow: controller enqueues job → job broadcasts Turbo Stream update when done
- `Turbo::StreamsChannel.broadcast_update_to` used in `GenerateThemeSuggestionsJob` — reuse exact same pattern
- Error broadcasting: `broadcast_error` pattern in `GenerateThemeSuggestionsJob` — adapt for export failures

### Integration Points
- `app/controllers/decks_controller.rb` → `export` action: enqueue job, return Turbo-friendly response
- `app/views/decks/show.html.erb` → Export button: needs `turbo_stream_from` target + disabled state handling
- `lib/pptx_generator/` — Python script lives here (create directory); Rails serialises deck to JSON, calls script via subprocess
- `config/routes.rb` → export route already exists (`post :export` on decks)

</code_context>

<deferred>
## Deferred Ideas

- Storing generated .pptx for instant re-download — decided against for v1 (always regenerate)
- Thumbnail preview generated from PPTX — future phase

</deferred>

---

*Phase: 04-pptx-export*
*Context gathered: 2026-03-14*
