# Project Research Summary

**Project:** ChurchSlides (praise-project)
**Domain:** Worship presentation / PPTX slide generator for Chinese church teams
**Researched:** 2026-03-07
**Confidence:** HIGH — based on direct codebase inspection and domain expertise

## Executive Summary

ChurchSlides is a specialized worship preparation tool that automates the most tedious part of Chinese church worship planning: searching for song lyrics, adding pinyin tone marks, and assembling formatted PowerPoint slides for projection. The core value loop is a two-stage AI pipeline — Claude first (it knows most mainstream Chinese worship songs), then targeted Nokogiri scrapers for gaps — which feeds a structured lyrics editor and ultimately produces a PPTX file usable on any projector system. The existing Rails 8.1.2 codebase already has Devise, Solid Queue, Hotwire, and the Python subprocess stub in place; the critical missing pieces are the `anthropic` gem and Python/CJK font configuration in the Dockerfile.

The recommended architecture is strictly phased: establish data models and auth first, then the AI lyrics pipeline, then the deck editor with slide arrangement, then PPTX export. These phases are hard dependencies — the export has no value without slides, slides have no value without lyrics, and lyrics require the AI pipeline to be reliable. Every external call (Claude API, PPTX generation) must run in a Solid Queue background job from the start; running either synchronously in a controller will produce request timeouts under Thruster.

The single highest-impact risk is CJK font rendering in PPTX: slides will look correct on the developer's Mac but render as empty rectangles on a Windows projector if the east-Asian font slot is not explicitly set in python-pptx and the Noto CJK font is not bundled in the Docker image. Pinyin accuracy for polyphonic characters (多音字) is the second trust-breaking risk — Claude must receive full lyric sections for context, and the editor must surface a "needs review" flag to worship leaders before the tool is used in a live service.

## Key Findings

### Recommended Stack

The existing stack is well-chosen for this scope and mostly already installed. The importmap-only setup rules out React/Vue — Turbo Frames and Stimulus are the correct choice. Solid Queue (already present) handles background jobs without requiring Redis. The only Ruby-side gap is `gem "anthropic"`, which is documented in the codebase but missing from the Gemfile.

For PPTX generation, every Ruby gem alternative was evaluated and rejected: `caracal` produces DOCX, `ruby-pptx` has poor CJK support and is unmaintained, and `caxlsx` targets spreadsheets. `python-pptx` via a Ruby subprocess using `Open3.capture3` is the correct solution — it is mature, actively maintained, and has full CJK support. The Dockerfile must add `python3`, `python3-pip`, `python-pptx`, and `fonts-noto-cjk`.

**Core technologies:**
- Rails 8.1.2 + Devise: web framework and auth — already installed
- Turbo Frames + Stimulus (Hotwire): UI framework — no npm; fits importmap setup perfectly
- Solid Queue: background jobs — already installed; PostgreSQL-backed, no Redis needed
- `gem "anthropic"`: Claude API client — **must add to Gemfile**
- python-pptx (Python subprocess): PPTX generation — **must configure Dockerfile**
- Nokogiri: lyrics scraping fallback — already a transitive dependency
- Active Storage: PPTX file delivery — built into Rails 8

### Expected Features

**Must have (table stakes):**
- Song search by title (CJK and English) — fundamental entry point
- AI lyric fetch with automatic section detection (verse/chorus/bridge) — core value loop
- Pinyin generation above Chinese text — non-native readers depend on this; accuracy is load-bearing
- Inline slide editing and text correction — AI output is never 100% accurate
- Slide reordering and deletion within a song — worship leaders adjust flow at runtime
- Service/setlist management — group songs into one service = one PPTX
- Visual theme selection (3-5 curated templates) — dark background + light text is the projection standard
- PPTX export — the deliverable; must survive round-trip on Windows PowerPoint
- Song library persistence — once fetched, reusable by all team members
- User authentication — multiple team members share the library

**Should have (differentiators):**
- Claude-first lyrics recall (zero scraping for mainstream songs) — biggest workflow time savings
- Context-aware pinyin with polyphone disambiguation — competitive advantage over Word plugins
- Simplified Chinese normalization from Traditional web sources — transparent to the user
- Bilingual song title search (English alias + Chinese) — matches how songs are known in Chinese churches
- Per-service theme (not per-song) — reduces cognitive load; one decision for the whole service
- Manual lyrics paste fallback — escape hatch when scraping fails

**Defer (v2+):**
- Scripture slides (version complexity, text licensing)
- Announcement or sermon slides (different workflow)
- Real-time multi-user collaboration (unnecessary for small team)
- Live in-browser presentation mode (PPTX export already achieves this)
- CCLI SongSelect import (format parsing is brittle)
- Multi-church / SaaS tenancy
- Version history / audit trail

### Architecture Approach

The architecture is a classic thin-controller Rails app with three service objects handling all external integrations: `LyricsScraper` (web search + Nokogiri parsing), `LyricsEnricher` (Claude API structuring + pinyin), and `PptxBuilder` (python-pptx subprocess). Controllers never call external services directly — they enqueue Solid Queue jobs and return immediately, with job completion broadcast to the UI via Turbo Streams. The data model uses `DeckSong.arrangement` as a JSONB array of lyric IDs as the authoritative slide order; `Slide` records are a derived projection of this, never an independent source of truth.

**Major components:**
1. `LyricsScraper` + `LyricFetchJob` — two-stage retrieval: Claude recall first, Nokogiri fallback second
2. `LyricsEnricher` + `LyricEnrichJob` — Claude API: section detection, Simplified conversion, pinyin generation in one call
3. `PptxBuilder` + `PptxGenerateJob` — Python subprocess with JSON protocol on stdout; Active Storage for file delivery
4. Deck editor (Turbo Frames + Stimulus + Sortable.js) — slide arrangement, inline editing, theme selection
5. Turbo Streams broadcasts — async job status updates ("Importing lyrics..." / "Export ready")

### Critical Pitfalls

1. **CJK characters render as rectangles on Windows projectors** — set the east-Asian font slot explicitly in python-pptx XML (`a:eastAsianFont`), bundle `fonts-noto-cjk` in the Docker image, and test on a Windows VM before any worship team demo. This is invisible in local development.

2. **Pinyin wrong for polyphonic characters (多音字)** — send Claude the full lyric section for sentence context, not character by character. Add a `pinyin_reviewed` flag on `Lyric` and surface a "needs review" badge in the editor. Worship leaders must be able to correct pinyin before PPTX export.

3. **Ruby → Python subprocess silent failure** — define a JSON protocol contract on stdout (`{ "status": "ok", "file_path": "..." }` or `{ "status": "error", "message": "..." }`), use `Open3.capture3` with explicit exit status checking, and surface errors to the user via Turbo Streams. Silent failure is the current default.

4. **Claude API timeout blocks web requests** — all Claude calls must run in background jobs from Phase 2 onward. Never call `LyricsEnricher` inline in a controller. Turbo Streams must broadcast import status so users know the job is running.

5. **Two-stacked-textbox pinyin layout fragility** — PPTX has no native ruby/furigana API. Use two fixed-Y text boxes per slide (pinyin box above, Chinese box below), disable auto-fit, and define explicit font size ratio (pinyin at ~50% of Chinese size). Test with the longest verse in the song library.

## Implications for Roadmap

Based on the dependency graph in FEATURES.md and the build order in ARCHITECTURE.md, four phases are clearly indicated. Phases 2-4 are strictly sequential.

### Phase 1: Auth + Core Data Models

**Rationale:** Everything depends on User identity (shared library requires it) and the core models (Songs, Lyrics, Decks, Themes). Build the schema and CRUD scaffolding before any external integration so the data layer is stable before complexity is added.

**Delivers:** Working authentication, song/lyric/deck/theme model CRUD, database schema locked, Solid Queue worker confirmed running in development and production.

**Addresses:** User authentication, song library persistence (structural prerequisites only — no AI yet).

**Avoids:** Pitfall #9 (Slide as dual source of truth) — nail the `DeckSong.arrangement` vs `Slide` derived-projection design now, before any UI is built on top of it. Avoids Pitfall #10 (Solid Queue not running in production) — verify worker Procfile entry before Phase 2.

### Phase 2: Lyrics Pipeline (AI Core)

**Rationale:** The AI pipeline is the highest-risk and highest-value part of the system. Build it second so real song data exists for testing Phases 3 and 4. This phase surfaces the hardest integration problems (Claude reliability, scraper fragility, pinyin accuracy) while there is still time to adjust.

**Delivers:** End-to-end lyric import — song search triggers fetch job, Claude enriches with pinyin and sections, lyrics appear in the library. Manual paste fallback for when scraping fails. Song status broadcast via Turbo Streams.

**Uses:** `gem "anthropic"`, Nokogiri, Solid Queue, Turbo Streams.

**Implements:** `LyricsScraper`, `LyricsEnricher`, `LyricFetchJob`, `LyricEnrichJob`.

**Avoids:** Pitfall #4 (Claude timeout) — background jobs from the start. Pitfall #7 (Claude hallucinating lyrics) — Claude structures provided text, never generates. Pitfall #2 (polyphone pinyin) — full-section context in prompt, `pinyin_reviewed` flag introduced here.

### Phase 3: Deck Editor + Slide Management

**Rationale:** With real lyrics in the database, the slide arrangement editor can be built and tested with actual content. This phase covers the full editing workflow worship leaders need before they trust the PPTX output.

**Delivers:** Service/setlist creation, adding songs to a deck, slide reordering (Sortable.js), slide text editing inline, slide deletion, theme selection. A complete deck ready for export.

**Addresses:** Slide reordering, inline editing, slide deletion, service management, theme selection — all table stakes features.

**Avoids:** Pitfall #9 (source of truth drift) — all reordering goes through `DeckSong.arrangement`, never directly to `Slide.position`. Pitfall #2 (pinyin review UI) — "needs review" badge built here before export ships.

### Phase 4: PPTX Export

**Rationale:** Export is the terminal deliverable. Build it last because it requires a complete deck (Phase 3) and because the python-pptx integration has the most environment-specific failure modes. Get everything else working first; then invest in the export layer.

**Delivers:** Working PPTX download — two-stacked-textbox layout, CJK fonts, correct pinyin placement, theme backgrounds applied. Active Storage for file storage. Turbo Streams "Download ready" link.

**Implements:** `PptxBuilder`, `PptxGenerateJob`, Dockerfile with Python 3 + python-pptx + `fonts-noto-cjk`.

**Avoids:** Pitfall #1 (CJK rectangles on Windows) — explicit east-Asian font XML slot, bundled Noto CJK font, Windows VM test required. Pitfall #3 (subprocess silent failure) — JSON protocol contract built before any generation logic. Pitfall #5 (mixed-script layout fragility) — two-stacked-textbox pattern, no auto-fit.

### Phase Ordering Rationale

- Phase 1 before everything: models and auth are prerequisites for all features; schema decisions (especially `DeckSong.arrangement` as source of truth) are expensive to change later.
- Phase 2 before Phase 3: the deck editor needs real lyrics to test meaningfully; testing with mock data masks the real layout challenges.
- Phase 3 before Phase 4: PPTX export needs a complete deck with slides; testing export against empty or stub data misses most real-world formatting issues.
- Pitfalls #1, #3, #5 (all PPTX-related) are grouped in Phase 4 and addressed together — they interact with each other and should be solved as a unit, not scattered across phases.

### Research Flags

Phases likely needing deeper research during planning:

- **Phase 2 (Lyrics Pipeline):** Claude prompt engineering for reliable structured JSON output (section_type, chinese_text, pinyin per section) needs a spike before planning. Which lyrics sites return usable content via SerpAPI for Chinese worship songs is also unvalidated — test before committing to specific scrapers.
- **Phase 4 (PPTX Export):** The two-stacked-textbox layout for pinyin + Chinese characters needs a prototype and Windows projector test before the phase is planned in detail. Font size ratios and Y-position math are environment-dependent.

Phases with well-documented patterns (research-phase can be skipped):

- **Phase 1 (Auth + Models):** Devise + Rails scaffold is a fully documented, established pattern. No research needed.
- **Phase 3 (Deck Editor):** Turbo Frames + Stimulus + Sortable.js is a standard Rails 8 pattern. The drag-to-reorder implementation is well-documented. No research needed.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Based on direct Gemfile.lock and codebase inspection; all decisions are grounded in confirmed existing dependencies |
| Features | HIGH | Feature list derived from established worship software (ProPresenter, EasyWorship, OpenLP) and confirmed against existing domain model |
| Architecture | HIGH | Based on direct codebase inspection; existing service stubs (`LyricsScraper`, python-pptx stub) confirm the architecture is already partially realized |
| Pitfalls | HIGH | CJK font and polyphone pitfalls are well-documented failure modes; subprocess protocol pitfall is confirmed by inspecting the existing stub |

**Overall confidence:** HIGH

### Gaps to Address

- **Claude lyrics coverage for this team's specific song repertoire:** Claude has good coverage of mainstream 赞美之泉 catalog and classic hymns, but coverage of locally-composed or obscure contemporary Chinese praise songs is unknown. Validate with a 20-song sample from the worship team before Phase 2 planning.
- **SerpAPI results for Chinese worship lyrics:** The research assumes SerpAPI returns usable hits for the target lyrics sites. This has not been validated with actual search queries. Test before committing to specific scraper targets in Phase 2.
- **Claude structured JSON prompt reliability:** The exact prompt design needed to reliably produce `{ section_type, chinese_text, pinyin }` JSON from Claude is unresolved. A spike (2-3 hours of prompt engineering) before Phase 2 planning will prevent rework.
- **PPTX layout on Windows projector:** The two-stacked-textbox layout has not been tested on a Windows PowerPoint installation. Font size ratios and Y-positions may need adjustment. Validate before Phase 4 ships to worship team.

## Sources

### Primary (HIGH confidence)
- Direct codebase inspection (`Gemfile.lock`, `database.yml`, `.ruby-version`, `lib/pptx_generator/`) — confirmed stack, versions, existing stubs
- python-pptx official documentation — PPTX generation approach, CJK font slot XML manipulation
- Anthropic `anthropic` Ruby gem documentation — Claude API integration approach

### Secondary (MEDIUM confidence)
- ProPresenter, EasyWorship, OpenLP feature comparison — table stakes feature list
- Chinese church tech community patterns — pinyin placement conventions, font preferences, workflow expectations
- 赞美之泉, 普世颂扬 site analysis — lyrics source viability for Chinese worship

### Tertiary (LOW confidence, needs validation)
- Claude training data coverage for Chinese worship songs — assumed good for mainstream catalog; unvalidated for locally-composed songs
- SerpAPI result quality for Chinese worship lyrics queries — assumed viable; untested

---
*Research completed: 2026-03-07*
*Ready for roadmap: yes*
