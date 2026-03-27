# Project Research Summary

**Project:** ChurchSlides (praise-project) — v1.1 Design Milestone
**Domain:** UI/UX redesign of existing Rails 8 worship slide generator
**Researched:** 2026-03-15
**Confidence:** HIGH — all findings grounded in direct codebase inspection

## Executive Summary

The v1.1 milestone is a visual redesign of a fully functional, shipped app — not a new build. The core problem is that v1.0 used the default Tailwind SaaS palette (indigo primary, gray-50 body, flat banner flash messages), which reads as generic admin software rather than a tool built for worship teams. The redesign goal is to replace that generic visual language with a warm, worshipful identity: earthy amber and stone tones, card-based layouts with date prominence, polished feedback patterns, and onboarding cues that orient new users. No backend changes are required for the visual work; three targeted data additions (META-01/02 for song metadata, SCRIP-01 for scripture slides) are bundled in this milestone and gate their respective UI display components.

The recommended approach is to proceed phase by phase with a strict dependency gate at Phase 1: the Tailwind config custom token definitions must land first, as every subsequent component change depends on those new palette tokens being available. From there, changes cascade — navigation, cards, forms, flash messages, empty states, and finally the most sensitive surface (the deck editor) where Turbo Stream targets, drag-and-drop data contracts, and inline theme styles all coexist. The tech stack requires no changes: Tailwind v4 via importmap, Hotwire (Turbo + Stimulus), and inline SVG icons from Heroicons are exactly the right tools for this scope.

The key risk in this milestone is not visual — it is behavioral. The deck editor and song import flows contain invisible contracts: hardcoded DOM IDs that background jobs broadcast to, `data-drag-handle` and `data-id` attributes that Stimulus controllers depend on, a `.pinyin-hidden` CSS class that lives outside Tailwind, and a deliberate `data: { turbo: false }` on the import form that must not be wrapped in a Turbo Frame. None of these constraints are visible from screenshots. The mitigation is simple: treat the deck show view as the highest-risk surface, defer it to the last redesign phase, and audit all `id=` attributes before modifying any template that a background job references.

---

## Key Findings

### Stack (from STACK.md — v1.0 research, UI-relevant subset)

The stack is locked and no additions are needed for the v1.1 redesign. All UI work is achievable with what is already installed.

**Core technologies relevant to the redesign:**
- **Tailwind CSS v4** (`tailwindcss-rails ~> 4.4`): CSS-first config via `@import "tailwindcss"` in `application.css`. Custom palette tokens go in `tailwind.config.js`. Tailwind v4 uses static content scanning — dynamic class string interpolation is invisible to the build.
- **Turbo + Stimulus (Hotwire)**: All interactive patterns (drag-and-drop, spinners, flash auto-dismiss) use Stimulus controllers. New controllers go in `app/javascript/controllers/` and are auto-registered via importmap.
- **Importmap (no Node/Webpack)**: No npm packages can be added. Icon libraries that require npm are off the table. Heroicons inline SVG in ERB is the correct approach.
- **Solid Cable**: Powers `turbo_stream_from` subscriptions on the deck show and song processing pages. Must run with the full `bin/dev` stack to test async UI updates.

### Expected Features (from FEATURES.md — v1.1 specific, primary source)

**Must have (table stakes) — milestone blockers:**
- Warm color palette (amber, stone, warm off-white) replacing default indigo/gray — enables everything else
- Consistent `rounded-xl` component language across cards, buttons, inputs
- Deck list as card grid with date prominence (date leads, title secondary)
- Deck creation as the primary nav entry point (Songs visually de-emphasized)
- Polished flash messages with icons and auto-dismiss Stimulus controller
- Actionable error messages with prominent fallback paths
- Consistent spinner/loading state conventions across import and export flows
- Empty states with workflow context on deck index, deck editor, and song library
- Readable typography scale (headline/body/caption hierarchy)
- Auth pages with brand context

**Should have (differentiators) — meaningful improvement over bare redesign:**
- Worship-specific color palette with named tokens (`worship-primary`, `worship-accent`) rather than raw Tailwind color references
- Empty state with worship-context copy ("Your Sunday slide deck starts here")
- Processing state copy that conveys AI activity ("Claude is structuring your lyrics...")
- Export button as prominent "done" affordance with download icon
- Song metadata display for CCLI, key, and artist fields (gated on META-01/02 migrations)
- Onboarding cue on first deck editor open ("Now add your first song...")
- Section type labels (verse/chorus/bridge) with color-coded badges in slide preview

**Defer to v1.2:**
- Song card section badge in library (nice, not critical)
- Auth page illustration or brand artwork (small team signs up once)
- Deck card with song count or thumbnail preview (extra DB query, minor value)
- Dark mode (doubles the visual system; users work in lit rooms)
- Responsive/mobile-first layout rework (primary use is desktop)

### Architecture Approach (from ARCHITECTURE.md — v1.0 research, UI-relevant subset)

The app is a multi-frame Rails page, not a SPA. The deck editor uses a 12-column grid with three nested surfaces: song order (outer sortable), slide arrangement per song (inner sortable), and slide preview panel. Turbo Frames handle song search results, slide previews, and inline editing. Turbo Streams handle async job completion. The redesign adds no new components to this architecture — it applies visual changes to existing partials.

**Surfaces the redesign touches:**
1. `layouts/application.html.erb` — navigation bar, flash messages, main container class yield
2. `decks/index.html.erb` — deck card grid and empty state
3. `decks/show.html.erb` — deck editor three-column layout, slide preview, export button, Turbo Stream targets (highest risk)
4. `songs/index.html.erb` — song library, empty state
5. `songs/show.html.erb`, `songs/processing.html.erb`, `songs/_failed.html.erb` — import status and error states
6. `devise/sessions/new.html.erb` — auth page brand treatment
7. `deck_songs/_song_block.html.erb`, `deck_songs/_slide_item.html.erb` — drag-and-drop items (data contract risk)

### Critical Pitfalls (from PITFALLS.md — v1.1 specific, primary source)

1. **Renaming Turbo Stream target DOM IDs** — Five hardcoded broadcast targets exist across the deck and song views (`export_button_#{deck_id}`, `theme_suggestions`, `import_status`, `song_status_#{song.id}`). Renaming or removing these IDs causes silent UI freeze — the background job completes but the browser never knows. Mitigation: audit all `id=` attributes before touching these templates; treat them as a public API; wrap redesign elements around, not instead of, these target `div`s.

2. **Breaking the `data-drag-handle` / `data-id` Sortable contract** — `sortable_controller.js` reads `data-id` on each draggable child and expects `data-drag-handle` on the handle element. Extra wrapper `div`s or restructured markup break drag-and-drop silently (the handle still moves but positions are wrong). Mitigation: carry `data-drag-handle` and `data-id` forward verbatim; do not add wrapper `div`s inside the sortable container's direct children.

3. **Removing `.pinyin-hidden` during stylesheet cleanup** — This one CSS class lives in `application.css` outside Tailwind. `pinyin_toggle_controller.js` adds/removes it. If pruned as "dead code" during a stylesheet consolidation, the pinyin toggle breaks with no visible error. Mitigation: keep the rule; add a comment marking it as consumed by the controller.

4. **Dynamic Tailwind class strings not detected by Tailwind v4** — Tailwind v4 only emits classes that appear as complete strings in scanned files. Classes assembled via string interpolation are silently omitted. Additionally, raw HTML strings in job files (`app/jobs/`) contain Tailwind classes that are not in the default content scan path. Mitigation: always use full class names in conditionals; grep `app/jobs/` for class strings before changing palette tokens; run `rails tailwindcss:build` in production mode before each commit.

5. **Song import form `data: { turbo: false }` must be preserved** — The song import form deliberately opts out of Turbo to trigger a full-page navigation to the processing page, where `redirect_controller.js` connects and waits for the job completion broadcast. Wrapping this form in a modal or Turbo Frame breaks the redirect. Mitigation: keep the import form as a full-page navigation for this milestone.

**Additional moderate risks:**
- Flash message redesign must use `flash.each` (not explicit `:notice`/`:alert` keys) to catch all Devise flash keys including `:error` and `:timedout`
- `content_for(:main_class)` override in `decks/show.html.erb` gives the deck editor full-width layout; replacing it with a fixed container class breaks the three-column grid
- Inline `style=` theme color attributes in the slide preview are user database values — never convert them to Tailwind classes
- Job broadcast HTML strings in `app/jobs/` contain Tailwind class names not visible to the content scanner

---

## Implications for Roadmap

Based on combined research, the v1.1 milestone maps cleanly to four phases with a strict dependency gate at Phase 1.

### Phase 1: Design Foundation (Tailwind tokens + navigation)

**Rationale:** Every visual change in the milestone depends on the custom palette tokens being defined. This phase must land first. Navigation redesign is low-risk (no Turbo Stream targets live in the nav bar) and delivers immediate visible impact.
**Delivers:** `tailwind.config.js` with `worship-*` color tokens, updated `bg-stone-50` body, warm navigation bar with Decks as primary entry point, wordmark treatment, button and input base classes using new tokens.
**Addresses:** Warm color palette, consistent component language, deck creation as primary entry point.
**Avoids:** Tailwind v4 dynamic class string pitfall — define tokens as complete names, never interpolated.
**Research flag:** Standard Tailwind config patterns — no phase research needed.

### Phase 2: Global Components (Flash, forms, typography)

**Rationale:** Flash messages and form elements appear on every page. Doing them after the design foundation (so new tokens are available) but before page-specific layouts means all subsequent phase work inherits the correct base styles without rework.
**Delivers:** Auto-dismiss flash message component with icon mapping and Devise key support, consistent form system (inputs, labels, focus rings using new tokens), typography scale applied globally.
**Addresses:** Polished flash messages, consistent form system, readable typography, Devise flash key coverage.
**Avoids:** Flash/Devise flash key pitfall — use `flash.each` not explicit key checks. Tailwind dynamic class pitfall — full class names in type-to-style mapping.
**Research flag:** Standard patterns — no phase research needed.

### Phase 3: Content Pages (Decks index, songs library, auth, empty states)

**Rationale:** These pages are visually independent from the deck editor's Turbo Stream and drag-and-drop complexity. Card grid for decks index, empty states, onboarding cues, and auth page brand treatment can all be built freely with low regression risk.
**Delivers:** Deck list as card grid with date prominence, empty states with worship-context copy on deck index and song library, onboarding cue on first deck editor open, auth page with brand context.
**Addresses:** Deck card grid, empty states, onboarding cue, auth page brand treatment.
**Avoids:** No Turbo Stream targets on these pages; avoid adding `data-controller` inside sortable containers on the deck index.
**Research flag:** Standard patterns — no phase research needed.

### Phase 4: Deck Editor and Import/Export Polish (highest risk)

**Rationale:** The deck editor (`decks/show.html.erb`) contains every critical pitfall: Turbo Stream targets, nested sortables with data contracts, `content_for(:main_class)`, inline theme colors, and the full-page import form. Deferring this to last ensures earlier phases are stable before touching the highest-risk surface.
**Delivers:** Processing state with AI-copy ("Claude is structuring your lyrics..."), consistent spinner conventions, export button visual upgrade, slide preview section badges, song metadata display (once META-01/02 land), scripture slide display (once SCRIP-01 lands).
**Addresses:** Loading state polish, export "done" affordance, section type visual labels, META-01/02 and SCRIP-01 display components.
**Avoids:** All five critical pitfalls; must audit `id=` attributes before any template change; must preserve `data-drag-handle`, `data-id`, `.pinyin-hidden`, `content_for(:main_class)`, inline `style=` theme attributes, and `data: { turbo: false }` on import form.
**Research flag:** No additional research needed, but this phase warrants a written pre-work checklist of all DOM contracts before coding begins.

### Phase Ordering Rationale

- Phase 1 gates Phases 2-4 because Tailwind token definitions must exist before class names can be applied
- Phases 2 and 3 are largely independent and could be parallelized if multiple contributors are available; sequential ordering recommended for a single developer to avoid style drift
- Phase 4 is last by design — it touches every critical pitfall and benefits from having the full visual system stabilized before high-risk template surgery
- META-01/02 and SCRIP-01 migrations are data-work prerequisites that should land before Phase 4 ships, but can be developed in parallel with Phases 1-3

### Research Flags

Phases likely needing deeper research during planning: none. All v1.1 changes are well-understood CSS class updates, small Stimulus controllers, and ERB partial edits with known constraints.

Phases with standard patterns (skip research-phase):
- **Phase 1:** Tailwind v4 CSS-first config and custom token definitions are well documented
- **Phase 2:** Auto-dismiss Stimulus controller is a well-documented pattern; Devise flash key handling is straightforward once the mapping is known
- **Phase 3:** Card grid layouts and empty state patterns have established Tailwind UI conventions
- **Phase 4:** No new patterns — upgrade existing implementations; the risk is preservation, not discovery

Pre-phase checklist recommended for Phase 4 instead of a research phase: before writing any code in Phase 4, produce a written inventory of all DOM IDs that jobs broadcast to, all `data-drag-handle`/`data-id` elements, and all inline `style=` attributes. This is a 30-minute audit, not a research session.

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack (UI-relevant) | HIGH | Direct Gemfile and stylesheet inspection; no ambiguity for this milestone's scope |
| Features | HIGH | v1.0 views inspected directly; gap diagnosis is factual, not estimated |
| Architecture (UI-relevant) | HIGH | DOM contracts, Turbo Stream targets, and controller dependencies all verified from source |
| Pitfalls | HIGH | Every pitfall grounded in specific file and line number from codebase inspection |

**Overall confidence:** HIGH

### Gaps to Address

- **Worshipful palette validation:** The exact amber/stone color choices for `worship-primary` and `worship-accent` tokens are research-informed recommendations, not validated against actual user preferences. The palette should be reviewed with the worship team before Phase 1 ships. Low cost to adjust at that stage; high cost after Phases 2-4 inherit the tokens.
- **META-01/02 and SCRIP-01 timeline:** The Phase 4 UI components for song metadata and scripture slides are gated on migrations tracked separately. If those migrations slip, Phase 4 should ship without those display components — do not block the visual redesign on data migrations.
- **Async flow testing environment:** Turbo Stream behavior (export button, theme suggestions, song import) can only be validated in a `bin/dev` environment with the Solid Queue worker running. The Phase 4 test checklist must explicitly require this setup.

---

## Sources

### Primary (HIGH confidence — direct codebase inspection)
- All views in `app/views/` — v1.0 gap diagnosis (FEATURES.md)
- `app/javascript/controllers/` — Stimulus controller inventory and DOM contract verification (PITFALLS.md)
- `app/jobs/` — Turbo Stream broadcast target IDs and inline HTML class strings (PITFALLS.md)
- `app/assets/tailwind/application.css` — Tailwind v4 CSS-first config confirmation
- `app/assets/stylesheets/application.css` — `.pinyin-hidden` custom CSS class location
- `Gemfile` / `Gemfile.lock` — stack version confirmation (STACK.md)
- `config/importmap.rb` — Stimulus controller auto-registration and no-npm constraint

### Secondary (MEDIUM confidence — knowledge of comparable tools)
- Planning Center Services visual patterns — card-based service lists, warm palette, date-first information hierarchy
- ProPresenter 7 UI conventions — dark mode evaluated and explicitly rejected for web app context
- Tailwind UI component library — card, flash message, and empty state component patterns

---
*Research completed: 2026-03-15*
*Ready for roadmap: yes*

# Architecture Research

**Domain:** Ruby on Rails worship PPTX generator with LLM integration
**Researched:** 2026-03-07
**Confidence:** HIGH — based on direct codebase inspection

---

## Component Overview

```
Browser (Turbo Frames + Stimulus)
    │
    ├─ Songs Controller ──> LyricsScraper (service) ──> SerpAPI
    │                   ──> LyricsEnrichJob ──────────> Claude API
    │                                                       │
    │                                               Lyric records (DB)
    │                                               (Chinese + pinyin stored)
    │
    ├─ Decks Controller ──> Deck / DeckSong / Slide (models)
    │                   ──> PptxGenerateJob ─────────> PptxBuilder (service)
    │                                                       │
    │                                               python-pptx (subprocess)
    │                                                       │
    │                                               Active Storage (.pptx file)
    │
    └─ Turbo Streams ────> Broadcast job completion ──> Download link in UI
```

---

## Component Boundaries

### Controllers (thin — orchestrate only)

- `SongsController` — triggers lyric fetch jobs, renders song library
- `DecksController` — manages service/setlist creation, triggers PPTX generation, serves download
- `SlidesController` — handles inline slide editing (text, order, visibility)
- `ThemesController` — per-deck theme configuration

Controllers never call external services directly. They enqueue jobs or call service objects that return immediately.

### Service Objects (`app/services/`)

| Service | Responsibility | External Dependency |
|---------|---------------|-------------------|
| `LyricsScraper` | Web search + page parsing for raw lyrics text | SerpAPI + Nokogiri |
| `LyricsEnricher` | Claude API call: structure lyrics + add pinyin + detect sections | Claude API (`anthropic` gem) |
| `PptxBuilder` | Assemble slide data, call python-pptx subprocess, return file path | python-pptx (Python) |

### Background Jobs (`app/jobs/`)

| Job | Trigger | Duration |
|-----|---------|---------|
| `LyricFetchJob` | Song search/import | 5-15s (web search + scraping) |
| `LyricEnrichJob` | After fetch completes | 10-30s (Claude API) |
| `PptxGenerateJob` | Export button clicked | 5-20s (python subprocess) |

All three are Solid Queue jobs. Never run synchronously in a controller — Claude API and PPTX generation will timeout under Thruster otherwise.

### Data Models

```
User (Devise)
  └─> has_many :decks (services/setlists)

Song (shared library, team-wide)
  └─> has_many :lyrics (one per section)
        Lyric: { section_type, position, chinese_text, pinyin, slide_number }

Deck (one service = one PPTX export)
  └─> belongs_to :theme
  └─> has_many :deck_songs (ordered)
        DeckSong: { position, arrangement: jsonb }
          arrangement = ordered array of lyric IDs
          (supports chorus repetition, section skipping)

Theme
  └─> { background_color, background_image, font_name, text_color, font_size }
```

**Key design decision:** `DeckSong.arrangement` is a JSONB array of lyric IDs — not a join table. This supports:
- Reordering sections within a song (drag chorus before verse 2)
- Repeating sections (chorus twice)
- Skipping sections (hide intro)

`Slide` records are a UI projection of this arrangement — derived from `DeckSong.arrangement`, not an independent source of truth. Regenerated when arrangement changes.

---

## Data Flow

### Lyric Import Flow

```
User: searches song title
  → SongsController#create
    → LyricFetchJob.perform_later(song_id)
      → LyricsScraper.fetch(title) → SerpAPI → Nokogiri → raw_text
      → LyricEnrichJob.perform_later(song_id, raw_text)
        → LyricsEnricher.process(raw_text) → Claude API
          → returns: [{ section: "verse1", chinese: "...", pinyin: "..." }]
          → creates Lyric records for each section
        → Turbo Streams broadcast to songs/:id channel
          → UI updates: "Song ready" + slide preview appears
```

### PPTX Export Flow

```
User: clicks "Export PPTX"
  → DecksController#export
    → PptxGenerateJob.perform_later(deck_id)
      → PptxBuilder.build(deck) → python-pptx subprocess
        → JSON protocol: { status: "ok", file_path: "..." } on stdout
      → Active Storage attach .pptx file
      → Turbo Streams broadcast to decks/:id channel
        → UI updates: Export button → "Download PPTX" link
```

### Slide Edit Flow (synchronous — no jobs needed)

```
User: edits slide text inline
  → SlidesController#update (Turbo Frame)
    → updates Lyric.chinese_text / Lyric.pinyin
    → returns updated slide partial
    → Turbo Frame replaces slide in DOM
```

---

## UI Technology Decision

**Turbo Frames + Stimulus — no React, no Vue.**

Rationale:
- Importmap-only setup (confirmed in codebase) rules out npm-dependent frameworks
- Turbo Frames handle: song search results, slide previews, inline editing
- Stimulus handles: drag-to-reorder (using Sortable.js via importmap), slide visibility toggles
- Turbo Streams handle: async job completion broadcasts

The slide editor is NOT a single-page app. It's a multi-frame Rails page. Each song's slide list is a Turbo Frame. Reordering sends a PATCH request that updates `DeckSong.arrangement` and re-renders the slide list partial.

---

## Build Order (Strict Dependencies)

```
Phase 1: Auth + Core Models
  └─ Devise users, Song, Lyric, Deck, DeckSong, Theme models
  └─ Basic CRUD controllers (no AI yet)

Phase 2: Lyrics Pipeline
  └─ LyricsScraper + LyricFetchJob (web search)
  └─ LyricsEnricher + LyricEnrichJob (Claude API)
  └─ Song library UI (search, browse, import status)

Phase 3: Deck Editor
  └─ Service/setlist creation
  └─ Add songs to deck
  └─ Slide arrangement editor (reorder, delete, edit text)
  └─ Theme configuration

Phase 4: PPTX Export
  └─ PptxBuilder + python-pptx subprocess
  └─ PptxGenerateJob
  └─ Active Storage for .pptx files
  └─ Download delivery
```

Phases 2-4 are strictly sequential. Phase 3 requires real songs with lyrics to test meaningfully. Phase 4 requires a complete deck with slides.

---

## Infrastructure Requirements

| Requirement | Why | When |
|-------------|-----|------|
| Solid Queue worker process | Jobs don't run without it | Before Phase 2 |
| `gem "anthropic"` in Gemfile | Claude API calls | Before Phase 2 |
| Python 3 + python-pptx in Dockerfile | PPTX generation | Before Phase 4 |
| CJK fonts in Docker image (`fonts-noto-cjk`) | Chinese character rendering in PPTX | Before Phase 4 |
| `SERPAPI_KEY` env var | Lyrics web search | Before Phase 2 |
| `ANTHROPIC_API_KEY` env var | Claude calls (already documented) | Before Phase 2 |

---

## Open Questions for Planning

1. **Lyrics source specifics:** Which lyrics sites does SerpAPI return for Chinese worship songs? Test before Phase 2 planning.
2. **Claude prompt structure:** How to reliably get structured JSON back (section_type, chinese_text, pinyin per section)? Needs prompt engineering spike.
3. **python-pptx two-stacked-textboxes layout:** Pinyin above Chinese text requires two text boxes at fixed Y positions — font sizing strategy needs validation on a Windows projector.

# Stack Research

**Domain:** Ruby on Rails worship PPTX generator with Claude API + lyrics retrieval
**Researched:** 2026-03-07
**Confidence:** HIGH — based on direct codebase inspection of existing praise-project

---

## Confirmed Existing Stack

Already locked in `Gemfile.lock` and running:

| Component | Version | Notes |
|-----------|---------|-------|
| Ruby | 4.0.1 | Confirmed in `.ruby-version` |
| Rails | 8.1.2 | Confirmed in `Gemfile.lock` |
| PostgreSQL | 18 | Confirmed in `database.yml` |
| Devise | 5.0.2 | Auth — already in Gemfile |
| Solid Queue | current | Background jobs — already in Gemfile |
| Tailwind CSS | 4 | Styling — already in Gemfile |
| Turbo + Stimulus (Hotwire) | current | UI framework — already in Gemfile |
| Importmap | current | No Node.js/webpack — rules out React |

---

## Critical Gaps (Must Add)

### 1. Claude API Ruby Gem — MISSING

`ANTHROPIC_API_KEY` is documented in the project but no `anthropic` gem is installed.

```ruby
gem "anthropic"  # Add to Gemfile
```

**Why:** Required for all LLM calls — lyric recall, structuring, and pinyin generation.

**Confidence:** HIGH — confirmed by Gemfile inspection.

---

### 2. PPTX Generation — python-pptx via subprocess

**Decision: python-pptx (Python) called via Ruby subprocess — NOT a Ruby gem.**

| Option | Verdict | Reason |
|--------|---------|--------|
| `caracal` | Reject | Generates DOCX, not PPTX |
| `ruby-pptx` | Reject | Immature; poor CJK character support; unmaintained |
| `caxlsx` | Reject | Excel spreadsheets, not PowerPoint |
| `python-pptx` via subprocess | Use this | Mature, actively maintained, full CJK support, handles background images and custom fonts |

**Implementation:** `lib/pptx_generator/generator.py` called from `PptxBuilder` service via `Open3.capture3`. JSON protocol on stdout for error handling.

**Requirement:** Dockerfile must add Python 3 + `pip install python-pptx`. Already stubbed in codebase.

**Confidence:** HIGH.

---

### 3. Lyrics Retrieval — Claude First, Scrapers Fallback

**Decision: Two-stage pipeline. No external search API.**

```
Stage 1: Ask Claude
  → "Do you know the lyrics to [song title]?
     If yes, return structured sections with pinyin.
     If not, say so — do not guess."
  → If Claude knows → done (one API call, zero scraping)

Stage 2: Fallback scrapers (only when Claude doesn't know)
  → Nokogiri scrapes 2-3 curated Chinese worship sites:
      - 赞美之泉 (Stream of Praise) — mainstream Chinese praise
      - 普世颂扬 — contemporary Chinese worship
      - [additional site TBD based on team's repertoire]
  → Raw lyrics text sent back to Claude to structure + add pinyin
```

**Why Claude first:** Claude knows most major Chinese worship songs (赞美之泉 catalog, classic hymns, mainstream contemporary praise). Scrapers only needed for obscure or locally-written songs.

**Why no search API:** Avoids SerpAPI cost (~$50/month) and Google CSE setup. Google Custom Search returns URLs + snippets — you still need Nokogiri to parse the page. Hardcoded scrapers for known sites are simpler and more reliable for a predictable song repertoire.

**Confidence:** MEDIUM-HIGH. Claude coverage is good for mainstream Chinese worship; scrapers cover the gap. Manual paste remains available for anything scrapers miss.

---

### 4. Pinyin Generation — Claude API (inline with lyrics recall)

**Decision: Claude generates pinyin as part of the same lyric structuring call. No pinyin gem.**

| Option | Verdict | Reason |
|--------|---------|--------|
| `ruby-pinyin` | Reject | Context-blind dictionary lookup; fails on polyphonic characters |
| `pypinyin` (Python) | Reject | Frequency-based; incorrect on rare hymn vocabulary |
| Claude API (inline) | Use this | Context-aware tone assignment; handles 多音字 with sentence context |

**Schema note:** `lyrics.pinyin` column already exists in schema — ready to receive Claude output.

**Prompt design:** Send full lyric section (not character-by-character) for sentence context.

**Confidence:** HIGH.

---

## Full Recommended Stack

| Layer | Choice | Notes |
|-------|--------|-------|
| Web framework | Rails 8.1.2 | Already installed |
| Auth | Devise 5.0.2 | Already installed |
| UI framework | Turbo Frames + Stimulus | Already installed via Hotwire |
| Background jobs | Solid Queue | Already installed |
| Database | PostgreSQL 18 | Already installed |
| Styling | Tailwind CSS 4 | Already installed |
| Claude API | `gem "anthropic"` | **Must add to Gemfile** |
| PPTX generation | python-pptx (Python subprocess) | **Must configure Dockerfile** |
| Lyrics retrieval (primary) | Claude API recall | No extra dependencies |
| Lyrics retrieval (fallback) | Nokogiri scrapers (2-3 curated sites) | Nokogiri already a transitive dep |
| Pinyin | Claude API (inline with lyrics) | No separate gem needed |
| File delivery | Active Storage | Built into Rails; local disk or S3 for .pptx files |
| CJK fonts | Noto Sans SC / Source Han Sans | Must include in Dockerfile |

---

## What NOT to Use

| Technology | Why Not |
|-----------|---------|
| React / Vue | Importmap-only setup rules out npm-dependent frameworks |
| `caracal` | DOCX not PPTX |
| `ruby-pptx` | Immature, poor CJK support |
| `ruby-pinyin` / `pypinyin` | Context-blind; fails on polyphonic worship song characters |
| SerpAPI / Google Custom Search | Adds cost and complexity; Claude + targeted scrapers cover the use case |
| Sidekiq | Solid Queue is already installed and sufficient |
| Redis | Not needed with Solid Queue (uses PostgreSQL as queue backend) |

---

## Deployment Notes

- Dockerfile must install: Python 3, pip, `python-pptx`, CJK font packages (`fonts-noto-cjk`)
- Single server sufficient for one-church team scale
- Active Storage: local disk initially; switch to S3 if needed

---

## Confidence Summary

| Decision | Confidence | Basis |
|----------|------------|-------|
| python-pptx for PPTX | HIGH | Only viable option with full CJK support; codebase already has stub |
| Claude for pinyin | HIGH | Polyphone problem makes gem-based approach unreliable |
| `gem "anthropic"` missing | HIGH | Direct Gemfile inspection |
| Claude-first lyrics recall | MEDIUM-HIGH | Good coverage for mainstream Chinese worship; scrapers cover gap |
| Hardcoded scrapers as fallback | MEDIUM | Reliable for known sites; needs site-specific parsing |
| Solid Queue for jobs | HIGH | Already in Gemfile; correct for this scale |

# Feature Landscape: v1.1 UI Redesign

**Domain:** Worship presentation app — UI/UX redesign milestone
**Researched:** 2026-03-15
**Scope:** What a warm/worshipful redesign looks like in practice for a Chinese church worship slide tool. Based on direct codebase inspection of v1.0 (shipped), analysis of comparable worship software, and UI pattern analysis for small-team ministry tools.
**Confidence note:** HIGH for diagnosis of existing v1.0 gaps (codebase inspected directly). MEDIUM for worshipful visual pattern recommendations (knowledge of ProPresenter, Planning Center, EasyWorship aesthetics, and general ministry app conventions).

---

## Context: What v1.0 Looks Like Today

v1.0 is fully functional but visually generic. A survey of all views reveals:

- **Color palette:** Indigo-600 as primary, gray-50 body, gray-900 text. This is the default Tailwind SaaS palette — identical to thousands of admin dashboards.
- **Components:** Rounded-sm or rounded-lg boxes, no consistent sizing. Some cards use `rounded`, some `rounded-lg`. No warm tones anywhere.
- **Navigation:** White `bg-white border-b border-gray-200` header. Flat text links. No visual weight hierarchy between Decks (primary flow) and Songs (secondary library).
- **Forms:** Consistent `focus:ring-indigo-500` pattern throughout — functional but cold blue. Labels `text-gray-700`. Buttons `bg-indigo-600`.
- **Flash messages:** Flat banner lines (`bg-green-50 border-green-200`) — no icon, no dismiss, no animation. Disappear on next navigation only.
- **Empty states:** Minimal ("No decks yet. Create your first deck." / "No songs yet. Search for a song above to get started"). Functional but provide no warmth or orientation.
- **Loading states:** Spinner in processing card is functional. Export button state machine (idle / generating / ready / error) exists but is plain.
- **Onboarding:** None. A new user lands on an empty decks list with a "New Deck" button. No walkthrough, no contextual cues, no hint of what the app does or how the workflow proceeds.
- **Auth pages:** Bare `max-w-md` form, plain "Praise Project" title, no brand context.

The existing architecture is sound and the Hotwire/Tailwind/Stimulus stack is well-suited for all redesign work. No technology changes are needed — this milestone is purely UI.

---

## Table Stakes

Features users expect from a redesigned worship tool. Missing any of these and the new visual skin will feel like a theme applied over a broken app.

| Feature | Why Expected | Complexity | Current State |
|---------|--------------|------------|---------------|
| Warm color palette (not indigo/gray default) | Generic SaaS palette signals "this isn't built for us"; worship teams use tools like ProPresenter, Planning Center, which have distinct identity | Low | Not present — pure default Tailwind palette |
| Consistent rounded-xl component language | Rounded shapes feel softer, less corporate; consistent rounding across cards, buttons, and inputs reads as intentional design | Low | Inconsistent — some `rounded`, some `rounded-lg`; no unified token |
| Deck list as card grid (not plain list) | Cards communicate "these are your worksessions"; a flat list of links feels like a spreadsheet | Low-Med | Flat `divide-y` list — no card personality |
| Deck creation as the primary nav entry point | The most common action for a worship leader starting their Sunday prep should be the most prominent affordance | Low | "Decks" and "Songs" are equal-weight nav links; no visual primary-action emphasis |
| Polished flash messages with icons and auto-dismiss | Raw banner text at the top of the page is jarring after an action; contextual icons (checkmark for success, warning for error) and auto-dismiss signal care | Medium | Flat banner, no icon, no auto-dismiss, disappears only on navigation |
| Actionable error messages | "Could not find lyrics" must tell the user exactly what to do next — the fallback path (paste lyrics) must be prominently surfaced, not buried in the current error card | Low | Functional but prose-heavy and unstyled |
| Skeleton/spinner conventions on loading states | The import processing card and export button spinners need visual consistency — same spinner size, same label style, same placement | Low | Each built independently — spinner in processing card is sized differently from export button spinner |
| Empty state with call to action on decks index | First time a worship leader logs in, they need immediate orientation: what is this, what should I do first | Low | Single sentence + button, no context |
| Readable typography scale | Headline / body / caption hierarchy must feel deliberate, not default browser / default Tailwind | Low | Text sizes are functional but not tuned as a type scale |
| Auth pages that feel like the product | Sign-in page currently has no brand context; a bare form makes first-time users uncertain they landed in the right place | Low | Bare form, no logo, no warmth |

---

## Differentiators

Features that give the redesigned app a noticeably better feel than "generic SaaS with a palette swap." These are what separate a thoughtful worship tool from a template.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Worship-specific color palette | Earthy warm tones (amber, warm stone, muted gold) rather than corporate indigo. Think candlelight, aged wood, rich fabric — materials that read as reverent rather than productive | Low | Tailwind config change: custom `worship-*` color tokens. No framework changes. |
| Song card "section badge" in library | Cards in the song library should show section count (e.g., "4 sections") or first lyric line — already partially implemented — but styled with a section type badge that communicates structure at a glance | Low | First lyric line preview already exists; needs visual badge treatment |
| "Add song" as inline drawer/panel, not page nav | Opening the "add song" workflow from the deck editor as a slide-in Turbo Frame panel rather than a list in the sidebar avoids the visual clutter of showing the entire library in a narrow column | Medium | Current implementation: song search is already inline in the sidebar. Could be enhanced with a drawer pattern for better use of space. |
| Processing state that communicates "AI is working" | The import spinner says "Importing song..." but doesn't convey that Claude is actively doing something interesting. A slightly warmer card with a subtle pulse animation and copy like "Claude is structuring your lyrics..." sets expectations and reduces abandon-and-refresh behavior | Low-Med | Stimulus controller already handles Turbo Stream updates; copy and visual style change only |
| Empty state with worship context | Rather than "No decks yet", an empty state that says something like "Your Sunday slide deck starts here — search for a song or start a new deck" with a small illustrated icon anchors the purpose of the tool | Low-Med | Copy and a simple SVG icon; no backend changes |
| Deck card with date prominence | Worship leaders think in terms of service dates. The deck card should lead with the date (e.g., "Sunday 15 March") in a prominent typographic position, with the deck title secondary | Low | Currently date is `text-sm text-gray-500 ml-2` — afterthought styling |
| Section labels (verse/chorus/bridge) with color coding | In the slide preview and arrangement panel, section type labels (verse, chorus, bridge) displayed with distinct warm-palette color chips help leaders scan arrangement at a glance | Low | Currently section_type is shown as raw text in the slide preview at 40% opacity |
| Export button as a prominent "done" state | The export button is a small `text-sm px-4 py-2` button in the header. For a download-first workflow, the export action should feel like a major affordance — larger, with a download icon, and the "ready" state should feel celebratory | Low | Button state machine already exists; visual treatment upgrade only |
| Song metadata display (CCLI, key, artist) | v1.1 adds CCLI number, key, and artist/composer fields (META-01/02). These should appear as a secondary metadata row on song cards and song pages — subtle but scannable | Low | Fields being added in this milestone; visual placement is a design decision |
| Onboarding cue on first deck creation | After a user creates their first deck and lands on the empty deck editor, a contextual banner saying "Now add your first song — search the library or import by title" removes the "now what?" moment | Low | No onboarding layer exists today |

---

## Anti-Features

Features to explicitly not build in this milestone, even though they may feel tempting during a redesign.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Dark mode toggle | Doubles the visual system to maintain; adds interaction complexity; users use projector tools in lit rooms, not dark rooms | Ship one warm light theme; revisit dark mode if users ask |
| Per-component animation library (AOS, Animate.css, etc.) | These libraries add kb, introduce timing conflicts with Turbo page transitions, and make the app feel like a marketing site | Use Tailwind's built-in `transition`, `duration-150`, `ease-in-out`; one global `animate-spin` for spinners |
| Custom icon set requiring asset pipeline changes | SVG icon libraries introduce dependency management overhead; Importmap does not handle npm icon packages cleanly | Use Heroicons inline SVG snippets directly in ERB; no icon library dependency |
| Skeleton loading screens for every page | Full skeleton screens require mirroring the layout structure in a placeholder component — high maintenance cost for minor polish | Spinner + contextual copy is sufficient; reserve skeletons for the slide preview panel only if needed |
| Redesigning the Devise registration/confirmation email templates | Email HTML is a separate maintenance surface; not visible to most users (small team that signs up once) | Leave email templates as-is; focus on in-app flows |
| Toast notification stack / snackbar system | A full toast system (multiple concurrent, stacking, dismiss queue) is over-engineered for an app that generates one flash message per action | Upgrade existing flash banner to a single polished auto-dismiss component; not a stack |
| Responsive/mobile-first layout rework | Primary use case is desktop (worship leader at a laptop building slides); mobile responsiveness is out of scope per PROJECT.md | Keep existing max-width containers; ensure nothing is actively broken at tablet width, but don't optimize for mobile |
| Sidebar navigation / rail navigation pattern | A sidebar nav implies the app has many peer sections; this app has two: Decks (primary) and Songs (secondary) | Top navigation bar is correct; de-emphasize Songs link, not add nav complexity |
| Custom Tailwind component library / design system docs | A full component library is overkill for a single-team app at this scale | Establish CSS custom property tokens (colors, radii) in `tailwind.config.js`; that's the full "design system" needed |

---

## Feature Dependencies

These apply specifically to the UI redesign work:

```
Tailwind config (custom color tokens, radius scale)
  └─> All component visual changes (buttons, inputs, cards, nav)
        └─> Form consistency pass (all forms use new tokens)
        └─> Navigation redesign (primary/secondary visual weight)
              └─> Auth pages (same layout and color system)

Flash message component upgrade
  └─> Auto-dismiss Stimulus controller (new small controller)

Empty state designs
  └─> Deck index empty state
  └─> Deck editor empty state (no songs added yet)
  └─> Song library empty state
  └─> Onboarding cue on first deck editor open

Song metadata display (CCLI, key, artist)
  └─> META-01 / META-02 migrations (must land before UI references fields)

Scripture slide UI
  └─> SCRIP-01 data model (must land before UI)
```

Key dependency constraints:
- All component visual work is gated on `tailwind.config.js` custom token definitions — that is the first PR
- Flash message auto-dismiss requires a new `flash_controller.js` Stimulus controller — small, self-contained, does not block anything
- Song metadata display (META-01/02) and scripture slide UI (SCRIP-01) are gated on their respective migrations shipping first; the visual design can be drafted in parallel but not deployed until data exists

---

## Worshipful vs. Generic SaaS: The Key Distinctions

This section directly answers the research question and is written to inform roadmap decisions on visual direction.

### What "worshipful" means in practice

**Color language:** Worship environments use warm, reverent tones — not because of a design trend, but because the physical environments (sanctuaries, lit candles, wood, fabric) create that expectation. Generic SaaS indigo/blue reads as productivity software. Amber, warm stone (Tailwind's `stone` palette), muted gold, and deep warm navy (not cold blue navy) read as appropriate for the domain. The background body color should be warm off-white (`stone-50`) not neutral gray (`gray-50`).

**Typography:** Worship software tends toward slightly larger, more spaced type than productivity tools. Line height is generous. Headings are not crowded. The reading experience should feel calm and deliberate, not dense.

**Borders and depth:** Softer borders (lighter border color, `border-stone-200` not `border-gray-200`), more generous padding inside cards, and subtle box shadows create breathing room. The deck editor's slide preview cards already use `shadow` — this visual approach should extend throughout.

**Iconography tone:** Worship tools use icons sparingly and favor simple outline icons (Heroicons outline set) over filled icons. Dense iconography feels like a dashboard; sparse iconography with clear labels feels focused.

**Interactive states:** Hover states in worship tools should be gentle — a light warm fill (`hover:bg-amber-50`) not a sharp color shift. Focus rings should be warm-colored (amber or warm indigo), not default browser blue.

### What "generic SaaS" looks like in v1.0 (and what to change)

| v1.0 Pattern | Generic SaaS Signal | Worshipful Replacement |
|---|---|---|
| `bg-gray-50` body | Default admin template | `bg-stone-50` or `bg-amber-50/30` warm off-white |
| `text-indigo-600` primary | Default SaaS accent | Custom warm primary: deep amber-brown or warm slate |
| `border-gray-200` everywhere | Default Tailwind border | `border-stone-200` or `border-warm-200` — same lightness, warmer hue |
| `bg-indigo-600` buttons | Default CTA color | Warm primary button: `bg-amber-700` or `bg-stone-700` |
| Flat banner flash messages | Bootstrap-era alert style | Rounded card with icon, auto-dismiss, warm success green |
| Equal-weight nav links | Generic multi-section app | Deck creation prominent; Songs de-emphasized |
| "No decks yet" empty state | Bare scaffolding | Illustrated empty state with workflow context |
| Plain "Praise Project" text logo | Default title | Wordmark with light warmth — even just a styled text mark |

### What ProPresenter and Planning Center do well (transferable patterns)

- **Planning Center** (the dominant worship planning tool in US evangelical churches) uses a warm, human color palette: deep teal-green primary, warm grays, gentle card shadows. Navigation is task-oriented ("Services" is the entry point, not a generic CRUD list).
- **ProPresenter** (projection software) uses a near-black dark theme for its editor to simulate the projection environment. This is NOT recommended for a web app — it works for desktop projection software but feels oppressive in a browser tab during planning.
- Both tools are generous with whitespace. They do not feel dense or information-overloaded even when displaying a full service plan.
- Both tools use card-based navigation for the primary objects (services/presentations), not table rows.
- Both tools surface the most recent/upcoming items prominently — dates are first-class information.

---

## MVP Recommendation for v1.1

**Prioritize (must ship for milestone):**

1. Tailwind config with custom warm palette tokens (`tailwind.config.js`) — enables everything else; Low complexity
2. Navigation visual redesign — Decks as primary, Songs as secondary; `bg-stone-50` body; warm logo wordmark; Low complexity
3. Deck list as card grid with date prominence — replaces flat list; Low-Medium complexity
4. Consistent form system — all inputs, labels, buttons, focus states use new tokens; Low complexity (search/replace CSS classes)
5. Flash message upgrade — rounded card, icon, auto-dismiss Stimulus controller; Medium complexity
6. Empty states with context — deck index, deck editor (no songs), song library; Low complexity (copy + SVG icon)
7. Onboarding cue on first deck — contextual banner after creation; Low complexity
8. Processing / loading state visual polish — consistent spinner, warmer copy on the import card; Low complexity

**Defer to v1.2 or as stretch goals:**

- Song section badge color coding (nice, not critical)
- Export button visual upgrade to prominent "done" affordance (functional now; cosmetic upgrade)
- Auth page illustration or brand artwork (low user-hours impact for a small team that signs up once)
- Deck card section count or song thumbnail preview (requires additional DB query, minor value)

---

## Sources

### Primary (HIGH confidence — direct codebase inspection)
- All views in `/app/views/` inspected: `layouts/application.html.erb`, `decks/index.html.erb`, `decks/show.html.erb`, `decks/_form.html.erb`, `decks/_export_button.html.erb`, `songs/index.html.erb`, `songs/show.html.erb`, `songs/_processing.html.erb`, `songs/_failed.html.erb`, `devise/sessions/new.html.erb`
- `app/assets/stylesheets/application.css` — confirms Tailwind is the only styling system; no custom CSS beyond pinyin toggle
- `app/javascript/controllers/` — confirms Stimulus controller inventory; no existing flash or onboarding controllers

### Secondary (MEDIUM confidence — knowledge of comparable tools)
- Planning Center People / Services visual patterns — card-based service list, warm palette, date prominence
- ProPresenter 7 UI conventions — large projection preview, operator-focused dark mode (explicitly rejected for web app use)
- EasyWorship — older tool; legacy patterns; not recommended as model
- Tailwind UI component library — component patterns for cards, flash messages, empty states

### Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| v1.0 gap diagnosis | HIGH | Based on direct code inspection of all views |
| Worshipful vs generic distinction | MEDIUM | Knowledge of Planning Center, ProPresenter, and ministry app aesthetics; no A/B test data |
| Complexity estimates | HIGH | All changes are CSS class updates + small Stimulus controllers; no new backends or APIs |
| Anti-feature reasoning | HIGH | Based on Importmap constraints (no npm icon packs), Turbo Streams behavior (avoid competing animations), and small-team scope |

---

*Research completed: 2026-03-15*
*Feeds: v1.1 Design milestone roadmap*

# Domain Pitfalls

**Domain:** UI redesign on existing Rails 8 + Hotwire (Turbo + Stimulus) + Tailwind v4 app
**Researched:** 2026-03-15
**Confidence:** HIGH — all pitfalls grounded in direct codebase inspection, not assumptions

---

## Critical Pitfalls

Mistakes that cause silent breakage of existing functionality or require rewrites to fix.

---

### Pitfall 1: Renaming Turbo Stream Target DOM IDs

**What goes wrong:** Three background jobs broadcast Turbo Stream updates that target hardcoded DOM IDs. If a redesign renames or removes those IDs in the ERB templates, the broadcast lands on a missing target and the UI never updates — no error, no feedback, silent failure.

**Root cause:** The contract between job and template is invisible — it lives only in the string literals.

| Job | Broadcast target | Template location |
|-----|-----------------|-------------------|
| `GeneratePptxJob` | `export_button_#{deck_id}` | `decks/_export_button.html.erb` line 5 |
| `GeneratePptxJob` (error) | `export_button_#{deck_id}` | same |
| `GenerateThemeSuggestionsJob` | `theme_suggestions` | `decks/show.html.erb` line 175 |
| `ImportSongJob` (step/done/fail) | `import_status` | `songs/processing.html.erb` line 13 |
| `ImportSongJob` | `song_status_#{song.id}` | `songs/show.html.erb` line 9 |

**Consequences:**
- Export button stays in "Generating..." state forever after PPTX finishes
- Theme suggestions spinner never resolves
- Song import page never transitions from "Importing song..."

**Prevention:** Before touching any of these templates, write a list of every `id=` attribute that appears as a `target:` in a job broadcast. Treat these IDs as a public API — change both sides atomically, or keep them as a stable internal wrapper `div` that the redesign decorates around, not replaces.

**Detection warning signs:**
- Clicking "Export PPTX" shows spinner indefinitely after redesign
- "Get AI Suggestions" button never populates suggestions panel
- Song import page frozen after Solid Queue worker completes the job

**Phase:** Any phase touching `decks/show.html.erb`, `decks/_export_button.html.erb`, `songs/processing.html.erb`, or `songs/show.html.erb`.

---

### Pitfall 2: Breaking the `data-drag-handle` and `data-id` Contract in Sortable Items

**What goes wrong:** `sortable_controller.js` relies on two conventions: every draggable item has a `data-id` attribute, and the drag handle is the element with `data-drag-handle`. It also reads `this.element.children` to reconstruct arrangement order. If redesign wraps items in an extra wrapper `div` or moves the drag handle into a nested component without `data-drag-handle`, the controller silently stops working.

**Root cause:** The controller reads structural assumptions about the DOM — direct children, presence of a specific data attribute — that are invisible to designers working from screenshots.

**Consequences:**
- Drag-and-drop reordering stops working for both songs (deck-level) and slides (within song blocks)
- `onEnd` callback fires with stale positions or undefined IDs
- PATCH request to `reorder` or `update_arrangement` sends wrong data, arrangement silently corrupts

**Prevention:** The `data-drag-handle` and `data-id` attributes must survive redesign. When rebuilding `_song_block.html.erb` and `_slide_item.html.erb`, carry these attributes forward verbatim on the same elements. Do not change the direct-children relationship on the sortable container.

**Detection warning signs:**
- Drag handle visible but dragging does nothing
- Reordering songs changes display order but next page load reverts
- Console error: `Cannot set properties of undefined (setting 'id')`

**Phase:** Any phase touching `deck_songs/_song_block.html.erb` or `deck_songs/_slide_item.html.erb`.

---

### Pitfall 3: Removing or Renaming the `.pinyin-hidden` CSS Class

**What goes wrong:** `pinyin_toggle_controller.js` adds/removes the class `pinyin-hidden` on a container element. This class is defined in `app/assets/stylesheets/application.css` (not in Tailwind). If a redesign removes this CSS rule while cleaning up stylesheets, or renames the class to match Tailwind conventions, the toggle stops hiding pinyin.

**Root cause:** One custom CSS class (`pinyin-hidden`) lives outside Tailwind. It is easy to miss during a stylesheet consolidation.

**Consequences:**
- "Show/Hide Pinyin" toggle appears functional (button text changes) but pinyin `<rt>` elements remain visible
- The slide preview loses its pinyin-hiding capability

**Prevention:** Keep `app/assets/stylesheets/application.css` with the `.pinyin-hidden` rule intact, or explicitly migrate it as part of any stylesheet change — never delete it as cleanup. Document that this class is consumed by `pinyin_toggle_controller.js`.

**Detection warning signs:**
- Toggle button text changes but pinyin does not disappear
- `<rt>` elements visible in the DOM with `pinyin-hidden` class present on ancestor

**Phase:** Any phase that consolidates or restructures stylesheets.

---

### Pitfall 4: Tailwind v4 Content Detection Missing Dynamic Class Strings

**What goes wrong:** This app uses `tailwindcss-rails ~> 4.4` which is Tailwind v4. Tailwind v4 uses CSS-first config (`@import "tailwindcss"` — confirmed in `app/assets/tailwind/application.css`). In v4, class detection is content-aware: only classes that appear as complete strings in scanned files are emitted. Classes assembled from string interpolation are invisible.

**Root cause:** Several templates construct class names at runtime. Known examples:
- `decks/show.html.erb` line 114: `font_cqw = { "small" => "2.8", "large" => "4.5" }.fetch(...)` — these strings are used in inline `style=`, not Tailwind classes, so this specific case is safe. But the pattern invites similar mistakes with Tailwind classes.
- Any redesign that introduces `"text-#{color}"` or `"bg-#{variant}"` string patterns will produce classes Tailwind never emits.

**Consequences:**
- Class silently missing from output CSS in production (Tailwind processes files at build time, not runtime)
- Element renders without the expected color, size, or spacing
- Works in development only if CSS is rebuilt on every change; breaks on first deploy

**Prevention:**
- Never construct Tailwind class names via string interpolation. Use full class names in conditionals: `condition ? "bg-red-500" : "bg-green-500"`.
- For conditional class switching in controllers (JavaScript side), always use full class names in the Stimulus controller source, not template literals.
- Use a safelist block in Tailwind v4 config if truly dynamic classes are required.
- After any major template change, do a production-mode CSS build (`rails tailwindcss:build`) and visually verify the affected page before committing.

**Detection warning signs:**
- Style present in development but absent after deploy
- `class="bg-indigo-600"` in page source but no matching rule in network tab CSS

**Phase:** All redesign phases. Highest risk when introducing new color palette or new conditional class sets.

---

### Pitfall 5: Navigation Restructuring Breaks `data: { turbo: false }` Import Form

**What goes wrong:** The song import form in `decks/show.html.erb` is deliberately marked `data: { turbo: false }`. This does a full-page navigation to `songs#processing`, which uses `turbo_stream_from` and `redirect_controller` to poll and redirect when done. If redesign moves this form into a modal, a Turbo Frame, or changes the navigation target without preserving the full-page navigation behavior, the broadcast-driven redirect breaks.

**Root cause:** `redirect_controller.js` calls `Turbo.visit(this.urlValue)` on connect. This works when the controller mounts in a full-page context. Inside a Turbo Frame, `Turbo.visit` navigates the top-level frame, which may or may not be the intended behavior. Inside a modal, the element may be destroyed before the controller connects.

**Consequences:**
- Song import appears to complete (job runs) but user is stuck on the form with no feedback
- `redirect_controller` connects inside a Turbo Frame and navigates only the frame instead of the page
- Modal dismissed before broadcast arrives, controller never connects

**Prevention:** Keep the song import flow as a full-page navigation for v1.1. If redesign wraps the import trigger in a modal or slide-out panel, ensure the form still targets a full-page response (preserve `data: { turbo: false }`), or redesign the entire flow with explicit awareness of the `redirect_controller` dependency.

**Detection warning signs:**
- Clicking "Import" submits successfully but the processing page never appears
- Song import job completes in logs but UI shows nothing
- After import, page does not redirect to the deck

**Phase:** Any phase that restructures the deck show layout or adds modal/panel patterns to song import.

---

## Moderate Pitfalls

---

### Pitfall 6: Adding New Stimulus Controllers That Conflict With Existing Ones

**What goes wrong:** Rails auto-registers all controllers in `app/javascript/controllers/` using `stimulus-loading`. A redesign adding new controllers is fine, but the app also uses SortableJS initialized inside `sortable_controller`. If a new UI pattern attaches a second `data-controller="sortable"` to an element that is already a child of another sortable, the two SortableJS instances conflict — drop events fire twice or in wrong order.

**Root cause:** Stimulus controller naming is global; the sortable controller uses `this.element.children` to read positions. Nested sortables require explicit `group` configuration in SortableJS.

**Consequences:**
- Dragging a slide item fires both the inner and outer sortable's `onEnd`
- PATCH requests sent twice with conflicting positions
- Arrangement JSONB gets corrupted

**Prevention:** The deck show page already has two nested sortable levels (song order outer, slide arrangement inner — in `_song_block.html.erb` lines 28-31 and the inner `div` lines 29-32). Do not add a third level without configuring SortableJS `group` options. When adding new draggable areas, audit whether they are inside an existing sortable container.

**Phase:** Any phase adding new drag-and-drop UI or restructuring the deck show three-column layout.

---

### Pitfall 7: Replacing `content_for(:main_class)` Without Accounting for Page-Specific Overrides

**What goes wrong:** The application layout uses a `content_for(:main_class)` yield to allow individual pages to override the main container class. `decks/show.html.erb` sets `content_for :main_class, 'w-full px-6 py-8'` to go full-width (the deck editor needs all available space). If a redesign replaces this mechanism with a fixed layout class or a CSS container, the deck show page loses its full-width layout.

**Root cause:** The override is a one-line comment at the top of the view that is easy to miss or remove as "old code."

**Consequences:**
- Deck editor constrained to `max-w-5xl` like all other pages
- Three-column layout (`grid-cols-12`) cramped and unusable

**Prevention:** Preserve the `content_for(:main_class)` mechanism or replace it with an equivalent override pattern. When redesigning the layout, verify the deck show page specifically at full browser width.

**Phase:** Phase redesigning `layouts/application.html.erb` or the main container structure.

---

### Pitfall 8: Flash Message Redesign Conflicts With Devise's Flash Keys

**What goes wrong:** Devise uses both `:notice` and `:alert` flash keys, but also adds `:error` in some code paths and uses `:timedout` for session expiry. The current layout checks only `if notice` and `if alert`. A redesign adding support for `:error`, `:success`, or other semantic flash types may not wire up Devise's actual keys, causing Devise errors to appear as raw yellow Rails debug output.

**Root cause:** Devise flash key behavior is not documented prominently and varies by Devise version.

**Consequences:**
- Password reset failure shows no visible error message
- Session timeout shows generic Rails error instead of styled message
- Custom error flash types silently swallowed

**Prevention:** When redesigning flash messages, map Devise's actual keys. At minimum: `notice`, `alert`. Consider wrapping both under a semantic-agnostic loop: `flash.each do |type, message|`. Use a type-to-style mapping for color.

**Phase:** Phase redesigning flash messages and global notification UI.

---

### Pitfall 9: Inline `style=` Attributes for Theme Colors Are Not Tailwind — Do Not Replace With Classes

**What goes wrong:** The slide preview in `decks/show.html.erb` uses inline `style=` attributes for dynamic theme colors (`background-color: #{theme.background_color}`, `color: #{theme.text_color}`). These are user-supplied hex values stored in the database — they cannot be Tailwind classes. A redesign that tries to "clean up" inline styles by converting them to Tailwind classes will break theme rendering entirely.

**Root cause:** Designers unfamiliar with the data model may see `style="background-color: #..."` as a code smell and attempt to replace it with `class="bg-indigo-600"`.

**Consequences:**
- Slide preview ignores user's custom theme colors and shows hardcoded Tailwind values
- PPTX export unaffected (uses database values directly in Python), so desktop output and preview diverge

**Prevention:** Never convert dynamic user data (colors, font sizes) from inline styles to Tailwind utility classes. These values must remain inline. The `style=` attributes in `decks/show.html.erb` (lines 112-115, 131) are intentional and correct.

**Phase:** Any phase touching the slide preview or theme display sections of deck show.

---

### Pitfall 10: `turbo_stream_from` Requires ActionCable — Verify Solid Cable in Redesign Environments

**What goes wrong:** The deck show page subscribes to two live channels via `turbo_stream_from`. These use Solid Cable (not Redis). If a redesign spin-up (staging server, preview deploy) does not run a Solid Queue worker and does not configure Solid Cable correctly, the export and theme suggestion streams silently never arrive. The bug manifests as an apparent redesign regression when it is actually an infrastructure issue.

**Root cause:** Solid Cable uses the database as the cable backend. In preview environments that share a database but don't run the full process stack, broadcasts are queued and never consumed.

**Prevention:** When evaluating redesign changes, always test in an environment with the full `bin/dev` process stack (web + worker). Do not evaluate Turbo Stream behavior in a static screenshot or a server started with `rails s` alone (no worker).

**Phase:** Infrastructure awareness for all testing phases. Note at start of every phase touching `decks/show.html.erb`.

---

## Minor Pitfalls

---

### Pitfall 11: Removing `hello_controller.js` Breaks Nothing But Creates Import Error

**What goes wrong:** `hello_controller.js` exists in `app/javascript/controllers/` and is auto-registered. It is scaffolding not used anywhere. If it is deleted during a cleanup phase without also removing or regenerating `index.js`, the auto-loader may throw a module not found error in the browser console — harmless but confusing.

**Prevention:** When removing scaffold controllers, run `bin/importmap audit` after deletion.

---

### Pitfall 12: Changing Button `type` Implicitly Breaks `button_to` Turbo Method

**What goes wrong:** `button_to` in Rails generates a single-button form. It relies on the button being `type="submit"`. If a redesign wraps a `button_to` output in a component that renders its own `<button>` element, the result has two nested forms or two submit buttons, causing unexpected behavior with `data: { turbo_method: :delete }`.

**Prevention:** When building UI components for action buttons, use ERB partials or `content_tag` helpers, not new `<button>` wrappers around existing `button_to` calls.

---

### Pitfall 13: `animate-spin` and Other Tailwind Utility Classes Used in Job-Broadcast HTML Strings

**What goes wrong:** `GenerateThemeSuggestionsJob` broadcasts raw HTML strings containing Tailwind classes directly: `class="text-xs text-red-400 py-2"`. If the redesign renames or removes these utility classes from the Tailwind source, the broadcast HTML renders without the expected styles — and there is no compile-time check because the strings live in Ruby job files, not scanned ERB templates.

**Prevention:** When changing Tailwind class names during a redesign (e.g., switching from `text-red-400` to a custom semantic token), grep for Tailwind class strings in `app/jobs/` and `app/controllers/`. These files are not scanned by the Tailwind content detector by default in Tailwind v4 unless explicitly added to the source list.

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Navigation bar redesign | Turbo Stream target IDs in deck/song views are nearby and easy to accidentally disturb | Audit all `id=` attributes before touching layout |
| Color palette and typography | Dynamic theme colors via `style=` must stay inline; palette only applies to static UI chrome | Separate "theme UI" from "deck theme colors" conceptually |
| Deck show layout restructure | Sortable data contracts, `content_for(:main_class)`, and all three Turbo channel targets live here | Touch last, test heavily |
| Flash / notification redesign | Devise flash keys may differ from app flash keys | Use `flash.each` instead of explicit key checks |
| Empty states / onboarding cues | These are new DOM elements; low risk of regression | Fine to build freely, but avoid adding `data-controller` inside sortable containers |
| Song import flow | `data: { turbo: false }` and `redirect_controller` are load-bearing; full-page navigation is intentional | Do not wrap import form in Turbo Frame or modal without redesigning the entire flow |
| Stylesheet consolidation | `.pinyin-hidden` class and any classes in job-broadcast HTML strings are outside Tailwind scan | Grep for class names in `.rb` files before pruning CSS |

---

## Sources

All findings are based on direct inspection of the following codebase files (HIGH confidence — no external sources required):

- `app/assets/tailwind/application.css` — confirms Tailwind v4 CSS-first config
- `app/assets/stylesheets/application.css` — confirms `.pinyin-hidden` lives outside Tailwind
- `app/javascript/controllers/sortable_controller.js` — drag handle and data-id contract
- `app/javascript/controllers/pinyin_toggle_controller.js` — `.pinyin-hidden` class dependency
- `app/javascript/controllers/redirect_controller.js` — `Turbo.visit` on connect
- `app/jobs/generate_pptx_job.rb` — hardcoded `export_button_#{deck_id}` target
- `app/jobs/import_song_job.rb` — hardcoded `import_status` target; raw HTML with Tailwind classes in broadcasts
- `app/jobs/generate_theme_suggestions_job.rb` — hardcoded `theme_suggestions` target; raw HTML with Tailwind classes
- `app/views/decks/show.html.erb` — `turbo_stream_from` subscriptions, `content_for(:main_class)`, inline style= theme colors, nested sortable setup
- `app/views/decks/_export_button.html.erb` — `id="export_button_#{deck.id}"` target
- `app/views/songs/processing.html.erb` — `id="import_status"` target
- `app/views/songs/show.html.erb` — `id="song_status_#{@song.id}"` target
- `app/views/deck_songs/_song_block.html.erb` — `data-drag-handle`, `data-id`, nested sortable
- `app/views/deck_songs/_slide_item.html.erb` — `data-drag-handle`, `data-id`
- `app/views/layouts/application.html.erb` — flash rendering, `content_for(:main_class)` yield
- `Gemfile` — confirms `tailwindcss-rails ~> 4.4`, `turbo-rails`, `solid_cable`
- `config/importmap.rb` — confirms auto-loaded controllers from `app/javascript/controllers/`
- `config/routes.rb` — all route paths used in action links and job redirects