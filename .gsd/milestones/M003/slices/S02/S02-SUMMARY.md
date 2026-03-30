---
id: S02
parent: M003
milestone: M003
provides:
  - Song-aware theme suggestions
  - Unsplash background visible in slide preview
  - dotenv-rails for dev API key loading
requires:
  - slice: S01
    provides: dotenv-rails gem and working API key loading
affects:
  []
key_files:
  - app/services/claude_theme_service.rb
  - app/views/themes/_suggestion_card.html.erb
  - app/views/decks/_slide_preview.html.erb
key_decisions:
  - Prompt enriched with lyric content not just deck title
  - unsplash_url persistence via hidden field — survives theme re-apply without re-running AI job
patterns_established:
  - unsplash_url preserved via hidden field on theme form re-submit
  - Background image priority: ActiveStorage file > unsplash_url > background_color
observability_surfaces:
  - none
drill_down_paths:
  - milestones/M003/slices/S02/tasks/T01-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-03-29T17:12:40.944Z
blocker_discovered: false
---

# S02: AI Theme Suggestions Polish

**Song-aware AI suggestions with vertical card layout and Unsplash backgrounds visible throughout theme panel**

## What Happened

Full AI suggestions polish pass. API keys load correctly. Suggestions are contextually relevant. Unsplash backgrounds flow through the entire theme pipeline: suggestions → applied card → theme form → slide preview.

## Verification

ClaudeThemeService returns song-themed suggestions. rails test 72/72. Browser visual confirmation.

## Requirements Advanced

- R009 — Suggestions now reflect song lyric themes via enriched Claude prompt

## Requirements Validated

- R009 — ClaudeThemeService.call returns song-themed names (e.g. Refuge and Strength from 主你是我 hiding-place lyric)

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Deviations

None.

## Known Limitations

None.

## Follow-ups

None.

## Files Created/Modified

- `Gemfile` — dotenv-rails added for dev/test
- `app/services/claude_theme_service.rb` — song_context helper enriches prompt with song titles, artists, first lyric lines
- `app/views/themes/_suggestion_row.html.erb` — Switched to space-y-3 vertical stack
- `app/views/themes/_suggestion_card.html.erb` — Full-width Unsplash image with gradient name overlay, Apply button in footer row
- `app/views/themes/_applied_theme.html.erb` — Image thumbnail shown above color swatches
- `app/views/themes/_form.html.erb` — Current image shown with Remove checkbox; unsplash_url preserved via hidden field
- `app/views/decks/_slide_preview.html.erb` — Falls back to unsplash_url when no ActiveStorage file attached
- `app/controllers/themes_controller.rb` — Clears unsplash_url when remove_background_image checked
