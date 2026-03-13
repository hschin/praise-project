# Roadmap: ChurchSlides

## Overview

ChurchSlides ships in four strictly sequential phases driven by hard data dependencies. Auth and schema come first because every other feature requires user identity and stable models. The AI lyrics pipeline comes second because the deck editor needs real lyric data to test meaningfully. The deck editor — slide arrangement, inline editing, theme selection — comes third because PPTX export needs a complete deck to render. Export ships last and is the terminal deliverable: a .pptx file a worship leader can present on any projector without further work.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Auth + Foundation** - User accounts, core data models, and background job infrastructure (completed 2026-03-07)
- [ ] **Phase 2: Lyrics Pipeline** - AI-powered song search, lyric enrichment, pinyin generation, and song library
- [ ] **Phase 3: Deck Editor** - Service/setlist creation, slide arrangement, inline editing, and theme selection
- [ ] **Phase 4: PPTX Export** - Background PPTX generation with CJK fonts and download delivery

## Phase Details

### Phase 1: Auth + Foundation
**Goal**: Team members can securely access the app and the core data schema is stable for all subsequent features
**Depends on**: Nothing (first phase)
**Requirements**: AUTH-01, AUTH-02, AUTH-03
**Success Criteria** (what must be TRUE):
  1. User can create an account with email and password and log in
  2. User session persists across browser refresh without re-login
  3. User can reset a forgotten password via email link
  4. Solid Queue background worker runs in both development and production (confirmed via job execution, not just boot)
**Plans**: 3 plans

Plans:
- [ ] 01-01-PLAN.md — Test scaffold: Wave 0 auth integration tests (fixture fix, new registrations/passwords tests, repair decks/songs tests)
- [ ] 01-02-PLAN.md — Auth UI polish: fix nav bar per spec, style passwords/new, add app name headings, fix mailer_sender
- [ ] 01-03-PLAN.md — Solid Queue wiring + empty states + human verification checkpoint

### Phase 2: Lyrics Pipeline
**Goal**: Users can search for any worship song and receive structured Chinese lyrics with tone-marked pinyin, saved to a shared team library
**Depends on**: Phase 1
**Requirements**: SONG-01, SONG-02, SONG-03, SONG-04, LIB-01, LIB-02, LIB-03
**Success Criteria** (what must be TRUE):
  1. User searches a song title and lyrics appear in the library within seconds (via background job with Turbo Stream status update)
  2. Lyrics display with Simplified Chinese characters and tone-marked pinyin, sectioned into verse/chorus/bridge
  3. User can paste raw lyrics manually when search fails and receive the same structured output
  4. Imported song is immediately visible to all team members in the shared library
  5. User can browse, search, and edit a saved song's lyrics and pinyin from the library
**Plans**: 6 plans

Plans:
- [ ] 02-01-PLAN.md — Gems + migration + Wave 0 test scaffold (anthropic/serpapi/faraday, import_status enum, RED test files)
- [ ] 02-02-PLAN.md — Service layer: ClaudeLyricsService, LyricsSearchService, LyricsScraperService (all tests GREEN)
- [ ] 02-03-PLAN.md — ImportSongJob (3-stage pipeline, Turbo broadcasts) + songs#import controller action
- [ ] 02-04-PLAN.md — Song show page (Turbo states, ruby-annotated lyrics, pinyin toggle) + index search/cards
- [ ] 02-05-PLAN.md — Song edit page with nested lyric fields (section_type, content, pinyin all editable)
- [ ] 02-06-PLAN.md — Human verification: end-to-end browser test with live API credentials

### Phase 3: Deck Editor
**Goal**: Users can assemble a complete service deck — adding songs, arranging slides, editing text, and choosing a visual theme — ready for export
**Depends on**: Phase 2
**Requirements**: SLIDE-01, SLIDE-02, SLIDE-03, SLIDE-04, SLIDE-05, DECK-01, DECK-02, DECK-03, DECK-04, THEME-01, THEME-02, THEME-03
**Success Criteria** (what must be TRUE):
  1. User can create a service deck with a title (pre-filled with upcoming Sunday's date) and add songs from the library in order
  2. User can reorder and remove songs within the deck without affecting the song library
  3. User can edit, reorder, delete, and repeat individual slides inline within the browser
  4. User can preview how slides will look in the browser before downloading
  5. User can apply a visual theme (AI-suggested, custom colors, or uploaded background image) to the entire deck
**Plans**: 5 plans

Plans:
- [ ] 03-01-PLAN.md — Wave 0 scaffold: Theme model + migrations, arrangement init on DeckSong create, date pre-fill, test fixtures
- [ ] 03-02-PLAN.md — Deck editor UI: sortable song list, slide arrangement per song (reorder/remove/repeat), slide preview section
- [ ] 03-03-PLAN.md — Custom theme form: color pickers, font size select, background image upload (THEME-02, THEME-03)
- [ ] 03-04-PLAN.md — AI theme suggestions: ClaudeThemeService, GenerateThemeSuggestionsJob, Unsplash fetch, suggestion cards (THEME-01)
- [ ] 03-05-PLAN.md — DeckSong model tests + full suite gate + human verification checkpoint

### Phase 4: PPTX Export
**Goal**: Users can download a complete, presentation-ready .pptx file that renders Chinese characters and pinyin correctly on any projector
**Depends on**: Phase 3
**Requirements**: EXPORT-01, EXPORT-02, EXPORT-03
**Success Criteria** (what must be TRUE):
  1. User clicks export and sees a "Generating..." status indicator; button becomes a download link when the file is ready
  2. Downloaded .pptx renders Chinese characters (not empty rectangles) and pinyin correctly in Windows PowerPoint
  3. User can re-export a deck after editing slides or changing the theme and receive an updated file
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Auth + Foundation | 3/3 | Complete   | 2026-03-07 |
| 2. Lyrics Pipeline | 5/6 | In Progress|  |
| 3. Deck Editor | 1/5 | In Progress|  |
| 4. PPTX Export | 0/TBD | Not started | - |
