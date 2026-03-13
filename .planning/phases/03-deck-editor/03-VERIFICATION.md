---
phase: 03-deck-editor
verified: 2026-03-13T15:00:00Z
status: human_needed
score: 11/12 must-haves verified
re_verification: false
human_verification:
  - test: "Navigate to a deck show page with songs, click Edit lyrics arrow on a song block"
    expected: "Song edit page opens in a new browser tab showing inline-editable Chinese text and pinyin fields"
    why_human: "SLIDE-01 says 'edit slide Chinese text and pinyin inline' — implementation links to song edit page in new tab. Whether this satisfies the intent of 'inline' editing requires a human judgment call. The test only checks for a[href*='songs']; it does not verify the target page provides lyric-level editing from within the deck context."
---

# Phase 3: Deck Editor Verification Report

**Phase Goal:** Users can assemble a complete service deck — adding songs, arranging slides, editing text, and choosing a visual theme — ready for export
**Verified:** 2026-03-13
**Status:** human_needed
**Re-verification:** No — initial verification

---

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Theme model exists with all required columns and validations | VERIFIED | `app/models/theme.rb` validated; schema confirms themes table with name, source, background_color, text_color, font_size, unsplash_url, deck_id |
| 2 | Deck belongs_to :theme (optional) — deck.theme_id column exists | VERIFIED | `app/models/deck.rb` line 3: `belongs_to :theme, optional: true`; schema confirms decks.theme_id column and FK |
| 3 | DeckSong.arrangement populated with integer lyric IDs on song add | VERIFIED | `DeckSongsController#create` line 8: `@deck_song.arrangement = @deck_song.song.lyrics.order(:position).pluck(:id).map(&:to_i)`; `before_save :cast_arrangement_ids` in model |
| 4 | DecksController#new pre-fills date with next Sunday | VERIFIED | `decks_controller.rb` lines 13-14; test `GET new pre-fills date with next Sunday` passes GREEN |
| 5 | User can add songs to a deck and see slide arrangement | VERIFIED | `DeckSongsController#create` populates arrangement; `_song_block.html.erb` renders slide list; 50 tests GREEN |
| 6 | User can drag-reorder songs (position) and slides (arrangement) | VERIFIED | `sortable_controller.js` handles both modes; `reorder` and `update_arrangement` routes and actions exist; DnD tests pass GREEN |
| 7 | User can remove a slide from arrangement without deleting lyric | VERIFIED | `_slide_item.html.erb` computes `new_arrangement_without` via delete_at(index); posts to `update_arrangement`; DECK-04 test GREEN |
| 8 | User can repeat a slide (append duplicate lyric ID to arrangement) | VERIFIED | `_slide_item.html.erb` computes `new_arrangement_repeat` via insert(arrangement_index + 1, lyric.id); SLIDE-05 test GREEN |
| 9 | Slide previews render as 16:9 CSS thumbnails with ruby/pinyin annotation | VERIFIED | `show.html.erb` slide_preview_section renders `div.slide-preview` with aspect-ratio 16:9, ruby tags, pinyin rt elements, "Approximate Preview" label; SLIDE-04 test GREEN |
| 10 | Custom theme form persists colors, font size, background image | VERIFIED | `ThemesController#create` + `themes/_form.html.erb`; ThemesController tests (create + image attach) GREEN; THEME-02 and THEME-03 satisfied |
| 11 | AI suggestion pipeline: Claude -> Unsplash -> Turbo Stream broadcast | VERIFIED | `ClaudeThemeService`, `GenerateThemeSuggestionsJob`, `_suggestion_row`, `_suggestion_card` all exist and are substantive; broadcast_update_to wired to `deck_themes_#{deck_id}` / `#theme_suggestions`; `suggest_deck_themes_path` route confirmed; job tests GREEN |
| 12 | User can edit slide Chinese text and pinyin (SLIDE-01) | ? UNCERTAIN | Implementation: "Edit lyrics" link in `_song_block.html.erb` opens `edit_song_path` in a new tab. Requirement text says "inline" — needs human judgment whether a new-tab link to the song edit page satisfies the intent |

**Score:** 11/12 truths automated-verified (1 needs human judgment)

---

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `app/models/theme.rb` | Theme model with validations, FONT_SIZE_PRESETS, has_one_attached | VERIFIED | All present: validates name/source, FONT_SIZE_PRESETS constant, has_one_attached :background_image, belongs_to :deck optional |
| `db/schema.rb` (themes table) | themes table with all columns | VERIFIED | name, source, background_color, text_color, font_size, unsplash_url, deck_id — all present |
| `db/schema.rb` (decks.theme_id) | theme_id reference on decks | VERIFIED | Confirmed in schema; FK with on_delete: :nullify |
| `app/models/deck.rb` | belongs_to :theme, optional: true | VERIFIED | Line 3 confirmed |
| `app/models/deck_song.rb` | before_save cast, safe_lyrics helper | VERIFIED | Both present and substantive |
| `app/controllers/deck_songs_controller.rb` | create populates arrangement; reorder; update_arrangement | VERIFIED | All three actions present with real logic; update_arrangement branches on content_type for DnD vs form-submit callers |
| `app/controllers/decks_controller.rb` | #new pre-fills next Sunday | VERIFIED | Lines 12-15 confirmed |
| `app/controllers/themes_controller.rb` | create + suggest actions, proper scoping | VERIFIED | Both actions present; set_deck scoped via current_user; source uses ||= for AI passthrough |
| `app/javascript/controllers/sortable_controller.js` | SortableJS Stimulus controller, both DnD modes | VERIFIED | Imports Sortable + patch; handles "position" and "arrangement" param modes; guards no-op drops |
| `app/views/deck_songs/_song_block.html.erb` | Song header, drag handle, Edit lyrics link, Remove song, slide list | VERIFIED | All elements present; data-controller="sortable" wired to update_arrangement URL |
| `app/views/deck_songs/_slide_item.html.erb` | Drag handle, section label, content preview, Remove, +Repeat | VERIFIED | All present; uses insert(arrangement_index + 1) for correct repeat position |
| `app/views/decks/show.html.erb` | Sortable song list, Add Song form, theme section, slide previews | VERIFIED | All sections present; turbo_stream_from + #theme_suggestions in place |
| `app/views/themes/_form.html.erb` | Color pickers, font size select, background image upload | VERIFIED | All inputs present; multipart: true |
| `app/views/themes/_applied_theme.html.erb` | Applied theme card with swatches and Applied label | VERIFIED | Color swatches, font_size, source, conditional image indicator |
| `app/services/claude_theme_service.rb` | ClaudeThemeService.call returns 5 theme hashes | VERIFIED | Substantive: Anthropic::Client, JSON regex extraction, error rescue |
| `app/jobs/generate_theme_suggestions_job.rb` | Fetch Unsplash photos, broadcast suggestion_row | VERIFIED | fetch_unsplash_photo returns attribution hash; Turbo broadcast to deck_themes channel; graceful error broadcast |
| `app/views/themes/_suggestion_row.html.erb` | Horizontal scrollable suggestion container | VERIFIED | Flex overflow-x-auto row rendering suggestion_card partials |
| `app/views/themes/_suggestion_card.html.erb` | Card with photo/swatch, Apply button, Unsplash attribution | VERIFIED | Conditional Unsplash image; Apply button POSTs to deck_themes_path with source: "ai"; attribution renders when url present |
| `test/models/deck_song_test.rb` | safe_lyrics nil/empty/stale/order + integer cast tests | VERIFIED | 6 substantive assertions, all GREEN |
| `config/importmap.rb` | sortablejs and @rails/request.js pinned | VERIFIED | Both CDN pins present before pin_all_from |

---

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `app/models/deck.rb` | `app/models/theme.rb` | belongs_to :theme, optional: true | WIRED | Line 3 confirmed |
| `DeckSongsController#create` | `song.lyrics` | `.order(:position).pluck(:id).map(&:to_i)` | WIRED | Line 8 of controller |
| `app/javascript/controllers/sortable_controller.js` | reorder_deck_deck_song_path | PATCH via urlValue + `:id` placeholder | WIRED | `patch(url, ...)` using `urlValue.replace(":id", id)` for song position reorder |
| `app/javascript/controllers/sortable_controller.js` | update_arrangement_deck_deck_song_path | PATCH with arrangement array | WIRED | `paramValue === "arrangement"` branch sends full array |
| `app/views/deck_songs/_slide_item.html.erb` | `DeckSongsController#update_arrangement` | button_to with arrangement array | WIRED | Both Remove and +Repeat button_to call update_arrangement_deck_deck_song_path |
| `app/views/decks/show.html.erb` | `app/views/themes/_form.html.erb` | render partial in theme_section div | WIRED | Lines 53 and 57 render "themes/form" |
| `app/controllers/themes_controller.rb` | `app/models/theme.rb` | @deck.build_theme(theme_params) + save | WIRED | ThemesController#create lines 6-9 |
| `app/jobs/generate_theme_suggestions_job.rb` | Turbo::StreamsChannel | broadcast_update_to "deck_themes_#{deck_id}" | WIRED | Line 25; target "theme_suggestions"; partial "themes/suggestion_row" |
| `app/views/themes/_suggestion_card.html.erb` | ThemesController#create | button_to deck_themes_path with source: "ai" params | WIRED | Lines 29-42; Apply button submits AI theme params to create action |
| `app/services/claude_theme_service.rb` | Anthropic Ruby SDK | Anthropic::Client.new | WIRED | Line 10; messages.create call |
| `app/views/decks/show.html.erb` | turbo_stream_from | "deck_themes_#{@deck.id}" | WIRED | Line 70; #theme_suggestions div line 71 |

---

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| DECK-01 | 03-01, 03-05 | Deck date pre-filled with next Sunday | SATISFIED | DecksController#new uses Date.today.next_occurring(:sunday); test GREEN |
| DECK-02 | 03-01, 03-02, 03-05 | Add songs to deck with arrangement initialized | SATISFIED | DeckSongsController#create populates arrangement from song.lyrics; tests GREEN |
| DECK-03 | 03-02, 03-05 | Reorder songs within a deck | SATISFIED | reorder PATCH route + action; sortable_controller.js position mode; test GREEN |
| DECK-04 | 03-01, 03-02, 03-05 | Remove song without deleting from library | SATISFIED | destroy action; DELETE deck_deck_song_path; test GREEN |
| SLIDE-01 | 03-02, 03-05 | Edit slide Chinese text and pinyin inline | UNCERTAIN | "Edit lyrics" link opens `edit_song_path` in new tab. Requirement says "inline" — see human verification below |
| SLIDE-02 | 03-02, 03-05 | Reorder slides within a song | SATISFIED | update_arrangement PATCH route; sortable_controller.js arrangement mode; test GREEN |
| SLIDE-03 | 03-02, 03-05 | Delete/hide individual slides from deck | SATISFIED | Remove button via update_arrangement with index deleted; test GREEN |
| SLIDE-04 | 03-02, 03-05 | Preview slides in browser before export | SATISFIED | .slide-preview divs with 16:9 aspect-ratio + ruby/pinyin; SLIDE-04 test GREEN |
| SLIDE-05 | 03-02, 03-05 | Repeat sections in arrangement | SATISFIED | +Repeat button via update_arrangement with insert(idx+1, id); test GREEN |
| THEME-01 | 03-04, 03-05 | AI-generated themes with Unsplash photos | SATISFIED | ClaudeThemeService + GenerateThemeSuggestionsJob pipeline; Turbo Stream broadcast; suggest route; job tests GREEN |
| THEME-02 | 03-01, 03-03, 03-05 | Custom theme with background color, text color, font size | SATISFIED | ThemesController#create + themes/_form.html.erb; ThemesController tests GREEN |
| THEME-03 | 03-01, 03-03, 03-05 | Upload own background image | SATISFIED | has_one_attached :background_image; file_field_tag in form; multipart: true; image attach test GREEN |

**All 12 Phase 3 requirement IDs claimed by plans are accounted for. No orphaned requirements found.**

REQUIREMENTS.md marks all 12 as [x] Complete.

---

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `app/controllers/decks_controller.rb` | 43-44 | `# PPTX generation — to be implemented` / `head :ok` | Info | Export action is intentionally stubbed — this is a Phase 4 deliverable (EXPORT-01/02/03), not a Phase 3 gap |

No blocker or warning anti-patterns found in Phase 3 files. The export stub is a known placeholder for Phase 4 and does not affect the Phase 3 goal.

---

### Human Verification Required

#### 1. SLIDE-01: Inline Editing Interpretation

**Test:** Navigate to a deck show page that has at least one song with lyrics. Locate the "Edit lyrics" arrow link in a song block header. Click it.

**Expected (per requirement):** User can edit the slide's Chinese text and pinyin from within the deck editing context. If the song edit page (which opens in a new tab) exposes per-lyric edit fields for Chinese content and pinyin, this satisfies the intent even if not strictly "inline" in the deck view.

**Why human:** SLIDE-01 says "edit slide Chinese text and pinyin inline" — but the implementation provides a link to `edit_song_path` opening in a new tab rather than an in-deck inline editor. The test only asserts `a[href*='songs']` is present — it does not verify that editing is inline to the deck. This is a scope interpretation decision: if the team intended "inline" to mean "from within the deck page without leaving the page," this is a gap. If "inline" was interpreted more loosely as "accessible without leaving the app," the new-tab link satisfies it.

**Scope note:** The song edit page (`edit_song_path`) does provide lyric editing. The Phase 3 CONTEXT.md and PLAN descriptions consistently describe SLIDE-01 as "Edit lyrics link that opens the song library in a new tab" — suggesting the team interpreted the requirement this way intentionally.

---

### Gaps Summary

No automated gaps found. All 11 of 12 truths pass programmatic verification. The full test suite runs GREEN: 50 runs, 109 assertions, 0 failures, 0 errors.

The single human_needed item (SLIDE-01 inline vs new-tab editing) is an interpretation question. All code, routes, controllers, models, views, and tests for the deck editor are substantive and wired. The phase goal — users can assemble a complete service deck, arrange slides, edit text, and choose a visual theme — is functionally achieved.

---

_Verified: 2026-03-13_
_Verifier: Claude (gsd-verifier)_
