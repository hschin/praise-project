# S03: Decks Index & Shared Components

**Goal:** Decks index shows gallery-style 16:9 theme-preview cards, tonal flash toasts, dashed Create New Deck card, empty state with Sanctuary Stone tokens
**Demo:** After this: After this: Deck list shows gallery-style cards with 16:9 theme-based preview, Newsreader headlines, song count badge, hover-delete, dashed Create New Deck card; flash toasts and empty states use Sanctuary Stone tokens

## Tasks
- [x] **T01: Decks index reskinned with 16:9 gallery cards, theme previews, tonal flash toasts, and dashed Create New Deck card** — Reskin decks/index.html.erb with gallery card layout, 16:9 theme preview area, Newsreader title, song count badge, hover-delete, dashed Create New Deck placeholder. Reskin flash toast and empty state with Sanctuary Stone tokens. Delivered as part of single M002 commit.
  - Estimate: 40m
  - Files: app/views/decks/index.html.erb, app/views/shared/_flash_toast.html.erb
  - Verify: bin/rails test && echo PASS
