# Testing Patterns

**Analysis Date:** 2026-03-07

## Test Framework

**Runner:**
- Minitest (Rails default) — `ActiveSupport::TestCase` for models, `ActionDispatch::IntegrationTest` for controllers
- Config: `test/test_helper.rb`
- Parallel execution enabled: `parallelize(workers: :number_of_processors)`

**System Testing:**
- Capybara + Selenium WebDriver available (in Gemfile test group) but no system tests written yet

**Assertion Library:**
- Minitest built-in (`assert`, `assert_response`, `assert_equal`, etc.)

**Run Commands:**
```bash
rails test               # Run all tests
rails test test/models/  # Run model tests only
rails test test/controllers/  # Run controller tests only
```

## Test File Organization

**Location:**
- Separate `test/` directory, mirroring `app/` structure
- Model tests: `test/models/<model_name>_test.rb`
- Controller tests: `test/controllers/<controller_name>_controller_test.rb`
- Integration tests directory exists but empty: `test/integration/`
- Mailer tests directory exists but empty: `test/mailers/`
- Helper tests directory exists but empty: `test/helpers/`

**Naming:**
- Test files: `<subject>_test.rb`
- Test classes: `<SubjectName>Test` (e.g., `SongTest`, `DecksControllerTest`)
- Test methods: String descriptors via `test "should do something" do`

**Structure:**
```
test/
├── test_helper.rb          # Shared config — parallel workers, fixtures :all
├── models/
│   ├── song_test.rb        # SongTest < ActiveSupport::TestCase
│   ├── deck_test.rb        # DeckTest < ActiveSupport::TestCase
│   ├── deck_song_test.rb   # DeckSongTest < ActiveSupport::TestCase
│   ├── lyric_test.rb       # LyricTest < ActiveSupport::TestCase
│   ├── slide_test.rb       # SlideTest < ActiveSupport::TestCase
│   └── user_test.rb        # UserTest < ActiveSupport::TestCase
├── controllers/
│   ├── songs_controller_test.rb       # SongsControllerTest < ActionDispatch::IntegrationTest
│   ├── decks_controller_test.rb       # DecksControllerTest < ActionDispatch::IntegrationTest
│   └── deck_songs_controller_test.rb  # DeckSongsControllerTest < ActionDispatch::IntegrationTest
└── fixtures/
    ├── songs.yml
    ├── decks.yml
    ├── deck_songs.yml
    ├── lyrics.yml
    ├── slides.yml
    └── users.yml
```

## Test Structure

**Suite Organization:**
```ruby
require "test_helper"

class SongsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get songs_index_url
    assert_response :success
  end
end
```

**Patterns:**
- All test files begin with `require "test_helper"`
- Model tests inherit from `ActiveSupport::TestCase`
- Controller tests inherit from `ActionDispatch::IntegrationTest`
- No setup/teardown blocks present — fixtures handle state
- Fixtures loaded globally via `fixtures :all` in `test/test_helper.rb`

## Mocking

**Framework:** None — Minitest's built-in stubbing only; no Mocha or RSpec mocks

**Patterns:**
- No mocking patterns established yet
- External service calls (e.g., Python subprocess for PPTX) not yet tested

**What to Mock:**
- Python subprocess calls for PPTX generation (when implemented)
- Any external HTTP calls

**What NOT to Mock:**
- Database interactions — use fixtures instead
- ActiveRecord validations — test against real model behavior

## Fixtures and Factories

**Test Data:**
```yaml
# test/fixtures/songs.yml
one:
  title: MyString
  artist: MyString
  default_key: MyString

two:
  title: MyString
  artist: MyString
  default_key: MyString
```

```yaml
# test/fixtures/decks.yml — fixtures support associations by name
one:
  user: one
  date: 2026-03-07
  title: MyString
  notes: MyText
```

```yaml
# test/fixtures/deck_songs.yml — join table fixture
one:
  deck: one
  song: one
  position: 1
  key: MyString
  arrangement:
```

**Location:** `test/fixtures/` — one YAML file per model

**Factory libraries:** Not used — Rails fixtures only

**Note:** Current fixture data uses Rails generator defaults (`MyString`, `MyText`). Fixtures should be updated to use realistic domain data before writing meaningful tests.

## Coverage

**Requirements:** None enforced — no coverage tooling configured

**View Coverage:**
```bash
# No coverage tool configured. Add simplecov to Gemfile to enable:
# gem "simplecov", require: false
```

## Test Types

**Unit Tests (Model):**
- Scope: Validations, associations, instance methods
- Location: `test/models/`
- All model test files exist but contain only commented-out boilerplate — no actual tests written
- Files: `test/models/song_test.rb`, `test/models/deck_test.rb`, `test/models/deck_song_test.rb`, `test/models/lyric_test.rb`, `test/models/slide_test.rb`, `test/models/user_test.rb`

**Controller Tests (Integration):**
- Scope: HTTP request/response assertions via `ActionDispatch::IntegrationTest`
- Location: `test/controllers/`
- `test/controllers/songs_controller_test.rb` and `test/controllers/decks_controller_test.rb` contain route smoke tests (`assert_response :success`) but use incorrect auto-generated URL helpers that will fail (e.g., `songs_index_url` instead of `songs_url`)
- `test/controllers/deck_songs_controller_test.rb` — empty, no tests

**System Tests:**
- Not yet written; Capybara + Selenium available in Gemfile
- No `test/system/` directory present

## Common Patterns

**HTTP Assertion (controller test):**
```ruby
test "should get index" do
  get songs_url
  assert_response :success
end
```

**Model Validation Test (recommended pattern — not yet implemented):**
```ruby
test "is invalid without title" do
  song = Song.new(title: nil)
  assert_not song.valid?
  assert_includes song.errors[:title], "can't be blank"
end
```

**Authenticated Controller Test (required pattern — auth not yet wired into tests):**
```ruby
# All controllers require authenticate_user! — tests must sign in first
# Using Devise test helpers:
include Devise::Test::IntegrationHelpers

setup do
  @user = users(:one)
  sign_in @user
end

test "should get index" do
  get decks_url
  assert_response :success
end
```

**Fixture Reference in Tests:**
```ruby
# Reference fixture by name
song = songs(:one)
deck = decks(:one)
```

## Critical Gap: Authentication in Tests

All controllers use `before_action :authenticate_user!` (Devise). The existing controller tests do not sign in a user, meaning all controller tests will redirect to sign-in rather than return `:success`. Tests must use Devise test helpers:

```ruby
# Add to test_helper.rb or include per controller test file:
include Devise::Test::IntegrationHelpers

setup do
  sign_in users(:one)
end
```

---

*Testing analysis: 2026-03-07*
