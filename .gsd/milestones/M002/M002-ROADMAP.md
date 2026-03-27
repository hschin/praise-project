# M002: M002

**Vision:** Implement the Sanctuary Stone design system from Google Stitch designs — a complete visual reskin transforming every user-facing page with editorial typography (Newsreader + Inter), Material Design 3-style color tokens, tonal layering instead of borders, gradient CTAs, ambient shadows, and Material Symbols icons. Pure frontend transformation — no new features, routes, or models.

## Success Criteria

- Every user-facing page renders with Sanctuary Stone color tokens — no remaining raw stone-*/rose-* utility classes for structural styling
- Newsreader + Inter typography serves from Google Fonts; Playfair Display reference fully removed
- Google Material Symbols web font loaded; no inline Heroicon SVGs remain in views
- No 1px solid borders used for sectioning anywhere — depth achieved via tonal layering
- All existing Stimulus controller behavior (inline_edit, sortable, song_search, color_picker, auto_save, flash, pinyin_toggle) works after reskin
- rails test passes with no regressions
- Visual inspection of login, decks index, song library, and deck editor confirms faithful match to Stitch designs

## Slices

- [ ] **S01: Design System Foundation** `risk:high` `depends:[]`
  > After this: After this: Tailwind tokens, fonts, Material Symbols, and shared layout (nav, flash, body) all render with Sanctuary Stone identity on every page

- [ ] **S02: Auth Views** `risk:low` `depends:[S01]`
  > After this: After this: Sign in, sign up, forgot password, reset password, and account settings all render with centered card, atmospheric blur blobs, bottom-line inputs, and gradient submit button

- [ ] **S03: Decks Index & Shared Components** `risk:medium` `depends:[S01]`
  > After this: After this: Deck list shows gallery-style cards with 16:9 theme-based preview, Newsreader headlines, song count badge, hover-delete, dashed Create New Deck card; flash toasts and empty states use Sanctuary Stone tokens

- [ ] **S04: Song Library & Song Views** `risk:medium` `depends:[S01]`
  > After this: After this: Song library has editorial search panel, lyric preview snippets, serif headlines, and scriptural footer; song show/edit/processing/failed pages use Sanctuary Stone tokens

- [ ] **S05: Deck Editor** `risk:high` `depends:[S01]`
  > After this: After this: 3-column deck editor uses Sanctuary Stone tokens throughout — arrangement panel with tonal layering, slide preview with numbered badges, theme panel with color circles, segmented toggle, and gradient AI button; all Stimulus controllers still work

## Boundary Map

### S01 → S02, S03, S04, S05

Produces:
- `app/assets/tailwind/application.css` → Full Sanctuary Stone @theme token set (~40 color tokens, font families, border radii)
- `app/views/layouts/application.html.erb` → Reskinned layout with Newsreader wordmark, Material Symbols, frosted glass nav, flash container
- Google Fonts CDN links for Newsreader, Inter, Material Symbols Outlined
- CSS custom properties available as Tailwind utilities (bg-surface, text-on-surface, bg-primary, etc.)
- Gradient CTA button pattern established (from-primary to-primary-container)

Consumes: nothing (foundation slice)

### S02 → nothing downstream

Produces:
- All Devise auth views reskinned with centered card + atmospheric blur treatment
- Auth error partial reskinned
- Bottom-line input pattern established for form fields

Consumes from S01:
- Sanctuary Stone @theme tokens
- Newsreader + Inter font families
- Material Symbols web font
- Gradient CTA button pattern

### S03 → nothing downstream

Produces:
- Decks index with 16:9 theme-based preview cards
- Flash toast partial reskinned
- Empty state pattern on Sanctuary Stone tokens
- Dashed "Create New Deck" placeholder card pattern

Consumes from S01:
- Sanctuary Stone @theme tokens
- Newsreader headline font
- Material Symbols web font
- Ambient shadow pattern

### S04 → nothing downstream

Produces:
- Song library with editorial search panel and lyric preview rows
- Song show, edit, processing, and failed views reskinned
- Unified search panel pattern (search + import + paste in one section)

Consumes from S01:
- Sanctuary Stone @theme tokens
- Newsreader + Inter typography
- Material Symbols web font
- Tonal layering pattern

### S05 → nothing downstream

Produces:
- Deck editor 3-column layout fully reskinned
- Theme panel with color circles, segmented toggle, gradient AI button
- Arrangement panel with tonal layering and Sanctuary Stone badges
- Slide preview with numbered badges
- All partials (song_block, slide_item, slide_preview, export_button, theme forms) reskinned

Consumes from S01:
- Sanctuary Stone @theme tokens
- Newsreader + Inter typography
- Material Symbols web font
- Gradient CTA button pattern
- Ambient shadow pattern
