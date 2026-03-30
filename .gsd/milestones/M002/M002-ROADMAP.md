# M002: M002: M002

## Vision
Implement the Sanctuary Stone design system from Google Stitch designs — a complete visual reskin transforming every user-facing page with editorial typography (Newsreader + Inter), Material Design 3-style color tokens, tonal layering instead of borders, gradient CTAs, ambient shadows, and Material Symbols icons. Pure frontend transformation — no new features, routes, or models.

## Slice Overview
| ID | Slice | Risk | Depends | Done | After this |
|----|-------|------|---------|------|------------|
| S01 | Design System Foundation | high | — | ✅ | After this: Tailwind tokens, fonts, Material Symbols, and shared layout (nav, flash, body) all render with Sanctuary Stone identity on every page |
| S02 | Auth Views | low | S01 | ✅ | After this: Sign in, sign up, forgot password, reset password, and account settings all render with centered card, atmospheric blur blobs, bottom-line inputs, and gradient submit button |
| S03 | Decks Index & Shared Components | medium | S01 | ✅ | After this: Deck list shows gallery-style cards with 16:9 theme-based preview, Newsreader headlines, song count badge, hover-delete, dashed Create New Deck card; flash toasts and empty states use Sanctuary Stone tokens |
| S04 | Song Library & Song Views | medium | S01 | ✅ | After this: Song library has editorial search panel, lyric preview snippets, serif headlines, and scriptural footer; song show/edit/processing/failed pages use Sanctuary Stone tokens |
| S05 | Deck Editor | high | S01 | ✅ | After this: 3-column deck editor uses Sanctuary Stone tokens throughout — arrangement panel with tonal layering, slide preview with numbered badges, theme panel with color circles, segmented toggle, and gradient AI button; all Stimulus controllers still work |
