# ChurchSlides

## What This Is

A Ruby on Rails web app for Chinese church worship teams to build and export PowerPoint (.pptx) slide decks. Users search for worship songs by title, the app fetches lyrics from the web and uses Claude to structure them with Simplified Chinese characters and pinyin, then worship leaders edit and reorder slides in-browser before downloading a presentation-ready PPTX file.

## Core Value

Worship leaders can go from song title to a complete, formatted Chinese+pinyin PPTX slide deck in minutes — without manual copy-paste or formatting work.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] User can create an account and log in
- [ ] User can search for a worship song by title and have lyrics fetched + structured by Claude
- [ ] Lyrics are displayed with Simplified Chinese characters and pinyin (one verse per slide)
- [ ] Searched songs are saved to a reusable song library
- [ ] User can create a service (setlist) and add songs from the library
- [ ] User can choose a visual theme per service (background, font, colors)
- [ ] User can edit, reorder, and remove individual slides inline before export
- [ ] User can export the service as a .pptx file
- [ ] Multiple team members share the same song library and can each build services

### Out of Scope

- Scripture slides — songs only for v1; expand later
- Announcements / sermon outline slides — out of scope for v1
- Mobile app — web-first
- Public SaaS / multi-church — single church team only for v1
- Real-time collaboration — one user edits at a time

## Context

- Single church team: small group of worship leaders, shared song library
- Lyrics sourced via web search, then structured and enriched with pinyin by Claude API
- Pinyin generation is a key Claude responsibility — congregation includes non-native readers
- PPTX generation via a Ruby gem (e.g. caracal or ruby-pptx)
- Theme is chosen per-service (not per-song), applied uniformly across all slides

## Constraints

- **Tech stack**: Ruby on Rails (existing preference)
- **AI**: Claude API for lyric structuring, pinyin generation, section detection
- **Lyrics source**: Web search (scrape or search API) — lyrics not stored until Claude processes them
- **Output format**: .pptx (not PDF, not Google Slides)
- **Users**: Small team, single church — no multi-tenancy needed for v1

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Web search for lyrics | Claude alone may not know modern Chinese worship songs | — Pending |
| Claude for pinyin | Pinyin accuracy requires context-aware tone assignment | — Pending |
| One verse per slide | Balances readability vs. slide count for live projection | — Pending |
| Per-service theme | Different services may have different visual moods | — Pending |
| Song library | Avoid re-fetching and re-processing the same songs | — Pending |

---
*Last updated: 2026-03-07 after initialization*
