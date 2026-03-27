# T01: 07-content-pages 01

**Slice:** S07 — **Milestone:** M001

## Description

Add Wave 0 test assertions to three existing test files so all Phase 7 requirement behaviors have automated verification before the view changes are written.

Purpose: Nyquist compliance — tests must exist and fail RED before implementation begins.
Output: Failing tests in decks_controller_test.rb, songs_controller_test.rb, and registrations_controller_test.rb that will go green after Plans 02-04 complete.

## Must-Haves

- [ ] "Automated tests exist for all five Phase 7 requirements before any view changes are made"
- [ ] "NAV-02 tests verify the card grid class and date-before-title DOM order"
- [ ] "EMPTY-01 tests verify the empty state headline copy renders when no decks exist"
- [ ] "EMPTY-02 tests verify the deck editor empty branch copy renders when no deck_songs exist"
- [ ] "EMPTY-03 tests verify the song library empty state copy renders when no songs exist"
- [ ] "AUTH-01 tests verify font-serif class and card wrapper class are present on auth pages"

## Files

- `test/controllers/decks_controller_test.rb`
- `test/controllers/songs_controller_test.rb`
- `test/controllers/registrations_controller_test.rb`
