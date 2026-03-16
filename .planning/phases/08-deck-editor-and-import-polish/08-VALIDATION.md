---
phase: 8
slug: deck-editor-and-import-polish
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-16
---

# Phase 8 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Minitest (Rails default) |
| **Config file** | `test/test_helper.rb` |
| **Quick run command** | `rails test test/controllers/decks_controller_test.rb test/controllers/songs_controller_test.rb` |
| **Full suite command** | `rails test` |
| **Estimated runtime** | ~15 seconds |

---

## Sampling Rate

- **After every task commit:** Run `rails test test/controllers/decks_controller_test.rb test/controllers/songs_controller_test.rb`
- **After every plan wave:** Run `rails test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 15 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 8-01-01 | 01 | 1 | DECK-01 | integration | `rails test test/controllers/decks_controller_test.rb -n test_deck_show_renders_section_chip_for_slide_items` | ❌ Wave 0 | ⬜ pending |
| 8-01-02 | 01 | 1 | DECK-02 | integration | `rails test test/controllers/decks_controller_test.rb -n test_deck_show_renders_artist_in_library_panel` | ❌ Wave 0 | ⬜ pending |
| 8-02-01 | 02 | 1 | DECK-03 | integration | `rails test test/controllers/decks_controller_test.rb -n test_export_button_idle_renders_download_icon` | ❌ Wave 0 | ⬜ pending |
| 8-02-02 | 02 | 1 | DECK-03 | integration | `rails test test/controllers/decks_controller_test.rb -n test_export_button_ready_renders_green_button` | ❌ Wave 0 | ⬜ pending |
| 8-02-03 | 02 | 1 | DECK-04 | integration | `rails test test/controllers/decks_controller_test.rb -n test_deck_show_panel_labels` | ❌ Wave 0 | ⬜ pending |
| 8-03-01 | 03 | 2 | DECK-05 | integration | `rails test test/controllers/decks_controller_test.rb -n test_deck_title_pencil_hover_only` | ❌ Wave 0 | ⬜ pending |
| 8-03-02 | 03 | 2 | DECK-06 | integration | `rails test test/controllers/decks_controller_test.rb -n test_deck_show_renders_auto_save_indicator` | ❌ Wave 0 | ⬜ pending |
| 8-04-01 | 04 | 2 | IMPORT-01 | integration | `rails test test/controllers/songs_controller_test.rb -n test_processing_page_renders_claude_copy` | ❌ Wave 0 | ⬜ pending |
| 8-04-02 | 04 | 2 | IMPORT-02 | integration | `rails test test/controllers/songs_controller_test.rb -n test_song_show_done_renders_add_to_deck_link` | ❌ Wave 0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/controllers/decks_controller_test.rb` — add tests for DECK-01, DECK-02, DECK-03, DECK-04, DECK-05, DECK-06 (extend existing file)
- [ ] `test/controllers/songs_controller_test.rb` — add tests for IMPORT-01, IMPORT-02 (extend existing file)

*(Both test files already exist — new test cases needed within them.)*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Color-coded chips visually distinct | DECK-01 | CSS class presence tested automatically; visual color rendering requires browser | Open deck editor, confirm verse/chorus/bridge chips show distinct warm colors |
| Export button "celebratory" feel | DECK-03 | Subjective visual check | Export a deck, confirm ready state looks celebratory vs idle |
| Auto-save indicator timing | DECK-06 | Animation/timing requires browser | Make arrangement change, confirm "Saved" indicator appears and fades |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 15s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
