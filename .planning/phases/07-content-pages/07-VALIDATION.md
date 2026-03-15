---
phase: 7
slug: content-pages
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-16
---

# Phase 7 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Minitest (Rails default) |
| **Config file** | `test/test_helper.rb` |
| **Quick run command** | `rails test test/controllers/decks_controller_test.rb test/controllers/songs_controller_test.rb` |
| **Full suite command** | `rails test` |
| **Estimated runtime** | ~10 seconds |

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
| 7-01-01 | 01 | 1 | NAV-02 | integration | `rails test test/controllers/decks_controller_test.rb` | ❌ W0 | ⬜ pending |
| 7-01-02 | 01 | 1 | NAV-02 | integration | `rails test test/controllers/decks_controller_test.rb` | ❌ W0 | ⬜ pending |
| 7-01-03 | 01 | 1 | EMPTY-01 | integration | `rails test test/controllers/decks_controller_test.rb` | ❌ W0 | ⬜ pending |
| 7-02-01 | 02 | 1 | EMPTY-02 | integration | `rails test test/controllers/decks_controller_test.rb` | ⚠️ partial | ⬜ pending |
| 7-02-02 | 02 | 1 | EMPTY-03 | integration | `rails test test/controllers/songs_controller_test.rb` | ❌ W0 | ⬜ pending |
| 7-03-01 | 03 | 2 | AUTH-01 | integration | `rails test test/controllers/registrations_controller_test.rb` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/controllers/decks_controller_test.rb` — add `NAV-02` assertions: grid class present, date text before title in DOM, `data-turbo-confirm` on delete button
- [ ] `test/controllers/decks_controller_test.rb` — add `EMPTY-01` assertion: empty state headline visible when no decks
- [ ] `test/controllers/songs_controller_test.rb` — add `EMPTY-03` assertion: empty state copy when `@songs` is empty
- [ ] `test/controllers/registrations_controller_test.rb` — add `AUTH-01` assertions: `font-serif` class and `rounded-xl` card wrapper present on auth pages

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Hover-reveal trash icon visible on card hover | NAV-02 | CSS hover state not testable in Minitest | Open deck index in browser, hover a card, verify trash icon appears |
| Auth card wrapper looks visually centered and contained | AUTH-01 | Visual layout check | Load sign-in page, confirm form is in a white card on stone-50 bg |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 15s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
