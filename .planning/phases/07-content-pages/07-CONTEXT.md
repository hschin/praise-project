# Phase 7: Content Pages - Context

**Gathered:** 2026-03-16
**Status:** Ready for planning

<domain>
## Phase Boundary

Make the deck index, song library, and auth pages visually complete. Covers: deck card grid (NAV-02), empty states on three pages (EMPTY-01, EMPTY-02, EMPTY-03), and auth page brand treatment (AUTH-01).

Does NOT include: deck editor internals (Phase 8), import/export flow polish (Phase 8).

</domain>

<decisions>
## Implementation Decisions

### Deck card grid (NAV-02)

- **Layout**: 3-column grid on desktop
- **Date is the headline**: Date displayed as the primary text (e.g., "Sunday 16 March") — `text-lg font-semibold` or similar large weight. Not title-first.
- **Below date**: Deck title in smaller secondary text, then song count as metadata
- **Card style**: Consistent with established card pattern — `rounded-xl shadow-sm border border-stone-200 bg-white`
- **Delete action**: Hover-reveal only — a small trash icon appears in the card corner on hover. Not always visible. Uses `turbo_confirm` (existing DOM contract on delete).
- **Click target**: The card as a whole links to the deck editor

### Deck empty state (EMPTY-01)

- **Illustration**: Single large inline SVG icon — a music note, slides icon, or similar. Heroicon or custom SVG. No multi-element composed illustration needed.
- **Layout**: Icon centered above text, centered on page
- **Copy**: Micro-workflow hint format — headline + 3-step flow:
  - "Build worship slide decks in minutes"
  - 1. Search for songs
  - 2. Build your deck
  - 3. Download as PPTX
- **CTA**: Primary "New Deck" button (same rose-700 style) below the steps

### Auth pages (AUTH-01)

- **Wordmark**: Replace `font-bold` with `font-serif` on the "Praise Project" heading — matches nav wordmark (Phase 5). Color: `text-rose-700`.
- **No tagline needed** — wordmark alone is sufficient brand context
- **Form card**: Wrap the form in a white card (`bg-white rounded-xl shadow-sm border border-stone-200`) centered on the stone-50 page background
- **Background**: Keep stone-50 — no gradient or special treatment
- **Scope**: Sign-in (`devise/sessions/new`) and sign-up (`devise/registrations/new`) pages. Other Devise views (password reset, etc.) are Claude's discretion.

### Song library empty state (EMPTY-03)

- **Style**: Lighter than deck empty state — small music-note icon + single helpful line
- **Copy**: "Import a song above to build your library."
- **Rationale**: The import/search form is already visible above — no need to duplicate CTA. Just improve the empty area below the form.

### Deck editor no-songs state (EMPTY-02)

- **Style**: Small icon (music note or plus) + brief instruction
- **Copy**: "Your arrangement will appear here. Add a song from the left panel."
- **Placement**: Inside the arrangement/middle panel where songs render

### Claude's Discretion

- Exact icon choice for each empty state (music note, slides, document — pick whatever best conveys the concept)
- Exact font size and weight for date headline on deck cards
- Hover transition details on the trash icon (opacity fade or translate)
- Whether the 3-step micro-workflow uses numbered list, icon bullets, or horizontal steps
- Exact `max-w` and padding on auth page card wrapper
- Which remaining Devise views (password reset, etc.) to apply card treatment to

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets

- `app/views/decks/index.html.erb` — current list layout; replace the `divide-y` list with a CSS grid. The "New Deck" button_to and heading already exist; keep them.
- `app/views/songs/index.html.erb` — has `<% else %>` branch at the bottom for empty state; replace the two-line text with icon + copy.
- `app/views/decks/show.html.erb:94-96` — `<% else %>` branch inside the `sortable` div: `<p class="text-stone-400 text-sm">No songs added yet.</p>` — replace with icon + instruction.
- `app/views/devise/sessions/new.html.erb` — already has warm palette. Change `font-bold` → `font-serif text-rose-700` on wordmark, wrap form in white card.
- `app/views/devise/registrations/new.html.erb` — same treatment as sessions/new.

### Established Patterns

- Card style: `bg-white rounded-xl shadow-sm border border-stone-200` — established in Phase 5, used across the app.
- Primary button: `bg-rose-700 text-white text-sm px-4 py-2 rounded-lg hover:bg-rose-800 cursor-pointer font-medium`
- Font-serif wordmark: `font-serif text-rose-700` — set in Phase 5 on the nav; replicate on auth pages.
- Heroicons inline SVG: copy SVG path inline into ERB — no npm, per REQUIREMENTS.md constraint.
- Hover-reveal pattern: use Tailwind `group` / `group-hover:opacity-100 opacity-0` to reveal the trash icon on card hover.
- `turbo_confirm` on delete button — must be preserved on the deck card delete action.

### Integration Points

- `DecksController#index` — `@decks` already loaded; no controller changes needed. Grid is pure view change.
- `button_to` for delete on deck cards — keep `method: :delete, data: { turbo_confirm: ... }`. Just change the button's visual treatment to a hover-reveal icon.
- Auth pages are Devise views in `app/views/devise/` — no controller changes; pure ERB/CSS updates.
- DOM contract: `export_button_#{deck_id}` target IDs must not be touched (they're on show.html.erb, not index — safe here).

</code_context>

<specifics>
## Specific Ideas

- Deck card date format: "Sunday 16 March" — user approved this in discussion. Day name + day + month, no year (keeps it brief).
- 3-column grid: user chose this over 2-column for scannability across multiple decks.
- Micro-workflow hint on empty state: user chose the 3-step format over a single sentence — helps first-time users understand the full workflow before they start.
- Auth page card wrapper: the form should feel contained and focused, not floating on a bare page.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within Phase 7 scope.

</deferred>

---

*Phase: 07-content-pages*
*Context gathered: 2026-03-16*
