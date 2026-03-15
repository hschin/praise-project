# Requirements: ChurchSlides v1.1 Design

**Defined:** 2026-03-15
**Core Value:** Worship leaders can go from song title to a complete, formatted Chinese+pinyin PPTX slide deck in minutes — without manual copy-paste or formatting work.

## v1.1 Requirements

Requirements for v1.1 Design milestone. Each maps to roadmap phases.

### Visual Identity

- [x] **VIS-01**: App displays a warm, worshipful color palette (amber/stone tones) throughout all pages — no indigo/gray SaaS defaults
- [x] **VIS-02**: All cards, buttons, and inputs use a consistent rounded component language (unified border radius, padding, shadow)
- [x] **VIS-03**: Typography uses a deliberate scale with clear headline/body/caption hierarchy and generous line height
- [x] **VIS-04**: Navigation includes a styled app wordmark — not bare plain text

### Navigation & Flow

- [x] **NAV-01**: Deck creation is the primary nav entry point; Songs library link is visually de-emphasized
- [x] **NAV-02**: Deck list page displays decks as a card grid with the service date as the most prominent element on each card
- [x] **NAV-03**: Creating a new deck takes the user directly into the deck editor — no intermediate form step
- [x] **NAV-04**: New deck title is auto-filled with the upcoming Sunday's date and is inline-editable from the deck editor

### Forms & Feedback

- [x] **FORM-01**: All inputs, labels, buttons, and focus states across all pages use consistent warm palette styles
- [x] **FORM-02**: Flash messages display as rounded cards with a semantic icon (success/error) and auto-dismiss after a few seconds
- [x] **FORM-03**: Import and export error messages include a clear description of what went wrong and a specific next step (e.g., "Lyrics not found — try pasting them manually")

### Empty States

- [x] **EMPTY-01**: Deck index shows an illustrated empty state for new users that explains the app's purpose and prompts them to create their first deck
- [x] **EMPTY-02**: Deck editor with no songs added yet shows a contextual cue guiding the user to add their first song
- [x] **EMPTY-03**: Song library with no songs shows an orientation cue explaining how to import a song

### Auth Pages

- [x] **AUTH-01**: Sign-in and sign-up pages use the warm palette and brand context — they feel like the product, not a bare Devise scaffold

### Deck Editor Polish

- [ ] **DECK-01**: Slide panel labels section types (verse/chorus/bridge) with distinct warm color-coded chips
- [ ] **DECK-02**: Song cards in the library and deck editor display the artist/composer as secondary metadata
- [ ] **DECK-03**: PPTX export button is a prominent "done" affordance — visually distinct, includes a download icon, and the "ready" state is clearly celebratory
- [ ] **DECK-04**: Deck editor displays clear panel labels (Songs / Arrangement / Preview) so non-technical users understand the three-column layout
- [ ] **DECK-05**: Inline-editable deck title shows a pencil icon on hover so users know it's editable
- [ ] **DECK-06**: Deck editor shows a subtle auto-save indicator after arrangement or slide changes

### Import Flow

- [ ] **IMPORT-01**: Song import processing screen shows contextual copy ("Claude is structuring your lyrics...") that reflects what's actually happening
- [ ] **IMPORT-02**: After song import completes, user is prompted to add the song to a deck

## v2 Requirements

Deferred to future release.

### Song Metadata

- **META-01**: Song can store English title as alias for bilingual search
- **META-02**: Song can store CCLI number for rights tracking

### Scripture

- **SCRIP-01**: User can add Bible verse slides to a deck

### Deck Editor Extended

- **DECK-EXT-01**: Deck card shows song count or section preview thumbnail
- **DECK-EXT-02**: Auth page includes illustration or brand artwork

## Out of Scope

| Feature | Reason |
|---------|--------|
| Dark mode toggle | Doubles visual system to maintain; users plan slides in lit rooms |
| Animation library (AOS, Animate.css) | Conflicts with Turbo page transitions; marketing-site feel |
| Custom icon library (npm-based) | Importmap does not handle npm icon packs cleanly — use inline Heroicons SVG |
| Skeleton loading screens everywhere | High maintenance; spinner + copy is sufficient for this scale |
| Toast notification stack | Over-engineered for one-action-at-a-time app; single polished flash is right |
| Responsive/mobile layout rework | Primary use case is desktop; out of scope per PROJECT.md |
| Sidebar/rail navigation | App has two sections; top nav is correct; more nav structure adds complexity |
| Full Tailwind component library docs | Single `tailwind.config.js` with custom tokens is the right "design system" |
| Devise email template redesign | Low user-hours impact (small team signs up once); not visible in app |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| VIS-01 | Phase 5 | Complete |
| VIS-02 | Phase 5 | Complete |
| VIS-03 | Phase 5 | Complete |
| VIS-04 | Phase 5 | Complete |
| NAV-01 | Phase 5 | Complete |
| NAV-03 | Phase 5 | Complete |
| NAV-04 | Phase 5 | Complete |
| FORM-01 | Phase 6 | Complete |
| FORM-02 | Phase 6 | Complete |
| FORM-03 | Phase 6 | Complete |
| NAV-02 | Phase 7 | Complete |
| EMPTY-01 | Phase 7 | Complete |
| EMPTY-02 | Phase 7 | Complete |
| EMPTY-03 | Phase 7 | Complete |
| AUTH-01 | Phase 7 | Complete |
| DECK-01 | Phase 8 | Pending |
| DECK-02 | Phase 8 | Pending |
| DECK-03 | Phase 8 | Pending |
| DECK-04 | Phase 8 | Pending |
| DECK-05 | Phase 8 | Pending |
| DECK-06 | Phase 8 | Pending |
| IMPORT-01 | Phase 8 | Pending |
| IMPORT-02 | Phase 8 | Pending |

**Coverage:**
- v1.1 requirements: 23 total
- Mapped to phases: 23
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-15*
*Last updated: 2026-03-15 after 05-03 execution (NAV-03, NAV-04 complete)*
