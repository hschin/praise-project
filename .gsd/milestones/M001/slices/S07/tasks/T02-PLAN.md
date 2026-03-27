# T02: 07-content-pages 02

**Slice:** S07 — **Milestone:** M001

## Description

Replace the divide-y list layout in decks/index.html.erb with a 3-column card grid where the service date is the headline on each card. Add an illustrated empty state with a micro-workflow explainer for first-time users.

Purpose: NAV-02 — users scan their deck library by date, not by title. EMPTY-01 — new users understand the app's purpose before creating anything.
Output: Updated decks/index.html.erb with grid layout and illustrated empty state.

## Must-Haves

- [ ] "Deck index displays decks as a 3-column card grid with date as the dominant heading on each card"
- [ ] "Each card shows date in large text, title below in smaller text, song count as metadata"
- [ ] "The trash delete icon is hidden until the user hovers the card, then reveals via opacity transition"
- [ ] "The turbo_confirm data attribute is preserved on the delete button_to"
- [ ] "First-time users with no decks see an illustrated empty state with the micro-workflow explanation"
- [ ] "The empty state shows the Build worship slide decks in minutes headline and 3-step list"
- [ ] "The empty state has a New Deck button in rose-700 style"

## Files

- `app/views/decks/index.html.erb`
