# Phase 2: Lyrics Pipeline - Research

**Researched:** 2026-03-10
**Domain:** Anthropic Ruby SDK, Turbo Streams from background jobs, Nokogiri scraping, HTML ruby annotations, Rails enum state machine
**Confidence:** HIGH (core stack), MEDIUM (Claude prompt reliability, SerpAPI quality)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- After search submit: redirect to the song's show page in a "processing" state (not stay on index)
- Processing state shows progress steps: "Searching web → Fetching lyrics → Generating pinyin → Done"
- Job failure: show page displays a red error state with a "Try manual paste" link/button
- On success: brief green border (2 seconds) before settling into the normal song view
- Pinyin rendered ruby-style: above each Chinese character (not on a separate line)
- Pinyin toggle: show/hide button on the song view — pinyin on by default
- Sections stacked vertically, each with a labeled header (English: Verse 1, Chorus, Bridge, etc.)
- Chinese + pinyin always shown together when pinyin is toggled on — no read-only-without-pinyin mode
- Manual paste: always visible as a secondary option on the search form (not hidden behind failure state)
- User pastes any format — Claude handles both raw and pre-labeled lyrics
- Same background job pipeline runs — just skips the search/scrape step
- If a song's import job already failed, pasting replaces that song's lyrics in place (no duplicate created)
- Song card on index shows: title + first lyric line preview (not section count)
- Library search: the existing search bar on Songs index, searches by title (no separate search page)
- Editable fields: lyrics text, pinyin, and section labels — all three
- Edit view: standard separate edit page per song (not inline editing on show page)

### Claude's Discretion
- Exact Tailwind styling for the processing/error/success states on the song show page
- Progress step animation details (step indicators, transitions)
- How search-by-title filters results (client-side vs. server-side, debounce vs. on-submit)
- Pinyin toggle implementation (Stimulus controller, cookie vs. in-memory state)
- Edit form layout for lyrics sections with pinyin fields

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SONG-01 | User can search for a song by title; Claude recalls lyrics first, Nokogiri scrapers used as fallback if Claude doesn't know the song | Anthropic SDK `output_config` structured JSON, SerpAPI gem for web search URLs, Nokogiri + Faraday for scraping |
| SONG-02 | Claude automatically detects and labels lyric sections (verse, chorus, bridge, etc.) | Claude JSON schema with `sections` array, section_type field in Lyric model already exists |
| SONG-03 | Claude automatically generates tone-marked pinyin for all Simplified Chinese lyrics | Claude prompt instructs pinyin generation per character line; `pinyin` column on Lyric already exists |
| SONG-04 | User can manually paste raw lyrics if search and scrapers both fail | Same `ImportSongJob` with `raw_lyrics` param bypasses search/scrape steps; manual paste textarea on index |
| LIB-01 | Imported songs are automatically saved to the shared team library | Song+Lyric records created inside `ImportSongJob`; Song is shared (no user scope) |
| LIB-02 | User can browse and search saved songs in the library | SongsController#index already has ILIKE search; card partial needs first-lyric preview |
| LIB-03 | User can edit a song's lyrics and pinyin in the library | Edit page extended with per-lyric section fields; section_type, content, and pinyin editable |
</phase_requirements>

---

## Summary

This phase wires together three subsystems: (1) a background job that drives a Claude-first / scraper-fallback lyrics fetch, (2) Turbo Stream progress broadcasts that update the song show page in real-time without polling, and (3) an edit UI where section labels, lyrics text, and pinyin are all editable. The schema is already in place — `Song`, `Lyric` (with `pinyin` column), and `ApplicationJob` (Solid Queue) all exist from Phase 1.

The primary new dependency is the official Anthropic Ruby SDK (`anthropic` gem ~> 1.23.0). Structured JSON output via `output_config` gives parse-safe responses from Claude with no retry logic needed. The Song model needs an `import_status` string/enum column (`pending`, `processing`, `done`, `failed`) and an `import_step` string column to power the progress UI. Turbo Streams broadcast from the job to the show page using `Turbo::StreamsChannel.broadcast_replace_to`.

Two risks flagged from STATE.md are real and affect planning: Claude prompt reliability for structured JSON and SerpAPI quality for Chinese worship lyrics. Both should be treated as spike tasks at the start of the phase — fail fast, adjust before building the full pipeline.

**Primary recommendation:** Add `import_status` + `import_step` to `songs` table, implement `ImportSongJob` with three stages (search → scrape → Claude), broadcast each stage transition via `Turbo::StreamsChannel.broadcast_replace_to`, and render progress on the show page with a `turbo_stream_from @song` subscription.

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `anthropic` gem | ~> 1.23.0 | Official Anthropic Ruby SDK for Claude API calls | Official Anthropic-maintained SDK; `output_config` gives schema-guaranteed JSON, no parse retries needed. Requires Ruby >= 3.2.0 (project uses Ruby 4.0.1 — satisfied). |
| `turbo-rails` | already installed | Turbo Stream progress broadcasts from job to browser | Already in Gemfile. `Turbo::StreamsChannel.broadcast_replace_to` works from any background job without AR callbacks. |
| `stimulus-rails` | already installed | Pinyin show/hide toggle, progress animation | Already in Gemfile. One Stimulus controller for toggle; no extra JS needed. |
| `nokogiri` | already installed (Rails transitive dep) | Parse HTML from scraped lyrics pages | Part of Rails' activesupport dependencies; no separate installation. |
| `solid_queue` | already installed | Background job queue (Solid Queue) | Already installed and confirmed working in Phase 1. |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `serpapi` gem | ~> 1.0, >= 1.0.3 | Web search to find lyrics page URLs | Use when Claude says it doesn't know a song. Returns organic result URLs for scraping. Needs `SERPAPI_KEY` env var. |
| `faraday` gem | included in Rails ecosystem | HTTP client to fetch scraped URLs | Use for fetching the lyrics page HTML. Configure timeout (10s) and rescue `Faraday::Error` for graceful fallback. |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `anthropic` official SDK | `ruby-anthropic` (community gem) | Community gem is legacy; official SDK has `output_config` structured JSON which eliminates regex parsing |
| `serpapi` gem for URL discovery | Manual Google scrape | SerpAPI is reliable and avoids bot detection; manual Google scraping is fragile and ToS-violating |
| `Turbo::StreamsChannel.broadcast_replace_to` | `ActionCable.server.broadcast` | Turbo helper is higher-level, renders partials automatically, integrates with `turbo_stream_from` helper |

**Installation (new gems only):**
```bash
bundle add anthropic serpapi faraday
```

---

## Architecture Patterns

### Recommended Project Structure

```
app/
├── jobs/
│   └── import_song_job.rb          # 3-stage: search → scrape → Claude
├── services/
│   ├── lyrics_search_service.rb    # SerpAPI wrapper: title → ranked URLs
│   ├── lyrics_scraper_service.rb   # Nokogiri/Faraday: URL → raw text
│   └── claude_lyrics_service.rb    # Claude API: raw text → structured JSON
├── controllers/
│   └── songs_controller.rb         # add #import action (POST /songs/import)
├── views/songs/
│   ├── show.html.erb               # turbo_stream_from @song + progress/done states
│   ├── _processing.html.erb        # partial: step indicators during import
│   ├── _lyrics.html.erb            # partial: ruby-annotated lyrics (broadcast target)
│   └── edit.html.erb               # extended with per-lyric section fields
├── javascript/controllers/
│   └── pinyin_toggle_controller.js # Stimulus: show/hide ruby annotations
db/migrate/
└── YYYYMMDDHHMMSS_add_import_columns_to_songs.rb
```

### Pattern 1: Import Status on Song Model

**What:** Add `import_status` (enum: pending/processing/done/failed) and `import_step` (string) columns to `songs`. The job updates these, and the show page reads them to decide what partial to render on initial page load (before the Turbo Stream connection is established).

**When to use:** Any time a model drives an async import workflow — status on the model means the show page renders correctly on hard refresh, not just via Turbo.

```ruby
# Migration
add_column :songs, :import_status, :string, default: "pending", null: false
add_column :songs, :import_step, :string

# Model
enum :import_status, { pending: "pending", processing: "processing",
                       done: "done", failed: "failed" }

# Job sets status before broadcasting:
@song.update!(import_status: "processing", import_step: "Searching web...")
```

### Pattern 2: Turbo Stream Broadcasting from a Background Job

**What:** The job calls `Turbo::StreamsChannel.broadcast_replace_to` at each stage transition. The show page subscribes with `turbo_stream_from @song`. The broadcast replaces a named DOM element with a re-rendered partial.

**When to use:** Any multi-step background job that needs to push incremental UI state to the user without polling.

```erb
<%# app/views/songs/show.html.erb %>
<%= turbo_stream_from @song %>
<div id="song_status_<%= @song.id %>">
  <%= render partial: (@song.done? ? "lyrics" : "processing"), locals: { song: @song } %>
</div>
```

```ruby
# app/jobs/import_song_job.rb
def broadcast_step(song, step_text)
  song.update!(import_step: step_text)
  Turbo::StreamsChannel.broadcast_replace_to(
    song,
    target: "song_status_#{song.id}",
    partial: "songs/processing",
    locals: { song: song }
  )
end
```

**Critical:** The partial ID (`song_status_#{song.id}`) must match between `broadcast_replace_to`'s `target:` and the div's `id` in the view. Mismatch silently fails.

### Pattern 3: Claude Structured JSON Output

**What:** Pass lyrics text to Claude with a system prompt and `output_config` that enforces a JSON schema. Claude returns a schema-validated object — no `JSON.parse` or rescue needed.

**When to use:** Any time Claude must return structured data that will be written to the database.

```ruby
# app/services/claude_lyrics_service.rb
# Source: https://github.com/anthropics/anthropic-sdk-ruby

client = Anthropic::Client.new(api_key: ENV["ANTHROPIC_API_KEY"])

# Prompt strategy: Claude-first recall
# If raw_lyrics is nil → ask Claude to recall the song directly
# If raw_lyrics present → ask Claude to structure the provided text

system_prompt = <<~PROMPT
  You are a Chinese worship music expert. When given a song title (and optionally
  raw lyrics), return the complete Simplified Chinese lyrics with tone-marked pinyin
  (e.g. nǐ hǎo, not ni3 hao3) structured into labeled sections.
  If you do not know the song, return sections: [] with an unknown: true flag.
  Never generate or fabricate lyrics you do not know with confidence.
PROMPT

response = client.messages.create(
  model: "claude-sonnet-4-5-20250929",
  max_tokens: 4096,
  system: system_prompt,
  messages: [{ role: "user", content: user_message }],
  output_config: {
    format: {
      type: "json_schema",
      schema: {
        type: "object",
        properties: {
          unknown: { type: "boolean" },
          sections: {
            type: "array",
            items: {
              type: "object",
              properties: {
                section_type: { type: "string" },
                content:      { type: "string" },
                pinyin:       { type: "string" }
              },
              required: ["section_type", "content", "pinyin"],
              additionalProperties: false
            }
          }
        },
        required: ["unknown", "sections"],
        additionalProperties: false
      }
    }
  }
)

result = JSON.parse(response.content[0].text)
# result["unknown"] == true → trigger scraper fallback
# result["sections"] → array of {section_type, content, pinyin}
```

### Pattern 4: HTML Ruby Annotations for Pinyin

**What:** Use the HTML `<ruby>`, `<rt>`, and `<rp>` elements to render pinyin above Chinese characters. Browser support is "Baseline Widely available" (all modern browsers since 2015). CSS `ruby-position: over` is the default — no extra CSS needed.

**When to use:** Per-character pinyin annotations. The `<rp>` fallback shows parentheses in any browser that somehow doesn't support ruby (effectively none in 2026).

```erb
<%# Renders: nǐ hǎo above 你好 %>
<ruby>你<rp>(</rp><rt>nǐ</rt><rp>)</rp></ruby>
<ruby>好<rp>(</rp><rt>hǎo</rt><rp>)</rp></ruby>
```

**Key constraint from decisions:** Claude returns pinyin as a flat string aligned line-by-line with the Chinese. The implementation must either:
- Ask Claude to return per-character `[char, pinyin]` pairs in the JSON (simplest for ruby rendering), OR
- Store pinyin as a parallel string and pair at render time (fragile — character count must match)

**Recommendation:** Ask Claude for per-character pairs in the JSON schema (array of `{char, pinyin}`), store the rendered HTML approach separately, or at minimum store space-separated pinyin tokens that map 1:1 to space-separated character groups. Do not rely on string index alignment.

### Pattern 5: Pinyin Toggle (Stimulus Controller)

**What:** One Stimulus controller toggles a CSS class on the lyric container to show/hide all `<rt>` elements. State lives in memory (no cookie needed — pinyin is on by default as locked decision).

```javascript
// app/javascript/controllers/pinyin_toggle_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["container", "button"]

  toggle() {
    this.containerTarget.classList.toggle("pinyin-hidden")
    this.buttonTarget.textContent =
      this.containerTarget.classList.contains("pinyin-hidden")
        ? "Show Pinyin" : "Hide Pinyin"
  }
}
```

```css
/* In app/assets/stylesheets/application.css */
.pinyin-hidden ruby rt,
.pinyin-hidden ruby rp { display: none; }
```

### Anti-Patterns to Avoid

- **Calling Claude inline in a controller:** All Claude API calls must run in Solid Queue jobs (Thruster timeout risk, confirmed in STATE.md). Never call `Anthropic::Client` from a controller action.
- **Using flash messages for job status:** Flash messages don't persist across Turbo Stream updates. Use `import_status` + Turbo Stream broadcasts instead.
- **Creating a duplicate Song on manual paste after failure:** Locked decision: if a song's import already failed, paste replaces that song's lyrics in place. Query for existing failed song by title before `Song.create!`.
- **Storing pinyin as a parallel line string:** Fragile when Claude produces slightly different character spacing. Use per-character or per-token pairing structure in the JSON schema.
- **Hardcoding scraper target URLs:** Chinese worship sites change structure frequently. The scraper is a fallback — keep it simple (`css("body").text` is acceptable as a first pass) and design for it to fail gracefully.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| JSON schema enforcement on Claude output | Custom regex parser + retry loop | `output_config` with JSON schema in `anthropic` gem | Constrained decoding guarantees valid JSON — no parse errors, no retry logic needed |
| Search result page URLs for scraping | Direct Google scraping | `serpapi` gem | Google bot detection blocks direct scraping; SerpAPI handles it reliably |
| Progress push from job to browser | Polling endpoint (`/songs/1/status.json`) | `Turbo::StreamsChannel.broadcast_replace_to` | WebSocket push eliminates polling; already in stack via `solid_cable` |
| Background job queue | Custom threads or `at_exit` hooks | `Solid Queue` via `ApplicationJob` | Already wired and confirmed working in Phase 1 |
| Pinyin tone marks | Custom tone-mark generation algorithm | Claude prompt | Claude knows tones for Chinese characters; generating them algorithmically requires a full pronunciation dictionary (cc-cedict) |

**Key insight:** The hardest problems in this phase (structured lyrics parsing, pinyin generation, search result discovery) are all solved by Claude + SerpAPI. The Rails plumbing is standard — enum, job, Turbo Stream.

---

## Common Pitfalls

### Pitfall 1: Claude Returns `unknown: true` But Pipeline Doesn't Gate Properly

**What goes wrong:** Job skips the `unknown` flag check and proceeds to create empty Lyric records, or calls the scraper with a nil URL.
**Why it happens:** Optimistic coding assumes Claude always knows the song.
**How to avoid:** Explicitly check `result["unknown"]` before creating lyrics. If true and no scraper URL was found, mark `import_status: "failed"`.
**Warning signs:** Songs saved with zero lyrics or all-empty content fields.

### Pitfall 2: Turbo Stream Target ID Mismatch

**What goes wrong:** `broadcast_replace_to` fires but the DOM doesn't update. Silent failure — no error in logs.
**Why it happens:** The `target:` string in the job doesn't match the `id` on the div in the view.
**How to avoid:** Use a shared helper or constant for the target ID: `"song_status_#{song.id}"`. Test by inspecting the DOM and checking the Turbo Stream WebSocket frame in DevTools.
**Warning signs:** Logs show broadcast fired but UI doesn't update.

### Pitfall 3: `Turbo::StreamsChannel` Not Available in Job Context

**What goes wrong:** `NameError: uninitialized constant Turbo::StreamsChannel` in job.
**Why it happens:** The job file doesn't require turbo-rails, or the require order in application.rb is wrong.
**How to avoid:** Ensure `gem "turbo-rails"` is in Gemfile (already is). In the job, call the full constant `Turbo::StreamsChannel.broadcast_replace_to`. No require needed in Rails autoload context.
**Warning signs:** Job completes but raises NameError; may be swallowed by Solid Queue error handling.

### Pitfall 4: `output_config` Schema Too Strict Causes Claude Refusal

**What goes wrong:** Claude refuses to respond or returns an error when the schema has unsupported JSON Schema features.
**Why it happens:** Claude's constrained decoding supports a subset of JSON Schema (no `$ref`, limited `if/then`). Complex nesting may trigger silent fallback.
**How to avoid:** Keep schema flat — use `additionalProperties: false` and `required` arrays. Test schema independently with a spike before integrating into the full pipeline.
**Warning signs:** `response.content` is empty or response is a text error message instead of JSON.

### Pitfall 5: Scraper Returns Noise (Navigation, Ads, Metadata)

**What goes wrong:** `body.text` captures menus, copyright lines, and unrelated text alongside lyrics. Claude structures garbage.
**Why it happens:** Generic text extraction doesn't isolate lyric content.
**How to avoid:** Use Nokogiri CSS selectors where possible. As a fallback, pass the raw text to Claude with instructions to extract only lyric lines, discarding non-lyric text. This is acceptable because Claude is already in the pipeline.
**Warning signs:** Structured lyrics contain navigation text ("Home | About | Contact") or copyright notices.

### Pitfall 6: Pinyin-to-Character Alignment Breaks on Render

**What goes wrong:** Pinyin tokens don't match character count, producing misaligned ruby annotations.
**Why it happens:** Claude returns word-level pinyin (e.g., "nǐ hǎo" for "你好") but rendering treats it as character-level.
**How to avoid:** In the Claude JSON schema, request `sections[].lines` as an array where each line is an array of `{char, pinyin}` objects. This makes alignment explicit and parse-time verified.
**Warning signs:** Ruby annotations appear shifted or stacked on wrong characters.

### Pitfall 7: Song Created Before Job Enqueued (Race with Turbo Subscribe)

**What goes wrong:** Controller creates Song, enqueues job, redirects to show page. But the Turbo Stream subscription on show page connects *after* the job has already broadcast — update is missed.
**Why it happens:** Job runs very fast on a lightly loaded queue and broadcasts before the browser connects.
**How to avoid:** The show page should render initial state from `song.import_status` and `song.import_step` columns on page load. The Turbo Stream subscription catches subsequent steps. This means the page is correct on hard refresh AND on fast jobs.
**Warning signs:** Show page renders correct final state on refresh but not in real-time flow; or shows "processing" forever if job already completed.

---

## Code Examples

Verified patterns from official sources:

### Anthropic SDK — Basic Call with Structured Output

```ruby
# Source: https://github.com/anthropics/anthropic-sdk-ruby
client = Anthropic::Client.new(api_key: ENV["ANTHROPIC_API_KEY"])

response = client.messages.create(
  model: "claude-sonnet-4-5-20250929",
  max_tokens: 4096,
  system: "You are a Chinese worship music expert...",
  messages: [{ role: "user", content: "Song: 我願意 by 讚美之泉" }],
  output_config: {
    format: {
      type: "json_schema",
      schema: {
        type: "object",
        properties: {
          unknown:  { type: "boolean" },
          sections: {
            type: "array",
            items: {
              type: "object",
              properties: {
                section_type: { type: "string" },
                lines: {
                  type: "array",
                  items: {
                    type: "object",
                    properties: {
                      chars:  { type: "array", items: { type: "string" } },
                      pinyin: { type: "array", items: { type: "string" } }
                    },
                    required: ["chars", "pinyin"],
                    additionalProperties: false
                  }
                }
              },
              required: ["section_type", "lines"],
              additionalProperties: false
            }
          }
        },
        required: ["unknown", "sections"],
        additionalProperties: false
      }
    }
  }
)

result = JSON.parse(response.content[0].text)
```

### SerpAPI — Fetch Top Lyrics Page URLs

```ruby
# Source: https://serpapi.com/integrations/ruby
require "serpapi"
client = SerpApi::Client.new(engine: "google", api_key: ENV["SERPAPI_KEY"])
results = client.search(q: "#{title} 歌词 lyrics site:")
urls = results[:organic_results]&.map { |r| r[:link] }&.first(3) || []
```

### Faraday + Nokogiri — Fetch and Extract Lyrics Text

```ruby
require "faraday"
require "nokogiri"

conn = Faraday.new(request: { timeout: 10 }) do |f|
  f.headers["User-Agent"] = "Mozilla/5.0"
end

begin
  response = conn.get(url)
  if response.success?
    doc = Nokogiri::HTML(response.body)
    # Remove script/style noise
    doc.css("script, style, nav, header, footer").remove
    doc.css("body").text.strip
  end
rescue Faraday::Error
  nil
end
```

### Turbo Stream Progress Broadcast from Job

```ruby
# Source: https://www.visuality.pl/posts/showing-progress-of-background-jobs-with-turbo
Turbo::StreamsChannel.broadcast_replace_to(
  song,                           # channel identifier (matches turbo_stream_from @song)
  target: "song_status_#{song.id}", # DOM element id to replace
  partial: "songs/processing",
  locals: { song: song }
)
```

### View: Subscribe + Initial State Render

```erb
<%# app/views/songs/show.html.erb %>
<%= turbo_stream_from @song %>

<div id="song_status_<%= @song.id %>">
  <% if @song.done? %>
    <%= render "songs/lyrics", song: @song %>
  <% elsif @song.failed? %>
    <%= render "songs/failed", song: @song %>
  <% else %>
    <%= render "songs/processing", song: @song %>
  <% end %>
</div>
```

### HTML Ruby Annotation for One Character

```erb
<%# Source: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/ruby %>
<ruby>你<rp>(</rp><rt>nǐ</rt><rp>)</rp></ruby>
```

### Rails Enum for Import Status

```ruby
# Migration
add_column :songs, :import_status, :string, default: "pending", null: false
add_column :songs, :import_step,   :string

# Model
enum :import_status, {
  pending:    "pending",
  processing: "processing",
  done:       "done",
  failed:     "failed"
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `anthropic-sdk-beta` gem name | `anthropic` gem (official, v1.23.0) | Official release 2025 | Use `gem "anthropic", "~> 1.23.0"` — the beta gem name is retired |
| Manual JSON.parse with rescue retry | `output_config` with JSON schema | Structured outputs GA 2025 | Zero parse failures; no retry logic needed |
| `broadcast_append_to` in model callbacks | `Turbo::StreamsChannel.broadcast_replace_to` from job directly | Turbo Rails stable | Jobs can broadcast without model callbacks; more flexible for progress updates |
| `anthropic-beta: structured-outputs-2025-11-13` header required | No beta header needed | GA release | Remove beta header if seen in old examples |

**Deprecated/outdated:**
- `ruby-anthropic` / `alexrudall/anthropic` community gem: Use official `anthropic` gem instead
- `output_format` parameter name: Renamed to `output_config.format` in GA release
- Beta header `anthropic-beta: structured-outputs-2025-11-13`: No longer required

---

## Open Questions

1. **Claude recall quality for Chinese worship songs**
   - What we know: Claude is trained on Chinese internet text and knows many worship songs; quality is unvalidated for this specific domain
   - What's unclear: Does Claude reliably return `unknown: true` when it should? Does it ever hallucinate lyrics with `unknown: false`?
   - Recommendation: Make this the first task in the phase — a spike that calls Claude with 5 known songs and 5 obscure ones, inspects the structured output, and validates honesty before building the full pipeline

2. **SerpAPI result quality for Chinese worship lyrics**
   - What we know: SerpAPI reliably returns organic Google results; flagged as untested in STATE.md
   - What's unclear: Does a Google search for `宋冬野 歌词` actually return usable lyrics pages? Are the top results JS-rendered (blocking Nokogiri)?
   - Recommendation: Spike SerpAPI with 3-4 worship song titles, check if top results are static HTML pages Nokogiri can parse. Accept that the scraper is a best-effort fallback, not a guarantee.

3. **Pinyin granularity in JSON schema**
   - What we know: Claude can return pinyin at character or word level; ruby annotations need character-level alignment
   - What's unclear: Is Claude reliable enough to return properly structured per-character arrays without examples?
   - Recommendation: Include a few-shot example in the system prompt showing the `{chars: ["你","好"], pinyin: ["nǐ","hǎo"]}` structure for one line. A/B test versus word-level with an inline comment prompt.

4. **`SERPAPI_KEY` env var — does it already exist or need adding?**
   - What we know: `ANTHROPIC_API_KEY` is already referenced. `SERPAPI_KEY` is not mentioned in STATE.md or CONTEXT.md.
   - What's unclear: Whether the user has a SerpAPI account
   - Recommendation: Wave 0 task should add `SERPAPI_KEY` to `.env` / credentials and document that a free SerpAPI account (100 searches/month) is sufficient for development.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Minitest (Rails default, confirmed via test_helper.rb) |
| Config file | `test/test_helper.rb` |
| Quick run command | `rails test test/models/song_test.rb test/jobs/import_song_job_test.rb` |
| Full suite command | `rails test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SONG-01 | `ImportSongJob#perform` with title → lyrics created on song | unit (job) | `rails test test/jobs/import_song_job_test.rb` | ❌ Wave 0 |
| SONG-01 | `ClaudeLyricsService` returns `unknown: false` with sections | unit (service) | `rails test test/services/claude_lyrics_service_test.rb` | ❌ Wave 0 |
| SONG-01 | `LyricsSearchService` returns URLs array | unit (service) | `rails test test/services/lyrics_search_service_test.rb` | ❌ Wave 0 |
| SONG-02 | Imported lyrics have valid `section_type` values | unit (model) | `rails test test/models/lyric_test.rb` | ✅ (empty) |
| SONG-03 | Lyric records have non-blank `pinyin` after import | unit (model) | `rails test test/models/lyric_test.rb` | ✅ (empty) |
| SONG-04 | `ImportSongJob` with `raw_lyrics:` skips search/scrape | unit (job) | `rails test test/jobs/import_song_job_test.rb` | ❌ Wave 0 |
| LIB-01 | POST /songs/import creates Song + enqueues job | integration (controller) | `rails test test/controllers/songs_controller_test.rb` | ✅ (2 tests exist, needs extension) |
| LIB-02 | GET /songs?q=title returns filtered results | integration (controller) | `rails test test/controllers/songs_controller_test.rb` | ✅ (needs test added) |
| LIB-03 | PATCH /songs/:id updates lyrics and pinyin | integration (controller) | `rails test test/controllers/songs_controller_test.rb` | ✅ (needs test added) |

### Sampling Rate
- **Per task commit:** `rails test test/models/ test/jobs/`
- **Per wave merge:** `rails test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/jobs/import_song_job_test.rb` — covers SONG-01, SONG-04
- [ ] `test/services/claude_lyrics_service_test.rb` — covers SONG-01 (with stub/VCR for Anthropic API)
- [ ] `test/services/lyrics_search_service_test.rb` — covers SONG-01 (with stub for SerpAPI)
- [ ] `test/services/lyrics_scraper_service_test.rb` — covers SONG-01 (with stub for Faraday)
- [ ] `test/fixtures/lyrics.yml` — update from `MyString` placeholders to realistic Chinese worship song data

**Note on API stubs:** Claude and SerpAPI calls must be stubbed in tests. Use Minitest's `stub` or `mocha` (if added) to prevent real API calls. Alternatively use environment-gated VCR cassettes. The Wave 0 plan should decide the stubbing strategy before writing service tests.

---

## Sources

### Primary (HIGH confidence)
- `github.com/anthropics/anthropic-sdk-ruby` — gem name `anthropic` ~> 1.23.0, `output_config` API, model name, Ruby >= 3.2.0 requirement
- `platform.claude.com/docs/en/build-with-claude/structured-outputs` — `output_config.format` parameter format, JSON schema structure, no beta header required, supported models
- `developer.mozilla.org/en-US/docs/Web/HTML/Element/ruby` — `<ruby>`, `<rt>`, `<rp>` markup, browser support "Baseline Widely available"
- `rubygems.org/gems/anthropic` — confirmed official gem, version 1.23.0 released 2026-02-19

### Secondary (MEDIUM confidence)
- `serpapi.com/integrations/ruby` — gem `serpapi` ~> 1.0.3, `SerpApi::Client`, `organic_results[:link]` pattern
- `visuality.pl/posts/showing-progress-of-background-jobs-with-turbo` — `Turbo::StreamsChannel.broadcast_replace_to` from job, `turbo_stream_from` in view, partial target pattern
- `colby.so/posts/turbo-streams-on-rails` — `broadcast_replace_to` vs `broadcast_replace_later_to` distinction, channel scoping

### Tertiary (LOW confidence — needs validation via spike)
- SerpAPI result quality for Chinese worship lyrics queries — untested, flagged in STATE.md
- Claude recall accuracy for Chinese worship songs (domain-specific) — untested, flagged in STATE.md

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — official SDK confirmed on rubygems.org, Turbo/Solid Queue confirmed in Phase 1
- Architecture: HIGH — patterns derived from official docs and existing codebase structure
- Claude prompt reliability: LOW — must spike before full pipeline build
- SerpAPI quality: LOW — must spike with actual Chinese worship song titles

**Research date:** 2026-03-10
**Valid until:** 2026-04-10 (stable ecosystem — `anthropic` SDK, Turbo, Nokogiri change slowly; Claude model names may update)
