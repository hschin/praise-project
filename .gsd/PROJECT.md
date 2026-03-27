# ChurchSlides

## What This Is

A Ruby on Rails web app for Chinese church worship teams to build and export PowerPoint (.pptx) slide decks. Users search for worship songs by title — the app fetches lyrics from the web and uses Claude to structure them with Simplified Chinese characters and tone-marked pinyin — then worship leaders edit and reorder slides in-browser before downloading a presentation-ready PPTX file. v1.0 is fully shipped and functional. v1.1 completed a UI polish pass (warm palette, consistent forms, empty states, onboarding cues). v1.2 implements the "Sanctuary Stone" design system — a complete visual reskin from Google Stitch designs.

## Core Value

Worship leaders can go from song title to a complete, formatted Chinese+pinyin PPTX slide deck in minutes — without manual copy-paste or formatting work.

## Current State

- **v1.0** shipped 2026-03-15 — fully functional end-to-end
- **v1.1** completed — warm palette, navigation polish, empty states, flash messages, auth reskin, deck editor UX improvements
- **v1.2** in progress — "Sanctuary Stone" design system overhaul from Google Stitch designs

## Architecture / Key Patterns

- **Stack:** Rails 8.1.2, Ruby 4.0.1, PostgreSQL 18, Hotwire (Turbo + Stimulus), Solid Queue, Tailwind CSS v4
- **Frontend:** Importmap (no Node/Webpack), Tailwind v4 via `tailwindcss-rails` gem with `@theme` tokens in `app/assets/tailwind/application.css`
- **AI:** Claude Haiku for theme suggestions; Claude Sonnet for lyrics/pinyin; SerpAPI for song search
- **PPTX:** python-pptx via Ruby subprocess (embedded Noto Sans SC TTF for CJK support)
- **LOC:** ~2,800 Ruby, ~360 Python, ~1,058 ERB
- **Stimulus controllers:** inline_edit, flash, color_picker, song_search, song_order, sortable, pinyin_toggle, redirect, auto_save

## Capability Contract

See `.gsd/REQUIREMENTS.md` for the explicit capability contract, requirement status, and coverage mapping.

## Milestone Sequence

- [x] M001: v1.1 Design — Warm palette, navigation polish, empty states, consistent forms
- [ ] M002: v1.2 Sanctuary Stone — Complete visual reskin implementing the Sanctuary Stone design system from Google Stitch designs
