---
estimated_steps: 1
estimated_files: 2
skills_used: []
---

# T01: Migration and model/controller changes

Generate and run migration adding show_pinyin (boolean, default true, not null) and lines_per_slide (integer, default 4, not null) to decks table. Add validations to Deck model. Permit new params in decks_controller.

## Inputs

- None specified.

## Expected Output

- `db/migrate/TIMESTAMP_add_display_settings_to_decks.rb`
- `db/schema.rb`

## Verification

bin/rails db:migrate && bin/rails runner "d = Deck.new; puts d.show_pinyin.inspect + ' ' + d.lines_per_slide.inspect" && bin/rails test
