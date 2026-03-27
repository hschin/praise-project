# S08: Deck Editor and Import Polish

**Goal:** The deck editor and import flow are visually complete with section labels, a prominent export affordance, inline editing cues, and import status copy that reflects actual AI activity — all without breaking any existing Turbo Stream, drag-and-drop, or CSS contracts
**Demo:** Slide items show color-coded section chips, export button has download icon and celebratory ready state, panel labels orient non-technical users, import screen shows AI activity copy, and post-import prompts deck addition

## Must-Haves

- Slide items show color-coded chips labeling verse/chorus/bridge section types
- Song cards display artist/composer as secondary metadata
- PPTX export button is prominent with download icon; ready state is celebratory
- Deck editor three-column layout is labeled (Songs / Arrangement / Preview)
- Import processing screen shows "Claude is structuring your lyrics..." copy
- Post-import screen prompts user to add song to a deck

## Tasks

- [x] **T01: Wave 0 Test Scaffolding** `est:12min`
  - 9 failing TDD scaffolding tests across 2 controller test files, covering all Phase 8 DECK and IMPORT requirements as RED baseline for Wave 1 implementation
- [x] **T02: Slide Section Chips + Export Button States** `est:10min`
  - Color-coded section chip badges (verse=amber, chorus=rose, bridge=stone) and icon-enhanced export button in two self-contained partials
- [x] **T03: Deck Editor Show Page Polish** `est:15min`
  - Panel label split (ARRANGEMENT / ADD SONGS), auto-save Stimulus controller, artist secondary text, and hover-only title pencil
- [x] **T04: Import Processing Copy + Add-to-Deck CTA** `est:5min`
  - Updated spinner copy to "Claude is structuring your lyrics..." and conditional add-to-deck link on done song show pages

## Files Likely Touched

- `test/controllers/decks_controller_test.rb`
- `test/controllers/songs_controller_test.rb`
- `app/views/deck_songs/_slide_item.html.erb`
- `app/views/decks/_export_button.html.erb`
- `app/views/decks/show.html.erb`
- `app/javascript/controllers/auto_save_controller.js`
- `app/views/songs/_processing.html.erb`
- `app/views/songs/show.html.erb`
