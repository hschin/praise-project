# Codebase Structure

**Analysis Date:** 2026-03-07

## Directory Layout

```
praise-project/
├── app/
│   ├── assets/
│   │   ├── builds/            # Compiled Tailwind CSS (generated, committed)
│   │   ├── images/            # Static images
│   │   ├── stylesheets/       # application.css (Propshaft)
│   │   └── tailwind/          # Tailwind source: application.css
│   ├── controllers/
│   │   ├── concerns/          # Shared controller modules (empty)
│   │   ├── application_controller.rb
│   │   ├── deck_songs_controller.rb
│   │   ├── decks_controller.rb
│   │   └── songs_controller.rb
│   ├── helpers/
│   │   └── application_helper.rb
│   ├── javascript/
│   │   └── controllers/       # Stimulus controllers
│   │       ├── application.js
│   │       ├── hello_controller.js
│   │       └── index.js
│   ├── jobs/
│   │   └── application_job.rb
│   ├── mailers/
│   │   └── application_mailer.rb
│   ├── models/
│   │   ├── concerns/          # Shared model modules (empty)
│   │   ├── application_record.rb
│   │   ├── deck.rb
│   │   ├── deck_song.rb
│   │   ├── lyric.rb
│   │   ├── slide.rb
│   │   ├── song.rb
│   │   └── user.rb
│   └── views/
│       ├── decks/             # Deck CRUD views + _form partial
│       ├── deck_songs/        # (empty — no dedicated views)
│       ├── devise/            # Auth views (sessions, registrations, passwords)
│       ├── layouts/           # application.html.erb, mailer layouts
│       ├── pwa/               # manifest.json.erb, service-worker.js
│       └── songs/             # Song CRUD views + _form partial
├── bin/                       # Executable scripts (rails, puma, jobs, etc.)
├── config/
│   ├── environments/          # development.rb, production.rb, test.rb
│   ├── initializers/          # devise.rb, assets.rb, CSP, etc.
│   ├── locales/               # i18n YAML files
│   ├── routes.rb              # All route definitions
│   └── application.rb         # App config
├── db/
│   ├── migrate/               # Timestamped migration files
│   ├── schema.rb              # Canonical schema (auto-generated)
│   ├── queue_schema.rb        # Solid Queue tables
│   ├── cable_schema.rb        # Solid Cable tables
│   ├── cache_schema.rb        # Solid Cache tables
│   └── seeds.rb               # Seed data
├── lib/
│   └── tasks/                 # Custom Rake tasks (empty)
├── public/                    # Static public assets (icons, 404, etc.)
├── storage/                   # ActiveStorage local file storage
├── test/
│   ├── controllers/           # Controller tests (Minitest)
│   ├── fixtures/              # YAML fixture files per model
│   ├── helpers/               # Helper tests (empty)
│   ├── integration/           # Integration tests (empty)
│   ├── mailers/               # Mailer tests (empty)
│   ├── models/                # Model unit tests
│   └── test_helper.rb
├── tmp/                       # Cache, pids, sockets (not committed)
├── vendor/javascript/         # Vendored JS packages (importmap)
├── .kamal/                    # Kamal deployment hooks
├── .github/workflows/         # CI workflow definitions
├── agent-os/standards/        # Agent OS convention files
├── CLAUDE.md                  # Claude AI project instructions
├── Gemfile / Gemfile.lock
├── Dockerfile
├── Procfile.dev               # Dev process definitions
├── Rakefile
└── config.ru
```

## Directory Purposes

**`app/models/`:**
- Purpose: ActiveRecord models — domain logic, associations, validations
- Contains: One file per model, named after the singular entity
- Key files: `deck.rb`, `deck_song.rb`, `song.rb`, `lyric.rb`, `slide.rb`, `user.rb`

**`app/controllers/`:**
- Purpose: Handle HTTP actions, authenticate users, set instance variables for views
- Contains: One controller per resource; `application_controller.rb` as the base
- Key files: `decks_controller.rb`, `songs_controller.rb`, `deck_songs_controller.rb`

**`app/views/`:**
- Purpose: ERB templates rendered by controllers
- Contains: One subdirectory per resource; shared partials prefixed with `_`
- Key files: `layouts/application.html.erb` (root layout), `decks/show.html.erb` (primary deck management UI)

**`app/javascript/controllers/`:**
- Purpose: Stimulus controllers for client-side interactivity
- Contains: `*_controller.js` files auto-loaded via `eagerLoadControllersFrom`
- Key files: `index.js` (auto-discovery entry point)

**`app/assets/tailwind/`:**
- Purpose: Tailwind CSS source file processed by `tailwindcss-rails`
- Output: Compiled to `app/assets/builds/tailwind.css`

**`config/`:**
- Purpose: All Rails and gem configuration
- Key files: `routes.rb` (URL routing), `initializers/devise.rb` (auth config)

**`db/`:**
- Purpose: Database schema and migrations
- Key files: `schema.rb` (source of truth for current schema), `migrate/` (incremental changes)

**`lib/tasks/`:**
- Purpose: Custom Rake tasks
- Currently empty — planned location for PPTX generation support tasks

**`test/`:**
- Purpose: Minitest tests
- Contains: Mirrors `app/` structure; `fixtures/` holds YAML test data per model

**`storage/`:**
- Purpose: Local ActiveStorage file storage (development/test)
- Generated: Yes (runtime)
- Committed: No (only `.keep` placeholder)

**`vendor/javascript/`:**
- Purpose: Importmap-pinned JavaScript packages served locally
- Generated: No — manually vendored via `bin/importmap pin`
- Committed: Yes

## Key File Locations

**Entry Points:**
- `config.ru`: Rack entry point, boots Rails
- `config/routes.rb`: All URL-to-controller mappings
- `app/views/layouts/application.html.erb`: Root HTML layout

**Configuration:**
- `Gemfile`: Ruby gem dependencies
- `config/initializers/devise.rb`: Devise authentication settings
- `config/initializers/content_security_policy.rb`: CSP headers
- `.ruby-version`: Ruby version pin for rbenv

**Core Logic:**
- `app/models/deck.rb`: Primary domain entity (a worship service)
- `app/models/deck_song.rb`: Join model with arrangement logic
- `app/controllers/decks_controller.rb`: Primary CRUD + export stub
- `db/schema.rb`: Complete current database schema

**Testing:**
- `test/test_helper.rb`: Test configuration and setup
- `test/fixtures/`: YAML data fixtures for all six models
- `test/models/`: Unit tests for each model
- `test/controllers/`: Controller tests for decks, songs, deck_songs

## Naming Conventions

**Files:**
- Models: `snake_case.rb` singular — e.g., `deck_song.rb`, `lyric.rb`
- Controllers: `snake_case_controller.rb` plural resource — e.g., `decks_controller.rb`
- Views: `action_name.html.erb`; partials prefixed with `_` — e.g., `_form.html.erb`
- Migrations: `YYYYMMDDHHMMSS_verb_noun.rb` — e.g., `20260307132252_create_deck_songs.rb`
- Tests: mirror source file names with `_test.rb` suffix — e.g., `deck_test.rb`
- Stimulus controllers: `name_controller.js`

**Directories:**
- Views grouped by resource name (plural) matching controller name
- Test subdirectories mirror `app/` subdirectory structure

## Where to Add New Code

**New Resource (e.g., `Setlist`):**
- Model: `app/models/setlist.rb`
- Controller: `app/controllers/setlists_controller.rb`
- Views: `app/views/setlists/` (index, show, new, edit, `_form`)
- Route: Add `resources :setlists` to `config/routes.rb`
- Migration: `rails g migration CreateSetlists ...`
- Tests: `test/models/setlist_test.rb`, `test/controllers/setlists_controller_test.rb`, `test/fixtures/setlists.yml`

**New Stimulus Controller:**
- Implementation: `app/javascript/controllers/name_controller.js`
- Auto-discovered by `eagerLoadControllersFrom` — no manual registration needed

**New Background Job:**
- Implementation: `app/jobs/name_job.rb` (inherit from `ApplicationJob`)
- Enqueue via: `NameJob.perform_later(args)`

**New Rake Task:**
- Implementation: `lib/tasks/name.rake`

**New Model Concern:**
- Implementation: `app/models/concerns/concern_name.rb`
- Include in model: `include ConcernName`

**New Controller Concern:**
- Implementation: `app/controllers/concerns/concern_name.rb`

**Python Integration Script:**
- Target location: `lib/pptx_generator/` (planned, not yet created)
- Called via Rails subprocess from `DecksController#export`

**Utilities / Shared Helpers:**
- View helpers: `app/helpers/application_helper.rb` (or resource-specific `*_helper.rb`)
- Rake tasks: `lib/tasks/`

## Special Directories

**`tmp/`:**
- Purpose: Runtime cache (Bootsnap), PIDs, sockets, temp file storage
- Generated: Yes (runtime)
- Committed: No

**`app/assets/builds/`:**
- Purpose: Compiled Tailwind CSS output
- Generated: Yes (by `tailwindcss-rails` watcher)
- Committed: Yes (checked in so production does not require build step)

**`agent-os/standards/`:**
- Purpose: Agent OS convention and standards files for AI-assisted development
- Generated: No
- Committed: Yes

**`.kamal/`:**
- Purpose: Kamal deployment hooks and configuration
- Generated: No
- Committed: Yes

---

*Structure analysis: 2026-03-07*
