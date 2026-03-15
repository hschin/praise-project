# Phase 5: Design Foundation - Context

**Gathered:** 2026-03-15
**Status:** Ready for planning

<domain>
## Phase Boundary

Define the Tailwind design token foundation (palette, typography, border radius), apply the unified component language to all shared elements, and restructure navigation so deck creation is the primary entry point. This phase delivers the visual and structural foundation that all subsequent phases (6–8) build on.

Does NOT include: form system polish (Phase 6), deck card grid / empty states (Phase 7), deck editor internals (Phase 8).

</domain>

<decisions>
## Implementation Decisions

### Palette tokens

- **Primary action color**: Deep amber-brown — Tailwind `amber-800` / `amber-900`. Used for buttons, active links, and the wordmark.
- **Body background**: `stone-50` — warm off-white, like cream paper. Replaces `gray-50` everywhere.
- **Nav background**: `stone-100` — slightly warmer than pure white. Replaces `bg-white` on the nav bar.
- **Borders**: `stone-200` — same lightness as current `gray-200` but warm hue. Replace all `border-gray-200` and `border-gray-300`.
- **Focus rings**: amber-colored — replace all `focus:ring-indigo-500` with warm equivalent (amber-600 or amber-700).
- **Body text**: `stone-900` — replaces `gray-900`.
- **Secondary text**: `stone-500` / `stone-600` — replaces `gray-500` / `gray-600`.
- All `bg-indigo-600`, `text-indigo-600`, `hover:bg-indigo-700` instances across views must be replaced with the amber-brown primary.

### Tailwind v4 token approach

- The app uses Tailwind v4 with CSS-first config (`@import "tailwindcss"` in `application.css`).
- Custom design tokens should be defined using `@theme` block in `app/assets/tailwind/application.css` — NOT a `tailwind.config.js` file.
- Define semantic tokens: `--color-worship-primary` (amber-800), `--color-worship-surface` (stone-50), `--color-worship-nav` (stone-100), `--color-worship-border` (stone-200).
- After defining tokens, do a global class replacement pass across all ERB views: `indigo-*` → appropriate worship token.

### Wordmark

- Styled text only — no icon or symbol.
- Use Tailwind's `font-serif` utility to give a traditional, reverential feel.
- Color: amber-brown primary (`text-amber-800` or custom `worship-primary` token).
- The current "Praise Project" plain bold text becomes a font-serif wordmark.

### Navigation structure

- **Songs link moves to the right side**, near Logout — treated as a utility link, not a primary nav item.
- **Decks link** stays on the left side in the main nav area.
- **"New Deck" button** added to the nav as a persistent amber-brown CTA button — visible from every page, always one click away.
- New nav layout: `[Praise Project wordmark] [Decks] ............. [New Deck button] [Songs] [email] [Logout]`

### Deck creation flow (NAV-03 + NAV-04)

- **No form step**: Clicking "New Deck" (anywhere — nav or deck index) performs an instant POST that creates the deck with default values and redirects to the deck editor.
- **Default title**: Upcoming Sunday's date as the title string (e.g., "Sunday 15 March"). Logic: if today is Mon–Sat, use this coming Sunday; if today is Sunday, use today.
- **Inline-editable title**: The deck editor (Phase 5 only sets up the creation path — inline editing behavior for the title is NAV-04, also Phase 5). The title shown in the deck editor header should be wrapped in an inline-edit affordance (pencil icon on hover) from day one.
- The existing `new_deck` route and `DecksController#new` action can be preserved for any edge-case uses, but the primary "New Deck" button flow bypasses it via a direct POST to `decks#create` with pre-filled params.

### Component language (VIS-02)

- All rounded corners should be unified: cards → `rounded-xl`, buttons → `rounded-lg`, inputs → `rounded-lg`. Replace inconsistent `rounded` / `rounded-lg` mix.
- Shadows: cards get `shadow-sm`, not `shadow`. Consistent across all card elements.
- Button padding: `px-4 py-2` minimum for primary buttons. Consistent everywhere.

### Typography scale (VIS-03)

- Page headings (`h1`): `text-2xl font-semibold` with `leading-snug` — not `font-bold` which feels too heavy for a worship tool.
- Section headings (`h2`, card labels): `text-base font-medium`.
- Body text: `text-sm` with `leading-relaxed` for comfortable reading.
- Caption/metadata: `text-xs text-stone-500`.

### Claude's Discretion

- Exact hex values for amber-brown primary (whether to use Tailwind's built-in `amber-800` or define a custom hex) — Claude should pick the warmer, more muted option.
- Whether to use `@theme` CSS variables or direct Tailwind class replacements in views — use whichever is more idiomatic for Tailwind v4.
- Specific letter-spacing or font-size tuning on the wordmark beyond `font-serif`.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets

- `app/views/layouts/application.html.erb` — nav and flash messages live here; this is the primary file for VIS-01/VIS-02/NAV-01/VIS-04 changes.
- `app/assets/tailwind/application.css` — currently only `@import "tailwindcss"`. This is where `@theme` token block goes.
- `app/assets/stylesheets/application.css` — contains `.pinyin-hidden` class; must NOT be modified or pruned.
- `app/views/decks/index.html.erb` — current deck list; "New Deck" button is here (`link_to "New Deck", new_deck_path`).
- `app/views/decks/_form.html.erb` — current deck creation form; will be bypassed for the primary flow but can be kept as fallback.
- `app/views/devise/sessions/new.html.erb` — currently bare Devise form; auth page redesign is Phase 7, but the palette change will cascade here automatically once tokens are applied globally.

### Established Patterns

- All primary buttons: `bg-indigo-600 text-white text-sm px-4 py-2 rounded hover:bg-indigo-700` — global search-replace target for amber-brown.
- All focus rings: `focus:ring-indigo-500` — global search-replace target for amber equivalent.
- Nav links: `text-sm text-gray-600 hover:text-gray-900` — secondary nav pattern to be preserved for Songs.
- `content_for(:main_class)` in `decks/show.html.erb` — DO NOT change. The deck editor needs `w-full` layout override; preserve this mechanism.

### Integration Points

- `DecksController#create` — needs to accept a quick-create path (default title + redirect). Existing controller logic creates a deck from form params; new path either adds a separate `quick_create` action or handles blank params with defaults.
- Routes: a new route `POST /decks/quick_create` is one clean option, or `create` can detect the "no form" case (blank params = use defaults).
- Turbo Stream DOM IDs — `export_button_#{deck_id}`, `theme_suggestions`, `import_status`, `song_status_#{song.id}` — these `id=` attributes are contracts with background jobs. DO NOT rename them during any layout refactor.

</code_context>

<specifics>
## Specific Ideas

- "Warm off-white like cream paper" — user's frame for stone-50 background.
- "Reverential" — user's word for the font-serif wordmark.
- Songs link repositioned to right side near Logout — "utility link" positioning, not removed.
- "New Deck" button always visible in nav — reinforces deck creation as the primary workflow regardless of which page the user is on.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within Phase 5 scope.

</deferred>

---

*Phase: 05-design-foundation*
*Context gathered: 2026-03-15*
