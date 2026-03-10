# Requirements: ChurchSlides

**Defined:** 2026-03-08
**Core Value:** Worship leaders can go from song title to a complete, formatted Chinese+pinyin PPTX slide deck in minutes — without manual copy-paste or formatting work.

## v1 Requirements

### Authentication

- [x] **AUTH-01**: User can sign up with email and password
- [x] **AUTH-02**: User session persists across browser refresh
- [x] **AUTH-03**: User can reset password via email link

### Song Import

- [x] **SONG-01**: User can search for a song by title; Claude recalls lyrics first, Nokogiri scrapers used as fallback if Claude doesn't know the song
- [x] **SONG-02**: Claude automatically detects and labels lyric sections (verse, chorus, bridge, etc.)
- [x] **SONG-03**: Claude automatically generates tone-marked pinyin for all Simplified Chinese lyrics
- [x] **SONG-04**: User can manually paste raw lyrics if search and scrapers both fail

### Song Library

- [x] **LIB-01**: Imported songs are automatically saved to the shared team library
- [ ] **LIB-02**: User can browse and search saved songs in the library
- [ ] **LIB-03**: User can edit a song's lyrics and pinyin in the library

### Slide Editor

- [ ] **SLIDE-01**: User can edit slide Chinese text and pinyin inline
- [ ] **SLIDE-02**: User can reorder slides within a song in the deck
- [ ] **SLIDE-03**: User can delete or hide individual slides from the deck
- [ ] **SLIDE-04**: User can preview slides in the browser before export
- [ ] **SLIDE-05**: User can repeat sections within a song (e.g., add chorus again after verse 2)

### Decks

- [ ] **DECK-01**: User can create a deck with a title field pre-filled with the upcoming Sunday's date (editable)
- [ ] **DECK-02**: User can add songs from the library to a deck in order
- [ ] **DECK-03**: User can reorder songs within a deck
- [ ] **DECK-04**: User can remove a song from a deck without deleting it from the library

### Themes

- [ ] **THEME-01**: User can request AI-generated theme suggestions; Claude produces 5 themes with Unsplash background photos for the user to pick from
- [ ] **THEME-02**: User can create a custom theme by setting background color, text color, and font size
- [ ] **THEME-03**: User can upload their own background image for a deck theme

### Export

- [ ] **EXPORT-01**: User can download a deck as a .pptx file with Chinese characters, pinyin, and theme applied
- [ ] **EXPORT-02**: PPTX generation runs as a background job with a "Generating…" status indicator; button becomes a download link when ready
- [ ] **EXPORT-03**: User can re-export a deck after making edits to slides or theme

## v2 Requirements

### Song Metadata

- **META-01**: Song can store English title as an alias for bilingual search
- **META-02**: Song can store CCLI number, key, and artist/composer

### Additional Auth

- **AUTH-04**: User can log in with Google (OAuth)

### Scripture

- **SCRIP-01**: User can add Bible verse slides to a deck
- **SCRIP-02**: Bible verses support multiple translations (CUV, NIV, ESV)

### Admin

- **ADMIN-01**: Admin can invite new team members via email
- **ADMIN-02**: Admin can remove team members

## Out of Scope

| Feature | Reason |
|---------|--------|
| Announcement / sermon outline slides | Different workflow; not lyrics-based; v2+ |
| Real-time multi-user collaboration | Unnecessary for a small team editing sequentially |
| Live in-browser presentation mode | PPTX export achieves this via PowerPoint/Keynote |
| Mobile app | Web-first; desktop use case |
| Multi-church SaaS / multi-tenancy | Single church team for v1 |
| Key transposition / chord charts | Musicians' tool, not a slides tool |
| Import from ProPresenter / CCLI SongSelect | Brittle format parsing; manual search is sufficient |
| Version history / edit audit trail | Small team tolerates last-write-wins |

## Traceability

Phase mapping confirmed during roadmap creation (2026-03-08).

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01 | Phase 1 — Auth + Foundation | Complete |
| AUTH-02 | Phase 1 — Auth + Foundation | Complete |
| AUTH-03 | Phase 1 — Auth + Foundation | Complete |
| SONG-01 | Phase 2 — Lyrics Pipeline | Complete |
| SONG-02 | Phase 2 — Lyrics Pipeline | Complete |
| SONG-03 | Phase 2 — Lyrics Pipeline | Complete |
| SONG-04 | Phase 2 — Lyrics Pipeline | Complete |
| LIB-01 | Phase 2 — Lyrics Pipeline | Complete |
| LIB-02 | Phase 2 — Lyrics Pipeline | Pending |
| LIB-03 | Phase 2 — Lyrics Pipeline | Pending |
| SLIDE-01 | Phase 3 — Deck Editor | Pending |
| SLIDE-02 | Phase 3 — Deck Editor | Pending |
| SLIDE-03 | Phase 3 — Deck Editor | Pending |
| SLIDE-04 | Phase 3 — Deck Editor | Pending |
| SLIDE-05 | Phase 3 — Deck Editor | Pending |
| DECK-01 | Phase 3 — Deck Editor | Pending |
| DECK-02 | Phase 3 — Deck Editor | Pending |
| DECK-03 | Phase 3 — Deck Editor | Pending |
| DECK-04 | Phase 3 — Deck Editor | Pending |
| THEME-01 | Phase 3 — Deck Editor | Pending |
| THEME-02 | Phase 3 — Deck Editor | Pending |
| THEME-03 | Phase 3 — Deck Editor | Pending |
| EXPORT-01 | Phase 4 — PPTX Export | Pending |
| EXPORT-02 | Phase 4 — PPTX Export | Pending |
| EXPORT-03 | Phase 4 — PPTX Export | Pending |

**Coverage:**
- v1 requirements: 25 total
- Mapped to phases: 25
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-08*
*Last updated: 2026-03-08 — traceability confirmed after roadmap creation*
