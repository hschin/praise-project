---
phase: 03-deck-editor
plan: 01
subsystem: database
tags: [rails, postgresql, activestorage, jsonb, theme, deck, migrations]

# Dependency graph
requires:
  - phase: 02-lyrics-pipeline
    provides: Deck, DeckSong, Song, Lyric models; arrangement JSONB column on deck_songs

provides:
  - themes table with name, source, colors, font_size, unsplash_url, deck_id columns
  - theme_id reference on decks table
  - Theme model with has_one_attached :background_image and FONT_SIZE_PRESETS
  - Deck belongs_to :theme, optional: true
  - DeckSong#create initializes arrangement from song.lyrics in position order
  - DeckSong before_save casts arrangement IDs to integers
  - DeckSong#safe_lyrics helper returns Lyric objects skipping stale IDs
  - DecksController#new pre-fills date with next Sunday
  - Wave 0 test scaffolds for Theme, ThemesController, GenerateThemeSuggestionsJob

affects:
  - 03-02 (routes, reorder, update_arrangement actions depend on fixture arrangement state)
  - 03-03 (slide editor depends on arrangement JSONB and safe_lyrics)
  - 03-05 (ThemesController and GenerateThemeSuggestionsJob implement against these test scaffolds)

# Tech tracking
tech-stack:
  added:
    - sortablejs@1.15.2 (importmap CDN pin for drag-and-drop in Plan 02)
    - "@rails/request.js"@0.0.9 (importmap CDN pin for fetch requests in Plan 02)
  patterns:
    - Theme FONT_SIZE_PRESETS constant hash (small=28, medium=36, large=48)
    - Wave 0 test scaffold pattern: create RED tests first, implement later plans turn GREEN
    - DeckSong.arrangement populated at create time from song.lyrics.order(:position).pluck(:id)
    - before_save callback on DeckSong to ensure arrangement integer types

key-files:
  created:
    - db/migrate/20260313221614_create_themes.rb
    - db/migrate/20260313221615_add_theme_to_decks.rb
    - app/models/theme.rb
    - test/fixtures/themes.yml
    - test/models/theme_test.rb
    - test/controllers/themes_controller_test.rb
    - test/jobs/generate_theme_suggestions_job_test.rb
  modified:
    - app/models/deck.rb
    - app/models/deck_song.rb
    - app/controllers/deck_songs_controller.rb
    - app/controllers/decks_controller.rb
    - config/importmap.rb
    - test/fixtures/deck_songs.yml
    - test/controllers/deck_songs_controller_test.rb
    - test/controllers/decks_controller_test.rb
    - db/schema.rb

key-decisions:
  - "assigns helper removed from Rails 8 - DECK-01 test uses assert_select on form input value instead of assigns(:deck).date"
  - "Theme belongs_to :deck and Deck belongs_to :theme both optional - bidirectional association via deck_id on themes and theme_id on decks"
  - "deck_songs fixture :one uses ActiveRecord::FixtureSet.identify to get integer lyric IDs for arrangement - ensures fixture IDs match what tests expect"

patterns-established:
  - "Wave 0 test scaffold: write RED tests in plan 01, subsequent plans implement to turn GREEN"
  - "DeckSong.arrangement always stores integer IDs (cast in before_save)"
  - "DecksController#new uses Date.today.next_occurring(:sunday) for default date"

requirements-completed: [DECK-01, DECK-02, DECK-04, THEME-02, THEME-03]

# Metrics
duration: 4min
completed: 2026-03-13
---

# Phase 03 Plan 01: Theme Model, Migrations, and Wave 0 Test Scaffolds

**Theme model with ActiveStorage, FONT_SIZE_PRESETS, and DeckSong arrangement initialized from song lyrics at create time**

## Performance

- **Duration:** 4 min
- **Started:** 2026-03-13T14:15:40Z
- **Completed:** 2026-03-13T14:20:00Z
- **Tasks:** 3
- **Files modified:** 15

## Accomplishments
- Created themes table (name, source, background/text colors, font_size, unsplash_url, deck_id) and added theme_id to decks via two migrations
- Theme model with has_one_attached :background_image, validates name+source, FONT_SIZE_PRESETS constant
- DeckSongsController#create now populates arrangement with integer lyric IDs in position order; DeckSong#safe_lyrics returns Lyric objects skipping stale IDs
- DecksController#new pre-fills deck.date with next Sunday
- Wave 0 test scaffolds for ThemesController and GenerateThemeSuggestionsJob (RED — implemented in Plans 05); deck and deck_song controller tests extended with RED tests for Plan 02 routes

## Task Commits

Each task was committed atomically:

1. **Task 1: Theme model, migrations, and model associations** - `aaee19c` (feat)
2. **Task 2: DeckSong arrangement init and DecksController date pre-fill** - `19e7ad4` (feat)
3. **Task 3: Wave 0 test scaffolds** - `58e39fb` (test)

## Files Created/Modified
- `db/migrate/20260313221614_create_themes.rb` - themes table with all required columns
- `db/migrate/20260313221615_add_theme_to_decks.rb` - theme_id reference on decks
- `app/models/theme.rb` - Theme model with ActiveStorage, validations, FONT_SIZE_PRESETS
- `app/models/deck.rb` - Added belongs_to :theme, optional: true
- `app/models/deck_song.rb` - Added before_save cast, safe_lyrics helper
- `app/controllers/deck_songs_controller.rb` - arrangement init in create, array permit
- `app/controllers/decks_controller.rb` - next Sunday date pre-fill in new
- `config/importmap.rb` - sortablejs and @rails/request.js CDN pins
- `test/fixtures/themes.yml` - custom_theme and ai_theme fixtures
- `test/fixtures/deck_songs.yml` - arrangement populated via FixtureSet.identify
- `test/models/theme_test.rb` - 7 tests GREEN
- `test/controllers/themes_controller_test.rb` - RED scaffold pending Plan 05
- `test/jobs/generate_theme_suggestions_job_test.rb` - RED scaffold pending Plan 05
- `test/controllers/deck_songs_controller_test.rb` - full suite with DECK-02/04 GREEN, others RED
- `test/controllers/decks_controller_test.rb` - DECK-01 GREEN, SLIDE-04 RED pending Plan 02

## Decisions Made
- `assigns` helper is extracted from Rails 8 core into rails-controller-testing gem; rather than add the gem, rewrote DECK-01 test to use `assert_select` on the rendered form input value — avoids a test-only dependency.
- Both `themes.deck_id` and `decks.theme_id` columns coexist for bidirectional association; both are optional with on_delete: :nullify foreign keys.
- Fixture arrangement uses `ActiveRecord::FixtureSet.identify(:one, :integer)` to get stable deterministic IDs matching the lyric fixtures, ensuring DECK-02 test assertions match.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Replaced assigns(:deck) with assert_select for DECK-01 test**
- **Found during:** Task 3 (Wave 0 test scaffolds)
- **Issue:** `assigns(:deck)` raises NoMethodError in Rails 8 — method extracted to separate gem
- **Fix:** Changed test to use `assert_select "input[name='deck[date]'][value='#{next_sunday}']"` — tests the actual rendered HTML input value
- **Files modified:** test/controllers/decks_controller_test.rb
- **Verification:** rails test test/controllers/decks_controller_test.rb:23 passes GREEN
- **Committed in:** 58e39fb (Task 3 commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Required fix — assigns() is unavailable in Rails 8. HTML-level assertion is more realistic anyway.

## Issues Encountered
None beyond the auto-fixed assigns deviation.

## Next Phase Readiness
- Theme model and migrations ready — Plan 02 can build routes and show view
- DeckSong.arrangement initialized at create — Plan 02 reorder/update_arrangement actions have data to work with
- Wave 0 test scaffolds in place — Plans 02-05 implement against these RED tests
- sortablejs and @rails/request.js CDN pins registered — Plan 02 can build Stimulus controllers

## Self-Check: PASSED

All created files verified present. All task commits verified in git log.

---
*Phase: 03-deck-editor*
*Completed: 2026-03-13*
