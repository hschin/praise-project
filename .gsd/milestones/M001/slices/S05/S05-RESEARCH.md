# Phase 5: Design Foundation - Research

**Researched:** 2026-03-15
**Domain:** Tailwind CSS v4 design tokens, Rails ERB view refactoring, Stimulus controller authoring, Rails controller quick-create pattern
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Palette tokens**
- Primary action color: Deep amber-brown — Tailwind `amber-800` / `amber-900`. Used for buttons, active links, and the wordmark.
- Body background: `stone-50` — warm off-white, like cream paper. Replaces `gray-50` everywhere.
- Nav background: `stone-100` — slightly warmer than pure white. Replaces `bg-white` on the nav bar.
- Borders: `stone-200` — same lightness as current `gray-200` but warm hue. Replace all `border-gray-200` and `border-gray-300`.
- Focus rings: amber-colored — replace all `focus:ring-indigo-500` with warm equivalent (amber-600 or amber-700).
- Body text: `stone-900` — replaces `gray-900`.
- Secondary text: `stone-500` / `stone-600` — replaces `gray-500` / `gray-600`.
- All `bg-indigo-600`, `text-indigo-600`, `hover:bg-indigo-700` instances across views must be replaced with the amber-brown primary.

**Tailwind v4 token approach**
- The app uses Tailwind v4 with CSS-first config (`@import "tailwindcss"` in `application.css`).
- Custom design tokens should be defined using `@theme` block in `app/assets/tailwind/application.css` — NOT a `tailwind.config.js` file.
- Define semantic tokens: `--color-worship-primary` (amber-800), `--color-worship-surface` (stone-50), `--color-worship-nav` (stone-100), `--color-worship-border` (stone-200).
- After defining tokens, do a global class replacement pass across all ERB views: `indigo-*` → appropriate worship token.

**Wordmark**
- Styled text only — no icon or symbol.
- Use Tailwind's `font-serif` utility to give a traditional, reverential feel.
- Color: amber-brown primary (`text-amber-800` or custom `worship-primary` token).
- The current "Praise Project" plain bold text becomes a font-serif wordmark.

**Navigation structure**
- Songs link moves to the right side, near Logout — treated as a utility link, not a primary nav item.
- Decks link stays on the left side in the main nav area.
- "New Deck" button added to the nav as a persistent amber-brown CTA button — visible from every page, always one click away.
- New nav layout: `[Praise Project wordmark] [Decks] ............. [New Deck button] [Songs] [email] [Logout]`

**Deck creation flow (NAV-03 + NAV-04)**
- No form step: Clicking "New Deck" (anywhere — nav or deck index) performs an instant POST that creates the deck with default values and redirects to the deck editor.
- Default title: Upcoming Sunday's date as the title string (e.g., "Sunday 15 March"). Logic: if today is Mon–Sat, use this coming Sunday; if today is Sunday, use today.
- Inline-editable title: The title shown in the deck editor header should be wrapped in an inline-edit affordance (pencil icon on hover) from day one.
- The existing `new_deck` route and `DecksController#new` action can be preserved for any edge-case uses, but the primary "New Deck" button flow bypasses it via a direct POST to `decks#create` with pre-filled params.

**Component language (VIS-02)**
- All rounded corners unified: cards → `rounded-xl`, buttons → `rounded-lg`, inputs → `rounded-lg`.
- Shadows: cards get `shadow-sm`. Consistent across all card elements.
- Button padding: `px-4 py-2` minimum for primary buttons. Consistent everywhere.

**Typography scale (VIS-03)**
- Page headings (h1): `text-2xl font-semibold` with `leading-snug`.
- Section headings (h2, card labels): `text-base font-medium`.
- Body text: `text-sm` with `leading-relaxed`.
- Caption/metadata: `text-xs text-stone-500`.

### Claude's Discretion
- Exact hex values for amber-brown primary (whether to use Tailwind's built-in `amber-800` or define a custom hex) — use `amber-800` as it is already muted and warm.
- Whether to use `@theme` CSS variables or direct Tailwind class replacements in views — use `@theme` variables as the canonical tokens, then use the generated utility classes (e.g., `bg-worship-primary`) in views.
- Specific letter-spacing or font-size tuning on the wordmark beyond `font-serif`.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within Phase 5 scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| VIS-01 | App displays a warm, worshipful color palette (amber/stone tones) throughout all pages — no indigo/gray SaaS defaults | Tailwind v4 `@theme` tokens + global ERB class replacement pass |
| VIS-02 | All cards, buttons, and inputs use a consistent rounded component language (unified border radius, padding, shadow) | Audit of existing rounded/shadow classes; unified replace to `rounded-xl`/`rounded-lg`/`shadow-sm` |
| VIS-03 | Typography uses a deliberate scale with clear headline/body/caption hierarchy and generous line height | Tailwind typography utilities already available; apply `font-semibold leading-snug` pattern to all h1 elements |
| VIS-04 | Navigation includes a styled app wordmark — not bare plain text | Replace `text-indigo-600 font-bold` with `font-serif text-amber-800` in `application.html.erb` |
| NAV-01 | Deck creation is the primary nav entry point; Songs library link is visually de-emphasized | Nav restructure in `application.html.erb`; "New Deck" button added as persistent CTA |
| NAV-03 | Creating a new deck takes the user directly into the deck editor — no intermediate form step | New `quick_create` action in `DecksController`; new route `POST /decks/quick_create` |
| NAV-04 | New deck title is auto-filled with the upcoming Sunday's date and is inline-editable from the deck editor | Date logic in controller; Stimulus `inline-edit` controller for pencil-icon affordance in `decks/show.html.erb` header |
</phase_requirements>

---

## Summary

Phase 5 is a focused visual and structural refactoring with no database schema changes. The work divides cleanly into three streams: (1) CSS token definition and palette replacement, (2) navigation restructure with quick-create flow, and (3) inline-edit affordance for the deck title.

The app runs Tailwind CSS v4 via the `tailwindcss-rails` gem (~4.4), which uses a CSS-first config model — no `tailwind.config.js`. The `@theme` block in `app/assets/tailwind/application.css` is the correct place to define semantic design tokens. Once defined, Tailwind automatically generates utility classes from those tokens (e.g., `bg-worship-primary`, `text-worship-primary`), so view files can use them like any built-in class.

The palette replacement is wide but mechanical: `grep` shows indigo classes appear in 22 ERB files across `app/views/`. The replacement follows a clear mapping. The DOM contracts (Turbo Stream IDs, sortable `data-*` attributes, `.pinyin-hidden`, `content_for(:main_class)`) are all safe because this phase never restructures element IDs or CSS class-based JavaScript hooks — only Tailwind utility classes on decorative elements.

**Primary recommendation:** Define `@theme` tokens first, then do a systematic file-by-file replacement pass, then add the quick-create route + controller action, then add the Stimulus inline-edit controller.

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| tailwindcss-rails | ~4.4 | Tailwind v4 integration for Rails with Propshaft | Already in Gemfile; CSS-first config |
| Stimulus (stimulus-rails) | bundled with Rails 8.1 | Inline-edit behavior for deck title | Already in app; no additional install |
| Turbo (turbo-rails) | bundled with Rails 8.1 | Form POST without page reload, Turbo Stream updates | Already in app |
| Minitest | Rails default | Controller and model tests | Already configured |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Heroicons (inline SVG) | n/a | Pencil icon for inline-edit affordance | Per REQUIREMENTS.md: "use inline Heroicons SVG" — no npm icon packs |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `@theme` CSS variables | Direct Tailwind class replacement in views only | `@theme` variables give a single source of truth; direct replacement alone creates drift risk if a new view is added |
| New `quick_create` route | Overload existing `create` with blank-param detection | Separate action is cleaner and more testable; avoids param sniffing in existing `create` |
| Stimulus inline-edit | `contenteditable` with plain JS | Stimulus integrates with Turbo lifecycle; avoids stale event listeners after Turbo navigation |

**Installation:** No new packages needed. All required libraries are already installed.

---

## Architecture Patterns

### Recommended Project Structure

No new directories needed. Changes touch existing files:

```
app/
├── assets/tailwind/application.css      # Add @theme block (token definitions)
├── views/layouts/application.html.erb  # Nav restructure, wordmark, New Deck CTA
├── views/decks/
│   ├── show.html.erb                   # Inline-edit title header (NAV-04)
│   └── index.html.erb                  # Update New Deck button to POST quick_create
├── controllers/decks_controller.rb     # Add quick_create action
├── javascript/controllers/
│   └── inline_edit_controller.js       # New Stimulus controller (NAV-04)
config/
└── routes.rb                           # Add quick_create collection route
```

### Pattern 1: Tailwind v4 `@theme` Token Definition

**What:** Define named color tokens in a CSS `@theme` block; Tailwind generates utility classes from them automatically.
**When to use:** Any time a semantic token needs to be reusable across views without hardcoding a color name.

```css
/* app/assets/tailwind/application.css */
@import "tailwindcss";

@theme {
  --color-worship-primary: oklch(38% 0.09 60);   /* amber-800 equivalent */
  --color-worship-surface: oklch(98% 0.005 80);  /* stone-50 equivalent */
  --color-worship-nav: oklch(96% 0.007 80);      /* stone-100 equivalent */
  --color-worship-border: oklch(91% 0.01 80);    /* stone-200 equivalent */
}
```

After this, Tailwind generates: `bg-worship-primary`, `text-worship-primary`, `border-worship-border`, `bg-worship-surface`, etc.

> Note on oklch vs hex: Tailwind v4 uses oklch internally for its palette. The simplest approach is to reference the existing Tailwind color values as CSS custom properties within `@theme`. Alternatively, use the exact Tailwind class names (`amber-800`) as-is in views and only define `@theme` tokens for semantic names. Both are valid. Given the narrow scope, using direct Tailwind class names (`text-amber-800`, `bg-stone-50`) in views is lowest-risk; semantic tokens add flexibility but require verifying that custom classes like `bg-worship-primary` are generated correctly.

**Simpler alternative (lower risk for this phase):** Skip `@theme` custom tokens entirely and use direct Tailwind utility classes (`text-amber-800`, `bg-stone-50`) in views. This avoids any Tailwind v4 `@theme` gotchas and is fully verifiable. The CONTEXT.md locks in the `@theme` approach, but the planner should be aware this is where most Tailwind v4 unfamiliarity risk lives.

### Pattern 2: Global Indigo-to-Amber Replacement Mapping

**What:** Mechanical class substitution across 22 ERB view files.
**Replacement table:**

| Old class | New class | Semantic meaning |
|-----------|-----------|-----------------|
| `bg-indigo-600` | `bg-amber-800` | Primary button background |
| `hover:bg-indigo-700` | `hover:bg-amber-900` | Primary button hover |
| `text-indigo-600` | `text-amber-800` | Accent text / links |
| `hover:text-indigo-600` | `hover:text-amber-800` | Link hover |
| `focus:ring-indigo-500` | `focus:ring-amber-600` | Focus ring |
| `bg-indigo-50` | `bg-amber-50` | Light tint background |
| `hover:bg-indigo-50` | `hover:bg-amber-50` | Hover tint |
| `border-indigo-300` | `border-amber-300` | Accent border |
| `text-indigo-400` | `text-amber-700` | Muted accent |
| `text-indigo-500` | `text-amber-700` | Muted accent |
| `border-indigo-100` | `border-amber-100` | Section divider tint |
| `bg-indigo-400` | `bg-amber-700` | Disabled state button |
| `bg-gray-50` | `bg-stone-50` | Page background |
| `bg-white` (nav only) | `bg-stone-100` | Nav background |
| `border-gray-200` | `border-stone-200` | Card/nav borders |
| `border-gray-300` | `border-stone-200` | Input borders |
| `text-gray-900` | `text-stone-900` | Body text |
| `text-gray-600` | `text-stone-600` | Secondary text |
| `text-gray-500` | `text-stone-500` | Caption text |
| `text-gray-400` | `text-stone-400` | Placeholder/muted |
| `divide-gray-100` | `divide-stone-100` | Table dividers |
| `border-gray-100` | `border-stone-100` | Light dividers |

### Pattern 3: Rails Quick-Create Controller Action

**What:** A dedicated `quick_create` action that bypasses the form, pre-fills defaults, and redirects to the deck editor.
**When to use:** Any "one-click create with defaults" flow in Rails.

```ruby
# config/routes.rb — add to decks resources block
resources :decks do
  collection do
    post :quick_create
  end
  # ... existing member routes
end
```

```ruby
# app/controllers/decks_controller.rb
def quick_create
  title = upcoming_sunday_title
  date  = upcoming_sunday_date
  @deck = current_user.decks.new(title: title, date: date)
  if @deck.save
    redirect_to @deck
  else
    redirect_to decks_path, alert: "Could not create deck."
  end
end

private

def upcoming_sunday_date
  today = Date.today
  today.sunday? ? today : today.next_occurring(:sunday)
end

def upcoming_sunday_title
  "Sunday #{upcoming_sunday_date.strftime('%-d %B')}"
end
```

> Note: `Date#sunday?` is available in ActiveSupport (Rails). `%-d` on macOS/Linux gives day without zero-padding ("15 March" not "15 March"). On Windows `%-d` is not supported but this is a server-side Rails app on Linux/macOS, so it is safe.

### Pattern 4: Stimulus Inline-Edit Controller

**What:** Stimulus controller that shows an editable `<input>` when user clicks the pencil icon, and PATCHes the title on blur/enter.
**When to use:** Any inline-edit affordance for a single field in a Turbo-enabled Rails app.

```javascript
// app/javascript/controllers/inline_edit_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "input"]
  static values  = { url: String }

  edit() {
    this.displayTarget.hidden = true
    this.inputTarget.hidden   = false
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  async save() {
    const value = this.inputTarget.value.trim()
    if (!value) { this.cancel(); return }

    const token = document.querySelector("meta[name='csrf-token']").content
    await fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token
      },
      body: JSON.stringify({ deck: { title: value } })
    })

    this.displayTarget.textContent = value
    this.displayTarget.hidden = false
    this.inputTarget.hidden   = true
  }

  cancel() {
    this.displayTarget.hidden = false
    this.inputTarget.hidden   = true
    this.inputTarget.value    = this.displayTarget.textContent.trim()
  }
}
```

Register in `app/javascript/controllers/index.js`:
```javascript
import InlineEditController from "./inline_edit_controller"
application.register("inline-edit", InlineEditController)
```

ERB usage in `decks/show.html.erb` header:
```erb
<div data-controller="inline-edit"
     data-inline-edit-url-value="<%= deck_path(@deck) %>">
  <span data-inline-edit-target="display"
        class="text-2xl font-semibold leading-snug text-stone-900">
    <%= @deck.title %>
  </span>
  <button data-action="click->inline-edit#edit"
          class="ml-2 opacity-0 group-hover:opacity-100 text-stone-400 hover:text-amber-800"
          aria-label="Edit title">
    <%# Heroicons pencil-square, 16px inline SVG %>
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor" class="w-4 h-4">
      <path d="M11.013 2.513a1.75 1.75 0 0 1 2.475 2.474L6.226 12.25a2.751 2.751 0 0 1-.892.596l-2.047.848a.75.75 0 0 1-.98-.98l.848-2.047a2.75 2.75 0 0 1 .596-.892l7.262-7.262Z"/>
    </svg>
  </button>
  <input data-inline-edit-target="input"
         hidden
         type="text"
         value="<%= @deck.title %>"
         data-action="blur->inline-edit#save keydown.enter->inline-edit#save keydown.escape->inline-edit#cancel"
         class="text-2xl font-semibold leading-snug text-stone-900 border-b border-amber-600 focus:outline-none bg-transparent w-full">
</div>
```

### Anti-Patterns to Avoid

- **Replacing `.pinyin-hidden` or `application.css`:** This file is outside Tailwind and must not be touched. The `.pinyin-hidden` class is a JavaScript contract, not a styling concern.
- **Renaming Turbo Stream target IDs:** `export_button_#{deck_id}`, `theme_suggestions`, `import_status`, `song_status_#{song.id}` are wired to background jobs. Class changes on these elements are safe; ID changes are not.
- **Wrapping sortable items in new divs:** `data-drag-handle` and `data-id` on sortable children are positional contracts. Do not add wrapper divs inside sortable containers during layout refactoring.
- **Removing `content_for(:main_class)` yield:** The `decks/show.html.erb` sets `w-full` via this mechanism. Replacing with a hardcoded `class=` on `<main>` would break all other pages.
- **Using `tailwind.config.js` for v4:** Not supported. All config is CSS-first in v4.
- **Using `form_with model: @deck` with button_to for quick_create:** The quick_create action takes no form input, so a bare `button_to` to the `quick_create_decks_path` is correct — not a form with hidden fields.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Next Sunday date logic | Custom day-of-week arithmetic | `Date.today.next_occurring(:sunday)` (ActiveSupport) | Handles all edge cases including Sunday itself |
| CSRF token in fetch | Manual token lookup every time | `document.querySelector("meta[name='csrf-token']").content` pattern is standard Rails convention | Rails injects this; using `rails-ujs` or this pattern is idiomatic |
| Inline SVG icons | Reimplementing icons from scratch | Heroicons SVG snippets pasted inline | Consistent with project constraint: no npm icon packs, inline SVG |
| Focus ring styles | Custom CSS focus rules | `focus:ring-2 focus:ring-amber-600` Tailwind utilities | Tailwind generates the right `:focus-visible` CSS |

---

## Common Pitfalls

### Pitfall 1: Tailwind v4 Custom Token Classes Not Generated

**What goes wrong:** You define `--color-worship-primary` in `@theme` but use `bg-worship-primary` in a view and the class appears unstyled.
**Why it happens:** Tailwind v4 scans source files to generate only the utilities actually used. If the class string doesn't appear literally in a scanned file at build time, it won't be in the output CSS.
**How to avoid:** Use the full class name literally in ERB views (not via string interpolation or computed class names). Alternatively, bypass `@theme` and use direct Tailwind class names (`bg-amber-800`) — these are always available.
**Warning signs:** Element is unstyled despite class being in HTML source. Inspect the compiled CSS to confirm whether the class was generated.

### Pitfall 2: `%-d` Date Format String on macOS vs. Linux

**What goes wrong:** `Date.strftime("%-d %B")` produces "15 March" on macOS/Linux but raises an error or produces unexpected output in some environments.
**Why it happens:** `%-d` is a POSIX extension (strips leading zero) not in the C standard. On macOS and Linux (glibc), it works. Not relevant for this project (Rails runs on macOS in dev, Linux in prod) but worth noting.
**How to avoid:** Test the output in dev. Alternatively use `date.day.to_s` + `" " + date.strftime("%B")` for portability.

### Pitfall 3: `button_to` Quick Create Doubles as a Form

**What goes wrong:** Using `link_to` with `data: { turbo_method: :post }` for quick_create — some Turbo versions may not send the CSRF token correctly without a form wrapper.
**Why it happens:** `link_to` with `turbo_method` injects a hidden form via Turbo, which should work, but `button_to` is the explicit Rails convention for non-GET actions.
**How to avoid:** Use `button_to "New Deck", quick_create_decks_path, method: :post` which Rails renders as a proper `<form>` with CSRF token.

### Pitfall 4: Inline-Edit Save Race on Fast Blur

**What goes wrong:** User types a title and immediately presses Tab — `blur` fires, fetch is dispatched, but the user navigates away before the response. The title shows correctly in the database but the display target is already gone from DOM.
**Why it happens:** `fetch` is async; DOM removal by Turbo navigation races with the response callback.
**How to avoid:** The save method shown above does not await a response body — it fires and forgets. The database is updated. On next page load the correct title renders server-side. No special handling needed given the app's scale.

### Pitfall 5: Gray Tailwind Classes Left in Shared Partials

**What goes wrong:** The gray-to-stone replacement pass misses `_song_block.html.erb` or `_slide_item.html.erb` partials because they aren't opened during a top-level pass.
**Why it happens:** Grep results show indigo classes in 22 files — it's easy to miss partials in subdirectories.
**How to avoid:** The file list from `grep -r "indigo\|gray-" app/views/` identifies all 22 files to touch. Treat this list as a checklist and confirm each file is edited. The files are: layouts/application, decks/index, decks/show, decks/_form, decks/_export_button, deck_songs/_song_block, deck_songs/_slide_item, songs/index, songs/show, songs/edit, songs/_form, songs/_lyrics, songs/_failed, songs/_processing, songs/processing, themes/_form, themes/_applied_theme, themes/_suggestion_card, devise/sessions/new, devise/registrations/new, devise/passwords/new, devise/shared/_links.

---

## Code Examples

### Tailwind v4 `@theme` Block
```css
/* app/assets/tailwind/application.css */
/* Source: Tailwind CSS v4 docs — https://tailwindcss.com/docs/theme */
@import "tailwindcss";

@theme {
  --color-worship-primary: var(--color-amber-800);
  --color-worship-primary-hover: var(--color-amber-900);
  --color-worship-surface: var(--color-stone-50);
  --color-worship-nav: var(--color-stone-100);
  --color-worship-border: var(--color-stone-200);
  --color-worship-text: var(--color-stone-900);
  --color-worship-secondary: var(--color-stone-600);
  --color-worship-muted: var(--color-stone-500);
}
```

> Note: Tailwind v4 exposes its built-in palette as CSS custom properties (e.g., `--color-amber-800`). Referencing them in `@theme` creates aliases that generate new utility classes, inheriting the correct color values without hardcoding hex.

### Nav Restructure (application.html.erb)
```erb
<!-- Before -->
<nav class="bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
  <%= link_to "Praise Project", root_path, class: "text-lg font-bold text-indigo-600" %>
  <div class="flex items-center gap-6 ml-8">
    <%= link_to "Decks", decks_path, class: "text-sm text-gray-600 hover:text-gray-900" %>
    <%= link_to "Songs", songs_path, class: "text-sm text-gray-600 hover:text-gray-900" %>
  </div>

<!-- After -->
<nav class="bg-stone-100 border-b border-stone-200 px-6 py-4 flex items-center justify-between">
  <%= link_to "Praise Project", root_path, class: "text-lg font-serif text-amber-800" %>
  <div class="flex items-center gap-6 ml-8">
    <%= link_to "Decks", decks_path, class: "text-sm text-stone-600 hover:text-stone-900" %>
  </div>
  <div class="ml-auto flex items-center gap-4">
    <%= button_to "New Deck", quick_create_decks_path, method: :post,
          class: "bg-amber-800 text-white text-sm px-4 py-2 rounded-lg hover:bg-amber-900 cursor-pointer" %>
    <%= link_to "Songs", songs_path, class: "text-sm text-stone-500 hover:text-stone-700" %>
    <span class="text-sm text-stone-500"><%= current_user.email %></span>
    <%= link_to "Logout", destroy_user_session_path, data: { turbo_method: :delete },
          class: "text-sm text-stone-600 hover:text-stone-900" %>
  </div>
```

### Body Background in Layout
```erb
<!-- app/views/layouts/application.html.erb body tag -->
<body class="bg-stone-50 text-stone-900">
```

### Primary Button Pattern (after replacement)
```erb
<!-- Primary CTA button -->
<%= link_to "Label", path, class: "bg-amber-800 text-white text-sm px-4 py-2 rounded-lg hover:bg-amber-900" %>

<!-- Input field -->
<%= f.text_field :title, class: "w-full border border-stone-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-amber-600" %>

<!-- Card container -->
<div class="bg-white rounded-xl border border-stone-200 shadow-sm p-4">
```

### Quick Create Route
```ruby
# config/routes.rb
resources :decks do
  collection do
    post :quick_create
  end
  member do
    post :export
    get  :download_export
  end
  # ... existing nested resources
end
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `tailwind.config.js` | CSS-first `@theme` block in `.css` | Tailwind v4 (2024) | No JS config; tokens defined in CSS |
| `tailwindcss-rails` v3.x | `tailwindcss-rails` v4.x | 2024 | `@import "tailwindcss"` replaces `@tailwind base/components/utilities` directives |
| `@apply` for component classes | Direct utility classes in HTML | Tailwind team recommendation | `@apply` still works in v4 but is discouraged for new work |

**Deprecated/outdated:**
- `@tailwind base; @tailwind components; @tailwind utilities;` directives: Replaced by `@import "tailwindcss"` in v4.
- `tailwind.config.js` `theme.extend` pattern: Replaced by `@theme` block in CSS for v4.

---

## Open Questions

1. **Whether `var(--color-amber-800)` is available in Tailwind v4's generated CSS**
   - What we know: Tailwind v4 uses CSS custom properties internally for its palette.
   - What's unclear: Whether these properties are globally available without explicitly importing them, or only available within the `@theme` scope.
   - Recommendation: If CSS variable aliasing proves unreliable, fall back to direct hex values or direct Tailwind classes (`bg-amber-800`) in views. This is lower risk and the phase can still ship cleanly.

2. **Inline-edit PATCH response handling**
   - What we know: The `DecksController#update` currently redirects to the deck on success.
   - What's unclear: Whether a redirect response from `update` during a `fetch` PATCH will cause a Turbo full-page reload (undesirable for inline edit).
   - Recommendation: Add a JSON response branch to `update`: `respond_to { |f| f.json { head :ok } }` so the inline-edit fetch gets a 200 with no body and no redirect. This is the standard pattern for Stimulus-driven PATCH calls.

---

## Validation Architecture

nyquist_validation is enabled per `.planning/config.json`.

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
| VIS-01 | Page body uses `bg-stone-50`, no `gray-50` in layout | unit (view) | `rails test test/controllers/decks_controller_test.rb` — assert_no_match | ✅ extend existing |
| VIS-02 | Cards/buttons/inputs use `rounded-xl`/`rounded-lg`/`shadow-sm` | manual visual | n/a — manual review | n/a |
| VIS-03 | h1 elements use `font-semibold leading-snug` | unit (view) | `rails test test/controllers/decks_controller_test.rb` — assert_select | ✅ extend existing |
| VIS-04 | Nav wordmark uses `font-serif` and amber color | unit (view) | `rails test test/controllers/decks_controller_test.rb` — assert_select | ✅ extend existing |
| NAV-01 | Nav contains "New Deck" CTA button | unit (controller) | `rails test test/controllers/decks_controller_test.rb` — assert_select | ✅ extend existing |
| NAV-03 | POST quick_create redirects to deck editor (show page) | unit (controller) | `rails test test/controllers/decks_controller_test.rb` | ✅ existing file, new test |
| NAV-04 | quick_create deck title matches upcoming Sunday format | unit (controller) | `rails test test/controllers/decks_controller_test.rb` | ✅ existing file, new test |

### Sampling Rate
- **Per task commit:** `rails test test/controllers/decks_controller_test.rb`
- **Per wave merge:** `rails test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/controllers/decks_controller_test.rb` — add `test "POST quick_create redirects to deck editor"` and `test "POST quick_create title contains upcoming Sunday"` (file exists, tests need adding)

---

## Sources

### Primary (HIGH confidence)
- Tailwind CSS v4 docs — `@theme` block syntax and CSS-first config: https://tailwindcss.com/docs/theme
- Rails routing guide — collection routes: https://guides.rubyonrails.org/routing.html#adding-collection-routes
- Stimulus handbook — targets, values, actions: https://stimulus.hotwired.dev/reference/targets
- ActiveSupport `Date#next_occurring` — Ruby on Rails API docs

### Secondary (MEDIUM confidence)
- tailwindcss-rails gem changelog — v4.x CSS-first config: https://github.com/rails/tailwindcss-rails
- Heroicons — inline SVG source: https://heroicons.com (pencil-square 16px solid)

### Tertiary (LOW confidence)
- CSS custom property aliasing in Tailwind v4 `@theme` scope — behavior not independently verified beyond documentation reading. Flagged in Open Questions.

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all libraries already in Gemfile; no new dependencies
- Architecture: HIGH — patterns are direct Rails/Stimulus conventions with no novel techniques
- Palette replacement mapping: HIGH — derived from reading actual view files (22 files catalogued)
- Tailwind v4 `@theme` CSS variable aliasing: MEDIUM — documented pattern, but runtime behavior in Propshaft pipeline not independently verified
- Pitfalls: HIGH — derived from reading actual codebase contracts and Rails conventions

**Research date:** 2026-03-15
**Valid until:** 2026-04-15 (Tailwind v4 is stable; Rails 8.1 is stable)