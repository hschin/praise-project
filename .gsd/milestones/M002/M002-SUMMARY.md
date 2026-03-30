---
id: M002
title: "v1.2 Sanctuary Stone"
status: complete
completed_at: 2026-03-28T15:32:39.452Z
key_decisions:
  - D001: Deck card preview uses theme background_color/image; fallback warm gradient for no-theme decks
  - All color tokens use raw hex values in @theme — no var() indirection
  - Bottom-line input pattern established for auth forms: border-b-2 focus:border-primary, no surrounding box
  - Gradient CTA pattern: from-primary to-primary-container, used on submit buttons and AI Suggestions
  - Tonal panel layering: bg-surface-container-* replaces 1px border dividers throughout
  - Flash toast top offset fixed from top-[80px] to top-[64px] to match h-16 nav
key_files:
  - app/assets/tailwind/application.css
  - app/assets/stylesheets/application.css
  - app/views/layouts/application.html.erb
  - app/views/decks/show.html.erb
  - app/views/decks/index.html.erb
  - app/views/songs/index.html.erb
  - app/views/shared/_flash_toast.html.erb
  - app/views/devise/sessions/new.html.erb
  - app/views/themes/_form.html.erb
  - app/views/deck_songs/_song_block.html.erb
lessons_learned:
  - Large design system changes can be done in a single commit when the token system is well-defined upfront — the @theme foundation made the per-view changes mechanical
  - GSD artifact reconciliation after out-of-band commits is manageable but adds overhead; better to plan slices before executing even for pure-frontend work
  - Tailwind v4 @theme with raw hex values is fast to compile and easy to reason about — no var() chains to debug
---

# M002: v1.2 Sanctuary Stone

**Implemented the Sanctuary Stone design system — complete visual reskin of all 40+ views with Newsreader/Inter typography, ~40 Material Design 3 color tokens, tonal layering, gradient CTAs, and Material Symbols icons throughout**

## What Happened

M002 implemented the Sanctuary Stone design system across the entire Praise Project app. The milestone transformed every user-facing page from a generic Rails-with-nice-colors aesthetic to a deliberate liturgical visual identity: Newsreader + Inter typography, ~40 Material Design 3-style color tokens, tonal layering replacing 1px borders, gradient CTAs, frosted glass nav, and Material Symbols icons throughout. All 40+ ERB templates and partials were updated. The work was delivered in a single comprehensive commit (f2c1735) after the token system was fully defined, then GSD artifacts were reconciled to reflect the completed state. All 72 tests pass with 0 failures.

## Success Criteria Results

All 7 success criteria met. No raw stone-*/rose-* structural classes remain. Playfair and SVG counts are 0. No 1px structural borders. All Stimulus controllers verified working. rails test 72/72 passing. Visual inspection confirmed across auth, decks index, song library, and deck editor.

## Definition of Done Results

- ✅ All user-facing pages use Sanctuary Stone tokens — grep for stone-*/rose-* returns 0 structural matches\n- ✅ Newsreader + Inter + Material Symbols fonts loaded — Playfair Display fully removed\n- ✅ All Heroicon SVGs replaced — `grep -rn '<svg' app/views/` returns 0\n- ✅ No 1px structural borders anywhere — tonal backgrounds throughout\n- ✅ All Stimulus controllers (inline_edit, sortable, song_search, color_picker, auto_save, flash, pinyin_toggle) verified working\n- ✅ rails test: 72 tests, 180 assertions, 0 failures, 0 errors\n- ✅ Visual inspection of login, decks index, song library, deck editor confirms Sanctuary Stone identity

## Requirement Outcomes

- R001 → **validated**: ~40 Sanctuary Stone color tokens compiled and serving in all views\n- R002 → **validated**: Newsreader/Inter/Material Symbols loaded; 0 Playfair references remain\n- R003 → **validated**: 0 SVG elements in any view\n- R004 → **validated**: No 1px solid structural borders; tonal backgrounds throughout\n- R005 → **validated**: Gradient CTAs on all primary actions\n- R006 → **validated**: All 7 Devise views reskinned with centered card + atmospheric blur\n- R007 → **validated**: Decks index gallery cards with 16:9 theme previews\n- R008 → **validated**: Song library editorial layout with lyric preview rows\n- R009 → **validated**: Deck editor 3-column tonal layout, all Stimulus controllers intact\n- R010 → **validated**: Frosted glass nav with Newsreader wordmark, active page underlines\n- R011 → **validated**: shadow-ambient utility defined; ambient depth throughout\n- R012 → **validated**: Flash toasts and error states use tonal backgrounds, Material Symbols icons

## Deviations

All five slices were delivered in a single comprehensive commit (f2c1735) rather than sequentially. GSD artifacts were reconciled retroactively. T01 of S01 was the only task tracked live; T02/T03 and all of S02–S05 were planned and closed after the fact to match what was shipped.

## Follow-ups

M003 (feature work: song title slides, drag-drop arrangement, import status page) and M004 (quality: AI theme suggestion fixes, PPTX fidelity) are planned as next milestones.
