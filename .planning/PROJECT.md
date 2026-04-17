# ChurchSlides

## What This Is

A Ruby on Rails web app for Chinese church worship teams to build and export PowerPoint (.pptx) slide decks. Users search for worship songs by title — the app fetches lyrics from the web and uses Claude to structure them with Simplified Chinese characters and tone-marked pinyin — then worship leaders edit and reorder slides in-browser before downloading a presentation-ready PPTX file. v1.0 is fully shipped and functional.

## Core Value

Worship leaders can go from song title to a complete, formatted Chinese+pinyin PPTX slide deck in minutes — without manual copy-paste or formatting work.

## Requirements

### Validated

- ✓ User can sign up with email and password — v1.0
- ✓ User session persists across browser refresh — v1.0
- ✓ User can reset password via email link — v1.0
- ✓ User can search for a song by title; Claude recalls lyrics first, Nokogiri scrapers as fallback — v1.0 (Nokogiri wired but not called in job; Claude + SerpAPI covers all tested cases)
- ✓ Claude automatically detects and labels lyric sections (verse, chorus, bridge) — v1.0
- ✓ Claude automatically generates tone-marked pinyin for all Simplified Chinese lyrics — v1.0
- ✓ User can manually paste raw lyrics if search fails — v1.0
- ✓ Imported songs automatically saved to shared team library — v1.0
- ✓ User can browse and search saved songs in the library — v1.0
- ✓ User can edit a song's lyrics and pinyin in the library — v1.0
- ✓ User can edit slide Chinese text and pinyin inline — v1.0 (opens song edit in new tab; team accepted)
- ✓ User can reorder slides within a song in the deck — v1.0
- ✓ User can delete or hide individual slides from the deck — v1.0
- ✓ User can preview slides in the browser before export — v1.0
- ✓ User can repeat sections within a song — v1.0
- ✓ User can create a deck with title pre-filled with upcoming Sunday's date — v1.0
- ✓ User can add songs from the library to a deck in order — v1.0
- ✓ User can reorder songs within a deck — v1.0
- ✓ User can remove a song from a deck without deleting it from the library — v1.0
- ✓ User can request AI-generated theme suggestions (5 themes with Unsplash backgrounds) — v1.0
- ✓ User can create a custom theme by setting background color, text color, and font size — v1.0
- ✓ User can upload their own background image for a deck theme — v1.0
- ✓ User can download a deck as a .pptx file with Chinese characters, pinyin, and theme applied — v1.0
- ✓ PPTX generation runs as a background job with live status indicator — v1.0
- ✓ User can re-export a deck after making edits to slides or theme — v1.0

## Current Milestone: v1.1 Design

**Goal:** Replace the generic SaaS feel with a warm, worshipful visual identity and streamline the UI so non-technical worship leaders can navigate the deck creation flow without confusion.

**Target features:**
- Warm custom color palette, rounded components, consistent typography
- Deck creation as the primary nav entry point (songs added within deck flow)
- Consistent forms, inputs, and spacing across all pages
- Helpful error states, clear loading indicators, polished flash messages
- Onboarding cues and empty states guiding new users through the full workflow

### Active

- [ ] UI has a warm, worshipful visual identity (custom palette, typography, rounded components)
- [ ] Deck creation is the primary navigation flow; songs can be added inline
- [ ] Song library page is retained but de-emphasized in navigation
- [ ] All forms use consistent input styles, labels, and spacing
- [ ] Error states provide actionable messages; loading states are clearly indicated
- [ ] Flash messages are visually polished and contextually appropriate
- [ ] Empty states guide new users on what to do next
- [ ] Song can store English title as alias for bilingual search (META-01)
- [ ] Song can store CCLI number, key, and artist/composer (META-02)

### Out of Scope

| Feature | Reason |
|---------|--------|
| Announcement / sermon outline slides | Different workflow; not lyrics-based; v2+ |
| Real-time multi-user collaboration | Unnecessary for a small team editing sequentially |
| Live in-browser presentation mode | PPTX export achieves this via PowerPoint/Keynote |
| Mobile app | Web-first; desktop use case |
| Multi-church SaaS / multi-tenancy | Single church team for v1 |
| Bible verse slides | Out of scope for this app |
| Key transposition / chord charts | Musicians' tool, not a slides tool |
| Import from ProPresenter / CCLI SongSelect | Brittle format parsing; manual search is sufficient |
| Version history / edit audit trail | Small team tolerates last-write-wins |
| Google OAuth | Nice-to-have; email auth sufficient for small team |

## Context

- **Shipped v1.0:** 2026-03-15 — fully functional end-to-end
- **Stack:** Rails 8.1.2, Ruby 4.0.1, PostgreSQL 18, Hotwire (Turbo + Stimulus), Solid Queue, python-pptx via subprocess
- **LOC:** ~2,800 Ruby, ~360 Python, ~1,058 ERB
- **AI:** Claude Haiku for theme suggestions; claude-sonnet for lyrics/pinyin; SerpAPI for song search
- **PPTX:** python-pptx (not Ruby gem — all Ruby PPTX gems rejected for CJK/maintenance reasons)
- **Known tech debt:** LyricsSearchService/LyricsScraperService implemented but not wired into ImportSongJob (Nokogiri fallback inoperative); Windows CJK rendering validated on macOS only

## Constraints

- **Tech stack**: Ruby on Rails (existing preference)
- **AI**: Claude API for lyric structuring, pinyin generation, section detection, theme suggestions
- **Lyrics source**: Web search (SerpAPI) + Claude recall — lyrics not stored until Claude processes them
- **Output format**: .pptx (not PDF, not Google Slides)
- **Users**: Small team, single church — no multi-tenancy needed for v1
- **PPTX generation**: python-pptx via Ruby subprocess (python-pptx is the only viable CJK-capable option)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Web search for lyrics | Claude alone may not know modern Chinese worship songs | ✓ Good — SerpAPI + Claude recall covers all tested songs; Nokogiri implemented but not wired (acceptable) |
| Claude for pinyin | Pinyin accuracy requires context-aware tone assignment | ✓ Good — tone-marked pinyin validated in E2E testing |
| One verse per slide | Balances readability vs. slide count for live projection | ✓ Good — DeckSong.arrangement JSONB enables flexible repeat/reorder |
| Per-service theme | Different services may have different visual moods | ✓ Good — Theme model with AI suggestions, custom colors, and background image upload |
| Song library | Avoid re-fetching and re-processing the same songs | ✓ Good — shared team library (no user scoping on songs) |
| python-pptx via subprocess | All Ruby PPTX gems lack reliable CJK support | ✓ Good — embedded Noto Sans SC TTF via ZIP post-processing; CJK validated |
| Solid Cache for export tokens | Bridge async job output to sync download without ActiveStorage | ✓ Good — 10-minute TTL cache key; no temp file cleanup needed |

---
*Last updated: 2026-03-15 after v1.1 milestone start*
