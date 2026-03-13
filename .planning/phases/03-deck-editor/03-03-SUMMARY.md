---
phase: 03-deck-editor
plan: 03
subsystem: ui
tags: [rails, activestorage, hotwire, turbo, theme, forms]

# Dependency graph
requires:
  - phase: 03-01
    provides: Theme model with has_one_attached :background_image, FONT_SIZE_PRESETS, source enum
  - phase: 03-02
    provides: Deck show page foundation with deck_songs, deck_themes route structure

provides:
  - ThemesController with create action scoped to current_user decks
  - POST /decks/:deck_id/themes route (nested resource)
  - themes/_form.html.erb with color pickers, font size select, background image upload
  - themes/_applied_theme.html.erb showing name, swatches, font size, Applied badge
  - deck show page theme_section with conditional form/card, turbo_stream_from, #theme_suggestions div

affects: [03-05]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Nested resource controller scoped via current_user.decks.find — prevents cross-user access"
    - "build_theme + update_column(:theme_id) pattern to associate theme after save"
    - "turbo_stream_from placeholder added before job implementation (Plan 05 dependency)"

key-files:
  created:
    - app/controllers/themes_controller.rb
    - app/views/themes/_form.html.erb
    - app/views/themes/_applied_theme.html.erb
  modified:
    - config/routes.rb
    - app/views/decks/show.html.erb

key-decisions:
  - "update_column(:theme_id) used instead of @deck.update(theme: @theme) to skip deck validations on association"
  - "turbo_stream_from 'deck_themes_#{deck.id}' and #theme_suggestions div added now so Plan 05 broadcasts land without template changes"
  - "color_field_tag hex text inputs are cosmetic only — color value carried by the native color input, no JS required for basic functionality"

patterns-established:
  - "Nested resource pattern: current_user.decks.find(params[:deck_id]) in set_deck before_action"
  - "Theme applied state: deck show shows applied_theme card with collapsible Change theme form via <details>"

requirements-completed: [THEME-02, THEME-03]

# Metrics
duration: 3min
completed: 2026-03-13
---

# Phase 03 Plan 03: Custom Theme Form Summary

**ThemesController with create action, color picker form partial, and ActiveStorage image upload wired into deck show page**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-13T14:22:11Z
- **Completed:** 2026-03-13T14:24:44Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- ThemesController with create action scoped to current_user's decks — cross-user access blocked via RecordNotFound
- POST /decks/:deck_id/themes creates Theme with source: "custom" and associates it to deck via update_column
- Background image file upload attaches via ActiveStorage — Theme.last.background_image.attached? confirmed true in tests
- Deck show page conditionally renders applied theme card or blank form, with turbo_stream_from + #theme_suggestions placeholder for Plan 05

## Task Commits

Each task was committed atomically:

1. **Task 1: ThemesController with create action and nested route** - `815e65c` (feat)
2. **Task 2: Custom theme form partial and deck show integration** - `f58398a` (feat)

**Plan metadata:** (docs commit — see final_commit step)

_Note: Task 1 followed TDD flow — tests were RED before controller/route implementation_

## Files Created/Modified
- `app/controllers/themes_controller.rb` - ThemesController with create action, set_deck before_action, theme_params
- `config/routes.rb` - Added `resources :themes, only: [:create]` nested inside resources :decks
- `app/views/themes/_form.html.erb` - Custom theme form: color pickers, font size select, background image upload
- `app/views/themes/_applied_theme.html.erb` - Applied theme card showing name, color swatches, font size, source
- `app/views/decks/show.html.erb` - Added theme_section div with conditional form/card, turbo_stream_from, #theme_suggestions

## Decisions Made
- `update_column(:theme_id, @theme.id)` used instead of `@deck.update(theme: @theme)` to set theme association directly, bypassing deck validations which may grow in future plans
- `turbo_stream_from "deck_themes_#{@deck.id}"` and `<div id="theme_suggestions">` added now — Plan 05 broadcasts to this channel and target, so they must exist before Plan 05 implementation
- Hex text inputs beside color pickers are cosmetic UI only — the native color input carries the form value; no JS required for basic submission

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- Pre-existing test failures in full suite (out of scope, logged to deferred-items.md):
  - `DecksControllerTest#test_deck_show_page_renders_slide_preview_divs_for_arrangement_entries` — SLIDE-04 requirement, .slide-preview not yet in show template
  - `GenerateThemeSuggestionsJobTest#test_job_enqueues_without_error` — Plan 05 job class not yet implemented

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- THEME-02 and THEME-03 requirements fulfilled — theme form accepts colors, font size, and background image upload
- deck.theme association correctly set after form submission
- turbo_stream_from and #theme_suggestions placeholder in place for Plan 05 AI suggestion broadcasts
- Plan 04 (DeckSong arrangement UI) and Plan 05 (AI theme suggestions) can proceed

---
*Phase: 03-deck-editor*
*Completed: 2026-03-13*
