# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-08)

**Core value:** Worship leaders can go from song title to a complete, formatted Chinese+pinyin PPTX slide deck in minutes — without manual copy-paste or formatting work.
**Current focus:** Phase 1 — Auth + Foundation

## Current Position

Phase: 1 of 4 (Auth + Foundation)
Plan: 0 of TBD in current phase
Status: Ready to plan
Last activity: 2026-03-08 — Roadmap created

Progress: [░░░░░░░░░░] 0%

## Performance Metrics

**Velocity:**
- Total plans completed: 0
- Average duration: -
- Total execution time: -

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| - | - | - | - |

**Recent Trend:**
- Last 5 plans: -
- Trend: -

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Research]: python-pptx via Ruby subprocess is the correct PPTX generator — all Ruby gems rejected (caracal=DOCX, ruby-pptx=unmaintained+poor CJK, caxlsx=spreadsheets)
- [Research]: Claude-first lyric recall with Nokogiri scraper fallback; never generate lyrics, only structure provided text
- [Research]: All Claude API and PPTX generation calls must run in Solid Queue background jobs — never inline in controllers (Thruster timeout risk)
- [Research]: DeckSong.arrangement as JSONB array is the authoritative slide order; Slide records are a derived projection

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 2 risk]: Claude structured JSON prompt reliability unvalidated — spike needed before Phase 2 planning
- [Phase 2 risk]: SerpAPI result quality for Chinese worship lyrics queries untested
- [Phase 4 risk]: CJK font rendering on Windows projector untested — must validate before Phase 4 ships (east-Asian font XML slot + Noto CJK in Docker)

## Session Continuity

Last session: 2026-03-08
Stopped at: Roadmap created, ready to plan Phase 1
Resume file: None
