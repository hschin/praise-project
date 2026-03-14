---
phase: 03-deck-editor
plan: "02"
subsystem: ui
tags: [sortablejs, stimulus, drag-and-drop, turbo, hotwire, deck-editor, arrangement]

# Dependency graph
requires:
  - phase: 03-deck-editor/03-01
    provides: DeckSong model with arrangement JSONB, safe_lyrics, importmap with sortablejs and @rails/request.js pinned

provides:
  - PATCH /decks/:deck_id/deck_songs/:id/reorder — updates DeckSong position
  - PATCH /decks/:deck_id/deck_songs/:id/update_arrangement — replaces arrangement array
  - SortableJS Stimulus controller (sortable_controller.js) handling both song-level and slide-level DnD
  - Deck show page with sortable song list, per-song slide arrangement, Remove/+Repeat per slide, Edit lyrics link, Slide Preview section

affects:
  - 03-deck-editor/03-03
  - 03-deck-editor/03-04
  - 03-deck-editor/03-05

# Tech tracking
tech-stack:
  added: []
  patterns:
    - SortableJS Stimulus controller with URL template (:id placeholder) for song-level reorder
    - arrangement mutations via button_to with method :patch passing full new array as params
    - slide_item partial owns its own arrangement delta (new_arrangement_without, new_arrangement_repeat)
    - eagerLoadControllersFrom auto-registers sortable_controller — no manual index.js registration

key-files:
  created:
    - app/javascript/controllers/sortable_controller.js
    - app/views/deck_songs/_slide_item.html.erb
    - app/views/deck_songs/_song_block.html.erb
  modified:
    - config/routes.rb
    - app/controllers/deck_songs_controller.rb
    - app/views/decks/show.html.erb

key-decisions:
  - "sortable_controller urlValue uses :id placeholder string, replaced at runtime with event.item.dataset.id — avoids one controller per song"
  - "slide Remove uses arrangement.dup.delete_at(index) by index (not lyric_id) to correctly handle duplicate slides"
  - "decks/show.html.erb preserved existing theme section content from Plan 03-03 while adding sortable song list and slide preview sections"

patterns-established:
  - "Arrangement mutation pattern: partial computes new_arrangement locally, button_to POSTs full array — server replaces, no partial update"
  - "SortableJS onEnd guard: if (event.oldIndex === event.newIndex) return — prevents redundant PATCH on no-op drop"

requirements-completed: [SLIDE-01, SLIDE-02, SLIDE-03, SLIDE-05, DECK-02, DECK-03, DECK-04]

# Metrics
duration: 3min
completed: 2026-03-13
---

# Phase 03 Plan 02: Deck Editor — Interactive Drag-and-Drop Song and Slide Arrangement

**SortableJS Stimulus controller + reorder/update_arrangement PATCH endpoints + rebuilt deck show view with per-song slide cards featuring Remove, +Repeat, and Edit lyrics actions**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-13T14:22:17Z
- **Completed:** 2026-03-13T14:25:27Z
- **Tasks:** 3
- **Files modified:** 6

## Accomplishments
- Added `reorder` and `update_arrangement` PATCH member routes and controller actions — server-side persistence for both DnD modes
- Created `sortable_controller.js` handling both song-list (position) and slide-list (arrangement) drag modes from a single controller via `paramValue`
- Rebuilt `decks/show.html.erb` with sortable song list, `_song_block` and `_slide_item` partials, slide preview with ruby/pinyin annotation, and theme section preserved from Plan 03-03

## Task Commits

Each task was committed atomically:

1. **Task 1: Add routes and DeckSongsController reorder + update_arrangement actions** - `a3ffd79` (feat)
2. **Task 2: SortableJS Stimulus controller** - `bba32a4` (feat)
3. **Task 3: Rebuild decks/show with sortable song list and slide arrangement partials** - `f4b974f` (feat)

**Plan metadata:** (docs commit — see final commit)

## Files Created/Modified
- `config/routes.rb` — added member routes patch :reorder and patch :update_arrangement under deck_songs
- `app/controllers/deck_songs_controller.rb` — added reorder and update_arrangement actions returning head :ok
- `app/javascript/controllers/sortable_controller.js` — SortableJS Stimulus controller, both DnD modes
- `app/views/deck_songs/_slide_item.html.erb` — draggable slide card with Remove and +Repeat buttons
- `app/views/deck_songs/_song_block.html.erb` — song header with drag handle, Edit lyrics link, sortable slide list
- `app/views/decks/show.html.erb` — rebuilt with sortable song list, Add Song form, theme section, slide preview

## Decisions Made
- `sortable_controller.js` uses a `:id` placeholder in `urlValue` replaced at runtime with `event.item.dataset.id` — a single controller instance handles all songs without re-instantiation
- The Remove button uses `arrangement.dup.delete_at(arrangement_index)` by index (not value) so duplicate lyric entries are removed at the correct position
- `decks/show.html.erb` preserved the theme partial integration added by Plan 03-03 (which had already committed `_applied_theme.html.erb`, `_form.html.erb`, theme turbo stream, etc.) while integrating the new sortable song list and slide preview sections

## Deviations from Plan

None — plan executed exactly as written. The theme section in `decks/show.html.erb` was already updated by Plan 03-03 commits; the rebuild preserved those changes rather than discarding them.

## Issues Encountered
- `app/views/decks/show.html.erb` had been modified by Plan 03-03 (themes controller) between plan authorship and execution. Read the updated file and incorporated existing theme partials before rewriting.
- Pre-existing `GenerateThemeSuggestionsJobTest` failures (Wave 0 stubs for future plans) present in full test suite — unrelated to this plan, not fixed.

## User Setup Required
None — no external service configuration required.

## Next Phase Readiness
- Sortable DnD infrastructure complete for both song and slide level
- Routes and controller actions ready for Plan 03-03 (PPTX export / slide preview enhancement)
- Theme section placeholder `id="theme_section"` and slide preview `id="slide_preview_section"` anchors present for Plans 04/05

## Self-Check: PASSED

- sortable_controller.js: FOUND
- _slide_item.html.erb: FOUND
- _song_block.html.erb: FOUND
- 03-02-SUMMARY.md: FOUND
- Commit a3ffd79 (Task 1): FOUND
- Commit bba32a4 (Task 2): FOUND
- Commit f4b974f (Task 3): FOUND

---
*Phase: 03-deck-editor*
*Completed: 2026-03-13*
