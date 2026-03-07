# Phase 1: Auth + Foundation - Research

**Researched:** 2026-03-08
**Domain:** Rails 8.1 / Devise 5 / Tailwind CSS / Solid Queue — auth UI polish and worker wiring
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Sign-up Policy**
- Open signup — anyone with the URL can register
- Email + password only (no name field on registration)
- No invite flow needed for v1

**Auth Page Branding**
- App name: **Praise Project** (English)
- Layout: Clean centered card — app name above the form, nothing else
- Form labels and buttons: English only
- No logo, no split layout, no tagline

**App Navigation**
- Top navigation bar (not sidebar)
- Layout: "Praise Project" (app name/home link) on the left | Decks | Songs | [user email] | Logout on the right
- All authenticated pages share this nav
- No nav shown on auth pages (sign-in, sign-up, password reset)

**Empty States**
- Decks index (no decks): "No decks yet. Create your first deck." + prominent "New Deck" button
- Songs index (no songs): "No songs yet. Search for a song to get started." + search bar
- Simple message + action — no guided onboarding steps

### Claude's Discretion
- Exact Tailwind styling details (colors, spacing, shadows within the established indigo/gray palette)
- Flash message placement and styling
- Mobile responsiveness level
- Solid Queue smoke test implementation details

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| AUTH-01 | User can sign up with email and password | Devise `:registerable` is installed and `registrations/new.html.erb` already exists with Tailwind styling; needs app name heading added |
| AUTH-02 | User session persists across browser refresh | Devise `:rememberable` is installed; `remember_created_at` column exists in schema; "Remember me" checkbox already in sessions form |
| AUTH-03 | User can reset password via email link | Devise `:recoverable` is installed; `reset_password_token` column exists; `passwords/new.html.erb` needs Tailwind styling (only view still using unstyled HTML); mailer sender email must be set in `devise.rb` |
</phase_requirements>

---

## Summary

This phase is overwhelmingly a polish and wiring task on an already-functional codebase. Devise 5 is fully installed with all required modules (`:database_authenticatable`, `:registerable`, `:recoverable`, `:rememberable`, `:validatable`). The database schema is complete. Two of three auth views (`sessions/new`, `registrations/new`) are already styled with Tailwind following project conventions. Only `passwords/new` remains in raw unstyled HTML.

The navigation layout already exists in `application.html.erb` but diverges from the locked spec in two ways: (1) the app name link reads "PraiseProject" (missing the space — should be "Praise Project"), and (2) nav currently shows on auth pages because there is no conditional hiding for Devise controller contexts. The user email in the nav is also missing — currently only a "Sign out" link appears.

Solid Queue is installed as a gem and `bin/jobs` exists, but the Procfile.dev only has `web` and `css` processes — `bin/jobs` is absent. In development, no `queue_adapter` is configured, meaning jobs currently run as `:async` (the Rails default). Adding Solid Queue to the Procfile.dev and configuring the development adapter is the Solid Queue work this phase requires.

**Primary recommendation:** Do not rebuild any auth infrastructure. The work is: (1) fix the nav bar per spec, (2) style `passwords/new`, (3) add app name heading to auth pages, (4) wire Solid Queue for development, (5) write auth controller tests with Devise test helpers.

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Devise | ~> 5.0 (installed) | Authentication — sign-up, sign-in, password reset, session management | De facto Rails auth gem; already installed and configured |
| tailwindcss-rails | ~> 4.4 (installed) | Utility-first CSS | Already in Gemfile; all existing views use Tailwind |
| Solid Queue | (Rails 8 built-in, installed) | Background job processing | Rails 8 default; already in Gemfile; `bin/jobs` already exists |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Minitest | Rails default (built-in) | Test framework | Already in use (`test/test_helper.rb`, existing test files) |
| Capybara | Installed in test group | System/integration tests | For smoke-testing auth flows end-to-end if needed |
| Devise::Test::IntegrationHelpers | Part of Devise gem | Sign-in helpers for controller tests | Use in `ActionDispatch::IntegrationTest` subclasses |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Minitest | RSpec | No — project convention is Minitest, CLAUDE.md confirms |
| Solid Queue (separate process) | `SOLID_QUEUE_IN_PUMA=1` | Only use in-puma mode for production convenience; dev benefits from separate process for visibility |

**No additional gem installation needed for this phase.**

---

## Architecture Patterns

### Recommended Project Structure
No new directories needed. All work touches existing files:

```
app/
├── controllers/
│   └── songs_controller.rb        # Add before_action :authenticate_user!
├── views/
│   ├── layouts/
│   │   └── application.html.erb   # Fix nav: spacing, user email, hide on auth pages
│   └── devise/
│       ├── sessions/new.html.erb  # Already styled — add "Praise Project" heading
│       ├── registrations/new.html.erb  # Already styled — add "Praise Project" heading
│       └── passwords/new.html.erb      # Needs full Tailwind styling
config/
├── initializers/
│   └── devise.rb                  # Fix mailer_sender email
└── environments/
    └── development.rb             # Add queue_adapter: :solid_queue
Procfile.dev                       # Add: jobs: bin/jobs
```

### Pattern 1: Hiding Nav on Devise Controller Pages

Devise controllers inherit from `DeviseController`. Use `devise_controller?` helper to conditionally suppress the nav in the layout.

**What:** Wrap the `<nav>` block so it only renders when NOT on a Devise controller page.
**When to use:** Auth pages (sign-in, sign-up, password reset) must not show the nav per spec.

```erb
<%# In app/views/layouts/application.html.erb %>
<% unless devise_controller? %>
  <nav class="bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
    <%= link_to "Praise Project", root_path, class: "text-lg font-bold text-indigo-600" %>
    <% if user_signed_in? %>
      <div class="flex items-center gap-6">
        <%= link_to "Decks", decks_path, class: "text-sm text-gray-600 hover:text-gray-900" %>
        <%= link_to "Songs", songs_path, class: "text-sm text-gray-600 hover:text-gray-900" %>
      </div>
      <div class="flex items-center gap-4">
        <span class="text-sm text-gray-500"><%= current_user.email %></span>
        <%= link_to "Logout", destroy_user_session_path, data: { turbo_method: :delete }, class: "text-sm text-gray-600 hover:text-gray-900" %>
      </div>
    <% end %>
  </nav>
<% end %>
```

### Pattern 2: Auth Page Centered Card with App Name

Per spec: app name above form, clean centered card, nothing else.

```erb
<%# In app/views/devise/passwords/new.html.erb (unstyled — needs full rewrite) %>
<div class="max-w-md mx-auto mt-12">
  <h1 class="text-2xl font-bold text-center mb-2">Praise Project</h1>
  <h2 class="text-lg text-gray-600 text-center mb-6">Reset your password</h2>

  <%= form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :post, class: "space-y-4" }) do |f| %>
    <%= render "devise/shared/error_messages", resource: resource %>

    <div>
      <%= f.label :email, class: "block text-sm font-medium text-gray-700 mb-1" %>
      <%= f.email_field :email, autofocus: true, autocomplete: "email",
          class: "w-full border border-gray-300 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500" %>
    </div>

    <%= f.submit "Send reset instructions",
        class: "w-full bg-indigo-600 text-white text-sm px-4 py-2 rounded hover:bg-indigo-700 cursor-pointer" %>
  <% end %>

  <div class="mt-4 space-y-1 text-sm text-gray-500">
    <%= render "devise/shared/links" %>
  </div>
</div>
```

### Pattern 3: Solid Queue in Development

The development environment has no `queue_adapter` set, so Rails defaults to `:async`. To actually run Solid Queue as a background process in development (required for smoke test verification):

```ruby
# config/environments/development.rb — add inside Rails.application.configure block
config.active_job.queue_adapter = :solid_queue
```

```
# Procfile.dev — add jobs process
web: bin/rails server
css: bin/rails tailwindcss:watch
jobs: bin/jobs
```

### Pattern 4: Devise Integration Test Helpers

For controller/integration tests that require authentication:

```ruby
# test/controllers/decks_controller_test.rb
class DecksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)  # fixture user
    sign_in @user
  end

  test "redirects to sign in when not authenticated" do
    sign_out @user
    get decks_url
    assert_redirected_to new_user_session_path
  end

  test "authenticated user sees decks index" do
    get decks_url
    assert_response :success
  end
end
```

### Pattern 5: Solid Queue Smoke Test Job

A minimal job to verify the worker actually processes jobs (not just boots):

```ruby
# app/jobs/smoke_test_job.rb
class SmokeTestJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "[SmokeTestJob] Worker is alive at #{Time.current}"
  end
end
```

Verify via: `SmokeTestJob.perform_later` then watch `bin/jobs` output for the log line.

### Anti-Patterns to Avoid

- **Rendering nav on Devise pages:** Without `unless devise_controller?`, auth pages show the full nav. Confirmed: current nav has no such guard.
- **Leaving `mailer_sender` as example.com:** Password reset emails won't send properly; the `devise.rb` initializer still has `'please-change-me-at-config-initializers-devise@example.com'`. Must set a real address.
- **Testing Devise routes directly by string:** Use `new_user_session_path`, `destroy_user_session_path`, etc. — not hardcoded paths.
- **Using `async` adapter and calling it "Solid Queue":** The success criterion requires confirmed job _execution_, not just boot. Must set `:solid_queue` adapter in development.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Session management | Custom token system | Devise `:rememberable` | Already implemented; `remember_created_at` column present |
| Password reset tokens | Custom email+token flow | Devise `:recoverable` | Already implemented; `reset_password_token` column present |
| Password hashing | Custom bcrypt calls | Devise `:database_authenticatable` | Already implemented |
| Auth redirect after login | Custom session storage | `after_sign_in_path_for` override | Already implemented in `ApplicationController` |
| Form CSRF protection | Manual token handling | Rails `csrf_meta_tags` + `form_for`/`form_with` | Already in layout |

**Key insight:** Every auth concern is already handled by Devise. This phase is styling + wiring, not building auth infrastructure.

---

## Common Pitfalls

### Pitfall 1: Nav Renders on Auth Pages
**What goes wrong:** The nav (with Decks, Songs links) appears on sign-in/sign-up/password reset pages — violating the locked spec.
**Why it happens:** `application.html.erb` is the layout for all pages including Devise unless overridden; Devise does not have its own layout configured.
**How to avoid:** Wrap the `<nav>` in `<% unless devise_controller? %>`.
**Warning signs:** Visiting `/users/sign_in` and seeing the top nav bar.

### Pitfall 2: `mailer_sender` Still Set to Example.com
**What goes wrong:** Password reset emails either fail delivery or show an invalid from address.
**Why it happens:** Rails generators leave a placeholder; `config/initializers/devise.rb` line 25 has `'please-change-me-at-config-initializers-devise@example.com'`.
**How to avoid:** Set to something like `'noreply@praiseproject.app'` or an address that will work in the deployment environment. For development, `config.action_mailer.delivery_method = :letter_opener` (or `:test`) avoids the need for a real SMTP server.
**Warning signs:** Password reset test failing with SMTP connection errors; emails showing wrong from address.

### Pitfall 3: Solid Queue Not Running in Development
**What goes wrong:** `SomeJob.perform_later` silently enqueues but the job never executes, because `queue_adapter` defaults to `:async` in development and no Solid Queue process is running.
**Why it happens:** `Procfile.dev` only has `web` and `css`. No `queue_adapter` is configured in `development.rb`.
**How to avoid:** Add `config.active_job.queue_adapter = :solid_queue` to `development.rb` AND add `jobs: bin/jobs` to `Procfile.dev`. Run with `bin/dev` (which reads Procfile.dev via `foreman`).
**Warning signs:** Jobs enqueue without errors but never appear in Solid Queue's `solid_queue_jobs` table; no log output from `bin/jobs`.

### Pitfall 4: User Fixture Has No Encrypted Password
**What goes wrong:** Devise authentication fails in tests because the fixture user has empty `{}` record with no `encrypted_password`.
**Why it happens:** Devise passwords are bcrypt-hashed; plain text passwords in fixtures don't work.
**How to avoid:** Use `Devise::Encryptor.digest(User, 'password')` in the fixture, OR use `sign_in @user = User.create!(email: 'test@example.com', password: 'password123')` in test setup. The fixture approach:

```yaml
# test/fixtures/users.yml
one:
  email: user@example.com
  encrypted_password: <%= Devise::Encryptor.digest(User, 'password123') %>
```

**Warning signs:** `sign_in users(:one)` doesn't authenticate the user; controller tests redirect to sign-in unexpectedly.

### Pitfall 5: Nav Layout Mismatch with Spec
**What goes wrong:** Nav shows "PraiseProject" (no space) and has Decks/Songs on the left next to the app name — but the spec calls for "Praise Project" on the far left and `[user email] | Logout` on the right.
**Why it happens:** The existing nav was scaffolded but not fully aligned to the final spec. Current layout puts "Decks" and "Songs" in the same flex container as the app name (left side), but user email is missing entirely.
**How to avoid:** Rewrite nav per spec: left side = app name link only; right side = Decks | Songs | [email] | Logout.

---

## Code Examples

Verified patterns from existing codebase:

### Existing Button Class (established convention)
```erb
<%# Source: existing app/views/decks/index.html.erb %>
class: "bg-indigo-600 text-white text-sm px-4 py-2 rounded hover:bg-indigo-700"
```

### Existing Form Field Class (established convention)
```erb
<%# Source: existing app/views/devise/sessions/new.html.erb %>
class: "w-full border border-gray-300 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
```

### Existing Label Class (established convention)
```erb
<%# Source: existing app/views/devise/sessions/new.html.erb %>
class: "block text-sm font-medium text-gray-700 mb-1"
```

### Turbo-compatible Sign Out Link
```erb
<%# Must use data-turbo-method: :delete — Devise sessions#destroy is a DELETE route %>
<%= link_to "Logout", destroy_user_session_path, data: { turbo_method: :delete }, class: "text-sm text-gray-600 hover:text-gray-900" %>
```

### Solid Queue Development Configuration
```ruby
# config/environments/development.rb
config.active_job.queue_adapter = :solid_queue
```

### Devise Integration Test Pattern
```ruby
class SongsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "requires authentication" do
    get songs_url
    assert_redirected_to new_user_session_path
  end
end
```

---

## What's Already Done (No Work Needed)

| Item | Status | Evidence |
|------|--------|---------|
| Devise gem installed | Done | `Gemfile` line 68: `gem "devise", "~> 5.0"` |
| User model with all modules | Done | `app/models/user.rb`: `:database_authenticatable, :registerable, :recoverable, :rememberable, :validatable` |
| Users table with all Devise columns | Done | `db/schema.rb`: `encrypted_password`, `reset_password_token`, `reset_password_sent_at`, `remember_created_at` |
| `devise_for :users` routes | Done | `config/routes.rb` line 2 |
| `after_sign_in_path_for` → decks | Done | `ApplicationController` lines 8-10 |
| `before_action :authenticate_user!` in DecksController | Done | `app/controllers/decks_controller.rb` line 2 |
| `sessions/new.html.erb` Tailwind styling | Done | Already uses project's form field + button classes |
| `registrations/new.html.erb` Tailwind styling | Done | Already uses project's form field + button classes |
| Flash message rendering in layout | Done | `application.html.erb` lines 44-49 |
| Solid Queue gem + `bin/jobs` + `config/queue.yml` | Done | `Gemfile`, `bin/jobs`, `config/queue.yml` |
| All application tables (songs, decks, lyrics, slides, deck_songs) | Done | `db/schema.rb` — all tables present, no migrations needed |

---

## What This Phase Actually Needs to Build

| Item | Work Required | Confidence |
|------|---------------|------------|
| Nav bar fix: "Praise Project" (with space) as text | 1-line change in `application.html.erb` | HIGH |
| Nav bar fix: user email in right section | Add `current_user.email` span to nav | HIGH |
| Nav bar fix: "Logout" label (not "Sign out") | 1-line change | HIGH |
| Nav bar fix: hide on Devise pages | Wrap `<nav>` in `unless devise_controller?` | HIGH |
| Nav bar fix: Decks + Songs moved to right side per spec | Restructure nav flex layout | HIGH |
| `passwords/new.html.erb` Tailwind styling | Full view rewrite (currently raw HTML) | HIGH |
| Add "Praise Project" app name heading to all 3 auth pages | Edit 3 view files | HIGH |
| `SongsController` already has `before_action :authenticate_user!` | Already done — verify in test | HIGH |
| Solid Queue in dev: `queue_adapter` in development.rb | 1-line config change | HIGH |
| Solid Queue in dev: add `jobs: bin/jobs` to Procfile.dev | 1-line Procfile change | HIGH |
| Solid Queue smoke test: create `SmokeTestJob` and verify execution | New job class + manual verification | HIGH |
| `mailer_sender` in devise.rb | Set to real/valid email address | HIGH |
| Auth controller tests with Devise helpers | New test methods in controller test files | HIGH |
| User fixture with encrypted password | Update `test/fixtures/users.yml` | HIGH |
| Empty state text on decks index | Check current text vs. spec — minor wording fix | MEDIUM |
| Empty state text on songs index | Check current text vs. spec — minor wording fix | MEDIUM |

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| Devise `devise_controller?` unavailable | Available in all Devise versions | Use it to hide nav on auth pages |
| Solid Queue separate gem | Rails 8 built-in | Already installed; no separate gem needed |
| `SOLID_QUEUE_IN_PUMA` env var | Separate `bin/jobs` process in Procfile.dev | More visible in dev; clear separation |

---

## Open Questions

1. **Development mailer delivery method**
   - What we know: `development.rb` does not configure a delivery method — Rails defaults to `:smtp` in production but development typically uses `:test` or `:letter_opener`.
   - What's unclear: Should `letter_opener` gem be added so password reset emails are previewable in dev, or is `:test` (log-only) sufficient for this phase?
   - Recommendation: Use `:letter_opener` if we want to manually verify the reset email link works in dev. Use `:test` (already default in test env) for automated tests. This is Claude's discretion per CONTEXT.md.

2. **Solid Queue: in-puma vs. separate process in development**
   - What we know: `puma.rb` already has `plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]`. Setting this env var would avoid needing `foreman`.
   - What's unclear: Which pattern does the team prefer for dev workflow?
   - Recommendation: Use Procfile.dev + `bin/dev` (foreman) pattern — it keeps the worker visible as a separate process in the terminal, making job execution easier to confirm. This aligns with the "confirmed via job execution" success criterion.

---

## Validation Architecture

> nyquist_validation is enabled in .planning/config.json.

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Minitest (Rails default) |
| Config file | `test/test_helper.rb` |
| Quick run command | `rails test test/controllers/` |
| Full suite command | `rails test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| AUTH-01 | Unauthenticated GET /users/sign_up returns 200 | integration | `rails test test/controllers/registrations_controller_test.rb` | ❌ Wave 0 |
| AUTH-01 | POST /users with valid params redirects to decks | integration | `rails test test/controllers/registrations_controller_test.rb` | ❌ Wave 0 |
| AUTH-01 | POST /users with invalid params re-renders form | integration | `rails test test/controllers/registrations_controller_test.rb` | ❌ Wave 0 |
| AUTH-02 | Authenticated user GET /decks returns 200 (session persists) | integration | `rails test test/controllers/decks_controller_test.rb` | ✅ (needs Devise helpers fix) |
| AUTH-02 | Unauthenticated user GET /decks redirects to sign-in | integration | `rails test test/controllers/decks_controller_test.rb` | ✅ (needs implementation) |
| AUTH-02 | Unauthenticated user GET /songs redirects to sign-in | integration | `rails test test/controllers/songs_controller_test.rb` | ✅ (needs Devise helpers + test) |
| AUTH-03 | GET /users/password/new returns 200 | integration | `rails test test/controllers/passwords_controller_test.rb` | ❌ Wave 0 |
| AUTH-03 | POST /users/password with valid email enqueues reset | integration | `rails test test/controllers/passwords_controller_test.rb` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `rails test test/controllers/`
- **Per wave merge:** `rails test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/fixtures/users.yml` — add encrypted_password to fixture (currently `{}`)
- [ ] `test/controllers/registrations_controller_test.rb` — covers AUTH-01 signup flow
- [ ] `test/controllers/passwords_controller_test.rb` — covers AUTH-03 password reset request
- [ ] Fix `test/controllers/decks_controller_test.rb` — current tests use wrong route helpers and have no auth setup; needs `include Devise::Test::IntegrationHelpers` and `sign_in` calls
- [ ] Fix `test/controllers/songs_controller_test.rb` — same auth setup issues as decks

---

## Sources

### Primary (HIGH confidence)
- Codebase direct inspection — `app/models/user.rb`, `config/initializers/devise.rb`, `db/schema.rb`, `Gemfile`, `Procfile.dev`, `config/environments/development.rb`, `config/puma.rb`, `app/views/layouts/application.html.erb`, all Devise views, both controller files
- Rails 8.1 conventions — Solid Queue built-in, Procfile.dev via foreman/bin/dev pattern

### Secondary (MEDIUM confidence)
- Devise 5.x `devise_controller?` helper — well-documented standard helper available in all Devise layouts
- `Devise::Test::IntegrationHelpers` — standard Devise test pattern, included in Devise gem

### Tertiary (LOW confidence)
- None — all findings are directly verifiable from the codebase or established Rails/Devise patterns.

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all gems confirmed in Gemfile and schema
- Architecture: HIGH — all patterns are from existing codebase conventions or Devise documentation
- Pitfalls: HIGH — identified from direct inspection of existing code gaps (missing nav guard, missing `mailer_sender`, missing Procfile.dev entry)

**Research date:** 2026-03-08
**Valid until:** 2026-04-08 (stable stack; Devise and Rails 8.1 are not fast-moving targets)
