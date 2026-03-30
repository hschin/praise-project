---
id: M004
title: "v1.4 Deck Display Settings"
status: complete
completed_at: 2026-03-29T17:43:53.548Z
key_decisions:
  - form_with scope: :deck needed when using url: instead of model: for param namespacing
  - deck.settings object in PPTX payload keeps display settings separate from theme
  - chunk_idx * lines_per_slide for correct pinyin offset when lines repeat
  - add_slide show_pinyin kwarg defaults True for backwards compatibility
key_files:
  - db/migrate/20260329172602_add_display_settings_to_deck.rb
  - app/models/deck.rb
  - app/views/decks/show.html.erb
  - app/views/decks/_slide_preview.html.erb
  - lib/pptx_generator/generate.py
  - app/jobs/generate_pptx_job.rb
lessons_learned:
  - form_with url: does not set a param scope — need scope: :model_name explicitly
  - each_slice is cleaner than manual index arithmetic for chunking arrays in ERB
---

# M004: v1.4 Deck Display Settings

**Deck display settings — show/hide pinyin and lines per slide — flow from the editor panel through to the slide preview and PPTX export**

## What Happened

M004 added two deck-level display settings: show_pinyin (toggle whether pinyin appears on slides) and lines_per_slide (control how many lyric lines appear per slide, splitting longer sections across multiple slides). Settings are stored on the Deck model, controlled via a Display panel in the deck editor right column, and flow through to both the in-editor slide preview and the exported PPTX file.

## Success Criteria Results

All five success criteria met. Settings persist, preview reflects changes, PPTX slide count changes correctly with lines_per_slide setting.

## Definition of Done Results

- ✅ Migration runs cleanly; Deck model validates lines_per_slide 1..8\n- ✅ Settings panel renders in deck editor and persists via PATCH /decks/:id\n- ✅ Slide preview hides pinyin when show_pinyin is false\n- ✅ Slide preview splits lyric sections into multiple cards when lines exceed lines_per_slide\n- ✅ PPTX export respects both settings — 24 slides with lines_per_slide=2 vs 14 default\n- ✅ rails test: 72 tests, 186 assertions, 0 failures

## Requirement Outcomes

- R009 (Deck editor) → **advanced**: display settings panel and PPTX export both respect show_pinyin and lines_per_slide

## Deviations

chunk_start calculation initially used content_lines.index(chunk.first) — fixed to chunk_idx * lines_per_slide to handle duplicate line content correctly.

## Follow-ups

None identified.
