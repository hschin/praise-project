# Phase 3: Deck Editor - Research

**Researched:** 2026-03-12
**Domain:** Rails 8 + Hotwire + SortableJS drag-and-drop, JSONB arrangement, Theme model, Unsplash API, ActiveStorage image upload, CSS slide preview
**Confidence:** HIGH (stack is well-understood; all critical patterns verified against official docs or existing codebase)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Slides are **read-only** within the deck editor — no inline text editing
- Each song block in the deck shows an "Edit lyrics →" link that opens the song's edit page (in new tab)
- To change slide content, users go to the song library; changes propagate to all decks using that song
- No per-deck Slide content override needed
- When a song is added to a deck, `DeckSong.arrangement` is initialized from the song's lyrics in natural position order
- User can reorder slides within a song using drag-and-drop (same SortableJS instance as song reordering)
- Removing a slide permanently removes its lyric ID from `DeckSong.arrangement` — no soft-hide/toggle
- Repeating a section: each slide card has a "+ Repeat" button that appends a duplicate lyric ID to the arrangement (SLIDE-05)
- **Drag-and-drop for everything**: SortableJS for both song reordering in the deck and slide reordering within songs
- Consistent interaction — same pattern at both levels
- Fires a Turbo request to persist new positions to the server
- CSS simulation: 16:9 styled rectangle with theme background color/image, large centered Chinese text, pinyin displayed above characters (ruby-style)
- Labeled "Approximate Preview" — user is aware it may not be pixel-perfect vs. the PPTX
- Inline below the slide arrangement list on the deck page — always visible, no extra click
- Pinyin always shown in preview thumbnails (regardless of song view toggle state)
- Separate `Theme` table (not JSONB on Deck) — allows reusing themes across decks in future
- `Deck` belongs_to `Theme` (optional — deck can have no theme assigned)
- Theme attributes: `background_color`, `text_color`, `font_size`, `background_image` (ActiveStorage attachment), `name`, `source` (ai/custom), `unsplash_url`
- "Get AI suggestions" triggers a background job — Claude returns 5 theme suggestions with Unsplash photo URLs
- Suggestions render as a horizontal scrollable row inline on the deck edit page (no modal)
- Each card shows: Unsplash thumbnail, suggested colors as swatches, theme name
- User clicks a card to apply — creates a Theme record and associates it with the deck
- Custom theme form on the deck edit page: background color picker/hex input, text color picker/hex input, font size (small/medium/large presets)
- Background image upload (THEME-03): file upload stored via ActiveStorage — replaces background_color when present
- All three (THEME-01, 02, 03) feed into the same Theme model; AI suggestions are just pre-filled Theme records

### Claude's Discretion
- Exact SortableJS configuration and Stimulus controller structure
- CSS details for the 16:9 preview thumbnails (shadow, rounded corners, scale)
- Font size pixel values for the small/medium/large presets
- Color picker implementation (native HTML input[type=color] is fine)
- How arrangement updates are sent to the server (PATCH with JSON array vs. individual position params)

### Deferred Ideas (OUT OF SCOPE)
- Theme library UI (browse/reuse saved themes across decks) — future phase; Theme table structure supports it
- Visual pixel-perfect preview via PPTX thumbnail generation — Phase 4 (once PPTX pipeline exists)
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SLIDE-01 | User can edit slide Chinese text and pinyin inline | LOCKED OUT OF SCOPE for this phase — slides are read-only in the deck; editing goes to song library |
| SLIDE-02 | User can reorder slides within a song in the deck | SortableJS nested controller on slide list within each DeckSong block; PATCH to arrangement update action |
| SLIDE-03 | User can delete or hide individual slides from the deck | Remove lyric ID from `DeckSong.arrangement` array; button_to DELETE to arrangement update or dedicated remove action |
| SLIDE-04 | User can preview slides in the browser before export | CSS 16:9 aspect-ratio div; HTML `<ruby>` element (already proven in `_lyrics.html.erb`) for pinyin |
| SLIDE-05 | User can repeat sections within a song | "+ Repeat" button POSTs to append duplicate lyric ID to arrangement; same arrangement PATCH pattern |
| DECK-01 | User can create a deck with date pre-filled to upcoming Sunday | `Date.today.next_occurring(:sunday)` or similar in `new` action; existing Deck CRUD already in place |
| DECK-02 | User can add songs from the library to a deck in order | Already exists in `DeckSongsController#create`; extend to initialize arrangement from song lyrics |
| DECK-03 | User can reorder songs within a deck | SortableJS on song list; PATCH reorder action on `DeckSong.position` |
| DECK-04 | User can remove a song from a deck without deleting it from the library | Already exists in `DeckSongsController#destroy` |
| THEME-01 | AI-generated theme suggestions (5 themes with Unsplash photos) | Background job calls Claude with theme prompt; Turbo Stream broadcasts cards to deck page; Unsplash photo URLs stored in `unsplash_url` |
| THEME-02 | Custom theme: background color, text color, font size | Native `input[type=color]` + select for font size presets; creates/updates Theme record on deck |
| THEME-03 | Upload own background image for deck theme | ActiveStorage `has_one_attached :background_image` on Theme; regular (not direct) upload via form |
</phase_requirements>

---

## Summary

Phase 3 builds the interactive deck-editing surface. The two highest-complexity areas are (1) SortableJS integration without npm (importmap-only) and (2) the AI theme suggestion pipeline. Both have established patterns in this codebase and ecosystem.

The `DeckSong.arrangement` JSONB column is already in the schema and documented. Its role as the authoritative slide order means the `Slide` table records are NOT needed for the deck editor view — the arrangement array plus a lookup of `Lyric` objects is sufficient. This simplifies the implementation significantly.

The Unsplash API has a 50 req/hr demo limit. Since AI theme suggestions are user-triggered and produce 5 results at a time, this limit is not a practical concern for internal church-team use. Attribution is required per Unsplash guidelines: each photo card must link back to the photographer's profile and to Unsplash with `?utm_source=praiseproject&utm_medium=referral`.

**Primary recommendation:** Build the deck editor on the existing `decks/show` view. Add a sortable Stimulus controller using SortableJS pinned via importmap (no npm). Use the existing Turbo broadcast pattern from `ImportSongJob` for the AI theme suggestion job. Reuse the `<ruby>` element pattern from `_lyrics.html.erb` for slide previews.

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SortableJS | 1.15.x | Drag-and-drop reordering | De facto standard for touch+mouse sortable lists; ESM module available for importmap |
| @rails/request.js | 0.0.9+ | Fetch wrapper that sends CSRF token + Turbo headers | Required for AJAX from Stimulus without Rails UJS; importmap-pinnable |
| Hotwire Turbo | bundled | Turbo Stream responses for arrangement updates | Already in project; use `respond_to :turbo_stream` for PATCH reorder actions |
| Stimulus | bundled | Sortable controller, color preview controller | Already in project; `eagerLoadControllersFrom` auto-registers new controllers |
| ActiveStorage | bundled | Theme background image upload | Already configured; `has_one_attached :background_image` on Theme model |
| Anthropic Ruby SDK | bundled | AI theme suggestion generation | Already used in `ClaudeLyricsService` |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| @rails/activestorage | bundled | Direct upload JS events | Only needed if showing upload progress bar; for simple file upload, standard form suffices |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| SortableJS via importmap | stimulus-sortable npm package | stimulus-sortable requires npm/yarn; importmap pin of sortablejs.esm.js is sufficient without adding build tooling |
| Regular ActiveStorage upload | Direct upload | Direct upload sends file to storage before form submit, better for large files; for background images (photos), regular upload is simpler and sufficient |
| Unsplash API | Pre-seeded photo URLs | Unsplash API gives real church-appropriate photos on demand; pre-seeding is brittle |

**Installation (importmap pins to add):**
```ruby
# config/importmap.rb
pin "sortablejs", to: "https://cdn.jsdelivr.net/npm/sortablejs@1.15.2/modular/sortable.esm.js"
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.9/src/index.js"
```

No gem additions needed for drag-and-drop. These are CDN ESM pins.

---

## Architecture Patterns

### Recommended File Structure (new files only)
```
app/
├── models/
│   └── theme.rb                        # Theme model with has_one_attached
├── controllers/
│   ├── themes_controller.rb            # create, update (apply to deck)
│   └── deck_songs_controller.rb        # extend: initialize arrangement on create
│                                       # add: reorder action (PATCH positions)
│                                       # add: arrangement update action (slide reorder/remove/repeat)
├── jobs/
│   └── generate_theme_suggestions_job.rb  # Calls Claude, broadcasts 5 theme cards
├── services/
│   └── claude_theme_service.rb         # Claude API call for 5 theme JSON suggestions
├── views/
│   ├── decks/
│   │   └── show.html.erb               # Extend: song DnD, slide lists, preview, theme UI
│   ├── themes/
│   │   ├── _suggestion_card.html.erb   # Individual AI theme card partial
│   │   └── _form.html.erb              # Custom theme form
│   └── deck_songs/
│       └── _slide_item.html.erb        # Single draggable slide card with preview
└── javascript/controllers/
    ├── sortable_controller.js          # SortableJS Stimulus controller (songs + slides)
    └── color_preview_controller.js     # Live preview of color picker changes on slide preview
db/migrate/
    ├── YYYYMMDD_create_themes.rb
    └── YYYYMMDD_add_theme_to_decks.rb
```

### Pattern 1: SortableJS via Importmap + Stimulus

**What:** Pin SortableJS ESM module to importmap; write a single Stimulus controller that handles both song-level and slide-level reordering by reading the PATCH URL from a data attribute.

**When to use:** Anywhere items need drag-and-drop reordering with server persistence. Same controller handles both the song list and each per-song slide list.

**Example:**
```javascript
// app/javascript/controllers/sortable_controller.js
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import { patch } from "@rails/request.js"

export default class extends Controller {
  static values = { url: String, param: { type: String, default: "position" } }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: "[data-drag-handle]",
      onEnd: this.onEnd.bind(this)
    })
  }

  disconnect() {
    this.sortable.destroy()
  }

  async onEnd(event) {
    const id = event.item.dataset.id
    const url = this.urlValue.replace(":id", id)
    await patch(url, {
      body: JSON.stringify({ [this.paramValue]: event.newIndex + 1 }),
      contentType: "application/json",
      responseKind: "turbo-stream"
    })
  }
}
```

HTML usage:
```erb
<%# Song list — reorder DeckSong positions %>
<div data-controller="sortable"
     data-sortable-url-value="<%= reorder_deck_deck_song_path(@deck, ':id') %>"
     class="space-y-3">
  <% @deck.deck_songs.each do |ds| %>
    <div data-id="<%= ds.id %>" class="...">
      <span data-drag-handle class="cursor-grab">⣿</span>
      ...
    </div>
  <% end %>
</div>
```

### Pattern 2: DeckSong.arrangement JSONB — Initialize and Mutate

**What:** When a song is added to a deck, populate `arrangement` from the song's lyrics in position order. For slide reorder/remove/repeat, replace the entire array in a single PATCH.

**When to use:** All arrangement mutations go through `DeckSongsController#update_arrangement`. Never mutate individual positions; replace the whole array atomically.

**Example:**
```ruby
# In DeckSongsController#create (extend existing)
def create
  @deck_song = @deck.deck_songs.new(song_id: params[:song_id], key: params[:key])
  @deck_song.position = @deck.deck_songs.count + 1
  @deck_song.arrangement = @deck_song.song.lyrics.order(:position).pluck(:id)
  # ...
end

# New action: update_arrangement
def update_arrangement
  @deck_song = @deck.deck_songs.find(params[:id])
  new_arrangement = params[:arrangement]  # Array of lyric IDs
  @deck_song.update!(arrangement: new_arrangement)
  head :ok
end
```

Routes:
```ruby
resources :deck_songs, only: [:create, :update, :destroy] do
  member do
    patch :reorder          # song position in deck
    patch :update_arrangement  # slide order within song
  end
end
```

JSONB array operations in Ruby (do NOT use raw SQL `||` operator — fetch, mutate, save):
```ruby
# Append a repeat
arr = deck_song.arrangement.dup   # [1, 2, 3]
arr.push(lyric_id)                # [1, 2, 3, 3]
deck_song.update!(arrangement: arr)

# Remove at index
arr = deck_song.arrangement.dup
arr.delete_at(index)
deck_song.update!(arrangement: arr)
```

### Pattern 3: AI Theme Suggestion — Background Job + Turbo Stream

**What:** Follows the same job + broadcast pattern as `ImportSongJob`. Controller enqueues job, sets up Turbo stream subscription, job calls Claude, broadcasts 5 theme card partials.

**When to use:** THEME-01 — user clicks "Get AI Suggestions."

**Example:**
```ruby
# app/jobs/generate_theme_suggestions_job.rb
class GenerateThemeSuggestionsJob < ApplicationJob
  queue_as :default

  def perform(deck_id)
    deck = Deck.find(deck_id)
    suggestions = ClaudeThemeService.call(deck: deck)
    Turbo::StreamsChannel.broadcast_update_to(
      "deck_themes_#{deck_id}",
      target: "theme_suggestions",
      partial: "themes/suggestion_row",
      locals: { suggestions: suggestions, deck: deck }
    )
  end
end
```

Claude theme prompt structure (JSON output):
```json
[
  {
    "name": "Heavenly Morning",
    "background_color": "#1a3a5c",
    "text_color": "#ffffff",
    "font_size": "medium",
    "unsplash_query": "sunrise worship church",
    "unsplash_url": "https://images.unsplash.com/photo-xxxx?..."
  }
]
```

The job fetches one Unsplash photo per suggestion using `/search/photos?query=...&per_page=1&orientation=landscape` and stores the `urls.regular` value as `unsplash_url`.

### Pattern 4: Theme Model + ActiveStorage

**What:** Standard Rails model with `has_one_attached` for background image; belongs to deck optionally.

```ruby
class Theme < ApplicationRecord
  belongs_to :deck, optional: true
  has_one_attached :background_image

  validates :name, presence: true
  validates :source, inclusion: { in: %w[ai custom] }

  FONT_SIZE_PRESETS = { "small" => 28, "medium" => 36, "large" => 48 }.freeze
end
```

Migration:
```ruby
create_table :themes do |t|
  t.string  :name,             null: false
  t.string  :source,           null: false, default: "custom"
  t.string  :background_color, default: "#000000"
  t.string  :text_color,       default: "#ffffff"
  t.string  :font_size,        default: "medium"
  t.string  :unsplash_url
  t.bigint  :deck_id
  t.timestamps
end
add_foreign_key :themes, :decks, on_delete: :nullify

# Separate migration for decks table
add_reference :decks, :theme, foreign_key: { on_delete: :nullify }, null: true
```

### Pattern 5: CSS 16:9 Slide Preview with HTML ruby Element

**What:** A fixed-aspect div using `aspect-ratio: 16/9` containing a scaled-down slide preview. Reuses the `<ruby>` element pattern already proven in `_lyrics.html.erb`.

**When to use:** SLIDE-04 — inline preview below each slide in the arrangement.

```erb
<%# Slide preview card %>
<div class="slide-preview w-48 rounded shadow-md overflow-hidden relative"
     style="aspect-ratio: 16/9;
            background-color: <%= @deck.theme&.background_color || '#000000' %>;
            <%= @deck.theme&.background_image&.attached? ? "background-image: url(#{url_for(@deck.theme.background_image)}); background-size: cover;" : '' %>">
  <div class="absolute inset-0 flex items-center justify-center p-2">
    <div class="text-center" style="color: <%= @deck.theme&.text_color || '#ffffff' %>; font-size: 0.6rem;">
      <% lyric = Lyric.find_by(id: lyric_id) %>
      <% if lyric %>
        <% content_lines = lyric.content.to_s.split("\n") %>
        <% pinyin_lines = lyric.pinyin.to_s.split("\n") %>
        <% content_lines.each_with_index do |line, li| %>
          <div>
            <% chars = line.chars %>
            <% tokens = (pinyin_lines[li] || "").split(" ") %>
            <% pi = 0 %>
            <% chars.each do |char| %>
              <% if char.match?(/\p{Han}/) %>
                <ruby><%= char %><rt style="font-size:0.5em"><%= tokens[pi] %></rt></ruby><% pi += 1 %>
              <% else %><%= char %><% end %>
            <% end %>
          </div>
        <% end %>
      <% end %>
    </div>
  </div>
</div>
<p class="text-xs text-gray-400 mt-1 text-center">Approximate Preview</p>
```

**Key insight on `<ruby>` element:** Browser support is universal for modern browsers. The pattern is already used in `_lyrics.html.erb`. Use inline `font-size` on `<rt>` tags to keep pinyin proportional at the small preview scale.

### Anti-Patterns to Avoid

- **Mutating JSONB with SQL `||` operator:** Fetch the array in Ruby, mutate it, and save. This keeps callbacks/validations active and avoids PostgreSQL-specific syntax.
- **Using `acts_as_list` gem for DeckSong positions:** This project does not use acts_as_list. Position reordering is done by updating `position` directly in the controller action — simpler, fewer dependencies.
- **Rendering the Slide table for deck editor view:** The `Slide` model exists but arrangement is authoritative. For the editor, render slides from `deck_song.arrangement.map { |id| Lyric.find_by(id: id) }`. Slide records are a projection for the export pipeline (Phase 4).
- **Calling Unsplash API inline in a controller:** Must be called inside `GenerateThemeSuggestionsJob` (same principle as ClaudeAPI calls — Thruster timeout risk noted in STATE.md).
- **Pinning stimulus-sortable via importmap:** The npm package `@stimulus-components/sortable` uses yarn installation. Write a custom Stimulus controller instead — it's ~25 lines and fully under project control.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Drag-and-drop with touch support | Custom mousedown/touchstart handlers | SortableJS | Handles touch, accessibility, cross-browser quirks, group nesting, ghost element |
| CSRF-safe AJAX from Stimulus | Custom fetch with CSRF token extraction | `@rails/request.js` `patch()` | Automatically adds CSRF token + `Accept: text/vnd.turbo-stream.html` header |
| File upload to ActiveStorage | Custom multipart form handler | `form.file_field :background_image` + `has_one_attached` | ActiveStorage handles storage routing, variant generation, signed URL generation |
| Color hex validation | Regex validator | Native `input[type=color]` | Always returns valid 6-char hex; no validation needed |
| Background job error handling | Manual retry logic | Solid Queue + ApplicationJob | Retry is configurable in ApplicationJob; already proven in ImportSongJob |

**Key insight:** The importmap-pinned SortableJS ESM module approach avoids any npm/build tooling changes while being functionally equivalent to a full npm install for this use case.

---

## Common Pitfalls

### Pitfall 1: Arrangement Array Contains Stale Lyric IDs
**What goes wrong:** If a lyric is deleted from the song library while a deck arrangement references it, `Lyric.find(id)` raises `ActiveRecord::RecordNotFound`.
**Why it happens:** The DB schema uses `on_delete: :nullify` for `slides.lyric_id`, but `deck_songs.arrangement` is a raw JSONB array — no FK constraint enforces validity.
**How to avoid:** Always use `Lyric.find_by(id: lyric_id)` (returns nil, not raise) when rendering arrangement items. Guard with `next if lyric.nil?` in view loops. Slide count should filter nil results.
**Warning signs:** NoMethodError on nil when calling `lyric.content` in views.

### Pitfall 2: SortableJS onEnd Fires with Same Position (No-Op)
**What goes wrong:** User grabs and drops without moving — `event.oldIndex == event.newIndex` — triggering an unnecessary PATCH request and potential flicker.
**Why it happens:** SortableJS fires `onEnd` even for zero-movement drops.
**How to avoid:** In the `onEnd` handler, guard with `if (event.oldIndex === event.newIndex) return;` before making the request.
**Warning signs:** Server logs showing redundant PATCH requests on every click of a draggable item.

### Pitfall 3: JSONB Column Returns Strings, Not Integers for Lyric IDs
**What goes wrong:** `deck_song.arrangement` returns `["1", "3", "2"]` instead of `[1, 3, 2]` after PATCH with JSON body.
**Why it happens:** Rails JSONB columns deserialize arrays as-is; if the client sends string IDs (e.g., from `dataset.id` in JS), they remain strings.
**How to avoid:** In the controller, cast before saving: `arrangement = params[:arrangement].map(&:to_i)`. In the model, add a before_save callback or serializer: `before_save { self.arrangement = arrangement&.map(&:to_i) }`.
**Warning signs:** `Lyric.find_by(id: "1")` works (Rails casts), but direct comparison `arrangement.include?(1)` fails when IDs are stored as strings.

### Pitfall 4: Unsplash Demo Rate Limit (50 req/hr)
**What goes wrong:** Multiple users clicking "Get AI Suggestions" in quick succession exhausts the hourly quota; subsequent requests return 403.
**Why it happens:** Demo apps are limited to 50 requests/hour. At 5 Unsplash searches per suggestion batch (one per theme), each click costs 5 requests.
**How to avoid:** Store Unsplash photo URLs after the first fetch (already done — `unsplash_url` column on Theme). Consider caching a set of pre-fetched Unsplash URLs for common worship keywords in development. For v1 internal use, 50 req/hr is unlikely to be hit.
**Warning signs:** Unsplash API returns HTTP 403 with `Rate Limit Exceeded` message in job logs.

### Pitfall 5: ActiveStorage URL Expiration in CSS `background-image`
**What goes wrong:** Inlining `url_for(theme.background_image)` in a CSS `style` attribute generates a signed URL that expires. On page reload hours later, the image shows as broken.
**Why it happens:** ActiveStorage signed URLs expire (default: 5 minutes for redirects in some configurations).
**How to avoid:** For the deck editor (a human interaction flow, not a cached page), this is acceptable — the page will be re-rendered from a fresh request. If caching is added later, use `rails_storage_proxy_url` with proxy mode configured.
**Warning signs:** Background image shows correctly on page load but breaks if the page is left open or cached.

### Pitfall 6: Turbo Stream Target Missing on First Load
**What goes wrong:** The AI theme suggestion job broadcasts to `theme_suggestions` target ID, but the target `<div id="theme_suggestions">` doesn't exist yet on the page (or has a different ID).
**Why it happens:** The Turbo Stream broadcast uses `update` action — if the target doesn't exist, the update is silently discarded.
**How to avoid:** Ensure the deck show page always renders `<div id="theme_suggestions"></div>` as a placeholder, even when empty. Use `broadcast_update_to` with the same channel key used in the view's `turbo_stream_from` tag.

---

## Code Examples

Verified patterns from official sources and existing codebase:

### Importmap pins for SortableJS and @rails/request.js
```ruby
# config/importmap.rb
pin "sortablejs", to: "https://cdn.jsdelivr.net/npm/sortablejs@1.15.2/modular/sortable.esm.js"
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.9/src/index.js"
```
Source: importmap-rails README; jsDelivr ESM distribution of sortablejs

### DeckSong.arrangement initialization on create
```ruby
# app/controllers/deck_songs_controller.rb
def create
  @deck_song = @deck.deck_songs.new(song_id: params[:song_id], key: params[:key])
  @deck_song.position = @deck.deck_songs.count + 1
  @deck_song.arrangement = @deck_song.song.lyrics.order(:position).pluck(:id)
  if @deck_song.save
    redirect_to @deck, notice: "Song added to deck."
  else
    redirect_to @deck, alert: "Could not add song."
  end
end
```

### Arrangement mutation — remove by index
```ruby
# Remove lyric at position index from arrangement
arr = deck_song.arrangement.dup
arr.delete_at(index.to_i)
deck_song.update!(arrangement: arr.map(&:to_i))
```

### Arrangement mutation — append repeat
```ruby
# Append lyric_id repeat to arrangement
arr = deck_song.arrangement.dup
arr.push(lyric_id.to_i)
deck_song.update!(arrangement: arr)
```

### Turbo Stream subscription in view (following ImportSongJob pattern)
```erb
<%# In decks/show.html.erb %>
<%= turbo_stream_from "deck_themes_#{@deck.id}" %>
<div id="theme_suggestions" class="flex gap-3 overflow-x-auto py-2"></div>
```

### ActiveStorage background image in inline style
```erb
<% if theme&.background_image&.attached? %>
  style="background-image: url(<%= url_for(theme.background_image) %>); background-size: cover;"
<% else %>
  style="background-color: <%= theme&.background_color || '#000000' %>;"
<% end %>
```
Source: Rails Active Storage Overview guide

### Next Sunday date pre-fill (DECK-01)
```ruby
# In DecksController#new
def new
  next_sunday = Date.today.next_occurring(:sunday)
  @deck = current_user.decks.new(date: next_sunday)
end
```
Source: Ruby Date#next_occurring (standard library, available in Ruby 2.6+)

### Unsplash photo search (inside job only)
```ruby
# HTTP GET with Net::HTTP or Faraday (already used for scrapers)
response = Faraday.get("https://api.unsplash.com/search/photos") do |req|
  req.params["query"]       = keyword
  req.params["per_page"]    = 1
  req.params["orientation"] = "landscape"
  req.headers["Authorization"] = "Client-ID #{ENV.fetch('UNSPLASH_ACCESS_KEY')}"
end
result = JSON.parse(response.body)
photo_url = result.dig("results", 0, "urls", "regular")
photo_attribution = result.dig("results", 0, "user", "name")
photo_profile = result.dig("results", 0, "user", "links", "html")
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `acts_as_list` gem for position management | Direct `position` integer column + manual reindex | Rails 7+ community shift | Fewer gem dependencies; position gaps acceptable for UI ordering |
| `dragula` or jQuery UI Sortable | SortableJS (framework-agnostic ESM) | ~2019 | Touch support, no jQuery dependency, ESM-importable |
| `jquery_fileupload` / CarrierWave | ActiveStorage `has_one_attached` | Rails 5.2 | Built-in, no extra gem, S3-ready |
| Custom CSS for 16:9 ratio (padding-bottom hack) | `aspect-ratio: 16/9` CSS property | ~2021 (all modern browsers) | One line; no padding-bottom: 56.25% hack needed |

**Deprecated/outdated:**
- `data-remote: true` form attribute: Replaced by Turbo Drive default behavior — all forms are Turbo forms now.
- `rails-ujs` drag-and-drop patterns: Replaced by `@rails/request.js` + Stimulus.

---

## Open Questions

1. **SLIDE-01 vs. read-only scope**
   - What we know: REQUIREMENTS.md lists SLIDE-01 as "User can edit slide Chinese text and pinyin inline" and maps it to Phase 3.
   - What's unclear: CONTEXT.md explicitly locks slides as read-only in the deck; editing goes to the song library. This contradicts REQUIREMENTS.md SLIDE-01 literally.
   - Recommendation: Treat SLIDE-01 as satisfied by the "Edit lyrics →" link to the song library. The per-deck inline text editing is explicitly out of scope per user decision. The planner should note this interpretation clearly.

2. **Unsplash API key setup**
   - What we know: Requires `UNSPLASH_ACCESS_KEY` environment variable; free demo tier (50 req/hr).
   - What's unclear: Whether the project has an Unsplash app registered or if this needs to be done during implementation.
   - Recommendation: Plan a setup task that includes Unsplash app registration and ENV variable documentation in the project README.

3. **Arrangement index vs. lyric_id for slide remove/repeat**
   - What we know: Arrangement is `[lyric_id, lyric_id, ...]` with possible duplicates.
   - What's unclear: For "+ Repeat" removal (removing one of two identical lyric IDs), the client must pass an index (not just the lyric_id) to avoid ambiguity.
   - Recommendation: Remove action should accept `index` parameter (position in arrangement array), not just `lyric_id`. Repeat action accepts `lyric_id` to append. The slide card's data attribute should carry `data-arrangement-index`.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Minitest (Rails default) with custom Object#stub and Minitest::Mock shims (see test_helper.rb) |
| Config file | test/test_helper.rb |
| Quick run command | `rails test test/models/deck_song_test.rb test/models/theme_test.rb` |
| Full suite command | `rails test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SLIDE-01 | "Edit lyrics" link present on deck_song card | controller | `rails test test/controllers/decks_controller_test.rb` | ✅ (extend) |
| SLIDE-02 | PATCH update_arrangement reorders lyric IDs | controller | `rails test test/controllers/deck_songs_controller_test.rb` | ✅ (extend) |
| SLIDE-03 | DELETE/PATCH removes lyric ID at index from arrangement | controller | `rails test test/controllers/deck_songs_controller_test.rb` | ✅ (extend) |
| SLIDE-04 | Deck show page renders slide preview divs for each arrangement entry | controller | `rails test test/controllers/decks_controller_test.rb` | ✅ (extend) |
| SLIDE-05 | "+ Repeat" appends lyric ID duplicate to arrangement | controller | `rails test test/controllers/deck_songs_controller_test.rb` | ✅ (extend) |
| DECK-01 | `new` action pre-fills date with next Sunday | controller | `rails test test/controllers/decks_controller_test.rb` | ✅ (extend) |
| DECK-02 | `create` DeckSong initializes arrangement from song lyrics | model + controller | `rails test test/models/deck_song_test.rb test/controllers/deck_songs_controller_test.rb` | ✅ (extend) |
| DECK-03 | PATCH reorder changes DeckSong.position | controller | `rails test test/controllers/deck_songs_controller_test.rb` | ✅ (extend) |
| DECK-04 | DELETE DeckSong does not delete Song | controller | `rails test test/controllers/deck_songs_controller_test.rb` | ✅ (extend) |
| THEME-01 | GenerateThemeSuggestionsJob enqueues and broadcasts Turbo Stream | job | `rails test test/jobs/generate_theme_suggestions_job_test.rb` | ❌ Wave 0 |
| THEME-02 | Theme created with color/font_size; deck.theme association set | model + controller | `rails test test/models/theme_test.rb test/controllers/themes_controller_test.rb` | ❌ Wave 0 |
| THEME-03 | Theme.background_image attached; url_for returns non-nil | model | `rails test test/models/theme_test.rb` | ❌ Wave 0 |

### Integration Points That Need Testing

1. **Arrangement stale ID handling:** Fixture with a deck_song where arrangement contains an ID for a lyric that has been deleted — deck show should render without raising RecordNotFound.
2. **Arrangement integer casting:** Creating a deck_song via controller with song lyrics → arrangement should contain Integer IDs, not Strings.
3. **Theme apply via AI suggestion:** Clicking a suggestion card should create a Theme record and set `deck.theme_id`.
4. **DeckSong destroy does not cascade to Song:** Covered by DECK-04; verify Song.count unchanged after DeckSong.destroy.

### Edge Cases to Test

| Edge Case | Expected Behavior | Test Location |
|-----------|-------------------|--------------|
| Arrangement is nil (empty deck song) | Deck show renders 0 slide cards; no error | `test/controllers/decks_controller_test.rb` |
| Arrangement has duplicate lyric IDs (chorus repeated) | Both entries render as separate slide cards | `test/controllers/decks_controller_test.rb` |
| No theme assigned to deck | Preview renders with black background / white text defaults | `test/controllers/decks_controller_test.rb` |
| All lyrics deleted from song after adding to deck | Arrangement IDs return nil from `find_by`; view renders gracefully | `test/models/deck_song_test.rb` |
| Deck with 0 songs | Show page renders "No songs added yet" with Add Song form | ✅ existing behavior |
| Theme background_image not attached | Falls back to `background_color` in preview style | `test/models/theme_test.rb` |
| "+ Repeat" on song with one lyric | Arrangement becomes `[id, id]`; both preview cards render | `test/controllers/deck_songs_controller_test.rb` |
| Remove last slide from arrangement | Arrangement becomes `[]`; deck_song card shows 0 slides | `test/controllers/deck_songs_controller_test.rb` |

### Sampling Rate
- **Per task commit:** `rails test test/models/deck_song_test.rb test/models/theme_test.rb test/controllers/decks_controller_test.rb test/controllers/deck_songs_controller_test.rb`
- **Per wave merge:** `rails test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/models/theme_test.rb` — covers THEME-02, THEME-03; needs fixture `test/fixtures/themes.yml`
- [ ] `test/controllers/themes_controller_test.rb` — covers THEME-02 (create, apply to deck)
- [ ] `test/jobs/generate_theme_suggestions_job_test.rb` — covers THEME-01; stub ClaudeThemeService and Unsplash HTTP call
- [ ] `test/fixtures/themes.yml` — basic theme fixtures (no background_image attachment)
- [ ] `test/fixtures/deck_songs.yml` — update fixture `one` to include arrangement: `[<%= ActiveRecord::FixtureSet.identify(:one) %>]`

---

## Sources

### Primary (HIGH confidence)
- Existing codebase: `app/models/deck_song.rb`, `db/schema.rb`, `app/jobs/import_song_job.rb`, `app/views/songs/_lyrics.html.erb` — authoritative on existing patterns
- Rails Active Storage Overview (https://guides.rubyonrails.org/active_storage_overview.html) — `has_one_attached`, `url_for`, direct upload
- Unsplash API Documentation (https://unsplash.com/documentation) — `/search/photos` endpoint, rate limits, attribution requirements

### Secondary (MEDIUM confidence)
- SortableJS ESM on jsDelivr CDN: `https://cdn.jsdelivr.net/npm/sortablejs@1.15.2/modular/sortable.esm.js` — confirmed ESM module available; version verified against jsDelivr
- @rails/request.js importmap pin pattern — confirmed via multiple Rails 7/8 community sources (GoRails, Hotwire Discussion, importmap-rails README)
- Stimulus Components docs (https://www.stimulus-components.com/docs/stimulus-sortable/) — confirmed data attribute names and approach; not used directly (requires yarn)

### Tertiary (LOW confidence)
- Unsplash 50 req/hr demo limit — stated consistently across multiple sources but not confirmed directly from the Unsplash API terms page; treat as accurate for planning, validate during implementation
- `Date#next_occurring(:sunday)` — standard Ruby Date method; LOW confidence only because Ruby 4.0.1 is pre-release and API changes are possible, though this is a stable method

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all libraries are already in use or established importmap patterns
- Architecture: HIGH — follows existing patterns in ImportSongJob, ClaudeLyricsService, DeckSongsController
- Pitfalls: HIGH — most derived from direct schema and code inspection (stale IDs, integer casting)
- Unsplash rate limits: MEDIUM — cross-referenced with official docs but not signed in to verify exact current limits

**Research date:** 2026-03-12
**Valid until:** 2026-04-12 (stable stack; SortableJS and @rails/request.js are mature libraries)
