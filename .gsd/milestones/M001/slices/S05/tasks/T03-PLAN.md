# T03: 05-design-foundation 03

**Slice:** S05 — **Milestone:** M001

## Description

Add the quick-create deck flow: a new route, controller action, and updated index button — so clicking "New Deck" anywhere creates a deck with the upcoming Sunday's date and drops the user directly into the deck editor with no intermediate form step.

Purpose: NAV-03 and NAV-04 (backend part) — the user never sees a creation form. The action also prepares the `update` action for the inline-edit Stimulus fetch that Plan 04 wires up.
Output: `quick_create` route + controller action, updated decks index button, Wave 0 test stubs passing.

## Must-Haves

- [ ] "POST /decks/quick_create creates a deck with the upcoming Sunday's date as title and redirects to the deck editor"
- [ ] "The deck title produced by quick_create matches the format 'Sunday D Month' (e.g., 'Sunday 15 March') for the next occurring Sunday"
- [ ] "The decks index 'New Deck' button POSTs to quick_create_decks_path instead of linking to new_deck_path"
- [ ] "DecksController#update responds to JSON format with head :ok so inline-edit Stimulus fetches get a non-redirecting 200"

## Files

- `config/routes.rb`
- `app/controllers/decks_controller.rb`
- `app/views/decks/index.html.erb`
- `test/controllers/decks_controller_test.rb`
