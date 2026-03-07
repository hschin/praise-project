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
