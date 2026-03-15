# Deferred Items — Phase 06

## Pre-existing Test Failures (out of scope)

### DecksControllerTest failures
- `test_flash_notice_renders_toast_with_green-50_class` — test expects `green-50` but flash uses `rose-50`
- `test_flash_alert_renders_toast_with_red-50_class` — related flash test failure
- **Discovered during:** 06-02 Task 3 (full controllers test run)
- **Status:** Pre-existing, not caused by 06-02 changes

## Partial Deletion Deferred (06-02)

### _error_messages.html.erb still exists
- **Reason:** 4 other Devise views still reference it: unlocks/new, passwords/edit, passwords/new, confirmations/new
- **Plan assumed:** Only registrations views used the partial
- **Impact:** Deleting partial would cause ActionView::MissingTemplate errors
- **Recommendation:** A future plan should update all Devise views with inline error blocks and then delete the partial
