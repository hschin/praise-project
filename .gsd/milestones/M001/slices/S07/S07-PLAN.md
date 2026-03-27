# S07: Content Pages

**Goal:** Add Wave 0 test assertions to three existing test files so all Phase 7 requirement behaviors have automated verification before the view changes are written.
**Demo:** Add Wave 0 test assertions to three existing test files so all Phase 7 requirement behaviors have automated verification before the view changes are written.

## Must-Haves


## Tasks

- [x] **T01: 07-content-pages 01**
  - Add Wave 0 test assertions to three existing test files so all Phase 7 requirement behaviors have automated verification before the view changes are written.

Purpose: Nyquist compliance — tests must exist and fail RED before implementation begins.
Output: Failing tests in decks_controller_test.rb, songs_controller_test.rb, and registrations_controller_test.rb that will go green after Plans 02-04 complete.
- [x] **T02: 07-content-pages 02** `est:8min`
  - Replace the divide-y list layout in decks/index.html.erb with a 3-column card grid where the service date is the headline on each card. Add an illustrated empty state with a micro-workflow explainer for first-time users.

Purpose: NAV-02 — users scan their deck library by date, not by title. EMPTY-01 — new users understand the app's purpose before creating anything.
Output: Updated decks/index.html.erb with grid layout and illustrated empty state.
- [x] **T03: 07-content-pages 03** `est:8min`
  - Replace the plain-text empty states in the deck editor arrangement panel and the song library with small icon + copy empty states.

Purpose: EMPTY-02 — deck editors know exactly where to look and what to do when a deck has no songs. EMPTY-03 — new users understand the import workflow without extra orientation.
Output: Targeted edits to two else branches in existing view files. No structural changes to the if branches.
- [x] **T04: 07-content-pages 04** `est:8min`
  - Apply brand treatment to the Devise auth pages: replace font-bold with font-serif text-rose-700 on the wordmark heading, and wrap each form in a white card matching the established card pattern.

Purpose: AUTH-01 — auth pages feel like the product (warm palette, brand wordmark) rather than a generic Devise scaffold.
Output: Updated sessions/new.html.erb, registrations/new.html.erb, and passwords/new.html.erb.

## Files Likely Touched

- `test/controllers/decks_controller_test.rb`
- `test/controllers/songs_controller_test.rb`
- `test/controllers/registrations_controller_test.rb`
- `app/views/decks/index.html.erb`
- `app/views/decks/show.html.erb`
- `app/views/songs/index.html.erb`
- `app/views/devise/sessions/new.html.erb`
- `app/views/devise/registrations/new.html.erb`
- `app/views/devise/passwords/new.html.erb`
