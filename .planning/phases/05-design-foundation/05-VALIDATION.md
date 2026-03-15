---
phase: 5
slug: design-foundation
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-15
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Minitest (Rails default) |
| **Config file** | `test/test_helper.rb` |
| **Quick run command** | `rails test test/controllers/decks_controller_test.rb` |
| **Full suite command** | `rails test` |
| **Estimated runtime** | ~5 seconds |

---

## Sampling Rate

- **After every task commit:** Run `rails test test/controllers/decks_controller_test.rb`
- **After every plan wave:** Run `rails test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 5 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 5-xx-01 | palette | 1 | VIS-01 | unit (view) | `rails test test/controllers/decks_controller_test.rb` | ✅ extend existing | ⬜ pending |
| 5-xx-02 | component | 1 | VIS-02 | manual visual | n/a — manual review | n/a | ⬜ pending |
| 5-xx-03 | typography | 1 | VIS-03 | unit (view) | `rails test test/controllers/decks_controller_test.rb` | ✅ extend existing | ⬜ pending |
| 5-xx-04 | wordmark | 1 | VIS-04 | unit (view) | `rails test test/controllers/decks_controller_test.rb` | ✅ extend existing | ⬜ pending |
| 5-xx-05 | nav | 2 | NAV-01 | unit (controller) | `rails test test/controllers/decks_controller_test.rb` | ✅ extend existing | ⬜ pending |
| 5-xx-06 | quick_create | 2 | NAV-03 | unit (controller) | `rails test test/controllers/decks_controller_test.rb` | ❌ W0 | ⬜ pending |
| 5-xx-07 | quick_create | 2 | NAV-04 | unit (controller) | `rails test test/controllers/decks_controller_test.rb` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/controllers/decks_controller_test.rb` — add `test "POST quick_create redirects to deck editor"` stub for NAV-03
- [ ] `test/controllers/decks_controller_test.rb` — add `test "POST quick_create title contains upcoming Sunday"` stub for NAV-04

*Wave 0 adds two test stubs to an existing file; no new test infrastructure needed.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Cards/buttons/inputs use consistent rounded corners and shadow | VIS-02 | Visual uniformity cannot be reliably asserted via controller tests; requires visual inspection | Load `/decks`, `/songs`, a deck editor — verify `rounded-xl` on cards, `rounded-lg` on buttons/inputs, `shadow-sm` on cards |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 5s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
