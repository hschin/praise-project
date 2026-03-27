# M002: v1.2 Sanctuary Stone

**Gathered:** 2026-03-25
**Status:** Ready for planning

## Project Description

Praise Project is a shipped Rails web app for Chinese church worship teams to build and export PPTX slide decks. v1.0 is fully functional. v1.1 completed a UI polish pass. This milestone implements the "Sanctuary Stone" design system — a complete visual reskin from Google Stitch designs — transforming the app from "Rails scaffold with nice colors" into a "digital sanctuary" with editorial, liturgical visual identity.

## Why This Milestone

The current UI (post-v1.1) uses a warm stone/rose Tailwind palette with standard component patterns — boxed inputs, 1px borders, Playfair Display serif, inline Heroicon SVGs. It's pleasant but generic. The Sanctuary Stone design system created in Google Stitch represents a deliberate visual identity: Newsreader + Inter typography, Material Design 3-style color tokens, tonal layering instead of borders, gradient CTAs, atmospheric depth. The worship leaders deserve a tool that looks like it was made for worship, not for SaaS.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Sign in and see the entire app rendered with the Sanctuary Stone identity — no page breaks the aesthetic
- Browse decks with gallery-style cards showing theme preview images
- Edit decks in the 3-column editor with the redesigned theme panel (color circles, segmented toggle, gradient AI button)
- Navigate with the new top bar (Newsreader italic wordmark, active page underline, Material Symbols icons)

### Entry point / environment

- Entry point: http://localhost:3000
- Environment: local dev (Rails server + Tailwind watcher)
- Live dependencies involved: Google Fonts CDN (Newsreader, Inter, Material Symbols)

## Completion Class

- Contract complete means: all ERB templates use Sanctuary Stone tokens; no raw stone/rose utility holdovers; `rails test` passes
- Integration complete means: every page renders correctly in browser with fonts loaded and tokens applied
- Operational complete means: none (no server-side behavior changes)

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- Navigate every user-facing page (auth, decks index, song library, deck editor, song show/edit) and visually confirm Sanctuary Stone identity
- No page shows raw stone-*/rose-* utility classes for structural styling
- All existing Stimulus controller behavior (inline_edit, sortable, song_search, color_picker, auto_save, flash, pinyin_toggle) still works after the reskin
- `rails test` passes with no regressions

## Risks and Unknowns

- Tailwind v4 @theme token depth — the DESIGN.md defines ~40 color tokens; need to confirm all resolve correctly in Tailwind v4's @theme directive
- Stimulus controller CSS coupling — controllers like sortable_controller and song_search_controller may have hardcoded Tailwind classes for UI state; changing classes could break interactivity
- Font loading performance — adding Newsreader + Inter + Material Symbols = 3 Google Fonts requests; need to verify no visible FOUT/FOUC
- Deck card theme previews — rendering theme background_color or background_image in a 16:9 preview area needs to handle decks with no theme gracefully

## Existing Codebase / Prior Art

- `app/assets/tailwind/application.css` — current @theme tokens (worship-primary, worship-surface, etc.) — will be completely rewritten
- `app/views/layouts/application.html.erb` — shared layout with nav, flash container, main wrapper
- `app/views/decks/show.html.erb` — deck editor (38 color references, most complex view)
- `app/views/songs/index.html.erb` — song library (17 color references)
- `app/views/devise/sessions/new.html.erb` — current login page
- `app/views/shared/_flash_toast.html.erb` — flash message partial
- `app/javascript/controllers/` — 9 Stimulus controllers that must survive the reskin
- `stitch_deck_editor/` — Google Stitch export with HTML, PNGs, and DESIGN.md reference

> See `.gsd/DECISIONS.md` for all architectural and pattern decisions — it is an append-only register; read it during planning, append to it during execution.

## Relevant Requirements

- R001-R003 — Token system, typography, and icon font (foundation, S01)
- R004-R005 — No-line rule and gradient CTAs (applied across S02-S05)
- R006 — Auth views (S02)
- R007 — Decks index with theme previews (S03)
- R008 — Song library (S04)
- R009 — Deck editor (S05)
- R010-R011 — Nav bar and shadow system (S01)
- R012 — Flash/error/processing states (S03-S04)

## Scope

### In Scope

- Complete Sanctuary Stone design token system in Tailwind v4 @theme
- Newsreader + Inter + Material Symbols font loading
- Reskin of all 40 ERB templates and partials
- Nav bar redesign (top bar only, no sidebar)
- Auth views (all Devise views)
- Decks index with 16:9 theme-based preview cards
- Song library with editorial search panel
- Deck editor with redesigned theme panel
- Flash messages, error states, processing screens
- Empty states

### Out of Scope / Non-Goals

- Left sidebar navigation (Collections/Drafts/Recent not real features)
- Grid/List view toggle
- Global Slide Master / Manage Transitions
- Any new backend features, routes, or models
- Mobile bottom nav bar (shown in Stitch but not prioritized)
- Dark mode (Stitch HTML has dark mode classes but not designed)

## Technical Constraints

- Tailwind CSS v4 via tailwindcss-rails gem — @theme directive for custom tokens
- No Node/Webpack — Importmap only; Material Symbols must be a CDN stylesheet, not an npm package
- All existing Stimulus controllers must continue working — no controller JS changes unless a class name dependency breaks
- Google Fonts CDN for all fonts (Newsreader, Inter, Material Symbols Outlined)

## Integration Points

- Google Fonts CDN — font loading for Newsreader, Inter, Material Symbols Outlined
- Stitch design exports — `stitch_deck_editor/` directory contains reference HTML and PNGs for each screen

## Open Questions

- None — all design decisions locked during discussion
