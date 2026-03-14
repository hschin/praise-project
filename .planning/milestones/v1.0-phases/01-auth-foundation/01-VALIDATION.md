---
phase: 1
slug: auth-foundation
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-08
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Minitest (Rails default) |
| **Config file** | `test/test_helper.rb` |
| **Quick run command** | `rails test test/controllers/` |
| **Full suite command** | `rails test` |
| **Estimated runtime** | ~10 seconds |

---

## Sampling Rate

- **After every task commit:** Run `rails test test/controllers/`
- **After every plan wave:** Run `rails test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| AUTH-01-signup-200 | 01 | 0 | AUTH-01 | integration | `rails test test/controllers/registrations_controller_test.rb` | ❌ W0 | ⬜ pending |
| AUTH-01-signup-valid | 01 | 0 | AUTH-01 | integration | `rails test test/controllers/registrations_controller_test.rb` | ❌ W0 | ⬜ pending |
| AUTH-01-signup-invalid | 01 | 0 | AUTH-01 | integration | `rails test test/controllers/registrations_controller_test.rb` | ❌ W0 | ⬜ pending |
| AUTH-02-session-persist | 01 | 0 | AUTH-02 | integration | `rails test test/controllers/decks_controller_test.rb` | ✅ (needs fix) | ⬜ pending |
| AUTH-02-unauth-decks | 01 | 0 | AUTH-02 | integration | `rails test test/controllers/decks_controller_test.rb` | ✅ (needs fix) | ⬜ pending |
| AUTH-02-unauth-songs | 01 | 0 | AUTH-02 | integration | `rails test test/controllers/songs_controller_test.rb` | ✅ (needs fix) | ⬜ pending |
| AUTH-03-reset-200 | 01 | 0 | AUTH-03 | integration | `rails test test/controllers/passwords_controller_test.rb` | ❌ W0 | ⬜ pending |
| AUTH-03-reset-email | 01 | 0 | AUTH-03 | integration | `rails test test/controllers/passwords_controller_test.rb` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/fixtures/users.yml` — add encrypted_password to fixture (currently `{}`)
- [ ] `test/controllers/registrations_controller_test.rb` — covers AUTH-01 signup flow
- [ ] `test/controllers/passwords_controller_test.rb` — covers AUTH-03 password reset request
- [ ] Fix `test/controllers/decks_controller_test.rb` — add `include Devise::Test::IntegrationHelpers` and `sign_in` calls, fix wrong route helpers
- [ ] Fix `test/controllers/songs_controller_test.rb` — same auth setup issues as decks

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Password reset email delivers correct link | AUTH-03 | Email delivery requires manual inspection | Trigger reset, check mailer preview at `/rails/mailers` or letter_opener |
| Solid Queue jobs execute in development | AUTH-01/02/03 | Process execution not testable via unit test | Start `bin/dev`, enqueue a test job, confirm it runs via logs |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
