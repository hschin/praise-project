# S01: Design System Foundation — Research

**Date:** 2026-03-27
**Depth:** Targeted

## Summary

S01 is the foundation slice that every other slice depends on. It requires three changes that divide cleanly: (1) replace the Tailwind `@theme` token set with ~40 Sanctuary Stone color tokens plus font family tokens, (2) replace the Google Fonts `<link>` tag to swap Playfair Display for Newsreader + Inter + Material Symbols Outlined, and (3) reskin the shared layout — nav bar, body background, and flash container. The SVG-to-Material-Symbols replacement is a cross-cutting concern: 8 view files contain 13 inline Heroicon SVGs that must become `<span class="material-symbols-outlined">icon_name</span>` elements. All changes are in 2 CSS files and ~9 ERB files.

The work is straightforward — there's no new technology, no risky integration, and the Stitch HTML exports provide exact token values and nav markup to copy from. The primary risk is the Tailwind v4 `@theme` directive: the current tokens use `var(--color-rose-700)` references to built-in Tailwind colors, but the Sanctuary Stone tokens are raw hex values (`#93000b`, `#fff8f5`, etc.). Tailwind v4's `@theme` supports raw hex values directly — confirmed by examining the compiled output which shows all built-in colors as resolved values. The Stitch HTML uses Tailwind CDN with `tailwind.config.colors` which maps 1:1 to `@theme` `--color-*` custom properties.

## Recommendation

Build in three tasks, ordered by dependency: (1) Token system + fonts first (CSS-only, unblocks everything), (2) Layout reskin (nav + body + flash container), (3) SVG → Material Symbols replacement across all views. Task 1 is the foundation — once tokens and fonts are defined, the nav and icon work can reference them. The nav reskin and SVG replacement are independent of each other.

## Implementation Landscape

### Key Files

**CSS (token system):**
- `app/assets/tailwind/application.css` — Currently 12 lines: `@import "tailwindcss"` + `@theme` with 7 `worship-*` tokens using `var()` references. Must be completely rewritten with ~40 Sanctuary Stone color tokens (raw hex values), 3 font family tokens (`--font-headline`, `--font-body`, `--font-label`), border radius overrides, and a custom ambient shadow utility. The token names from DESIGN.md map directly: `--color-surface: #fff8f5`, `--color-primary: #93000b`, etc.
- `app/assets/stylesheets/application.css` — Contains `.pinyin-hidden` CSS rule and the `.material-symbols-outlined` font-variation-settings rule should be added here (not in the Tailwind file).

**Layout (shared chrome):**
- `app/views/layouts/application.html.erb` — The single shared layout. Changes needed:
  - `<head>`: Replace Playfair Display Google Fonts link with Newsreader + Inter + Material Symbols Outlined links
  - `<body>`: Change `bg-stone-50 text-stone-900` → `bg-surface text-on-surface`
  - `<nav>`: Complete rewrite — from `bg-stone-100 border-b border-stone-200` box to frosted glass with `bg-surface/80 backdrop-blur-xl`, Newsreader italic wordmark, Material Symbols mail icon, gradient "New Deck" button
  - Flash container: Position adjustment may be needed if nav height changes (currently `top-[80px]`)

**Flash toast (partial):**
- `app/views/shared/_flash_toast.html.erb` — Uses `bg-green-50 border border-green-200` / `bg-red-50 border border-red-200`. These semantic colors (green/red for success/error) are NOT Sanctuary Stone tokens — they're status colors. The flash partial also has 3 inline SVGs (check-circle, exclamation-triangle, x-mark) that need Material Symbols replacement.

**Auth errors (partial):**
- `app/views/shared/_auth_errors.html.erb` — Has 2 inline SVGs and uses `bg-red-50 border border-red-200`. Same treatment as flash toast.

**Views with inline SVGs (icon replacement):**
- `app/views/decks/show.html.erb` — 3 SVGs (edit pencil icons for title/date/notes inline edit)
- `app/views/decks/index.html.erb` — 2 SVGs (trash icon on deck card, music-note empty state)
- `app/views/decks/_song_list.html.erb` — 1 SVG (music-note empty state)
- `app/views/decks/_export_button.html.erb` — 2 SVGs (check-circle success, arrow-down-tray download)
- `app/views/songs/index.html.erb` — 2 SVGs (search icon, music-note empty state)
- `app/views/songs/_failed.html.erb` — 1 SVG (exclamation-triangle error)

### Token Mapping

The complete color token set from DESIGN.md / Stitch HTML (all hex values):

| Token | Hex | Usage |
|-------|-----|-------|
| `surface` | `#fff8f5` | Global background (replaces `stone-50`) |
| `surface-dim` | `#e2d8d2` | Hover state for secondary buttons |
| `surface-container-lowest` | `#ffffff` | Card bodies |
| `surface-container-low` | `#fcf2eb` | Sidebar, secondary sections |
| `surface-container` | `#f6ece6` | Mid-level containers |
| `surface-container-high` | `#f0e6e0` | Elevated containers |
| `surface-container-highest` | `#eae1da` | Interactive elements, focus backgrounds |
| `surface-variant` | `#eae1da` | Same as container-highest (aliased) |
| `on-surface` | `#1f1b17` | Primary text (replaces `stone-900`) |
| `on-surface-variant` | `#5b403d` | Secondary text (replaces `stone-600`) |
| `primary` | `#93000b` | Primary brand color (replaces `rose-700`) |
| `primary-container` | `#b91c1c` | Gradient end for CTAs |
| `on-primary` | `#ffffff` | Text on primary bg |
| `secondary` | `#9f3f37` | Secondary actions |
| `tertiary` | `#00497f` | Informational/support actions |
| `outline` | `#8f6f6c` | Visible borders (rare) |
| `outline-variant` | `#e4beb9` | Ghost borders at 20% opacity |
| `error` | `#ba1a1a` | Error states |
| `inverse-surface` | `#342f2b` | Inverse container |
| `inverse-on-surface` | `#f9efe8` | Text on inverse |

Plus ~15 more tokens for fixed/dim variants (see Stitch HTML for complete set). Not all tokens need to be in `@theme` — only the ones actually used in views.

### Font Loading

Three Google Fonts links needed:
```
Newsreader: ital,opsz,wght@0,6..72,400;0,6..72,500;0,6..72,700;1,6..72,400
Inter: wght@400;500;600
Material Symbols Outlined: wght,FILL@100..700,0..1
```

The `material-symbols-outlined` class needs a CSS rule for font-variation-settings (goes in `application.css`):
```css
.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}
```

### SVG → Material Symbols Mapping

| Current SVG (Heroicon) | Material Symbol | Files |
|------------------------|-----------------|-------|
| check-circle | `check_circle` | flash_toast, export_button |
| exclamation-triangle | `warning` | flash_toast, auth_errors, songs/_failed |
| x-mark (close) | `close` | flash_toast, auth_errors |
| pencil (edit) | `edit` | decks/show (3 instances) |
| trash | `delete` | decks/index |
| music-note | `music_note` | decks/index, decks/_song_list, songs/index |
| arrow-down-tray | `download` | decks/_export_button |
| magnifying-glass | `search` | songs/index |

Replacement pattern: `<svg ...>...</svg>` → `<span class="material-symbols-outlined text-[size]">icon_name</span>`

### Build Order

1. **Tokens + Fonts** (CSS-only, zero ERB changes) — Rewrite `application.css` with full token set, add Material Symbols font-variation-settings to `app/assets/stylesheets/application.css`, swap Google Fonts links in layout `<head>`. After this, `bg-surface`, `text-on-surface`, `font-headline` all resolve. Verify by running Tailwind build and checking output includes new custom properties.

2. **Layout Reskin** — Rewrite `<body>` class and full `<nav>` block in `application.html.erb`. The nav changes from a simple `bg-stone-100 border-b` bar to the Stitch design: frosted glass (`bg-surface/80 backdrop-blur-xl`), Newsreader italic wordmark, nav links with active state detection, Material Symbols `mail` icon, gradient `New Deck` button (`bg-gradient-to-r from-primary to-primary-container`), and user email + logout. Flash container position may need adjustment.

3. **SVG → Material Symbols** — Replace all 13 SVG elements across 8 files. Each is a mechanical find-and-replace. This can happen in parallel with task 2 since they touch different files (except `_flash_toast.html.erb` which needs both color and icon changes — sequence carefully).

### Verification Approach

1. **Tailwind build succeeds**: `bin/rails tailwindcss:build` exits 0 and output CSS contains `--color-surface`, `--color-primary`, `--font-headline` etc.
2. **No SVG remnants**: `rg "<svg" app/views/` returns 0 results
3. **No Playfair references**: `rg "Playfair" app/` returns 0 results
4. **No worship-* tokens**: `rg "worship-" app/` returns 0 results
5. **Rails test**: `rails test` passes with no regressions (tests don't check CSS classes, so this is mainly checking nothing structural broke)
6. **Font loading**: Layout `<head>` contains links for Newsreader, Inter, and Material Symbols Outlined
7. **Token usage in body**: `<body>` uses `bg-surface text-on-surface` not `bg-stone-50 text-stone-900`

## Constraints

- **Tailwind v4 `@theme` syntax** — Tokens must be defined as `--color-*` custom properties with raw hex values, not `var()` references. The `@theme` block replaces the old `theme.extend.colors` from Tailwind v3 config. Font families use `--font-*` properties.
- **No Node/Webpack** — Material Symbols must load via Google Fonts CDN `<link>` tag, not npm. The stylesheet URL is `https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap`.
- **Importmap only** — No JS changes needed for this slice. All Stimulus controllers use generic CSS classes (opacity, translate, pinyin-hidden) — no stone/rose color references in any controller JS.
- **Status colors stay semantic** — Flash toasts and auth errors use green/red which are semantic status colors. These should stay as Tailwind built-in green/red (they're not part of the Sanctuary Stone palette). However, the `border` on them violates the "no-line rule" — replace with tonal background shifts.

## Common Pitfalls

- **`@theme` token naming** — In Tailwind v4, `--color-surface` maps to utility `bg-surface`, `text-surface` etc. But `--color-on-surface` maps to `bg-on-surface`, `text-on-surface`. Token names with hyphens work fine — just verify each token generates the expected utility by checking compiled CSS after the first build.
- **Opacity modifiers on custom colors** — Tailwind v4 supports `bg-primary/80` opacity syntax on custom `@theme` colors only when defined as raw hex or color values (not `var()` references). Since we're using hex values, this works. The nav uses `bg-surface/80` for the frosted glass effect.
- **Flash container positioning** — The flash container is positioned at `top-[80px]`. If the nav height changes (currently `py-4` = roughly 64px with content), update the flash offset to match.
- **Google Fonts `display=swap`** — All three font links should include `&display=swap` to prevent FOIT (flash of invisible text). The Stitch HTML already uses this.

## Sources

- Sanctuary Stone DESIGN.md (`stitch_deck_editor/stitch_deck_editor/sanctuary_stone/DESIGN.md`) — Full design system specification including color palette, typography scale, elevation rules, and component patterns
- Stitch login page HTML (`stitch_deck_editor/stitch_deck_editor/login_page/code.html`) — Complete token set in Tailwind config, Google Fonts links, Material Symbols setup
- Stitch deck editor HTML (`stitch_deck_editor/stitch_deck_editor/deck_editor_exclusive_background_theme/code.html`) — Nav bar markup reference, 3-column layout patterns
