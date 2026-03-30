# S01: Design System Foundation

**Goal:** Tailwind tokens, fonts, Material Symbols, and shared layout (nav, flash, body) all render with Sanctuary Stone identity on every page
**Demo:** After this: After this: Tailwind tokens, fonts, Material Symbols, and shared layout (nav, flash, body) all render with Sanctuary Stone identity on every page

## Tasks
- [x] **T01: Define Sanctuary Stone token system, swap fonts, and add ambient shadow utility** — 
  - Files: app/assets/tailwind/application.css, app/assets/stylesheets/application.css, app/views/layouts/application.html.erb
  - Verify: bin/rails tailwindcss:build && grep -q 'color-surface' app/assets/builds/tailwind.css && grep -q 'color-primary' app/assets/builds/tailwind.css && grep -q 'font-headline' app/assets/builds/tailwind.css && ! grep -q 'Playfair' app/views/layouts/application.html.erb && ! grep -q 'worship-' app/assets/tailwind/application.css && grep -q 'bg-surface' app/views/layouts/application.html.erb && echo 'PASS'
- [x] **T02: Reskinned nav bar with frosted glass, Newsreader italic wordmark, active page underlines, Material Symbols mail icon, and gradient New Deck CTA** — 
  - Files: app/views/layouts/application.html.erb
  - Verify: grep -q 'backdrop-blur' app/views/layouts/application.html.erb && grep -q 'font-headline italic' app/views/layouts/application.html.erb && grep -q 'from-primary to-primary-container' app/views/layouts/application.html.erb && grep -q 'material-symbols-outlined' app/views/layouts/application.html.erb && grep -q 'top-\[64px\]' app/views/layouts/application.html.erb && ! grep -q 'bg-stone-100 border-b' app/views/layouts/application.html.erb && echo 'PASS'
- [x] **T03: Replaced all 16 inline Heroicon SVGs with Material Symbols spans and removed 1px borders from flash/auth partials** — 
  - Files: app/views/shared/_flash_toast.html.erb, app/views/shared/_auth_errors.html.erb, app/views/decks/show.html.erb, app/views/decks/index.html.erb, app/views/decks/_song_list.html.erb, app/views/decks/_export_button.html.erb, app/views/songs/index.html.erb, app/views/songs/_failed.html.erb
  - Verify: test $(grep -rn '<svg' app/views/ | wc -l) -eq 0 && grep -q 'material-symbols-outlined' app/views/shared/_flash_toast.html.erb && grep -q 'material-symbols-outlined' app/views/decks/show.html.erb && grep -q 'material-symbols-outlined' app/views/songs/index.html.erb && ! grep -q 'border border-green-200' app/views/shared/_flash_toast.html.erb && ! grep -q 'border border-red-200' app/views/shared/_auth_errors.html.erb && rails test && echo 'PASS'
