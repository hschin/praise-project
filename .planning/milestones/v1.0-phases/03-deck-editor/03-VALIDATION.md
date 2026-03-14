# Phase 3: Deck Editor — Validation Architecture

**Source:** Extracted from 03-RESEARCH.md
**Date:** 2026-03-12

## Test Framework
| Property | Value |
|----------|-------|
| Framework | Minitest (Rails default) with custom Object#stub and Minitest::Mock shims (see test_helper.rb) |
| Config file | test/test_helper.rb |
| Quick run command | `rails test test/models/deck_song_test.rb test/models/theme_test.rb` |
| Full suite command | `rails test` |

## Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SLIDE-01 | "Edit lyrics" link present on deck_song card | controller | `rails test test/controllers/decks_controller_test.rb` | ✅ (extend) |
| SLIDE-02 | PATCH update_arrangement reorders lyric IDs | controller | `rails test test/controllers/deck_songs_controller_test.rb` | ✅ (extend) |
| SLIDE-03 | DELETE/PATCH removes lyric ID at index from arrangement | controller | `rails test test/controllers/deck_songs_controller_test.rb` | ✅ (extend) |
| SLIDE-04 | Deck show page renders slide preview divs for each arrangement entry | controller | `rails test test/controllers/decks_controller_test.rb` | ✅ (extend) |
| SLIDE-05 | "+ Repeat" appends lyric ID duplicate to arrangement | controller | `rails test test/controllers/deck_songs_controller_test.rb` | ✅ (extend) |
| DECK-01 | `new` action pre-fills date with next Sunday | controller | `rails test test/controllers/decks_controller_test.rb` | ✅ (extend) |
| DECK-02 | `create` DeckSong initializes arrangement from song lyrics | model + controller | `rails test test/models/deck_song_test.rb test/controllers/deck_songs_controller_test.rb` | ✅ (extend) |
| DECK-03 | PATCH reorder changes DeckSong.position | controller | `rails test test/controllers/deck_songs_controller_test.rb` | ✅ (extend) |
| DECK-04 | DELETE DeckSong does not delete Song | controller | `rails test test/controllers/deck_songs_controller_test.rb` | ✅ (extend) |
| THEME-01 | GenerateThemeSuggestionsJob enqueues and broadcasts Turbo Stream | job | `rails test test/jobs/generate_theme_suggestions_job_test.rb` | ❌ Wave 0 |
| THEME-02 | Theme created with color/font_size; deck.theme association set | model + controller | `rails test test/models/theme_test.rb test/controllers/themes_controller_test.rb` | ❌ Wave 0 |
| THEME-03 | Theme.background_image attached; url_for returns non-nil | model | `rails test test/models/theme_test.rb` | ❌ Wave 0 |

## Integration Points

1. **Arrangement stale ID handling:** Fixture with deleted lyric ID — deck show renders without RecordNotFound
2. **Arrangement integer casting:** Controller create → arrangement contains Integer IDs, not Strings
3. **Theme apply via AI suggestion:** Clicking suggestion card creates Theme record and sets deck.theme_id
4. **DeckSong destroy does not cascade to Song:** Song.count unchanged after DeckSong.destroy

## Edge Cases

| Edge Case | Expected Behavior |
|-----------|-------------------|
| Arrangement is nil | Deck show renders 0 slide cards; no error |
| Arrangement has duplicate lyric IDs | Both entries render as separate slide cards |
| No theme assigned to deck | Preview renders with black background / white text defaults |
| All lyrics deleted from song after adding to deck | arrangement IDs return nil from find_by; view renders gracefully |
| Theme background_image not attached | Falls back to background_color in preview style |
| "+ Repeat" on song with one lyric | Arrangement becomes [id, id]; both preview cards render |
| Remove last slide from arrangement | Arrangement becomes []; deck_song card shows 0 slides |

## Sampling Rate
- **Per task commit:** `rails test test/models/deck_song_test.rb test/models/theme_test.rb test/controllers/decks_controller_test.rb test/controllers/deck_songs_controller_test.rb`
- **Per wave merge:** `rails test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

## Wave 0 Gaps (must scaffold before Wave 1)
- [ ] `test/models/theme_test.rb` — covers THEME-02, THEME-03; needs `test/fixtures/themes.yml`
- [ ] `test/controllers/themes_controller_test.rb` — covers THEME-02 create/apply
- [ ] `test/jobs/generate_theme_suggestions_job_test.rb` — covers THEME-01; stub ClaudeThemeService + Unsplash
- [ ] `test/fixtures/themes.yml` — basic theme fixtures (no background_image attachment)
- [ ] `test/fixtures/deck_songs.yml` — update fixture to include arrangement
