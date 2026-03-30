# S01: Deck Settings — DB & Panel

**Goal:** Add show_pinyin and lines_per_slide to the Deck model with migration, validations, and a settings UI panel in the deck editor right column
**Demo:** After this: Open deck editor → see Settings panel below Theme → toggle Show Pinyin off → save → reload → setting persists. Change Lines per Slide to 2 → save → reload → persists.

## Tasks
- [x] **T01: Migration, model validation, and controller params for deck display settings** — Generate and run migration adding show_pinyin (boolean, default true, not null) and lines_per_slide (integer, default 4, not null) to decks table. Add validations to Deck model. Permit new params in decks_controller.
  - Estimate: 10m
  - Files: app/models/deck.rb, app/controllers/decks_controller.rb
  - Verify: bin/rails db:migrate && bin/rails runner "d = Deck.new; puts d.show_pinyin.inspect + ' ' + d.lines_per_slide.inspect" && bin/rails test
- [x] **T02: Display Settings panel in deck editor right column with pinyin toggle and lines-per-slide select** — Add a Display Settings section in the deck editor right column (show.html.erb), below the Theme section. Contains a Show Pinyin toggle checkbox and a Lines per Slide select (1-8). Submits via form_with to PATCH /decks/:id. Save button is the gradient CTA style.
  - Estimate: 20m
  - Files: app/views/decks/show.html.erb
  - Verify: bin/rails test && grep -q 'show_pinyin' app/views/decks/show.html.erb && echo PASS
