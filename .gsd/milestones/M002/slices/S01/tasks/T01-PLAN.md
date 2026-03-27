---
estimated_steps: 35
estimated_files: 3
skills_used: []
---

# T01: Define Sanctuary Stone token system, swap fonts, and add ambient shadow utility

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

## Inputs

- ``app/assets/tailwind/application.css` — current @theme block with worship-* tokens to be replaced`
- ``app/views/layouts/application.html.erb` — current layout with Playfair Display font link and stone-* body classes`
- ``app/assets/stylesheets/application.css` — current stylesheet where Material Symbols and shadow utility rules will be added`

## Expected Output

- ``app/assets/tailwind/application.css` — rewritten with full Sanctuary Stone @theme token set (~40 color tokens, font families, border radii)`
- ``app/assets/stylesheets/application.css` — updated with .material-symbols-outlined and .shadow-ambient CSS rules`
- ``app/views/layouts/application.html.erb` — <head> has Newsreader+Inter+Material Symbols font links, <body> uses bg-surface text-on-surface font-body`

## Verification

bin/rails tailwindcss:build && grep -q 'color-surface' app/assets/builds/tailwind.css && grep -q 'color-primary' app/assets/builds/tailwind.css && grep -q 'font-headline' app/assets/builds/tailwind.css && ! grep -q 'Playfair' app/views/layouts/application.html.erb && ! grep -q 'worship-' app/assets/tailwind/application.css && grep -q 'bg-surface' app/views/layouts/application.html.erb && echo 'PASS'
