---
estimated_steps: 38
estimated_files: 8
skills_used: []
---

# T03: Replace all inline Heroicon SVGs with Material Symbols and remove borders from flash/auth partials

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

## Inputs

- ``app/views/shared/_flash_toast.html.erb` — flash toast partial with 3 inline SVGs and border styling`
- ``app/views/shared/_auth_errors.html.erb` — auth errors partial with 2 inline SVGs and border styling`
- ``app/views/decks/show.html.erb` — deck show view with 3 pencil/edit SVGs`
- ``app/views/decks/index.html.erb` — decks index with trash and music-note SVGs`
- ``app/views/decks/_song_list.html.erb` — song list partial with music-note SVG`
- ``app/views/decks/_export_button.html.erb` — export button with check-circle and arrow-down-tray SVGs`
- ``app/views/songs/index.html.erb` — song index with search and music-note SVGs`
- ``app/views/songs/_failed.html.erb` — failed partial with exclamation-triangle SVG`

## Expected Output

- ``app/views/shared/_flash_toast.html.erb` — SVGs replaced with Material Symbols spans, border classes removed`
- ``app/views/shared/_auth_errors.html.erb` — SVGs replaced with Material Symbols spans, border classes removed`
- ``app/views/decks/show.html.erb` — 3 edit pencil SVGs replaced with Material Symbols edit spans`
- ``app/views/decks/index.html.erb` — trash and music-note SVGs replaced with Material Symbols spans`
- ``app/views/decks/_song_list.html.erb` — music-note SVG replaced with Material Symbols span`
- ``app/views/decks/_export_button.html.erb` — check-circle and download SVGs replaced with Material Symbols spans`
- ``app/views/songs/index.html.erb` — search and music-note SVGs replaced with Material Symbols spans`
- ``app/views/songs/_failed.html.erb` — warning SVG replaced with Material Symbols span`

## Verification

test $(grep -rn '<svg' app/views/ | wc -l) -eq 0 && grep -q 'material-symbols-outlined' app/views/shared/_flash_toast.html.erb && grep -q 'material-symbols-outlined' app/views/decks/show.html.erb && grep -q 'material-symbols-outlined' app/views/songs/index.html.erb && ! grep -q 'border border-green-200' app/views/shared/_flash_toast.html.erb && ! grep -q 'border border-red-200' app/views/shared/_auth_errors.html.erb && rails test && echo 'PASS'
