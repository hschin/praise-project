# T02: 05-design-foundation 02

**Slice:** S05 — **Milestone:** M001

## Description

Restructure the global application layout to apply the warm palette, styled wordmark, and redesigned navigation bar — establishing the visual foundation that every page inherits.

Purpose: The layout file is the single highest-leverage change in Phase 5 — it touches every page simultaneously. Getting the wordmark, nav structure, body class, and typography baseline right here delivers VIS-01, VIS-02, VIS-03, VIS-04, and NAV-01 in one file.
Output: Updated application.html.erb with warm body/nav colors, font-serif wordmark, restructured nav (Decks primary / New Deck CTA / Songs + Logout utility), and flash styling.

## Must-Haves

- [ ] "The page body uses bg-stone-50 text-stone-900 — not bg-gray-50 text-gray-900"
- [ ] "The nav wordmark 'Praise Project' uses font-serif and text-amber-800 — not font-bold text-indigo-600"
- [ ] "The nav bar background is bg-stone-100 with border-stone-200 — not bg-white"
- [ ] "The Decks link appears in the primary left-side nav area"
- [ ] "The Songs link appears in the right utility area near Logout"
- [ ] "A 'New Deck' button_to quick_create_decks_path is present in the nav and styled as the primary amber CTA"
- [ ] "Flash notice and alert divs use stone/warm colors — not green-50/red-50 bare divs"

## Files

- `app/views/layouts/application.html.erb`
