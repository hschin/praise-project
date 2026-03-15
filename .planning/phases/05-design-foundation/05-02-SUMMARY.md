---
phase: 05-design-foundation
plan: 02
subsystem: frontend-layout
tags: [tailwind, warm-palette, nav, layout, VIS-01, VIS-02, VIS-03, VIS-04, NAV-01]
dependency_graph:
  requires: []
  provides: [global-warm-palette, styled-wordmark, restructured-nav]
  affects: [every-page-via-layout-inheritance]
tech_stack:
  added: []
  patterns: [warm-stone-palette, font-serif-wordmark, amber-cta-button, utility-nav-split]
key_files:
  created: []
  modified:
    - app/views/layouts/application.html.erb
decisions:
  - "Stone palette (not gray) selected for all body/nav surfaces per v1.1 design direction"
  - "Decks in primary left nav area; Songs de-emphasized to right utility area"
  - "New Deck uses button_to (renders form with CSRF) not link_to"
  - "pre-existing quick_create_decks_url test failures resolved — route already existed"
metrics:
  duration: "1m 10s"
  completed_date: "2026-03-15"
  tasks_completed: 2
  tasks_total: 2
  files_changed: 1
---

# Phase 5 Plan 02: Global Layout Warm Palette and Nav Restructure Summary

Replaced legacy gray/indigo palette and nav structure with warm stone palette, font-serif wordmark, and restructured nav (Decks primary / New Deck amber CTA / Songs + Logout utility area) in a single layout file that every page inherits.

## Tasks Completed

| # | Task | Commit | Files |
|---|------|--------|-------|
| 1 | Apply warm palette to body, nav, and flash messages | 4d5d1f7 | app/views/layouts/application.html.erb |
| 2 | Styled wordmark and restructured nav with New Deck CTA | 641b185 | app/views/layouts/application.html.erb |

## What Was Built

**Task 1 — Warm palette foundation:**
- `<body>`: `bg-gray-50 text-gray-900` → `bg-stone-50 text-stone-900`
- `<nav>`: `bg-white border-gray-200` → `bg-stone-100 border-stone-200`
- Flash notice: bare `bg-green-50` div → `bg-amber-50 border-amber-200 text-amber-900 rounded-lg mx-6 mt-3` card
- Flash alert: bare `bg-red-50` div → `bg-red-50 rounded-lg mx-6 mt-3` card with spacing

**Task 2 — Wordmark and nav restructure:**
- Wordmark: `font-bold text-indigo-600` → `font-serif text-amber-800 tracking-wide`
- Decks moved to primary left-side nav area with `text-stone-700 font-medium`
- New Deck `button_to` added as amber-800 primary CTA (`quick_create_decks_path`)
- Songs moved to right utility area as de-emphasized `text-stone-500`
- Email and Logout updated to stone palette (`text-stone-400`, `text-stone-600`)

## Verification Results

1. `grep "bg-stone-50 text-stone-900"` — PASS
2. `grep "font-serif text-amber-800"` — PASS
3. `grep "quick_create_decks_path"` — PASS
4. `grep "bg-gray|text-gray|border-gray|indigo|bg-white"` — PASS (no legacy classes)
5. `grep "content_for.*main_class"` — PASS (DOM contract preserved)
6. `rails test test/controllers/decks_controller_test.rb` — 9/9 PASS

## Deviations from Plan

None - plan executed exactly as written.

Note: During Task 1 test run, 2 errors appeared for `quick_create_decks_url` not found. By Task 2 completion all 9 tests passed — the route was already present (likely from Plan 03 running in parallel Wave 1). No action was needed.

## Requirements Delivered

- VIS-01: Warm palette applied globally (body, nav, flash)
- VIS-02: Component language established (rounded-lg, px-4 py-2 baseline for buttons)
- VIS-03: Font-serif wordmark with tracking-wide
- VIS-04: Warm amber tones for CTA and wordmark
- NAV-01: Restructured nav — Decks primary, New Deck CTA, Songs utility

## Self-Check

- [x] app/views/layouts/application.html.erb modified (verified above)
- [x] Commit 4d5d1f7 exists (Task 1)
- [x] Commit 641b185 exists (Task 2)
- [x] All 5 grep verification checks pass
- [x] Test suite 9/9 green
