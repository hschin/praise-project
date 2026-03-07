# Codebase Concerns

**Analysis Date:** 2026-03-07

## Tech Debt

**PPTX Export is a Stub:**
- Issue: The core feature of the app — generating PowerPoint slides — is not implemented. The `export` action returns `head :ok` with no file generated, no background job, no Python subprocess call.
- Files: `app/controllers/decks_controller.rb` (line 41–44)
- Impact: Clicking "Export PPTX" silently succeeds but produces nothing. Users cannot complete the primary workflow.
- Fix approach: Implement using a background job (Solid Queue) that serializes the deck to JSON and shells out to a Python script in `lib/pptx_generator/`. The Python script directory doesn't exist yet and must be created.

**Lyric/Slide Management Has No UI:**
- Issue: No controllers, routes, or views exist for `Lyric` or `Slide` models. Songs display existing lyrics read-only in `app/views/songs/show.html.erb`, but there is no way to add, edit, reorder, or delete lyrics through the UI. Slides have no management UI at all.
- Files: `app/controllers/` (no `lyrics_controller.rb` or `slides_controller.rb`), `config/routes.rb`
- Impact: Songs cannot have lyrics entered via the web interface. The `Slide` model exists with no CRUD surface.
- Fix approach: Add nested `LyricsController` under `songs` routes. Add Slide generation as part of the export pipeline rather than as a separate UI concern.

**Arrangement Field is Unimplemented:**
- Issue: `deck_songs.arrangement` (jsonb) stores an ordered lyric ID array for performance sequencing, but there is no UI to build or edit it. The field is permitted in `deck_song_params` but never rendered or set in any view.
- Files: `app/models/deck_song.rb` (comment on lines 8–11), `app/controllers/deck_songs_controller.rb` (line 37), `app/views/decks/show.html.erb`
- Impact: The arrangement column is always null. The export feature (when implemented) will have no ordering data to use.
- Fix approach: Add a drag-and-drop or ordered selection UI within the deck show view that writes to the `arrangement` jsonb column.

**Song Position for DeckSong is Fragile:**
- Issue: Position is set as `@deck.deck_songs.count + 1` at creation time. There is no reorder endpoint, no drag-and-drop, and no gap-filling if a song is removed (leaving position gaps like 1, 3 after removing position 2).
- Files: `app/controllers/deck_songs_controller.rb` (line 7)
- Impact: Position ordering becomes unreliable after deletions. The deck song list relies on position for ordered display via the model scope in `app/models/deck.rb`.
- Fix approach: Add a reorder endpoint (e.g., `PATCH /decks/:id/deck_songs/reorder`) that reassigns contiguous positions. Use a Stimulus controller for drag-and-drop.

**Stimulus Hello World Controller is an Unused Placeholder:**
- Issue: `app/javascript/controllers/hello_controller.js` is the default scaffold controller that overwrites element text with "Hello World!". It is registered in the index but used nowhere in production views.
- Files: `app/javascript/controllers/hello_controller.js`, `app/javascript/controllers/index.js`
- Impact: Low — dead code only. Signals no real Stimulus controllers have been built yet for interactive UI.
- Fix approach: Delete `hello_controller.js` and its registration when real controllers are added.

**Seeds File is Empty:**
- Issue: `db/seeds.rb` contains only a comment block. There is no seed data for development.
- Files: `db/seeds.rb`
- Impact: New development environments have no songs, lyrics, or decks to work with. Manual setup is required every time the database is reset.
- Fix approach: Add representative seed data: at least 2–3 songs with lyrics and a sample deck.

---

## Known Bugs

**Controller Tests Use Non-Existent Routes:**
- Symptoms: `test/controllers/decks_controller_test.rb` calls `decks_index_url`, `decks_show_url`, `decks_new_url`, and `decks_edit_url`. These named routes do not exist — the correct routes are `decks_url`, `deck_url`, `new_deck_url`, and `edit_deck_url`. The tests will error before any assertion runs.
- Files: `test/controllers/decks_controller_test.rb`, `test/controllers/songs_controller_test.rb`
- Trigger: Running `rails test`
- Workaround: None — tests error before assertions are reached.

**Controller Tests Have No Authentication:**
- Symptoms: `DecksController` and `SongsController` require `authenticate_user!`. The controller tests make unauthenticated requests and will receive 302 redirects, causing all `assert_response :success` assertions to fail.
- Files: `test/controllers/decks_controller_test.rb`, `test/controllers/songs_controller_test.rb`
- Trigger: Running `rails test`
- Workaround: None currently. Tests need `sign_in` helpers from Devise test helpers and `include Devise::Test::IntegrationHelpers`.

**Users Fixture is Empty:**
- Symptoms: `test/fixtures/users.yml` defines `one: {}` and `two: {}` with no columns (no email, no encrypted_password). Fixtures that reference `user: one` (decks fixture) will fail to load because the users fixture creates invalid User records that fail Devise validations.
- Files: `test/fixtures/users.yml`, `test/fixtures/decks.yml`
- Trigger: Any test that loads fixtures
- Workaround: None — fixture load fails.

---

## Security Considerations

**Content Security Policy is Fully Disabled:**
- Risk: The CSP initializer is entirely commented out. No `Content-Security-Policy` header is set, leaving the app exposed to XSS via user-generated content (lyrics, song titles, deck notes).
- Files: `config/initializers/content_security_policy.rb`
- Current mitigation: Rails ERB auto-escapes by default, which reduces (but does not eliminate) XSS risk.
- Recommendations: Uncomment and configure CSP with `script-src :self`, `style-src :self`, and nonce generation for importmap compatibility.

**Songs Are a Global Shared Resource Without Ownership:**
- Risk: The `Song` model has no `user_id` or ownership column. Any authenticated user can edit or delete any song created by any other user. `SongsController#set_song` uses `Song.find(params[:id])` with no user scope.
- Files: `app/controllers/songs_controller.rb` (line 44), `app/models/song.rb`
- Current mitigation: Authentication is required (Devise), so anonymous access is blocked.
- Recommendations: Either add `user_id` to songs and scope queries to `current_user.songs`, or establish songs as intentionally shared and implement an admin/owner role.

**SSL and Host Validation Commented Out in Production:**
- Risk: `config.force_ssl` and `config.assume_ssl` are commented out in `config/environments/production.rb`. `config.hosts` allow-list is also commented out, leaving DNS rebinding protection disabled.
- Files: `config/environments/production.rb` (lines 27–31, 83–89)
- Current mitigation: Kamal/Thruster may handle SSL termination at proxy level, but it is not configured in `config/deploy.yml`.
- Recommendations: Uncomment `config.assume_ssl = true` and `config.force_ssl = true`. Configure `config.hosts` to restrict to the production domain.

**Production Mailer Host is a Placeholder:**
- Risk: `config.action_mailer.default_url_options = { host: "example.com" }` — Devise password reset emails will generate links pointing to `example.com` in production.
- Files: `config/environments/production.rb` (line 61)
- Current mitigation: Mailer delivery errors are silenced, so this may not be immediately visible.
- Recommendations: Replace `"example.com"` with the actual production hostname, or set it via an environment variable.

---

## Performance Bottlenecks

**N+1 Query on Decks Index:**
- Problem: `app/views/decks/index.html.erb` calls `deck.deck_songs.count` inside an `@decks.each` loop (line 15), executing a separate `COUNT` SQL query per deck.
- Files: `app/views/decks/index.html.erb` (line 15), `app/controllers/decks_controller.rb`
- Cause: No eager loading is applied — `@decks = current_user.decks.order(date: :desc)` loads decks without `deck_songs`.
- Improvement path: Use `includes(:deck_songs)` on the query and switch the view to `deck.deck_songs.size`, or add `counter_cache: true` to the `DeckSong` `belongs_to :deck` association.

**N+1 Query on Deck Show — Song Details:**
- Problem: `app/views/decks/show.html.erb` iterates `@deck.deck_songs.each` and calls `deck_song.song.title` and `deck_song.song.artist` on each iteration (lines 22–23), triggering a separate query per song.
- Files: `app/views/decks/show.html.erb` (lines 19–23), `app/controllers/decks_controller.rb`
- Cause: `set_deck` loads the deck with no eager loading of `deck_songs` or their associated `song`.
- Improvement path: Use `@deck = current_user.decks.includes(deck_songs: :song).find(params[:id])` in `set_deck` for show/edit actions.

**Full Song Table Scan Embedded in a View:**
- Problem: `app/views/decks/show.html.erb` calls `Song.order(:title).map { |s| [s.title, s.id] }` directly in the view (line 36). This loads all songs from the database on every deck show page render, with no caching.
- Files: `app/views/decks/show.html.erb` (line 36)
- Cause: Business logic embedded in a view with no controller assignment or caching.
- Improvement path: Move `@songs = Song.order(:title)` into `DecksController#show`. Add fragment caching or pagination if the song library grows large.

---

## Fragile Areas

**Slide Model Purpose is Ambiguous:**
- Files: `app/models/slide.rb`, `db/schema.rb` (slides table), `db/migrate/20260307132253_create_slides.rb`, `db/migrate/20260307134357_make_slides_lyric_id_nullable.rb`
- Why fragile: The `slides` table has a `content` (text) column and an optional `lyric_id`, but no `slide_type` column despite CLAUDE.md describing slides as having types (`title/verse/chorus/scripture/blank`). The PPTX generator will need to infer slide type from the lyric's `section_type` or the content field. The schema was already altered once (making `lyric_id` nullable), indicating the design is still evolving.
- Safe modification: Do not rely on `slides.content` as a source of truth until the PPTX export pipeline is defined. Treat the `Slide` model as a work-in-progress.
- Test coverage: Zero — `test/models/slide_test.rb` is empty.

**DeckSong Position Lacks Database Constraint:**
- Files: `db/schema.rb` (deck_songs table), `app/models/deck_song.rb`
- Why fragile: `position` is an integer with a Ruby-level presence validation but no `NOT NULL` database constraint and no uniqueness constraint scoped to `deck_id`. Concurrent requests adding songs to the same deck can produce duplicate positions.
- Safe modification: Always set position before saving. Be aware concurrent additions to the same deck can produce duplicate positions until a database-level unique index is added.
- Test coverage: Zero — `test/models/deck_song_test.rb` is empty.

**Kamal Deploy Config is Placeholder:**
- Files: `config/deploy.yml`
- Why fragile: Server IP is `192.168.0.1` (LAN placeholder), container registry is `localhost:5555`, and the SSL proxy block is commented out. Deploying without updating these values will fail or target the wrong host.
- Safe modification: Treat `config/deploy.yml` as a template. Update all placeholder values before any production deploy attempt.
- Test coverage: Not applicable.

---

## Test Coverage Gaps

**All Model Tests Are Empty:**
- What's not tested: Validations, associations, dependent destroy behavior, and position ordering for all models.
- Files: `test/models/deck_test.rb`, `test/models/song_test.rb`, `test/models/deck_song_test.rb`, `test/models/lyric_test.rb`, `test/models/slide_test.rb`, `test/models/user_test.rb`
- Risk: Regressions in model validations or association behavior go undetected.
- Priority: High

**DeckSongs Controller Has No Tests:**
- What's not tested: Song add/remove from deck, position assignment, arrangement update, authorization (user can only access their own decks).
- Files: `test/controllers/deck_songs_controller_test.rb`
- Risk: The most complex controller workflow has zero test coverage.
- Priority: High

**All Existing Controller Tests Are Broken:**
- What's not tested: Nothing currently passes — wrong route helpers and missing authentication cause all controller tests to error before assertions.
- Files: `test/controllers/decks_controller_test.rb`, `test/controllers/songs_controller_test.rb`
- Risk: False sense of test coverage. CI will report failures or be skipped entirely.
- Priority: High — fix route names and add Devise `sign_in` helpers first.

**No Integration or System Tests:**
- What's not tested: End-to-end user flows (sign up, add songs, create deck, export PPTX).
- Files: `test/integration/` (empty), no system test directory present.
- Risk: Multi-step workflows can break silently across controller and model layers.
- Priority: Medium

---

*Concerns audit: 2026-03-07*
