# Phase 7: Content Pages - Research

**Researched:** 2026-03-16
**Domain:** Rails ERB view updates — CSS grid layout, empty states, Tailwind group-hover pattern, Devise view brand treatment
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Deck card grid (NAV-02)**
- Layout: 3-column grid on desktop
- Date is the headline: "Sunday 16 March" format — `text-lg font-semibold` or similar. Not title-first.
- Below date: deck title in smaller secondary text, then song count as metadata
- Card style: `rounded-xl shadow-sm border border-stone-200 bg-white`
- Delete action: hover-reveal only — trash icon in card corner, uses `turbo_confirm` (existing DOM contract)
- Click target: the card as a whole links to the deck editor

**Deck empty state (EMPTY-01)**
- Single large inline SVG icon (music note, slides, or similar — Heroicon or custom)
- Icon centered above text, centered on page
- Copy: "Build worship slide decks in minutes" headline + 3-step flow:
  1. Search for songs
  2. Build your deck
  3. Download as PPTX
- Primary "New Deck" button (rose-700 style) below the steps

**Auth pages (AUTH-01)**
- Wordmark: `font-bold` → `font-serif text-rose-700` on the "Praise Project" heading
- No tagline needed
- Form card: `bg-white rounded-xl shadow-sm border border-stone-200` centered on stone-50 background
- Scope: `devise/sessions/new` and `devise/registrations/new` are required. Other Devise views at Claude's discretion.

**Song library empty state (EMPTY-03)**
- Lighter treatment: small music-note icon + single line
- Copy: "Import a song above to build your library."

**Deck editor no-songs state (EMPTY-02)**
- Small icon (music note or plus) + brief instruction
- Copy: "Your arrangement will appear here. Add a song from the left panel."
- Placement: inside the sortable div in `decks/show.html.erb` (line 93)

### Claude's Discretion

- Exact icon choice for each empty state
- Exact font size and weight for date headline on deck cards
- Hover transition details on the trash icon (opacity fade or translate)
- Whether the 3-step micro-workflow uses numbered list, icon bullets, or horizontal steps
- Exact `max-w` and padding on auth page card wrapper
- Which remaining Devise views (passwords/new, unlocks/new, etc.) to apply card treatment to

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within Phase 7 scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| NAV-02 | Deck list page displays decks as a card grid with service date as the most prominent element on each card | CSS grid layout pattern; Tailwind group-hover for trash reveal; date formatting via `strftime` |
| EMPTY-01 | Deck index shows illustrated empty state for new users that explains the app's purpose and prompts them to create their first deck | Inline SVG Heroicons pattern; centered layout with micro-workflow copy |
| EMPTY-02 | Deck editor with no songs added yet shows a contextual cue guiding the user to add their first song | Existing `<% else %>` branch at `show.html.erb:93`; small icon + copy replacement |
| EMPTY-03 | Song library with no songs shows an orientation cue explaining how to import a song | Existing `<% else %>` branch at `songs/index.html.erb:59`; small icon + copy replacement |
| AUTH-01 | Sign-in and sign-up pages use the warm palette and brand context | Wordmark treatment (`font-serif text-rose-700`); white card wrapper matching established card pattern |
</phase_requirements>

---

## Summary

Phase 7 is entirely a view layer exercise — no controller changes, no migrations, no JavaScript. Every requirement maps to a targeted ERB edit in an existing file. The backend already loads the correct data (`@decks`, `@songs`, Devise form objects); this phase only changes how it is displayed.

The two largest changes are the deck index (replacing a `divide-y` list with a CSS grid and redesigning the card) and the deck empty state (replacing two plain-text lines with an illustrated micro-workflow explainer). The auth and library empty-state changes are smaller — they involve wrapping existing form markup in a card div and dropping in a small icon + line of copy.

All established visual tokens are already in use across the app. The planner can reference them directly without introducing any new CSS files or Tailwind config changes.

**Primary recommendation:** Treat each requirement as one targeted file edit. Sequence by complexity: auth pages first (smallest), then empty states, then the deck card grid last (most structural).

---

## Standard Stack

### Core
| Library / Pattern | Version | Purpose | Why Standard |
|-------------------|---------|---------|--------------|
| Tailwind CSS (CDN/Propshaft) | v3.x | All utility classes | Already in use project-wide; no config file needed |
| Rails ERB | Rails 8.1.2 | View templating | Project stack |
| Heroicons inline SVG | — | Empty state icons | REQUIREMENTS.md explicitly disallows npm icon libraries; inline SVG is the approved pattern |
| Devise views | — | Auth form templates | Already customized in `app/views/devise/` |

### Supporting
| Pattern | Purpose | When to Use |
|---------|---------|-------------|
| `group` / `group-hover:` Tailwind | Reveal trash icon on card hover | On the deck card wrapper `<a>` tag |
| `button_to` with `method: :delete` | Delete deck with turbo_confirm | Preserve existing DOM contract exactly |
| `strftime("%A %-d %B")` | Format date as "Sunday 16 March" | On deck cards (day name, day number, month name — no year) |
| `content_for` / `yield` | Layout slots | Not needed here — all edits are within existing page content |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Inline SVG Heroicons | Font Awesome, Lucide npm package | npm packages don't work with Importmap cleanly — inline SVG is the project-approved approach |
| Tailwind group-hover | Stimulus controller for hover | Tailwind group-hover is zero-JS and sufficient; Stimulus adds unnecessary complexity for a simple opacity reveal |
| Pure Tailwind grid | Custom CSS grid | Tailwind grid utilities cover all cases needed here; no custom CSS required |

**Installation:** No new packages needed. This phase is pure view/ERB changes.

---

## Architecture Patterns

### Files Changed in This Phase

```
app/views/
├── decks/
│   ├── index.html.erb       # NAV-02, EMPTY-01 — grid layout + illustrated empty state
│   └── show.html.erb        # EMPTY-02 — replace plain text at line 93
├── songs/
│   └── index.html.erb       # EMPTY-03 — replace empty branch at line 59-63
└── devise/
    ├── sessions/new.html.erb           # AUTH-01 — wordmark + card wrapper
    ├── registrations/new.html.erb      # AUTH-01 — wordmark + card wrapper
    └── passwords/new.html.erb          # AUTH-01 discretionary — already has same structure
```

### Pattern 1: Tailwind CSS Grid (3-column deck cards)

**What:** Replace the `divide-y` list container with a `grid` container. Each deck becomes a card `<a>` link.
**When to use:** `@decks.any?` branch in `decks/index.html.erb`

```erb
<%# Source: established project pattern + Tailwind grid utilities %>
<div class="grid grid-cols-3 gap-4">
  <% @decks.each do |deck| %>
    <div class="relative group bg-white rounded-xl shadow-sm border border-stone-200 hover:shadow-md transition-shadow">
      <%= link_to deck_path(deck), class: "block p-4" do %>
        <p class="text-lg font-semibold text-stone-900">
          <%= deck.date.strftime("%A %-d %B") %>
        </p>
        <p class="text-sm text-stone-600 mt-0.5"><%= deck.title %></p>
        <p class="text-xs text-stone-400 mt-1"><%= deck.deck_songs.count %> songs</p>
      <% end %>
      <%# Hover-reveal delete — preserved turbo_confirm contract %>
      <div class="absolute top-3 right-3 opacity-0 group-hover:opacity-100 transition-opacity">
        <%= button_to deck_path(deck), method: :delete,
              data: { turbo_confirm: "Delete \"#{deck.title}\"?" },
              class: "p-1 text-stone-400 hover:text-red-600 bg-transparent border-0 cursor-pointer" do %>
          <%# Inline Heroicons trash SVG here %>
        <% end %>
      </div>
    </div>
  <% end %>
</div>
```

### Pattern 2: Illustrated Empty State (EMPTY-01)

**What:** Replace the plain two-line empty state with icon + headline + 3-step list + CTA button.
**When to use:** `@decks.empty?` branch in `decks/index.html.erb`

```erb
<%# Source: CONTEXT.md design decision + established button pattern %>
<div class="text-center py-20">
  <%# Inline Heroicons SVG — music note or presentation-chart-bar icon %>
  <div class="mx-auto w-16 h-16 text-stone-300 mb-6">
    <!-- SVG inline here -->
  </div>
  <h2 class="text-lg font-semibold text-stone-700 mb-2">Build worship slide decks in minutes</h2>
  <ol class="text-sm text-stone-500 space-y-1 mb-6 list-none">
    <li>1. Search for songs</li>
    <li>2. Build your deck</li>
    <li>3. Download as PPTX</li>
  </ol>
  <%= button_to "New Deck", quick_create_decks_path, method: :post,
        class: "bg-rose-700 text-white text-sm px-4 py-2 rounded-lg hover:bg-rose-800 cursor-pointer font-medium" %>
</div>
```

### Pattern 3: Auth Page Card Wrapper (AUTH-01)

**What:** Wrap existing form content in a white card; change `font-bold` to `font-serif text-rose-700` on the wordmark `<h1>`.
**When to use:** `devise/sessions/new.html.erb`, `devise/registrations/new.html.erb`

```erb
<%# Before: plain max-w-md wrapper %>
<%# After: max-w-md wrapper with inner card %>
<div class="max-w-md mx-auto mt-12">
  <h1 class="text-2xl font-serif text-rose-700 text-center mb-2">Praise Project</h1>
  <h2 class="text-lg text-stone-600 text-center mb-6">Sign in</h2>
  <div class="bg-white rounded-xl shadow-sm border border-stone-200 p-8">
    <%# form markup unchanged inside %>
  </div>
  <div class="mt-4 space-y-1 text-sm text-stone-500 text-center">
    <%= render "devise/shared/links" %>
  </div>
</div>
```

### Pattern 4: Small Icon Empty State (EMPTY-02, EMPTY-03)

**What:** Replace a plain `<p>` with a small centered icon + brief text line.
**When to use:** `else` branch in sortable div (`show.html.erb:93`); `else` branch in songs list (`songs/index.html.erb:59`)

```erb
<%# Compact — no CTA needed because the action affordance is already visible above/beside %>
<div class="text-center py-8">
  <div class="mx-auto w-8 h-8 text-stone-300 mb-2">
    <!-- small inline SVG icon -->
  </div>
  <p class="text-sm text-stone-400">Your arrangement will appear here. Add a song from the left panel.</p>
</div>
```

### Anti-Patterns to Avoid

- **Removing `turbo_confirm` from the delete button:** The `data: { turbo_confirm: ... }` attribute is a DOM contract listed in STATE.md. It must be preserved exactly.
- **Adding wrapper divs inside the sortable container:** `data-drag-handle` and `data-id` attributes on drag items must remain direct children of the sortable div. EMPTY-02 is the `else` branch, so there is no conflict, but the `if` branch must not be restructured.
- **Using `link_to` instead of `button_to` for delete:** The delete action requires `method: :delete` via `button_to`; `link_to` with `method:` is deprecated in Rails 7+.
- **Changing the `font-bold` on nav wordmark:** The nav wordmark was already changed to `font-serif text-rose-700` in Phase 5. Only the auth page `<h1>` still has `font-bold` — that is the target.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Icon display | Custom SVG sprite system or icon component | Copy Heroicons SVG path inline | REQUIREMENTS.md constraint: no npm icon packages; inline is the approved approach |
| Hover reveal | Stimulus controller with mouseenter/mouseleave | Tailwind `group` + `group-hover:opacity-100 opacity-0` | Pure CSS, zero JS, sufficient for a simple opacity toggle |
| 3-step list layout | Custom Stimulus counter or JS | Plain `<ol>` or `<ul>` with Tailwind spacing | Static content — no dynamic behavior needed |
| Card click area | JavaScript click handler | `<a>` wrapping the card content, delete `button_to` outside the `<a>` | Native HTML; avoids nested interactive elements inside `<a>` |

**Key insight:** Every interaction in this phase is either a plain link, a form submit, or a CSS hover — none require JavaScript.

---

## Common Pitfalls

### Pitfall 1: Nested `<a>` Inside `<a>`

**What goes wrong:** If the whole card is a `<a>` link and the delete button is also inside it, HTML spec prohibits interactive elements nested inside `<a>`. Some browsers will silently ignore the inner button's click.
**Why it happens:** Making the whole card clickable and wanting the delete affordance inside the same visual boundary.
**How to avoid:** Use `absolute` positioning to place the delete button visually inside the card while keeping it a sibling of the `<a>` in the DOM (both children of the `relative group` wrapper div).
**Warning signs:** Delete button appears to work in development but confirmation dialog doesn't fire.

### Pitfall 2: `strftime` Format String for "Day 16 March"

**What goes wrong:** Using `%d` (zero-padded: "16") instead of `%-d` (no-padding: "16") — only matters for single-digit days like "Sunday 5 March" vs "Sunday 05 March".
**Why it happens:** `%d` is the common strftime directive; `%-d` is the POSIX extension for no padding (Linux/macOS only).
**How to avoid:** Use `deck.date.strftime("%A %-d %B")` — confirmed correct on macOS/Linux (Heroku, Render). On Windows dev environments `%-d` may not work, but the app targets Unix.

### Pitfall 3: Breaking the `data-turbo-permanent` Flash Container

**What goes wrong:** Editing `decks/index.html.erb` layout changes might inadvertently restructure the page body. The flash toast container uses `data-turbo-permanent` (set in Phase 6) and must remain in the application layout, not inside page templates.
**Why it happens:** Confusion between what's in the layout vs what's in the page template.
**How to avoid:** `decks/index.html.erb` does not contain the flash container — it's in the application layout. No risk as long as edits stay within the template file.

### Pitfall 4: Auth Card Wrapping the Links Too

**What goes wrong:** Wrapping the entire `<div class="max-w-md mx-auto mt-12">` contents in the card, including the `render "devise/shared/links"` block, makes the "Forgot your password?" and "Sign up" links appear inside the card rather than as subtle footnote links below it.
**Why it happens:** The card wrapper is placed too broadly.
**How to avoid:** The card div should wrap only the `form_for` block. The `devise/shared/links` render stays outside the card, below it.

### Pitfall 5: `deck_songs.count` N+1 on Card Grid

**What goes wrong:** Each deck card calls `deck.deck_songs.count`, causing one SQL COUNT query per deck in the list.
**Why it happens:** The `@decks` collection is loaded in `DecksController#index` but without a `deck_songs_count` counter cache or preload.
**How to avoid:** The existing code at `decks/index.html.erb:17` already calls `deck.deck_songs.count`. This is a pre-existing issue, not introduced by Phase 7. Do not add an `includes` call to the controller (no controller changes in scope) — the count query per deck is acceptable at this app's scale (small team, few decks). Leave as-is.

---

## Code Examples

Verified patterns from the existing codebase:

### Date Format — "Sunday 16 March"
```ruby
# Source: Ruby stdlib strftime — verified format string
deck.date.strftime("%A %-d %B")
# => "Sunday 16 March"
```

### Established Card Token
```html
<!-- Source: CONTEXT.md code_context, used in Phase 5+ -->
bg-white rounded-xl shadow-sm border border-stone-200
```

### Established Primary Button Token
```html
<!-- Source: decks/index.html.erb line 3-4 -->
bg-rose-700 text-white text-sm px-4 py-2 rounded-lg hover:bg-rose-800 cursor-pointer font-medium
```

### Tailwind Group Hover (hover-reveal trash)
```html
<!-- Source: Tailwind CSS docs — group/group-hover utilities -->
<!-- Parent must have `group` class -->
<div class="relative group ...">
  <a href="..." class="block ...">...</a>
  <div class="absolute top-3 right-3 opacity-0 group-hover:opacity-100 transition-opacity">
    <!-- delete button_to here -->
  </div>
</div>
```

### Heroicons Inline SVG Pattern
```erb
<%# Source: REQUIREMENTS.md — "use inline Heroicons SVG" constraint %>
<%# Copy SVG from heroicons.com, paste directly into ERB %>
<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
     stroke-width="1.5" stroke="currentColor" class="w-16 h-16">
  <path stroke-linecap="round" stroke-linejoin="round" d="..." />
</svg>
```

### Preserving `button_to` Delete DOM Contract
```erb
<%# Source: decks/index.html.erb line 17 — existing contract to preserve %>
<%= button_to deck_path(deck), method: :delete,
      data: { turbo_confirm: "Delete \"#{deck.title}\"?" },
      class: "..." %>
```

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| `divide-y` list layout for decks | 3-column CSS grid of cards | Date becomes visually dominant; cards are scannable at a glance |
| Plain text empty state ("No decks yet") | Illustrated empty state with micro-workflow | First-time users understand the app purpose without reading docs |
| Bare Devise scaffold (max-w-md, `font-bold` h1) | Branded card with `font-serif text-rose-700` wordmark | Auth pages feel like the product, not a generic form |

**Deprecated/outdated in this phase:**
- The `divide-y` list container in `decks/index.html.erb` — replaced by grid
- `font-bold` on the auth page `<h1>` wordmark — replaced by `font-serif text-rose-700`
- Plain `<p class="text-stone-400 text-sm">No songs added yet.</p>` at `show.html.erb:93` — replaced by small icon + copy

---

## Open Questions

1. **`%-d` date format on dev environments**
   - What we know: `%-d` works on macOS and Linux (the production target)
   - What's unclear: Whether any developer uses Windows; this only affects dev, not prod
   - Recommendation: Use `%-d`. If a Windows dev environment is flagged later, switch to `.day.to_s` concatenation

2. **Other Devise views — password reset, unlock, confirm**
   - What we know: `passwords/new.html.erb` already uses the same `max-w-md mx-auto mt-12` structure and has the same `font-bold` wordmark
   - What's unclear: Whether the user wants these to match the primary auth pages
   - Recommendation: Per CONTEXT.md, this is Claude's discretion. Apply the same card treatment to `passwords/new.html.erb` for consistency. Leave mailer templates untouched (REQUIREMENTS.md explicitly defers them as low-impact).

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Minitest (Rails default) |
| Config file | `test/test_helper.rb` |
| Quick run command | `rails test test/controllers/decks_controller_test.rb` |
| Full suite command | `rails test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| NAV-02 | Deck index renders card grid (`.grid` class present) | integration | `rails test test/controllers/decks_controller_test.rb` | Wave 0 — add assertion |
| NAV-02 | Deck card displays date before title in DOM order | integration | `rails test test/controllers/decks_controller_test.rb` | Wave 0 — add assertion |
| NAV-02 | Delete button has `data-turbo-confirm` attribute | integration | `rails test test/controllers/decks_controller_test.rb` | Wave 0 — add assertion |
| EMPTY-01 | Deck index shows empty state copy when no decks | integration | `rails test test/controllers/decks_controller_test.rb` | Wave 0 — add assertion |
| EMPTY-02 | Deck show renders empty-state copy when no deck_songs | integration | `rails test test/controllers/decks_controller_test.rb` | ✅ Partially — existing `show` test covers render; add assert_match for new copy |
| EMPTY-03 | Song index shows empty-state copy when no songs | integration | `rails test test/controllers/songs_controller_test.rb` | Wave 0 — add assertion |
| AUTH-01 | Sessions/new renders `font-serif` on Praise Project heading | integration | `rails test test/controllers/registrations_controller_test.rb` | Wave 0 — add assertion |
| AUTH-01 | Sessions/new form is wrapped in `rounded-xl` card | integration | `rails test test/controllers/registrations_controller_test.rb` | Wave 0 — add assertion |

### Sampling Rate
- **Per task commit:** `rails test test/controllers/decks_controller_test.rb test/controllers/songs_controller_test.rb`
- **Per wave merge:** `rails test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `test/controllers/decks_controller_test.rb` — add `NAV-02` assertions: grid class, date prominence, turbo_confirm presence
- [ ] `test/controllers/decks_controller_test.rb` — add `EMPTY-01` assertion: empty state headline copy visible when no decks
- [ ] `test/controllers/songs_controller_test.rb` — add `EMPTY-03` assertion: empty state copy when `@songs` is empty
- [ ] `test/controllers/registrations_controller_test.rb` (or sessions) — add `AUTH-01` assertion: `font-serif` and `rounded-xl` present on auth pages

---

## Sources

### Primary (HIGH confidence)
- Direct inspection of `app/views/decks/index.html.erb` — current list layout confirmed
- Direct inspection of `app/views/songs/index.html.erb` — empty branch at lines 59-63 confirmed
- Direct inspection of `app/views/decks/show.html.erb` — empty branch at line 93 confirmed
- Direct inspection of `app/views/devise/sessions/new.html.erb` — `font-bold` wordmark and bare max-w-md wrapper confirmed
- Direct inspection of `app/views/devise/registrations/new.html.erb` — same structure as sessions/new confirmed
- `.planning/phases/07-content-pages/07-CONTEXT.md` — all design decisions locked by user
- `.planning/REQUIREMENTS.md` — inline Heroicons SVG constraint confirmed; no npm icon packs
- `.planning/STATE.md` — DOM contracts (turbo_confirm, sortable, export_button) confirmed

### Secondary (MEDIUM confidence)
- Ruby `strftime` `%-d` format — standard POSIX extension, works on macOS/Linux; verified by project conventions

### Tertiary (LOW confidence)
- None — all findings are grounded in direct codebase inspection or locked CONTEXT.md decisions

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new libraries; all patterns already in use in the codebase
- Architecture: HIGH — every target file was directly inspected; edit locations confirmed
- Pitfalls: HIGH — nested `<a>` and `turbo_confirm` contract are verified against actual code

**Research date:** 2026-03-16
**Valid until:** Stable — pure view changes, no framework API surface at risk of changing
