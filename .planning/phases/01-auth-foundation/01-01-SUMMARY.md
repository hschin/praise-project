---
phase: 01-auth-foundation
plan: 01
subsystem: testing
tags: [devise, minitest, integration-tests, authentication, fixtures]

# Dependency graph
requires: []
provides:
  - Devise-compatible user fixture with Encryptor.digest encrypted password
  - Integration tests for unauthenticated redirect on /decks (AUTH-02)
  - Integration tests for unauthenticated redirect on /songs (AUTH-02)
  - Integration tests for user sign-up flow — 3 cases (AUTH-01)
  - Integration tests for password reset flow — 3 cases (AUTH-03)
affects: [01-02, 01-03]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Devise::Test::IntegrationHelpers included in all controller integration tests
    - Devise route helpers used exclusively (new_user_registration_path, user_password_path, etc.)
    - ActionMailer::Base.deliveries cleared in setup and asserted after mailer-triggering actions

key-files:
  created:
    - test/controllers/registrations_controller_test.rb
    - test/controllers/passwords_controller_test.rb
  modified:
    - test/fixtures/users.yml
    - test/controllers/decks_controller_test.rb
    - test/controllers/songs_controller_test.rb

key-decisions:
  - "Assert_redirected_to decks_path (not root_path) after sign-up — Devise redirects to decks_path directly since the controller redefines after_sign_up_path_for"
  - "Use ActionMailer::Base.deliveries to assert password reset email enqueued in test delivery mode"

patterns-established:
  - "Pattern 1: All auth controller tests include Devise::Test::IntegrationHelpers and sign_in in setup"
  - "Pattern 2: Unauthenticated test calls sign_out before GET request to assert redirect"
  - "Pattern 3: Use Devise route helpers — never hardcode URL strings"

requirements-completed: [AUTH-01, AUTH-02, AUTH-03]

# Metrics
duration: 8min
completed: 2026-03-08
---

# Phase 1 Plan 01: Auth Test Scaffold Summary

**Minitest integration test scaffold for Devise auth — 10 tests covering signup, password reset, and route protection across 5 controller test files**

## Performance

- **Duration:** 8 min
- **Started:** 2026-03-07T17:38:15Z
- **Completed:** 2026-03-07T17:46:30Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- Fixed broken users fixture — added Devise::Encryptor.digest encrypted_password so sign_in works
- Rewrote decks and songs controller tests with Devise::Test::IntegrationHelpers, unauthenticated redirect tests, and authenticated success tests
- Created registrations_controller_test (GET sign-up page, valid sign-up, invalid sign-up) and passwords_controller_test (GET reset page, valid reset enqueues email, invalid email 422)

## Task Commits

Each task was committed atomically:

1. **Task 1: Fix user fixture and repair decks/songs controller tests** - `6f15a48` (feat)
2. **Task 2: Create registrations and passwords controller tests** - `142df10` (feat)

**Plan metadata:** `[see final commit below]` (docs: complete plan)

## Files Created/Modified
- `test/fixtures/users.yml` - Added Devise::Encryptor.digest encrypted_password for fixture sign_in
- `test/controllers/decks_controller_test.rb` - Rewritten with Devise helpers, auth redirect and success tests
- `test/controllers/songs_controller_test.rb` - Rewritten with Devise helpers, auth redirect and success tests
- `test/controllers/registrations_controller_test.rb` - Created: GET sign-up, valid POST, invalid POST
- `test/controllers/passwords_controller_test.rb` - Created: GET reset, valid POST (asserts mailer), invalid POST

## Decisions Made
- Assert `decks_path` not `root_path` after sign-up: Devise redirects to `decks_path` directly (the after_sign_up_path_for resolves to decks, not /). Discovered by running the test and observing the actual redirect target.
- Use `ActionMailer::Base.deliveries` to verify password reset email: delivery_method is already :test in test environment by default in Rails.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed sign-up redirect assertion from root_path to decks_path**
- **Found during:** Task 2 (registrations controller test creation)
- **Issue:** Plan specified `assert_redirected_to root_path` but Devise redirects to `decks_path` after sign-up
- **Fix:** Changed assertion to `assert_redirected_to decks_path` to match actual controller behavior
- **Files modified:** test/controllers/registrations_controller_test.rb
- **Verification:** Test passes after fix; 6/6 tests green
- **Committed in:** 142df10 (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 bug — wrong expected redirect target)
**Impact on plan:** Necessary correction to match actual Devise behavior. No scope creep.

## Issues Encountered
- Devise redirects to `decks_path` not `root_path` after sign-up because DecksController is the root controller and Devise resolves `after_sign_up_path_for` to the controller's canonical path.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Full test scaffold in place — `rails test test/controllers/` runs 10 tests, all green
- Ready for Phase 1 Plan 02 (implementation tasks) to make these tests the GREEN verification harness
- No blockers

---
*Phase: 01-auth-foundation*
*Completed: 2026-03-08*
