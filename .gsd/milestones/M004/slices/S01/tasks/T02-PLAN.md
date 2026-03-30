---
estimated_steps: 1
estimated_files: 1
skills_used: []
---

# T02: Settings panel in deck editor

Add a Display Settings section in the deck editor right column (show.html.erb), below the Theme section. Contains a Show Pinyin toggle checkbox and a Lines per Slide select (1-8). Submits via form_with to PATCH /decks/:id. Save button is the gradient CTA style.

## Inputs

- `app/models/deck.rb`

## Expected Output

- `app/views/decks/show.html.erb or a new partial`

## Verification

bin/rails test && grep -q 'show_pinyin' app/views/decks/show.html.erb && echo PASS
