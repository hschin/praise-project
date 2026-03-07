# Architecture

**Analysis Date:** 2026-03-07

## Pattern Overview

**Overall:** Rails MVC (Model-View-Controller) with server-rendered HTML via Hotwire

**Key Characteristics:**
- Full server-side rendering with Turbo Drive for SPA-like navigation (no full page reloads)
- Thin controllers that delegate validation and persistence to ActiveRecord models
- Authentication via Devise wrapping all resource routes
- PPTX export planned as a subprocess call to a Python script (`lib/pptx_generator/`) — not yet implemented; `DecksController#export` currently stubs `head :ok`
- Background jobs via Solid Queue (Rails 8 built-in) for any async work (no jobs defined yet beyond `ApplicationJob`)

## Layers

**Models (ActiveRecord):**
- Purpose: Domain logic, associations, validations, database persistence
- Location: `app/models/`
- Contains: `User`, `Deck`, `Song`, `Lyric`, `DeckSong`, `Slide`, `ApplicationRecord`
- Depends on: PostgreSQL via `pg` gem
- Used by: Controllers

**Controllers:**
- Purpose: Route actions to models and views; enforce authentication; shape params
- Location: `app/controllers/`
- Contains: `ApplicationController`, `DecksController`, `SongsController`, `DeckSongsController`
- Depends on: Models, Devise helpers (`authenticate_user!`, `current_user`)
- Used by: Rails router (`config/routes.rb`)

**Views (ERB + Hotwire):**
- Purpose: Render HTML responses; form submission via Turbo
- Location: `app/views/`
- Contains: ERB templates per resource (`decks/`, `songs/`, `devise/`, `layouts/`)
- Depends on: Controllers (instance variables), helpers, layout
- Used by: Controllers (rendered automatically by Rails convention)

**JavaScript (Stimulus):**
- Purpose: Lightweight client-side behavior attached to existing HTML
- Location: `app/javascript/controllers/`
- Contains: `application.js`, `index.js`, `hello_controller.js` (scaffold stub)
- Depends on: `@hotwired/stimulus`, importmap-rails
- Used by: Views (via `data-controller` attributes)

**Database / Schema:**
- Purpose: Persistent storage, foreign key integrity, JSONB for flexible arrangement data
- Location: `db/schema.rb`, `db/migrate/`
- Contains: Six tables: `users`, `decks`, `songs`, `lyrics`, `deck_songs`, `slides`
- Additional schema files: `db/queue_schema.rb` (Solid Queue), `db/cable_schema.rb` (Solid Cable), `db/cache_schema.rb` (Solid Cache)

**Library / External Integration Layer:**
- Purpose: House the planned Python-based PPTX generation script
- Location: `lib/` (currently empty aside from `lib/tasks/`)
- Contains: Placeholder for `lib/pptx_generator/` Python script (not yet created)

## Data Flow

**Standard CRUD Request:**

1. Browser sends HTTP request (Turbo Drive intercepts for non-GET forms)
2. Rails router (`config/routes.rb`) dispatches to controller action
3. Controller authenticates via `authenticate_user!` (Devise `before_action`)
4. Controller queries model: e.g., `current_user.decks.find(params[:id])`
5. Model executes SQL via ActiveRecord, returns object(s)
6. Controller renders ERB template with instance variables
7. Turbo Drive swaps the `<body>` in-place; no full page reload

**Deck → PPTX Export (planned, not yet implemented):**

1. User clicks "Export PPTX" button on `decks/show`
2. POST to `export_deck_path` → `DecksController#export`
3. Controller serializes `Deck` (with songs, lyrics, arrangement) to JSON
4. Rails invokes Python subprocess (`lib/pptx_generator/` script)
5. Script returns path to generated `.pptx` file
6. Controller sends file as download response

**State Management:**
- Server-authoritative: All state stored in PostgreSQL
- `DeckSong#arrangement` persists the ordered lyric sequence as a JSONB array of lyric IDs (supports repeated sections, e.g. chorus twice)
- No client-side state store; Turbo Drive maintains scroll position and history

## Key Abstractions

**Deck:**
- Purpose: Represents one church worship service session; owns an ordered list of songs
- Files: `app/models/deck.rb`, `app/controllers/decks_controller.rb`, `app/views/decks/`
- Pattern: Standard Rails resource; scoped to `current_user` on all queries

**DeckSong (join model with behavior):**
- Purpose: Links a `Song` to a `Deck` with per-instance data: position, performance key, and lyric arrangement
- Files: `app/models/deck_song.rb`, `app/controllers/deck_songs_controller.rb`
- Pattern: Enriched join model; `arrangement` column is a JSONB array of lyric IDs (order + repetition)

**Song + Lyric (shared library):**
- Purpose: `Song` is a reusable library entry; `Lyric` represents a named section (verse/chorus/bridge) with content and optional pinyin
- Files: `app/models/song.rb`, `app/models/lyric.rb`
- Pattern: Songs are global (not user-scoped); lyrics ordered by `position`

**Slide:**
- Purpose: Individual presentation slide tied to a `DeckSong`; optionally linked to a `Lyric`
- Files: `app/models/slide.rb`
- Pattern: `lyric_id` is nullable (allows non-lyric slides like title or blank); foreign key uses `on_delete: :nullify`

## Entry Points

**Web Server:**
- Location: `config.ru` → Puma via `bin/puma`
- Triggers: HTTP request
- Responsibilities: Boots Rails app, serves all routes

**Router:**
- Location: `config/routes.rb`
- Triggers: Every inbound request
- Responsibilities: Maps URLs to controller actions; root is `decks#index`; `devise_for :users` mounts auth routes

**Background Job Worker:**
- Location: `bin/jobs` → Solid Queue
- Triggers: `bin/jobs` process start
- Responsibilities: Process enqueued ActiveJob jobs from the database queue

**Application Layout:**
- Location: `app/views/layouts/application.html.erb`
- Triggers: Every HTML response
- Responsibilities: Renders nav, flash messages, loads Tailwind CSS and importmap JS, yields page content

## Error Handling

**Strategy:** Rails default — model validation errors re-render the form with `status: :unprocessable_entity`; no custom error pages defined

**Patterns:**
- Controller `if @model.save / else render` pattern for create/update
- `redirect_to ..., alert:` for operational failures (e.g., song not added to deck)
- Flash `notice` for success confirmations rendered in application layout

## Cross-Cutting Concerns

**Authentication:** Devise — all resource controllers require `before_action :authenticate_user!`; `current_user` scopes all deck queries; songs are not user-scoped (global library)

**Validation:** ActiveRecord model validations: `presence` on all required fields; uniqueness enforced at DB level (email index on users)

**Logging:** Rails default logger (`log/` directory); no custom log configuration

**Assets:** Propshaft pipeline; Tailwind CSS via `tailwindcss-rails`; JavaScript via `importmap-rails` (no Node/Webpack)

---

*Architecture analysis: 2026-03-07*
