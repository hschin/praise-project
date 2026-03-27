# S05: Design Foundation

**Goal:** Define the Tailwind v4 design token foundation and replace all indigo/gray Tailwind classes with warm amber/stone equivalents across the 21 non-layout ERB view files.
**Demo:** Define the Tailwind v4 design token foundation and replace all indigo/gray Tailwind classes with warm amber/stone equivalents across the 21 non-layout ERB view files.

## Must-Haves


## Tasks

- [x] **T01: 05-design-foundation 01**
  - Define the Tailwind v4 design token foundation and replace all indigo/gray Tailwind classes with warm amber/stone equivalents across the 21 non-layout ERB view files.

Purpose: Establish the canonical color token source of truth and eliminate every legacy indigo and gray class from views so that the app displays the warm, worshipful palette (VIS-01).
Output: An @theme block in application.css; 21 view files with all indigo-* and gray-* classes replaced using the mapping table below.
- [x] **T02: 05-design-foundation 02**
  - Restructure the global application layout to apply the warm palette, styled wordmark, and redesigned navigation bar — establishing the visual foundation that every page inherits.

Purpose: The layout file is the single highest-leverage change in Phase 5 — it touches every page simultaneously. Getting the wordmark, nav structure, body class, and typography baseline right here delivers VIS-01, VIS-02, VIS-03, VIS-04, and NAV-01 in one file.
Output: Updated application.html.erb with warm body/nav colors, font-serif wordmark, restructured nav (Decks primary / New Deck CTA / Songs + Logout utility), and flash styling.
- [x] **T03: 05-design-foundation 03** `est:8min`
  - Add the quick-create deck flow: a new route, controller action, and updated index button — so clicking "New Deck" anywhere creates a deck with the upcoming Sunday's date and drops the user directly into the deck editor with no intermediate form step.

Purpose: NAV-03 and NAV-04 (backend part) — the user never sees a creation form. The action also prepares the `update` action for the inline-edit Stimulus fetch that Plan 04 wires up.
Output: `quick_create` route + controller action, updated decks index button, Wave 0 test stubs passing.
- [x] **T04: 05-design-foundation 04** `est:45min`
  - Create the Stimulus inline-edit controller and wire it into the deck editor header so users can click a pencil icon to rename the deck title in-place without leaving the page.

Purpose: NAV-04 — The deck title created by quick_create needs to be immediately editable from the editor. The inline-edit affordance (pencil icon on hover) is the UX contract that makes this feel seamless.
Output: inline_edit_controller.js, registration in index.js, updated deck show header.

## Files Likely Touched

- `app/assets/tailwind/application.css`
- `app/views/decks/_export_button.html.erb`
- `app/views/decks/_form.html.erb`
- `app/views/decks/index.html.erb`
- `app/views/deck_songs/_song_block.html.erb`
- `app/views/deck_songs/_slide_item.html.erb`
- `app/views/songs/index.html.erb`
- `app/views/songs/show.html.erb`
- `app/views/songs/edit.html.erb`
- `app/views/songs/_form.html.erb`
- `app/views/songs/_lyrics.html.erb`
- `app/views/songs/_failed.html.erb`
- `app/views/songs/_processing.html.erb`
- `app/views/songs/processing.html.erb`
- `app/views/themes/_form.html.erb`
- `app/views/themes/_applied_theme.html.erb`
- `app/views/themes/_suggestion_card.html.erb`
- `app/views/devise/sessions/new.html.erb`
- `app/views/devise/registrations/new.html.erb`
- `app/views/devise/passwords/new.html.erb`
- `app/views/devise/shared/_links.html.erb`
- `app/views/layouts/application.html.erb`
- `config/routes.rb`
- `app/controllers/decks_controller.rb`
- `app/views/decks/index.html.erb`
- `test/controllers/decks_controller_test.rb`
- `app/javascript/controllers/inline_edit_controller.js`
- `app/javascript/controllers/index.js`
- `app/views/decks/show.html.erb`
