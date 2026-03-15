---
phase: 6
slug: global-components
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-15
---

# Phase 6 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Minitest (Rails default) |
| **Config file** | `test/test_helper.rb` |
| **Quick run command** | `rails test test/controllers/` |
| **Full suite command** | `rails test` |
| **Estimated runtime** | ~15 seconds |

---

## Sampling Rate

- **After every task commit:** Run `rails test test/controllers/`
- **After every plan wave:** Run `rails test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 15 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 6-W0-01 | W0 | 0 | FORM-01 | Integration | `rails test test/controllers/registrations_controller_test.rb` | ✅ (add case) | ⬜ pending |
| 6-W0-02 | W0 | 0 | FORM-02 | Integration | `rails test test/controllers/decks_controller_test.rb` | ✅ (add case) | ⬜ pending |
| 6-W0-03 | W0 | 0 | FORM-03 | Integration | `rails test test/controllers/songs_controller_test.rb` | ✅ (add case) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/controllers/registrations_controller_test.rb` — add test case: "GET edit renders with warm palette inputs" (FORM-01)
- [ ] `test/controllers/decks_controller_test.rb` — add test case: "flash notice partial includes green-50 class" (FORM-02)
- [ ] `test/controllers/songs_controller_test.rb` — add test case: "failed partial includes song title in error copy" (FORM-03)

*Note: all three test files already exist — these are additions to existing files, not new files.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Toast slides in from right with fade animation | FORM-02 | CSS transition — not testable in Minitest | Open any page, trigger a flash notice (e.g., save a deck), observe animation in browser |
| Error toast persists with X button; success toast auto-dismisses | FORM-02 | JS timing — not testable in Minitest | Trigger success flash, wait 4s (dismisses); trigger error flash, verify it persists, click X |
| Toast appears at fixed top-right during scroll | FORM-02 | Visual — not testable in Minitest | Scroll a long page, trigger flash, verify toast stays fixed |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 15s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
