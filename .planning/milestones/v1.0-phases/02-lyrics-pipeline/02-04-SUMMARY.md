---
phase: 02-lyrics-pipeline
plan: "04"
subsystem: frontend-views
tags: [turbo, stimulus, ruby-annotations, pinyin, hotwire]
dependency_graph:
  requires: [02-03]
  provides: [song-show-ui, songs-index-ui, pinyin-toggle]
  affects: [app/views/songs, app/javascript/controllers, app/assets/stylesheets]
tech_stack:
  added: [pinyin_toggle_controller.js]
  patterns: [turbo_stream_from, ruby-annotations, stimulus-toggle, css-animation]
key_files:
  created:
    - app/javascript/controllers/pinyin_toggle_controller.js
  modified:
    - app/views/songs/show.html.erb
    - app/views/songs/_processing.html.erb
    - app/views/songs/_lyrics.html.erb
    - app/views/songs/_failed.html.erb
    - app/views/songs/index.html.erb
    - app/assets/stylesheets/application.css
decisions:
  - eagerLoadControllersFrom auto-registers pinyin_toggle_controller without explicit registration in index.js
  - _processing.html.erb no longer wraps in song_status_ div (outer div in show.html.erb is the Turbo target)
  - _lyrics.html.erb and _failed.html.erb likewise remove their song_status_ wrapper divs since show.html.erb owns that container
metrics:
  duration: 2m
  completed_date: "2026-03-10"
  tasks_completed: 2
  files_modified: 6
---

# Phase 02 Plan 04: Song Show UI and Index Cards Summary

Song show page with live Turbo Stream updates, HTML ruby-annotated lyrics, Stimulus pinyin toggle, and songs index with import form and lyric preview cards.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Song show page — Turbo states and lyrics display | dd8b4fb | show.html.erb, _processing.html.erb, _lyrics.html.erb, _failed.html.erb, pinyin_toggle_controller.js, application.css |
| 2 | Songs index — search form and lyric preview cards | c855800 | index.html.erb |

## What Was Built

**Task 1 — Song show page:**
- `show.html.erb` uses `turbo_stream_from @song` and renders status-driven partials inside `#song_status_{id}` div
- `_processing.html.erb` shows animated spinner + 4-step progress list (Searching web / Fetching lyrics / Generating pinyin / Done) with active/inactive styling based on `import_step` and `import_status`
- `_lyrics.html.erb` renders each lyric line as `<ruby>char<rp>(</rp><rt>pinyin_token</rt><rp>)</rp></ruby>` per character, zipping content chars with pinyin tokens; wraps in `data-controller="pinyin-toggle"` with `.import-success` green flash animation
- `_failed.html.erb` shows red error box with embedded manual paste form posting to `import_songs_path`
- `pinyin_toggle_controller.js` Stimulus controller toggles `.pinyin-hidden` class on container, updates button text between "Hide Pinyin" / "Show Pinyin"
- `application.css` adds `.pinyin-hidden ruby rt, .pinyin-hidden ruby rp { display: none }` and `@keyframes import-success-fade` 2-second green border animation

**Task 2 — Songs index:**
- Import form at top posts title to `import_songs_path` (triggers background job)
- `<details>` disclosure with manual paste form always present (LOCKED decision)
- Library filter `GET /songs?q=` form for title search
- Song cards as `link_to` blocks showing title, first lyric line preview, and color-coded import_status badge

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed nested `song_status_` wrapper divs from partials**
- **Found during:** Task 1
- **Issue:** Prior stubs in `_processing.html.erb`, `_lyrics.html.erb`, and `_failed.html.erb` each wrapped their content in `<div id="song_status_<%= song.id %>">`. The plan's new `show.html.erb` places partials inside `<div id="song_status_<%= @song.id %>">` — nesting would produce duplicate IDs and Turbo replace would target the inner div, breaking the outer container on subsequent broadcasts.
- **Fix:** Partials rewritten without the `song_status_` wrapper div; the outer container in `show.html.erb` is now the sole Turbo target.
- **Files modified:** _processing.html.erb, _lyrics.html.erb, _failed.html.erb

## Self-Check: PASSED

Files exist:
- app/views/songs/show.html.erb — FOUND, contains `turbo_stream_from`
- app/views/songs/_lyrics.html.erb — FOUND, contains `<ruby>` elements
- app/views/songs/_failed.html.erb — FOUND, contains manual paste form
- app/javascript/controllers/pinyin_toggle_controller.js — FOUND
- app/assets/stylesheets/application.css — FOUND, contains `.pinyin-hidden` rule
- app/views/songs/index.html.erb — FOUND, contains `import_songs_path`

Commits:
- dd8b4fb — FOUND (feat(02-04): song show page with Turbo states...)
- c855800 — FOUND (feat(02-04): songs index with search form...)

Test suite: 24 runs, 51 assertions, 0 failures, 0 errors, 0 skips
