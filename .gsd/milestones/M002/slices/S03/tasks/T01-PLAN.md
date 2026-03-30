---
estimated_steps: 1
estimated_files: 2
skills_used: []
---

# T01: Reskin decks index with gallery cards, theme previews, tonal flash toasts, and dashed Create New Deck card

Reskin decks/index.html.erb with gallery card layout, 16:9 theme preview area, Newsreader title, song count badge, hover-delete, dashed Create New Deck placeholder. Reskin flash toast and empty state with Sanctuary Stone tokens. Delivered as part of single M002 commit.

## Inputs

- `app/assets/tailwind/application.css`

## Expected Output

- `Decks index with gallery cards and tonal flash toast`

## Verification

bin/rails test && echo PASS
