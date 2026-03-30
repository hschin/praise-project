---
estimated_steps: 1
estimated_files: 10
skills_used: []
---

# T01: Reskin deck editor and all deck/theme partials with Sanctuary Stone tokens; verify all Stimulus controllers work

Reskin decks/show.html.erb, deck_songs/_song_block, deck_songs/_slide_item, decks/_slide_preview, decks/_export_button, decks/_form, themes/_applied_theme, themes/_form, themes/_suggestion_card, themes/_suggestion_row. Apply tonal layering, slide number badges, gradient AI button. Delivered as part of single M002 commit.

## Inputs

- `app/assets/tailwind/application.css`

## Expected Output

- `Deck editor fully reskinned with Sanctuary Stone tokens; all Stimulus controllers working`

## Verification

bin/rails test && echo PASS
