---
id: T01
parent: S02
milestone: M003
provides: []
requires: []
affects: []
key_files: ["app/services/claude_theme_service.rb", "app/views/themes/_suggestion_card.html.erb", "app/views/themes/_suggestion_row.html.erb", "app/views/themes/_applied_theme.html.erb", "app/views/themes/_form.html.erb", "app/views/decks/_slide_preview.html.erb"]
key_decisions: ["song_context helper pulls title, artist, and first 2 lyric lines per song for prompt context", "unsplash_url preserved via hidden field on form re-submit", "Remove checkbox clears both ActiveStorage attachment and unsplash_url in controller"]
patterns_established: []
drill_down_paths: []
observability_surfaces: []
duration: ""
verification_result: "bin/rails runner confirms ClaudeThemeService returns 5 song-themed suggestions. rails test: 72 tests, 184 assertions, 0 failures. Visual: suggestions panel shows vertical cards with Unsplash photos; slide preview shows Unsplash background."
completed_at: 2026-03-29T17:12:14.215Z
blocker_discovered: false
---

# T01: AI suggestions now song-aware with vertical cards and background images visible throughout

> AI suggestions now song-aware with vertical cards and background images visible throughout

## What Happened
---
id: T01
parent: S02
milestone: M003
key_files:
  - app/services/claude_theme_service.rb
  - app/views/themes/_suggestion_card.html.erb
  - app/views/themes/_suggestion_row.html.erb
  - app/views/themes/_applied_theme.html.erb
  - app/views/themes/_form.html.erb
  - app/views/decks/_slide_preview.html.erb
key_decisions:
  - song_context helper pulls title, artist, and first 2 lyric lines per song for prompt context
  - unsplash_url preserved via hidden field on form re-submit
  - Remove checkbox clears both ActiveStorage attachment and unsplash_url in controller
duration: ""
verification_result: passed
completed_at: 2026-03-29T17:12:14.215Z
blocker_discovered: false
---

# T01: AI suggestions now song-aware with vertical cards and background images visible throughout

**AI suggestions now song-aware with vertical cards and background images visible throughout**

## What Happened

Added dotenv-rails gem (API keys now load from .env). Enriched ClaudeThemeService prompt with song titles, artists, and first lyric lines — suggestions now reflect actual worship content. Switched suggestion cards to vertical stack with full-width Unsplash images and gradient name overlay. Applied theme card shows image thumbnail. Theme form shows current image with Remove checkbox. Slide preview falls back to unsplash_url when no file attached. ThemesController clears unsplash_url on Remove.

## Verification

bin/rails runner confirms ClaudeThemeService returns 5 song-themed suggestions. rails test: 72 tests, 184 assertions, 0 failures. Visual: suggestions panel shows vertical cards with Unsplash photos; slide preview shows Unsplash background.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bin/rails test` | 0 | ✅ pass — 72 tests, 184 assertions, 0 failures | 1134ms |


## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `app/services/claude_theme_service.rb`
- `app/views/themes/_suggestion_card.html.erb`
- `app/views/themes/_suggestion_row.html.erb`
- `app/views/themes/_applied_theme.html.erb`
- `app/views/themes/_form.html.erb`
- `app/views/decks/_slide_preview.html.erb`


## Deviations
None.

## Known Issues
None.
