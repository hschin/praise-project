---
phase: 03-deck-editor
plan: "04"
subsystem: ui
tags: [claude-api, unsplash, turbo-streams, background-jobs, ai-suggestions]

# Dependency graph
requires:
  - phase: 03-deck-editor/03-03
    provides: turbo_stream_from target div and theme section scaffold on decks/show
  - phase: 03-deck-editor/03-01
    provides: Theme model with background_color/text_color/font_size/unsplash_url columns
  - phase: 02-lyrics-pipeline
    provides: ImportSongJob broadcast pattern and ClaudeLyricsService pattern
provides:
  - ClaudeThemeService.call(deck:) returning array of 5 theme hashes from Claude haiku
  - GenerateThemeSuggestionsJob fetching Unsplash photos with attribution, broadcasting suggestion_row partial
  - _suggestion_row.html.erb horizontal scrollable card container
  - _suggestion_card.html.erb with Unsplash thumbnail/swatch, color swatches, Apply button, attribution
  - POST /decks/:deck_id/themes/suggest route and ThemesController#suggest action
  - Apply button POSTs to ThemesController#create with source: "ai" and unsplash_url
affects:
  - 03-deck-editor/03-05
  - PPTX generation phase (theme unsplash_url in exported slides)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "ClaudeThemeService follows ClaudeLyricsService pattern: Anthropic::Client, JSON extraction via regex"
    - "GenerateThemeSuggestionsJob follows ImportSongJob broadcast pattern with Turbo::StreamsChannel.broadcast_update_to"
    - "Net::HTTP stdlib for Unsplash API — no Faraday dependency needed for simple GET"
    - "fetch_unsplash_photo returns hash {url:, name:, profile_url:} for full attribution support"

key-files:
  created:
    - app/services/claude_theme_service.rb
    - app/jobs/generate_theme_suggestions_job.rb
    - app/views/themes/_suggestion_card.html.erb
    - app/views/themes/_suggestion_row.html.erb
  modified:
    - app/controllers/themes_controller.rb
    - config/routes.rb
    - app/views/decks/show.html.erb

key-decisions:
  - "ClaudeThemeService uses claude-3-5-haiku model (cheaper/faster) for theme suggestions vs sonnet for lyrics"
  - "JSON extraction uses regex /\\[.*\\]/m as fallback in case Claude adds surrounding text despite instructions"
  - "theme_params permits :source so AI suggestions pass source: ai through; source defaults to custom only if not set"
  - "fetch_unsplash_photo returns nil hash on failure so suggestion card renders without photo (graceful fallback)"
  - "Unsplash attribution name and profile URL included per Unsplash API terms of service"

patterns-established:
  - "AI suggestion pipeline: Service (Claude) -> Job (fetch photos + broadcast) -> Turbo Stream -> card partial"
  - "button_to with pre-filled params to apply AI suggestion via existing create action — no separate create_from_suggestion action needed"

requirements-completed: [THEME-01]

# Metrics
duration: 2min
completed: 2026-03-13
---

# Phase 3 Plan 04: AI Theme Suggestion Pipeline Summary

**ClaudeThemeService + GenerateThemeSuggestionsJob pipeline: Claude haiku generates 5 worship theme suggestions, Unsplash fetches landscape photos with attribution, Turbo Stream broadcasts scrollable suggestion cards to deck show page**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-13T14:28:00Z
- **Completed:** 2026-03-13T14:30:00Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- ClaudeThemeService.call(deck:) calls Claude haiku with a structured JSON prompt and parses 5 theme suggestions
- GenerateThemeSuggestionsJob fetches Unsplash photos with full attribution (name + profile URL + UTM params) and broadcasts suggestion_row partial to the deck_themes Turbo channel
- Suggestion card partials render Unsplash thumbnails or color swatches, color swatches, Apply button (POSTs to ThemesController#create with source: "ai"), and Unsplash attribution per API terms
- "Get AI Suggestions" button added to deck show page; clicking enqueues the job and redirects

## Task Commits

Each task was committed atomically:

1. **Task 1: ClaudeThemeService and GenerateThemeSuggestionsJob** - `ad12d99` (feat)
2. **Task 2: Suggestion card partials and Apply button wiring** - `ae25ffc` (feat)

**Plan metadata:** (docs commit below)

_Note: Task 1 used TDD — tests existed (RED), implementation written (GREEN), all 43 tests pass._

## Files Created/Modified
- `app/services/claude_theme_service.rb` - Calls Claude haiku, parses JSON array of 5 theme suggestion hashes
- `app/jobs/generate_theme_suggestions_job.rb` - Fetches Unsplash photos with attribution, broadcasts suggestion_row partial; graceful error broadcast on failure
- `app/views/themes/_suggestion_card.html.erb` - Single AI theme card: Unsplash thumbnail or swatch, color dots, Apply button, attribution
- `app/views/themes/_suggestion_row.html.erb` - Horizontal scrollable container rendering suggestion cards
- `app/controllers/themes_controller.rb` - Added suggest action, permitted source and unsplash_url in theme_params, source defaults to custom only if not set
- `config/routes.rb` - Added collection POST :suggest route inside themes resource
- `app/views/decks/show.html.erb` - Added Get AI Suggestions button and description above Turbo target

## Decisions Made
- Used `source ||= "custom"` instead of `source = "custom"` so AI suggestions can set their own source via params
- ClaudeThemeService uses haiku (claude-3-5-haiku-20241022) — cheaper and faster for theme metadata vs sonnet for lyric generation
- JSON extraction via regex `/\[.*\]/m` tolerates any surrounding text Claude adds despite JSON-only instructions
- `fetch_unsplash_photo` returns `{url: nil, name: nil, profile_url: nil}` on failure so cards broadcast without photos rather than halting the job
- No separate `create_from_suggestion` action — the Apply button reuses ThemesController#create with pre-filled params

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] ThemesController#create hardcoded source: "custom", overriding AI source param**
- **Found during:** Task 2 (ThemesController update)
- **Issue:** The plan said create already handles source: "ai" via theme_params, but the controller unconditionally set `@theme.source = "custom"` after building from params
- **Fix:** Changed to `@theme.source ||= "custom"` so source from params is preserved; only defaults to custom when not provided
- **Files modified:** app/controllers/themes_controller.rb
- **Verification:** Full test suite GREEN (43 tests); existing ThemesController tests still pass
- **Committed in:** ae25ffc (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 - Bug)
**Impact on plan:** Essential correctness fix — without it, AI suggestions would be saved as source "custom" defeating the requirement.

## Issues Encountered
None — both tasks executed cleanly.

## User Setup Required
**External services require manual configuration:**
- `UNSPLASH_ACCESS_KEY` — Register a free Unsplash app at https://unsplash.com/developers (Developers > Your apps > New Application). Copy the "Access Key". Add to .env: `UNSPLASH_ACCESS_KEY=your_key_here`
- Note: Demo apps limited to 50 requests/hour. Each "Get AI Suggestions" click uses 5 requests. Attribution is required per Unsplash API terms — rendered in each suggestion card.

## Next Phase Readiness
- THEME-01 fully implemented: Claude suggestions + Unsplash photos + Apply button + attribution
- Plan 03-05 can use the established broadcast pattern if any additional theme features are needed
- Unsplash UNSPLASH_ACCESS_KEY must be configured in production environment before theme suggestions are usable

## Self-Check: PASSED
All 5 key files verified present. Both task commits (ad12d99, ae25ffc) confirmed in git log.

---
*Phase: 03-deck-editor*
*Completed: 2026-03-13*
