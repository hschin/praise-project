---
id: S01
parent: M004
milestone: M004
provides:
  - deck.show_pinyin and deck.lines_per_slide available for S02
  - Settings UI panel in deck editor right column
requires:
  []
affects:
  - S02
key_files:
  - app/views/decks/show.html.erb
  - app/models/deck.rb
  - db/migrate/20260329172602_add_display_settings_to_deck.rb
key_decisions:
  - form_with scope: :deck for param namespacing without model binding
  - f.check_box with '1'/'0' handles unchecked state via hidden field
patterns_established:
  - form_with url: + scope: :deck for settings forms that don't bind a model object directly
observability_surfaces:
  - none
drill_down_paths:
  - milestones/M004/slices/S01/tasks/T01-SUMMARY.md
  - milestones/M004/slices/S01/tasks/T02-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-03-29T17:35:56.717Z
blocker_discovered: false
---

# S01: Deck Settings — DB & Panel

**Deck display settings foundation — DB, model, controller, and settings panel all complete**

## What Happened

DB columns, model validation, controller params, and UI panel all delivered. Settings persist and reload correctly. S02 can now read deck.show_pinyin and deck.lines_per_slide to drive preview and PPTX behaviour.

## Verification

rails test 72/186, 0 failures. DB confirmed correct values after save via rails runner. Browser visual confirmed toggle state and select value persist across reload.

## Requirements Advanced

- R009 — show_pinyin and lines_per_slide added to Deck model with validation and UI

## Requirements Validated

None.

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Deviations

form_with scope: :deck needed explicitly — discovered during save verification.

## Known Limitations

None.

## Follow-ups

None.

## Files Created/Modified

- `db/migrate/20260329172602_add_display_settings_to_deck.rb` — Migration: show_pinyin boolean default true, lines_per_slide integer default 4, both NOT NULL
- `app/models/deck.rb` — validates lines_per_slide numericality in: 1..8
- `app/controllers/decks_controller.rb` — deck_params permits :show_pinyin, :lines_per_slide
- `app/views/decks/show.html.erb` — Display Settings section with pill toggle and lines select
