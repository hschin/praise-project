---
id: T01
parent: S01
milestone: M002
key_files:
  - app/assets/tailwind/application.css
  - app/views/layouts/application.html.erb
  - app/assets/stylesheets/application.css
key_decisions:
  - Replaced inline style on nav logo with font-headline utility class instead of leaving a Playfair reference
  - Used raw hex values for all color tokens (no var() indirection) as specified in the plan
duration: ""
verification_result: passed
completed_at: 2026-03-26T17:20:52.517Z
blocker_discovered: false
---

# T01: Define Sanctuary Stone token system with ~40 color tokens, swap fonts to Newsreader/Inter/Material Symbols, and add ambient shadow utility

**Define Sanctuary Stone token system with ~40 color tokens, swap fonts to Newsreader/Inter/Material Symbols, and add ambient shadow utility**

## What Happened

Rewrote the Tailwind v4 @theme block in `app/assets/tailwind/application.css`, replacing the old `worship-*` token system with the full Sanctuary Stone color palette (~40 tokens covering surface, primary, secondary, tertiary, error, outline, and inverse families), plus font family tokens (`--font-headline`, `--font-body`, `--font-label`) and border radius overrides. All values use raw hex — no `var()` indirection.

Swapped the Google Fonts `<link>` in the layout head from Playfair Display to three links: Newsreader (headline), Inter (body/label), and Material Symbols Outlined. Also removed an inline `style="font-family: 'Playfair Display'"` on the nav logo link and replaced it with the `font-headline` utility class.

Changed the `<body>` class from `bg-stone-50 text-stone-900` to `bg-surface text-on-surface font-body` so the page uses Sanctuary Stone design tokens.

Added Material Symbols `font-variation-settings` rule and `.shadow-ambient` utility class to `app/assets/stylesheets/application.css`.

Ran `bin/rails tailwindcss:build` — Tailwind v4.2.0 compiled successfully in ~140ms. Verified the build output contains `--color-surface`, `--color-primary`, `--font-headline`, `--font-body`, `--radius-lg`, and all other expected tokens.

## Verification

Ran the composite verification command: `bin/rails tailwindcss:build && grep -q 'color-surface' ... && echo 'PASS'`. All six checks passed:
1. `color-surface` found in build CSS
2. `color-primary` found in build CSS
3. `font-headline` found in build CSS
4. No `Playfair` references in layout
5. No `worship-` tokens in tailwind source
6. `bg-surface` present on body element

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bin/rails tailwindcss:build && grep -q 'color-surface' app/assets/builds/tailwind.css && grep -q 'color-primary' app/assets/builds/tailwind.css && grep -q 'font-headline' app/assets/builds/tailwind.css && ! grep -q 'Playfair' app/views/layouts/application.html.erb && ! grep -q 'worship-' app/assets/tailwind/application.css && grep -q 'bg-surface' app/views/layouts/application.html.erb && echo 'PASS'` | 0 | ✅ pass | 1500ms |


## Deviations

Removed an inline `style="font-family: 'Playfair Display', serif;"` from the nav logo link_to that was not mentioned in the task plan. This was necessary to fully eliminate Playfair Display references and was replaced with the `font-headline` Tailwind utility class.

## Known Issues

None.

## Files Created/Modified

- `app/assets/tailwind/application.css`
- `app/views/layouts/application.html.erb`
- `app/assets/stylesheets/application.css`
