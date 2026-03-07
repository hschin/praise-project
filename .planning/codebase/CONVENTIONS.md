# Coding Conventions

**Analysis Date:** 2026-03-07

## Naming Patterns

**Files:**
- Ruby models: `snake_case.rb` matching class name (e.g., `deck_song.rb` → `DeckSong`)
- Ruby controllers: `snake_case_controller.rb` (e.g., `deck_songs_controller.rb`)
- ERB views: `snake_case.html.erb`, partials prefixed with `_` (e.g., `_form.html.erb`)
- JavaScript Stimulus controllers: `snake_case_controller.js` (e.g., `hello_controller.js`)
- Test files: `snake_case_test.rb` mirroring the class under test

**Classes:**
- Models: `PascalCase` inheriting from `ApplicationRecord` (e.g., `DeckSong < ApplicationRecord`)
- Controllers: `PascalCase` + `Controller` suffix inheriting from `ApplicationController` (e.g., `DecksController < ApplicationController`)
- Test classes: `PascalCase` + `Test` suffix (e.g., `SongTest < ActiveSupport::TestCase`)

**Database / Attributes:**
- Column names: `snake_case` (e.g., `section_type`, `default_key`, `deck_songs`)
- Join tables use combined resource names (e.g., `deck_songs` for Deck ↔ Song)

**Routes:**
- RESTful resource names are plural (e.g., `resources :decks`, `resources :songs`)
- Nested resources use scope of parent (e.g., `deck_deck_songs_path`)

## Code Style

**Formatting:**
- Rubocop with `rubocop-rails-omakase` ruleset (Rails default style guide)
- Config: `/Users/hschin/Dev/praise-project/.rubocop.yml` — inherits omakase, no overrides active
- Two-space indentation (Ruby standard)
- Single quotes for strings in Ruby where interpolation not needed (omakase default)

**Linting:**
- Tool: `rubocop-rails-omakase`
- Security scanning: `brakeman` (available in dev/test group)
- Dependency auditing: `bundler-audit` (available in dev/test group)

## Controller Patterns

**Standard CRUD layout (`app/controllers/songs_controller.rb`, `app/controllers/decks_controller.rb`):**
- `before_action :authenticate_user!` at top of every controller — all actions require login
- `before_action :set_<resource>` scoped to relevant actions via `only:`
- Standard 7 RESTful actions (index, show, new, create, edit, update, destroy)
- `set_<resource>` private method uses `find(params[:id])` or scoped `current_user.<association>.find(...)`
- Strong parameters defined in private `<resource>_params` method

**Ownership scoping:**
- User-owned resources always scoped through `current_user` (e.g., `current_user.decks.find(...)`, never bare `Deck.find(...)`)
- Shared resources (e.g., `Song`) use bare model class with no user scope

**Response patterns:**
- Successful save: `redirect_to @resource, notice: "Action description."`
- Failed save: `render :action, status: :unprocessable_entity`
- Nested resource failures: `redirect_to @parent, alert: "Could not do action."`
- Destroy: always redirects to index or parent, never renders

**Flash messages:**
- Use `:notice` for success (green in layout)
- Use `:alert` for failure (red in layout)
- Terse, past-tense phrasing: "Song created.", "Deck updated.", "Song removed from deck."

## Model Patterns

**Associations (`app/models/*.rb`):**
- `has_many` with ordered scope lambda: `has_many :lyrics, -> { order(position: :asc) }, dependent: :destroy`
- `belongs_to` is required by default (Rails 5+ behavior)
- Optional associations explicitly marked: `belongs_to :lyric, optional: true`
- Through associations used for many-to-many: `has_many :songs, through: :deck_songs`

**Validations:**
- `validates :field, presence: true` — minimal, explicit validations only
- One validation per field, not chained
- No custom validators present

**Comments:**
- Inline comments in models explain non-obvious data structures (e.g., `arrangement` array semantics in `app/models/deck_song.rb`)

## View Patterns

**ERB templates (`app/views/**/*.html.erb`):**
- Partials used for shared form markup (`_form.html.erb` per resource)
- Instance variables from controller (`@deck`, `@song`) used directly in views
- Inline Tailwind CSS classes — no separate CSS modules
- Conditional rendering with `if resource.field.present?` or `if collection.any?`
- Empty states always provided with a helpful message and a link

**Tailwind conventions:**
- Indigo (`indigo-600`) for primary actions and links
- Red (`red-500`) for destructive actions
- Gray palette for secondary text and borders
- Consistent button style: `"bg-indigo-600 text-white text-sm px-4 py-2 rounded hover:bg-indigo-700"`
- Form fields: `"w-full border border-gray-300 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"`

**Destructive actions:**
- Use `button_to` with `method: :delete` (not `link_to`)
- Always include `data: { turbo_confirm: "Confirm message?" }` for user confirmation

**Layout (`app/views/layouts/application.html.erb`):**
- Flash notices/alerts rendered globally in layout, not per-view
- `max-w-5xl mx-auto px-6 py-8` container in `<main>`

## Import Organization

**Ruby:**
- No explicit import ordering rules; `require "test_helper"` at top of test files
- No aliasing patterns observed

**JavaScript:**
- Stimulus controllers: `import { Controller } from "@hotwired/stimulus"` first line
- Single default export per controller file: `export default class extends Controller { ... }`

## Error Handling

**Strategy:**
- Model validation errors surfaced via `model.errors.full_messages` in `_form.html.erb` partials
- No custom exception classes or `rescue` blocks present in application code
- Controller actions follow Rails `if resource.save / else render` convention — no exceptions raised manually
- Authentication errors handled by Devise (redirect to sign-in)

## Logging

**Framework:** Rails default logger (`Rails.logger`)

**Patterns:**
- No explicit application logging observed in current code
- Rails request logging available in `log/` directory

## Comments

**When to Comment:**
- Only when data structure semantics are non-obvious (see `arrangement` field comment in `app/models/deck_song.rb`)
- No JSDoc or RDoc annotations present
- Inline `# PPTX generation — to be implemented` used for stubs

## Function Design

**Size:** Controller actions are minimal; business logic not yet extracted to service objects

**Private methods:** All non-action methods in controllers placed under explicit `private` keyword

**Parameters:** Strong parameters pattern — `params.require(:model).permit(...)` always defined as private method

---

*Convention analysis: 2026-03-07*
