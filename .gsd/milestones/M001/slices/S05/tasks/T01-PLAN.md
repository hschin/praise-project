# T01: 05-design-foundation 01

**Slice:** S05 — **Milestone:** M001

## Description

Define the Tailwind v4 design token foundation and replace all indigo/gray Tailwind classes with warm amber/stone equivalents across the 21 non-layout ERB view files.

Purpose: Establish the canonical color token source of truth and eliminate every legacy indigo and gray class from views so that the app displays the warm, worshipful palette (VIS-01).
Output: An @theme block in application.css; 21 view files with all indigo-* and gray-* classes replaced using the mapping table below.

## Must-Haves

- [ ] "No indigo-* Tailwind class appears in any view file (excluding application.html.erb which is handled by Plan 02)"
- [ ] "No gray-* Tailwind class appears in any view file (excluding application.html.erb)"
- [ ] "Warm amber and stone tokens are defined in the @theme block in application.css"

## Files

- `app/assets/tailwind/application.css`
- `app/views/decks/_export_button.html.erb`
- `app/views/decks/_form.html.erb`
- `app/views/decks/index.html.erb`
- `app/views/deck_songs/_song_block.html.erb`
- `app/views/deck_songs/_slide_item.html.erb`
- `app/views/songs/index.html.erb`
- `app/views/songs/show.html.erb`
- `app/views/songs/edit.html.erb`
- `app/views/songs/_form.html.erb`
- `app/views/songs/_lyrics.html.erb`
- `app/views/songs/_failed.html.erb`
- `app/views/songs/_processing.html.erb`
- `app/views/songs/processing.html.erb`
- `app/views/themes/_form.html.erb`
- `app/views/themes/_applied_theme.html.erb`
- `app/views/themes/_suggestion_card.html.erb`
- `app/views/devise/sessions/new.html.erb`
- `app/views/devise/registrations/new.html.erb`
- `app/views/devise/passwords/new.html.erb`
- `app/views/devise/shared/_links.html.erb`
