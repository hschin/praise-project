# Phase 3: Deck Editor - Context

**Gathered:** 2026-03-12
**Status:** Ready for planning

<domain>
## Phase Boundary

Users build a complete service deck — adding songs from the library, arranging slides per song, reordering songs, and choosing a visual theme — ready for PPTX export. Slide content is not editable inside the deck; content changes go through the song library. PPTX generation is Phase 4.

</domain>

<decisions>
## Implementation Decisions

### Slide editing scope
- Slides are **read-only** within the deck editor — no inline text editing
- Each song block in the deck shows an "Edit lyrics →" link that opens the song's edit page (in new tab)
- To change slide content, users go to the song library; changes propagate to all decks using that song
- No per-deck Slide content override needed — simplifies data model significantly

### Slide arrangement
- When a song is added to a deck, `DeckSong.arrangement` is initialized from the song's lyrics in natural position order
- User can reorder slides within a song using drag-and-drop (same SortableJS instance as song reordering)
- Removing a slide permanently removes its lyric ID from `DeckSong.arrangement` — no soft-hide/toggle
- Repeating a section: each slide card has a "+ Repeat" button that appends a duplicate lyric ID to the arrangement (SLIDE-05)

### Reordering interaction
- **Drag-and-drop for everything**: SortableJS for both song reordering in the deck and slide reordering within songs
- Consistent interaction — same pattern at both levels
- Fires a Turbo request to persist new positions to the server

### Slide preview
- CSS simulation: 16:9 styled rectangle with theme background color/image, large centered Chinese text, pinyin displayed above characters (ruby-style)
- Labeled "Approximate Preview" — user is aware it may not be pixel-perfect vs. the PPTX
- Inline below the slide arrangement list on the deck page — always visible, no extra click
- Pinyin always shown in preview thumbnails (regardless of song view toggle state)

### Theme storage
- Separate `Theme` table (not JSONB on Deck) — allows reusing themes across decks in future
- `Deck` belongs_to `Theme` (optional — deck can have no theme assigned)
- Theme attributes: `background_color`, `text_color`, `font_size`, `background_image` (ActiveStorage attachment), `name`, `source` (ai/custom), `unsplash_url`

### AI theme suggestions (THEME-01)
- "Get AI suggestions" triggers a background job — Claude returns 5 theme suggestions with Unsplash photo URLs
- Suggestions render as a horizontal scrollable row inline on the deck edit page (no modal)
- Each card shows: Unsplash thumbnail, suggested colors as swatches, theme name
- User clicks a card to apply — creates a Theme record and associates it with the deck

### Custom theme (THEME-02 + THEME-03)
- Custom theme form on the deck edit page: background color picker/hex input, text color picker/hex input, font size (small/medium/large presets)
- Background image upload (THEME-03): file upload stored via ActiveStorage — replaces background_color when present
- All three (THEME-01, 02, 03) feed into the same Theme model; AI suggestions are just pre-filled Theme records

### Claude's Discretion
- Exact SortableJS configuration and Stimulus controller structure
- CSS details for the 16:9 preview thumbnails (shadow, rounded corners, scale)
- Font size pixel values for the small/medium/large presets
- Color picker implementation (native HTML input[type=color] is fine)
- How arrangement updates are sent to the server (PATCH with JSON array vs. individual position params)

</decisions>

<specifics>
## Specific Ideas

- Preview is intentionally approximate — label it clearly so worship leaders aren't surprised if PPTX output differs slightly
- Theme reusability across decks is the reason for a separate Theme table (even though v1 doesn't expose a theme library UI)
- Repeating the chorus is a core worship use case — "+ Repeat" per slide is the right granularity

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Deck` model: `belongs_to :user`, `has_many :deck_songs` — ready; needs `belongs_to :theme, optional: true`
- `DeckSong` model: `arrangement` JSONB column already exists and is documented — initialize it when song added
- `Slide` model: exists with `deck_song`, `lyric`, `content`, `position` — may not need to be materialized if arrangement JSONB drives order
- `DecksController`: full CRUD in place, `export` action stubbed — add theme assignment here
- `DeckSongsController`: create/update/destroy in place — extend create to initialize arrangement
- ActiveStorage: already configured — use for theme background image upload
- Solid Queue + ApplicationJob: use for AI theme suggestion generation (Claude API call)
- Turbo + Stimulus: use for drag-and-drop position persistence and theme suggestion loading

### Established Patterns
- Background jobs: `NameJob < ApplicationJob`, enqueued with `perform_later` — use for AI theme job
- Turbo Stream: use for broadcasting theme suggestions back to the deck page after Claude responds
- Drag-and-drop: SortableJS not yet installed — needs to be added via importmap or vendored
- Button style: `"bg-indigo-600 text-white text-sm px-4 py-2 rounded hover:bg-indigo-700"`
- Destructive action: `button_to` with `method: :delete` and `data: { turbo_confirm: "..." }` — already used on deck show

### Integration Points
- `app/views/decks/show.html.erb` — main editing surface; needs song drag-and-drop, slide arrangement per song, preview section, theme UI
- `app/controllers/deck_songs_controller.rb` — extend create to initialize arrangement from song lyrics
- `config/routes.rb` — likely needs nested routes for slides under deck_songs; reorder action for drag-and-drop
- `app/models/deck_song.rb` — add arrangement initialization logic and helper methods
- New: `Theme` model, `ThemesController`, AI theme suggestion job

</code_context>

<deferred>
## Deferred Ideas

- Theme library UI (browse/reuse saved themes across decks) — future phase; Theme table structure supports it
- Visual pixel-perfect preview via PPTX thumbnail generation — Phase 4 (once PPTX pipeline exists)

</deferred>

---

*Phase: 03-deck-editor*
*Context gathered: 2026-03-12*
