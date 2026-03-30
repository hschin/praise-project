# S05: Deck Editor

**Goal:** Deck editor renders with Sanctuary Stone tokens throughout — 3-column layout with tonal panels, slide number badges, theme panel with color inputs, gradient AI button; all Stimulus controllers working
**Demo:** After this: After this: 3-column deck editor uses Sanctuary Stone tokens throughout — arrangement panel with tonal layering, slide preview with numbered badges, theme panel with color circles, segmented toggle, and gradient AI button; all Stimulus controllers still work

## Tasks
- [x] **T01: Deck editor and all partials reskinned with Sanctuary Stone tokens; all Stimulus controllers verified working** — Reskin decks/show.html.erb, deck_songs/_song_block, deck_songs/_slide_item, decks/_slide_preview, decks/_export_button, decks/_form, themes/_applied_theme, themes/_form, themes/_suggestion_card, themes/_suggestion_row. Apply tonal layering, slide number badges, gradient AI button. Delivered as part of single M002 commit.
  - Estimate: 60m
  - Files: app/views/decks/show.html.erb, app/views/deck_songs/_song_block.html.erb, app/views/deck_songs/_slide_item.html.erb, app/views/decks/_slide_preview.html.erb, app/views/decks/_export_button.html.erb, app/views/decks/_form.html.erb, app/views/themes/_applied_theme.html.erb, app/views/themes/_form.html.erb, app/views/themes/_suggestion_card.html.erb, app/views/themes/_suggestion_row.html.erb
  - Verify: bin/rails test && echo PASS
