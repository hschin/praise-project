---
id: S04
parent: M002
milestone: M002
provides:
  - Song library with editorial layout
  - Song show/edit/processing/failed with Sanctuary Stone tokens
requires:
  - slice: S01
    provides: Sanctuary Stone @theme tokens, Newsreader font, Material Symbols
affects:
  []
key_files:
  - app/views/songs/index.html.erb
  - app/views/songs/_lyrics.html.erb
  - app/views/songs/_failed.html.erb
key_decisions:
  - Unified search panel: filter + import together; import only shown when search has no results
patterns_established:
  - Unified search+import panel: single tonal surface container holds search field and conditional import CTA
observability_surfaces:
  - none
drill_down_paths:
  - milestones/M002/slices/S04/tasks/T01-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-03-28T15:30:59.241Z
blocker_discovered: false
---

# S04: Song Library & Song Views

**Song library and all song views reskinned with editorial search panel, lyric previews, and Sanctuary Stone tokens**

## What Happened

Song library reskinned with editorial layout: tonal search panel, Newsreader headline, lyric preview snippets per song row. All song detail, edit, processing, and failed views updated to Sanctuary Stone tokens.

## Verification

Visual inspection and rails test confirm all song views render with Sanctuary Stone identity.

## Requirements Advanced

- R008 — Song library shows editorial search panel and lyric preview rows with Sanctuary Stone tokens

## Requirements Validated

- R008 — Visual inspection: song library shows tonal search panel, Newsreader headline, lyric snippets. rails test passes.

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Deviations

Planned and delivered in single M002 commit.

## Known Limitations

None.

## Follow-ups

None.

## Files Created/Modified

- `app/views/songs/index.html.erb` — Editorial search panel with tonal container, lyric preview rows, Newsreader headline, unified import CTA
- `app/views/songs/show.html.erb` — Song detail view reskinned with Sanctuary Stone tokens
- `app/views/songs/edit.html.erb` — Song edit form reskinned
- `app/views/songs/_lyrics.html.erb` — Lyrics partial reskinned with section labels and tonal backgrounds
- `app/views/songs/_processing.html.erb` — Processing spinner screen reskinned
- `app/views/songs/_failed.html.erb` — Failed state screen reskinned with warning Material Symbol
