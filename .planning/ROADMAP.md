# Roadmap: ChurchSlides

## Milestones

- ✅ **v1.0 MVP** — Phases 1-4 (shipped 2026-03-15)
- **v1.1 Design** — Phases 5-8 (active)

## Phases

<details>
<summary>✅ v1.0 MVP (Phases 1-4) — SHIPPED 2026-03-15</summary>

- [x] Phase 1: Auth + Foundation (3/3 plans) — completed 2026-03-07
- [x] Phase 2: Lyrics Pipeline (6/6 plans) — completed 2026-03-14
- [x] Phase 3: Deck Editor (5/5 plans) — completed 2026-03-13
- [x] Phase 4: PPTX Export (3/3 plans) — completed 2026-03-14

Full details: `.planning/milestones/v1.0-ROADMAP.md`

</details>

### v1.1 Design

- [ ] **Phase 5: Design Foundation** — Tailwind palette tokens, component language, and navigation restructure
- [ ] **Phase 6: Global Components** — Consistent form system, flash messages, and feedback patterns
- [ ] **Phase 7: Content Pages** — Deck card grid, empty states, and auth page brand treatment
- [ ] **Phase 8: Deck Editor and Import Polish** — High-risk surface: slide labels, export affordance, inline editing cues, and import flow

## Phase Details

### Phase 5: Design Foundation
**Goal**: The app speaks a warm, worshipful visual language — palette tokens defined, component language unified, and deck creation established as the primary navigation entry point
**Depends on**: Nothing (first phase of v1.1)
**Requirements**: VIS-01, VIS-02, VIS-03, VIS-04, NAV-01, NAV-03, NAV-04
**Success Criteria** (what must be TRUE):
  1. Every page uses amber/stone tones — indigo and generic gray are gone from the palette
  2. Cards, buttons, and inputs share a consistent rounded corner radius and padding — the component language is immediately recognizable as unified
  3. Headings, body text, and captions follow a readable typographic hierarchy with generous line height
  4. The navigation bar displays a styled wordmark — not bare plain text — and decks is the primary link while songs is visually de-emphasized
  5. Creating a new deck skips any intermediate form step and lands the user directly in the deck editor with the title auto-filled with the upcoming Sunday date
**Plans**: 4 plans
Plans:
- [x] 05-01-PLAN.md — Tailwind @theme tokens + palette replacement across 21 view files
- [x] 05-02-PLAN.md — Layout and nav restructure (body class, wordmark, New Deck CTA)
- [x] 05-03-PLAN.md — Quick-create deck flow (route, controller, test stubs)
- [ ] 05-04-PLAN.md — Inline-edit deck title Stimulus controller

### Phase 6: Global Components
**Goal**: Forms, inputs, flash messages, and loading feedback patterns are consistent and polished across every page in the app
**Depends on**: Phase 5 (palette tokens must exist before applying them globally)
**Requirements**: FORM-01, FORM-02, FORM-03
**Success Criteria** (what must be TRUE):
  1. Inputs, labels, buttons, and focus rings use the warm palette on every page — no legacy indigo or default gray form elements remain
  2. Flash messages appear as rounded cards with a semantic icon (green checkmark for success, red warning for error) and auto-dismiss after a few seconds without user action
  3. Import and export error messages state specifically what went wrong and name the next concrete step the user should take
**Plans**: TBD

### Phase 7: Content Pages
**Goal**: The deck index, song library, and auth pages are visually complete — users understand what the app does from the moment they land on any of these pages
**Depends on**: Phase 6 (global components applied before page-specific layouts)
**Requirements**: NAV-02, EMPTY-01, EMPTY-02, EMPTY-03, AUTH-01
**Success Criteria** (what must be TRUE):
  1. The deck index displays decks as a card grid with the service date as the most prominent element on each card — not the title
  2. A first-time user on the deck index sees an empty state that explains the app's purpose and shows a clear prompt to create their first deck
  3. A user who opens a deck with no songs added yet sees a contextual cue telling them how to add their first song
  4. A user who opens the song library with no songs sees an orientation cue explaining how to import a song
  5. The sign-in and sign-up pages use the warm palette and brand context — they feel like the product, not a bare Devise scaffold
**Plans**: TBD

### Phase 8: Deck Editor and Import Polish
**Goal**: The deck editor and import flow are visually complete with section labels, a prominent export affordance, inline editing cues, and import status copy that reflects actual AI activity — all without breaking any existing Turbo Stream, drag-and-drop, or CSS contracts
**Depends on**: Phase 7 (full visual system stabilized before touching the highest-risk surface)
**Requirements**: DECK-01, DECK-02, DECK-03, DECK-04, DECK-05, DECK-06, IMPORT-01, IMPORT-02
**Success Criteria** (what must be TRUE):
  1. Slide items in the deck editor show color-coded chips labeling each section as verse, chorus, or bridge using distinct warm colors
  2. Song cards in the deck editor and library show the artist or composer as secondary metadata below the song title
  3. The PPTX export button is visually distinct and prominent — it includes a download icon and its "ready" state is clearly celebratory; users cannot miss it
  4. The deck editor's three-column layout is labeled (Songs / Arrangement / Preview) so non-technical users understand each panel's purpose
  5. The import processing screen displays copy that reflects AI activity ("Claude is structuring your lyrics...") and the post-import screen prompts the user to add the song to a deck
**Plans**: TBD

## Progress

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Auth + Foundation | v1.0 | 3/3 | Complete | 2026-03-07 |
| 2. Lyrics Pipeline | v1.0 | 6/6 | Complete | 2026-03-14 |
| 3. Deck Editor | v1.0 | 5/5 | Complete | 2026-03-13 |
| 4. PPTX Export | v1.0 | 3/3 | Complete | 2026-03-14 |
| 5. Design Foundation | v1.1 | 3/4 | In Progress | — |
| 6. Global Components | v1.1 | 0/? | Not started | — |
| 7. Content Pages | v1.1 | 0/? | Not started | — |
| 8. Deck Editor and Import Polish | v1.1 | 0/? | Not started | — |
