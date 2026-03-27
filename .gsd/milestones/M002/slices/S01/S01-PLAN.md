# S01: Design System Foundation

**Goal:** Tailwind tokens, fonts, Material Symbols, and shared layout (nav, flash, body) all render with Sanctuary Stone identity on every page
**Demo:** After this: Tailwind tokens, fonts, Material Symbols, and shared layout (nav, flash, body) all render with Sanctuary Stone identity on every page

## Must-Haves

- Full Sanctuary Stone @theme token set defined in `app/assets/tailwind/application.css` with ~40 color tokens, 3 font family tokens, border radius overrides, and ambient shadow utility
- Google Fonts `<link>` tags load Newsreader, Inter, and Material Symbols Outlined (Playfair Display fully removed)
- `<body>` uses `bg-surface text-on-surface font-body` — no stone-*/rose-* in body class
- Nav bar uses frosted glass (backdrop-blur-xl), Newsreader italic wordmark, active page indicator, Material Symbols mail icon, gradient New Deck button
- Flash toasts and auth errors use tonal backgrounds instead of 1px borders, Material Symbols icons instead of inline SVGs
- All 16 inline Heroicon SVGs across 8 view files replaced with Material Symbols `<span>` elements
- `bin/rails tailwindcss:build` succeeds with new tokens
- `rails test` passes with no regressions
- `grep -rn "<svg" app/views/` returns 0 results
- `grep -rn "Playfair" app/` returns 0 results
- `grep -rn "worship-" app/` returns 0 results

## Proof Level

- This slice proves: contract — tokens, fonts, and layout chrome render correctly; downstream slices can consume the token system

## Integration Closure

- Upstream surfaces consumed: none (foundation slice)
- New wiring introduced: Tailwind @theme token set consumed by all views, Google Fonts CDN links in layout head, Material Symbols web font available globally
- What remains: S02–S05 must reskin their own views using these tokens — this slice only covers the shared layout and icon replacement

## Verification

- none — pure frontend CSS/HTML changes with no runtime boundaries

## Tasks

- [x] **T01: Define Sanctuary Stone token system, swap fonts, and add ambient shadow utility** `est:30m`
  Rewrite the Tailwind v4 @theme block with the full Sanctuary Stone color palette (~40 tokens), font family tokens (headline/body/label), and border radius overrides. Swap the Google Fonts <link> tag in the layout head from Playfair Display to Newsreader + Inter + Material Symbols Outlined. Add Material Symbols font-variation-settings rule to app/assets/stylesheets/application.css. Add an ambient shadow CSS utility class. Change <body> class from stone-50/stone-900 to surface/on-surface/font-body.

This task covers requirements R001 (color tokens), R002 (typography swap), and R011 (ambient shadow definition).

Steps:
1. Rewrite `app/assets/tailwind/application.css` — replace the entire @theme block with Sanctuary Stone tokens. Use raw hex values, not var() references. Token list (from Stitch HTML):
   - surface: #fff8f5, surface-bright: #fff8f5, surface-dim: #e2d8d2
   - surface-container-lowest: #ffffff, surface-container-low: #fcf2eb, surface-container: #f6ece6
   - surface-container-high: #f0e6e0, surface-container-highest: #eae1da, surface-variant: #eae1da
   - on-surface: #1f1b17, on-surface-variant: #5b403d, on-background: #1f1b17
   - primary: #93000b, primary-container: #b91c1c, on-primary: #ffffff, on-primary-container: #ffcdc7
   - primary-fixed: #ffdad6, primary-fixed-dim: #ffb4ab, on-primary-fixed: #410002, on-primary-fixed-variant: #93000b
   - secondary: #9f3f37, secondary-container: #ff897d, on-secondary: #ffffff, on-secondary-container: #76211c
   - secondary-fixed: #ffdad6, secondary-fixed-dim: #ffb4ab, on-secondary-fixed: #410002, on-secondary-fixed-variant: #802822
   - tertiary: #00497f, tertiary-container: #0061a6, on-tertiary: #ffffff, on-tertiary-container: #c1dbff
   - tertiary-fixed: #d2e4ff, tertiary-fixed-dim: #a0caff, on-tertiary-fixed: #001c37, on-tertiary-fixed-variant: #00497e
   - error: #ba1a1a, error-container: #ffdad6, on-error: #ffffff, on-error-container: #93000a
   - outline: #8f6f6c, outline-variant: #e4beb9
   - inverse-surface: #342f2b, inverse-on-surface: #f9efe8, inverse-primary: #ffb4ab
   - surface-tint: #b91c1c, background: #fff8f5
   Font families: --font-headline: 'Newsreader', serif; --font-body: 'Inter', sans-serif; --font-label: 'Inter', sans-serif
   Border radius: --radius-DEFAULT: 0.125rem; --radius-lg: 0.25rem; --radius-xl: 0.5rem; --radius-full: 0.75rem

2. In `app/views/layouts/application.html.erb` <head>: Replace the Playfair Display Google Fonts link with three links:
   - `https://fonts.googleapis.com/css2?family=Newsreader:ital,opsz,wght@0,6..72,400;0,6..72,500;0,6..72,700;1,6..72,400&display=swap`
   - `https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap`
   - `https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap`

3. In `app/views/layouts/application.html.erb` <body>: Change class from `bg-stone-50 text-stone-900` to `bg-surface text-on-surface font-body`.

4. In `app/assets/stylesheets/application.css`: Add Material Symbols CSS rule and ambient shadow utility:
   ```css
   .material-symbols-outlined {
     font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
   }
   .shadow-ambient {
     box-shadow: 0 10px 40px rgba(31, 27, 23, 0.06);
   }
   ```

5. Run `bin/rails tailwindcss:build` and verify output CSS contains --color-surface, --color-primary, --font-headline etc.
  - Files: `app/assets/tailwind/application.css`, `app/assets/stylesheets/application.css`, `app/views/layouts/application.html.erb`
  - Verify: bin/rails tailwindcss:build && grep -q 'color-surface' app/assets/builds/tailwind.css && grep -q 'color-primary' app/assets/builds/tailwind.css && grep -q 'font-headline' app/assets/builds/tailwind.css && ! grep -q 'Playfair' app/views/layouts/application.html.erb && ! grep -q 'worship-' app/assets/tailwind/application.css && grep -q 'bg-surface' app/views/layouts/application.html.erb && echo 'PASS'

- [ ] **T02: Reskin nav bar with frosted glass, Newsreader wordmark, active indicators, and gradient CTA** `est:25m`
  Completely rewrite the <nav> block in application.html.erb to match the Sanctuary Stone design: frosted glass effect, Newsreader italic wordmark, active page detection with primary-colored text, Material Symbols mail icon, gradient New Deck button, and user email + logout. Also adjust flash container positioning if nav height changes.

This task covers requirements R010 (nav design) and R011 (frosted glass effect).

The target nav markup (adapted from Stitch deck_editor HTML for Rails ERB):

Steps:
1. In `app/views/layouts/application.html.erb`, replace the entire `<nav>` block (inside `unless devise_controller?`) with:
   ```erb
   <header class="bg-surface/80 backdrop-blur-xl flex justify-between items-center w-full px-8 h-16 sticky top-0 z-50 shadow-ambient">
     <div class="flex items-center gap-6">
       <%= link_to root_path, class: "text-2xl font-headline italic text-on-surface hover:opacity-80 transition-opacity" do %>
         Praise Project
       <% end %>
       <nav class="flex gap-6">
         <%= link_to "Decks", decks_path, class: "font-medium transition-colors duration-200 #{request.path.start_with?('/decks') ? 'text-primary border-b-2 border-primary pb-0.5' : 'text-on-surface-variant hover:text-primary'}" %>
         <%= link_to "Songs", songs_path, class: "font-medium transition-colors duration-200 #{request.path.start_with?('/songs') ? 'text-primary border-b-2 border-primary pb-0.5' : 'text-on-surface-variant hover:text-primary'}" %>
       </nav>
     </div>
     <div class="flex items-center gap-4">
       <span class="material-symbols-outlined text-on-surface-variant hover:bg-surface-container-highest p-2 rounded-full transition-colors cursor-pointer">mail</span>
       <%= button_to "New Deck", quick_create_decks_path, method: :post,
             class: "bg-gradient-to-r from-primary to-primary-container text-on-primary px-5 py-2 rounded-xl font-medium hover:opacity-90 transition-all active:scale-95 duration-150 cursor-pointer" %>
       <span class="text-sm text-on-surface-variant"><%= current_user.email %></span>
       <%= link_to "Logout", destroy_user_session_path, data: { turbo_method: :delete },
             class: "text-on-surface-variant font-medium hover:text-primary transition-colors" %>
     </div>
   </header>
   ```

2. Update the flash container `top-[80px]` to `top-[64px]` since the nav is now h-16 (64px) instead of variable py-4.

3. Verify the nav renders correctly by checking the ERB for key elements: frosted glass classes, Newsreader italic wordmark, gradient button, Material Symbols mail icon, active state detection.
  - Files: `app/views/layouts/application.html.erb`
  - Verify: grep -q 'backdrop-blur' app/views/layouts/application.html.erb && grep -q 'font-headline italic' app/views/layouts/application.html.erb && grep -q 'from-primary to-primary-container' app/views/layouts/application.html.erb && grep -q 'material-symbols-outlined' app/views/layouts/application.html.erb && grep -q 'top-\[64px\]' app/views/layouts/application.html.erb && ! grep -q 'bg-stone-100 border-b' app/views/layouts/application.html.erb && echo 'PASS'

- [ ] **T03: Replace all inline Heroicon SVGs with Material Symbols and remove borders from flash/auth partials** `est:35m`
  Replace every inline Heroicon SVG in all view files with Material Symbols <span> elements. Also remove 1px solid borders from flash toast and auth error partials (replace with tonal background styling that maintains visual distinction without line borders).

This task covers requirement R003 (SVG → Material Symbols).

SVG → Material Symbol mapping:
| Current SVG (Heroicon) | Material Symbol name | Files |
|------------------------|---------------------|-------|
| check-circle (success) | check_circle | _flash_toast, _export_button |
| exclamation-triangle (error) | warning | _flash_toast, _auth_errors, _failed |
| x-mark (close button) | close | _flash_toast, _auth_errors |
| pencil (edit) | edit | decks/show (3 instances) |
| trash (delete) | delete | decks/index |
| music-note (empty state) | music_note | decks/index, decks/_song_list, songs/index |
| arrow-down-tray (download) | download | decks/_export_button |
| magnifying-glass (search) | search | songs/index |

Replacement pattern: `<svg ...>...</svg>` → `<span class="material-symbols-outlined text-[size]">icon_name</span>`
Size mapping: w-3/h-3 or w-4/h-4 → text-base, w-5/h-5 → text-xl, w-8/h-8 → text-3xl, w-16/h-16 → text-6xl

Steps:
1. Edit `app/views/shared/_flash_toast.html.erb`:
   - Replace check-circle SVG with `<span class="material-symbols-outlined text-xl flex-shrink-0 <%= text_class %>">check_circle</span>`
   - Replace exclamation-triangle SVG with `<span class="material-symbols-outlined text-xl flex-shrink-0 <%= text_class %>">warning</span>`
   - Replace x-mark SVG close button content with `<span class="material-symbols-outlined text-base">close</span>`
   - Remove `border border-green-200` and `border border-red-200` from bg_class — change to `bg-green-50` and `bg-red-50` (no border). The tonal background alone provides sufficient visual distinction per the no-line rule.

2. Edit `app/views/shared/_auth_errors.html.erb`:
   - Replace exclamation-triangle SVG with `<span class="material-symbols-outlined text-xl flex-shrink-0 text-red-700">warning</span>`
   - Replace x-mark close SVG with `<span class="material-symbols-outlined text-base">close</span>`
   - Remove `border border-red-200` from the container class (keep `bg-red-50`).

3. Edit `app/views/decks/show.html.erb` — replace 3 pencil/edit SVGs with `<span class="material-symbols-outlined text-base">edit</span>` (keep existing wrapper classes).

4. Edit `app/views/decks/index.html.erb`:
   - Replace trash SVG with `<span class="material-symbols-outlined text-base">delete</span>`
   - Replace music-note empty state SVG with `<span class="material-symbols-outlined text-6xl">music_note</span>`

5. Edit `app/views/decks/_song_list.html.erb` — replace music-note SVG with `<span class="material-symbols-outlined text-3xl">music_note</span>`.

6. Edit `app/views/decks/_export_button.html.erb`:
   - Replace check-circle SVG with `<span class="material-symbols-outlined text-base">check_circle</span>`
   - Replace arrow-down-tray SVG with `<span class="material-symbols-outlined text-base">download</span>`

7. Edit `app/views/songs/index.html.erb`:
   - Replace magnifying-glass/search SVG with `<span class="material-symbols-outlined text-base">search</span>`
   - Replace music-note empty state SVG with `<span class="material-symbols-outlined text-3xl">music_note</span>`

8. Edit `app/views/songs/_failed.html.erb` — replace exclamation-triangle SVG with `<span class="material-symbols-outlined text-xl flex-shrink-0 text-red-500">warning</span>`.

9. Run `grep -rn '<svg' app/views/` to confirm zero SVG elements remain.
  - Files: `app/views/shared/_flash_toast.html.erb`, `app/views/shared/_auth_errors.html.erb`, `app/views/decks/show.html.erb`, `app/views/decks/index.html.erb`, `app/views/decks/_song_list.html.erb`, `app/views/decks/_export_button.html.erb`, `app/views/songs/index.html.erb`, `app/views/songs/_failed.html.erb`
  - Verify: test $(grep -rn '<svg' app/views/ | wc -l) -eq 0 && grep -q 'material-symbols-outlined' app/views/shared/_flash_toast.html.erb && grep -q 'material-symbols-outlined' app/views/decks/show.html.erb && grep -q 'material-symbols-outlined' app/views/songs/index.html.erb && ! grep -q 'border border-green-200' app/views/shared/_flash_toast.html.erb && ! grep -q 'border border-red-200' app/views/shared/_auth_errors.html.erb && rails test && echo 'PASS'

## Files Likely Touched

- app/assets/tailwind/application.css
- app/assets/stylesheets/application.css
- app/views/layouts/application.html.erb
- app/views/shared/_flash_toast.html.erb
- app/views/shared/_auth_errors.html.erb
- app/views/decks/show.html.erb
- app/views/decks/index.html.erb
- app/views/decks/_song_list.html.erb
- app/views/decks/_export_button.html.erb
- app/views/songs/index.html.erb
- app/views/songs/_failed.html.erb
