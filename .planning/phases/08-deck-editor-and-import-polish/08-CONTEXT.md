# Phase 8: Deck Editor and Import Polish - Context

**Gathered:** 2026-03-16
**Status:** Ready for planning

<domain>
## Phase Boundary

Visual polish for the deck editor (slide section labels, export button, panel labels, inline edit cues, auto-save indicator) and the import flow (processing copy, post-import CTA). No new capabilities — all work clarifies or surfaces what's already there. Must not break existing Turbo Stream, drag-and-drop, or CSS contracts.

</domain>

<decisions>
## Implementation Decisions

### Export button — idle state (DECK-03)

- Keep same rose-700 size and padding as existing button
- Add Heroicon `arrow-down-tray` icon to the left of "Export PPTX" text
- No size change — consistent with other action buttons

### Export button — ready state (DECK-03)

- Upgrade from plain link to a proper button: green-600 bg, white text
- Add Heroicon `check-circle` icon to the left of "Download .pptx"
- "Re-export" stays as a small text link below the button
- Exact layout:
  ```
  [ ✓ Download .pptx ]  ← green-600 button
    Re-export           ← small text link below
  ```

### Export button — error state (DECK-03)

- Add specific copy: "Export failed — click to try again."
- Matches the Phase 6 FORM-03 spec that was carried forward but may not be implemented

### Export button — generating state

- Keep as-is: spinner + "Generating..." is clear enough

### Panel labels (DECK-04)

- Left panel: two sub-labels within the same column
  - "ADD SONGS" above the search/library area
  - "ARRANGEMENT" above the sortable slide list
- Middle panel: keep "Slide Preview" + "— approximate" note (honest and clear)
- Right panel: keep "Theme" (renaming to "Preview" would conflict with the middle panel)

### Post-import CTA — from deck editor (IMPORT-02)

- When `deck_id` param is present at import time: after the job completes, auto-add the song to that deck and redirect to the deck editor
- Flash message on return: "[Song Title] imported and added to your deck."
- Song appears already in the left panel arrangement

### Post-import CTA — from library (IMPORT-02)

- When no `deck_id`: user lands on the song show page as normal
- Add a simple text link below the song title: "Add this song to a deck →" linking to decks_path
- No dropdown, no auto-selection — user finds their deck and adds manually

### Import processing copy (IMPORT-01)

- Current: "Importing song..." + steps "Searching web" / "Generating pinyin"
- Update spinner label to: "Claude is structuring your lyrics..."
- Keep the two step indicators but update labels:
  - "Searching for lyrics" (was "Searching web")
  - "Generating pinyin" (unchanged)

### Section type chips (DECK-01)

- Per REQUIREMENTS: distinct warm color-coded chips per section type
- Verse / Chorus / Bridge each get a different warm chip color
- Current: all show as plain `text-rose-700` label — upgrade to a styled chip (small badge with bg color)
- Claude's discretion on exact color mapping (e.g., amber for verse, rose for chorus, stone/teal for bridge)

### Pencil icon on deck title (DECK-05)

- Current: pencil icon is always-visible — change to hover-only
- Reveal on `group-hover` of the title container (already uses `group` class)

### Auto-save indicator (DECK-06)

- Small, subtle indicator after arrangement or slide changes
- Claude's discretion on exact placement (e.g., small "Saved" text that fades in/out near the Arrangement sub-label)

### Song card artist metadata (DECK-02)

- `_song_block.html.erb` already shows artist as secondary text — no change needed for deck editor cards
- The library panel song list items (the search-to-add list in the left panel) do NOT show artist — add artist as secondary text below the song title in those list items

### Claude's Discretion

- Exact chip color mapping for verse / chorus / bridge (stay within warm palette: amber, rose, stone variants)
- Exact CSS for auto-save indicator (fade-in/out timing, placement)
- Which Devise views beyond sign-in/sign-up to apply card treatment (established in Phase 7)
- Whether `deck_id` auto-add logic lives in the job callback or the controller redirect

</decisions>

<specifics>
## Specific Ideas

- Export ready state should feel like an "achievement" — check icon + green button makes it visually distinct from the rose action buttons elsewhere
- Panel sub-labels ("ADD SONGS" / "ARRANGEMENT") should use the existing `text-xs font-semibold uppercase tracking-wider text-stone-400` style — consistent with "Slide Preview" and "Theme" labels already in use

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets

- `_export_button.html.erb`: Already has `:idle`, `:generating`, `:ready`, `:error` state branches — just update each branch's markup
- `_slide_item.html.erb`: Section type label already in place at `text-xs font-semibold uppercase tracking-wider text-rose-700` — upgrade to chip style
- `_song_block.html.erb`: Artist already rendered as `text-xs text-stone-400` — no change needed
- `songs/_processing.html.erb`: Step labels and spinner copy just need string updates
- `decks/show.html.erb`: Panel `h2` labels already exist as `text-xs font-semibold uppercase tracking-wider text-stone-400` — left panel currently has one "Arrangement" label; needs to be split into two sub-labels

### Established Patterns

- Heroicons inline SVG (no npm) — copy SVG inline
- `group` / `group-hover:opacity-100` pattern for hover-reveal (used on deck index card delete button in Phase 7)
- Turbo Stream from `"deck_export_#{@deck.id}"` — export button updates stream through this; don't break the `id="export_button_#{deck.id}"` DOM anchor
- `turbo_stream_from "song_import_#{@title.parameterize}"` in `songs/processing.html.erb` drives the processing page updates

### Integration Points

- `ImportSongJob` — job completion triggers Turbo Stream update to `song_status_#{song.id}`; auto-add + redirect logic (when `deck_id` present) would need a new Turbo Stream action or a controller-level redirect after job callback
- `GeneratePptxJob#broadcast_error` — update error copy here to match "Export failed — click to try again."
- `deck_deck_songs_path(@deck)` POST — already used for adding songs; auto-add from job can reuse this route

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 08-deck-editor-and-import-polish*
*Context gathered: 2026-03-16*
