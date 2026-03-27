# Phase 6: Global Components - Research

**Researched:** 2026-03-15
**Domain:** Stimulus.js toast controller, Tailwind CSS transitions, Devise error display, Rails flash, error copy
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Flash message behavior
- **Position**: Fixed top-right toast — floats in the corner, does not shift page content
- **Success/notice**: Auto-dismisses after ~4 seconds
- **Error/alert**: Stays visible until user manually dismisses with an X button
- **Animation**: Fade + slide in from right using CSS transitions only — no animation library
- **Implementation**: New Stimulus controller (`flash_controller.js`) handles auto-dismiss timer and X button click

#### Flash message icon design
- **Icon set**: Heroicons inline SVG (established pattern — no npm, copy SVG inline)
  - Success: `check-circle` icon
  - Error: `exclamation-triangle` icon
- **Colors**: Semantic — green for success, red for error
  - Success: `green-50` bg, `green-700` text/icon
  - Error: `red-50` bg, `red-700` text/icon
- **Types**: Two only — `notice` (success) and `alert` (error). No neutral/info type.

#### Devise error messages
- **Auth failures** (wrong password, unconfirmed email): Devise already routes these as `alert` flash — they flow through the new toast system automatically. No change needed to controller.
- **Registration model errors** (password too short, email taken): Styled inline error block on the registration form — `red-50` bg, `red-700` text, same pattern as `decks/_form.html.erb` and `songs/_form.html.erb`.
- **`devise/shared/_error_messages.html.erb`**: Remove entirely. Auth errors go through toast; registration errors get inline block treatment directly in the registration view.

#### Error copy specificity (FORM-03)
- **Export failure** (`_export_button.html.erb` `:error` state): Copy → "Export failed — click to try again." Points user to the Re-export button already present in that state.
  - Update `GeneratePptxJob#broadcast_error` calls to use this copy consistently.
- **Import failure** (`songs/_failed.html.erb`): Include song title in the message → "Couldn't find lyrics for \"[Title]\". Try pasting them manually below."
- **Theme and song save errors**: Ensure inline form error blocks (already styled) display actionable copy — not just bare Rails field names. Example: "Title can't be blank — please enter a title before saving."
  - Claude's discretion on exact copy for each form's error states.

### Claude's Discretion
- Exact CSS transition values for the toast slide-in animation
- Toast z-index and stacking behavior
- Exact wording for theme/song save validation errors
- Whether to use a `data-controller="flash"` wrapper in the layout or a dedicated toast partial

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within Phase 6 scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| FORM-01 | All inputs, labels, buttons, and focus states across all pages use consistent warm palette styles | Codebase audit shows most forms already use rose-600 focus rings and stone palette. Registration edit view (`devise/registrations/edit.html.erb`) is unstyled and needs full treatment. |
| FORM-02 | Flash messages display as rounded cards with a semantic icon (success/error) and auto-dismiss after a few seconds | New `flash_controller.js` Stimulus controller with auto-dismiss timer, X button, and CSS fade+slide animation replaces the two bare flash divs in the layout. |
| FORM-03 | Import and export error messages include a clear description of what went wrong and a specific next step | Three call sites in `GeneratePptxJob#broadcast_error`, `_export_button.html.erb` error state copy, `songs/_failed.html.erb` copy, and inline form error messages all need copy updates. |
</phase_requirements>

---

## Summary

Phase 6 is a focused polish pass with no new backend logic. Every change is either a view template update, a new Stimulus controller, or a copy string change. The codebase is already well-structured for this work: existing Stimulus auto-discovery means `flash_controller.js` drops in with zero registration overhead; form error blocks are already consistently styled in deck and song forms; the flash integration point in `application.html.erb` is a known, isolated two-line replacement.

The most technically novel piece is the Stimulus flash controller. It must handle two distinct behaviors (auto-dismiss for notice, manual-dismiss for alert), CSS transition entry/exit animation without an animation library, and Turbo Drive persistence (the toast container must survive page navigations via `data-turbo-permanent`). All three concerns have clear, established patterns in the Hotwire/Stimulus ecosystem.

The second concern is the `devise/registrations/edit.html.erb` view, which is entirely unstyled — bare scaffold HTML with no Tailwind classes. It needs a full makeover to match the pattern already established in `new.html.erb`, which is already styled.

**Primary recommendation:** Build the flash Stimulus controller first (it unblocks FORM-02 and is the most impactful UX change), then fix Devise edit page styling (FORM-01), then update all error copy strings (FORM-03).

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| @hotwired/stimulus | importmap pin | Flash controller auto-dismiss and X button | Already used; `eagerLoadControllersFrom` auto-discovers new controllers by filename |
| @hotwired/turbo-rails | importmap pin | Turbo Drive page transitions; `data-turbo-permanent` for toast persistence | Already used for Turbo Stream export updates |
| Tailwind CSS | project config | Transition utilities (`transition`, `duration-300`, `translate-x-full`, `opacity-0`) for fade+slide animation | Already used for all styling |
| Heroicons inline SVG | copy SVG paths | Semantic icons (check-circle, exclamation-triangle) | Established pattern per REQUIREMENTS.md out-of-scope note |

### No Additional Dependencies
This phase requires zero new npm packages, gems, or CDN imports. All capabilities are already present.

---

## Architecture Patterns

### Recommended Project Structure

Changes touch these existing files:
```
app/
├── views/layouts/application.html.erb          # Replace flash block with toast partial
├── views/shared/
│   └── _flash_toast.html.erb                   # New: toast partial (one per flash type)
├── javascript/controllers/
│   └── flash_controller.js                     # New: auto-dismiss + X button
├── views/devise/
│   ├── registrations/new.html.erb              # Remove _error_messages render, add inline block
│   ├── registrations/edit.html.erb             # Full restyle (currently bare scaffold)
│   └── shared/_error_messages.html.erb         # DELETE
├── views/decks/
│   └── _export_button.html.erb                 # Update error state copy
├── views/songs/
│   └── _failed.html.erb                        # Update copy (already close to correct)
└── jobs/
    └── generate_pptx_job.rb                    # Update 3 broadcast_error call sites
```

### Pattern 1: Stimulus Flash Controller Structure

The controller manages two state machines simultaneously: show/hide visibility, and auto-dismiss timer.

```javascript
// app/javascript/controllers/flash_controller.js
// Filename = controller identifier: "flash" (eagerLoadControllersFrom convention)
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    autoDismiss: { type: Boolean, default: false },
    delay:       { type: Number,  default: 4000 }
  }

  connect() {
    // Entry: start invisible (translate-x-full opacity-0), then transition to visible
    // Use requestAnimationFrame to ensure transition fires after paint
    requestAnimationFrame(() => {
      this.element.classList.remove("translate-x-full", "opacity-0")
    })
    if (this.autoDismissValue) {
      this._timer = setTimeout(() => this.dismiss(), this.delayValue)
    }
  }

  dismiss() {
    clearTimeout(this._timer)
    // Exit: transition back to invisible, then remove from DOM
    this.element.classList.add("translate-x-full", "opacity-0")
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
  }

  disconnect() {
    clearTimeout(this._timer)
  }
}
```

**Key insight:** `requestAnimationFrame` is required — without it, the element is painted already-visible and the CSS entry transition never fires.

### Pattern 2: Toast Partial in Application Layout

The layout replaces the two bare flash `<div>`s with a fixed-position container holding rendered partials. The `data-turbo-permanent` attribute on the container prevents Turbo Drive from re-rendering it during page navigations — critical for letting the 4-second auto-dismiss timer run to completion even after a redirect.

```erb
<%# app/views/layouts/application.html.erb — replaces lines 49-54 %>
<div id="flash-container" class="fixed top-4 right-4 z-50 flex flex-col gap-2 pointer-events-none" data-turbo-permanent>
  <% if notice %>
    <%= render "shared/flash_toast", type: :notice, message: notice %>
  <% end %>
  <% if alert %>
    <%= render "shared/flash_toast", type: :alert, message: alert %>
  <% end %>
</div>
```

```erb
<%# app/views/shared/_flash_toast.html.erb %>
<%
  is_success = type == :notice
  bg    = is_success ? "bg-green-50 border-green-200"  : "bg-red-50 border-red-200"
  text  = is_success ? "text-green-700"                : "text-red-700"
  auto  = is_success ? "true"                          : "false"
%>
<div class="pointer-events-auto w-80 border rounded-lg shadow-md px-4 py-3 flex items-start gap-3
            <%= bg %> transition-all duration-300 translate-x-full opacity-0"
     data-controller="flash"
     data-flash-auto-dismiss-value="<%= auto %>"
     data-flash-delay-value="4000">
  <%# Heroicons inline SVG — check-circle (success) or exclamation-triangle (error) %>
  <% if is_success %>
    <svg class="w-5 h-5 flex-shrink-0 <%= text %>" ...></svg>
  <% else %>
    <svg class="w-5 h-5 flex-shrink-0 <%= text %>" ...></svg>
  <% end %>
  <p class="text-sm flex-1 <%= text %>"><%= message %></p>
  <% unless is_success %>
    <button class="text-stone-400 hover:text-stone-600 flex-shrink-0"
            data-action="click->flash#dismiss">
      <%# Heroicons x-mark SVG inline %>
    </button>
  <% end %>
</div>
```

### Pattern 3: Devise Inline Error Block (matches existing form pattern)

The inline error block pattern already in `decks/_form.html.erb` and `songs/_form.html.erb` is the reference:

```erb
<%# Replace <%= render "devise/shared/error_messages", resource: resource %> with: %>
<% if resource.errors.any? %>
  <div class="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg p-3">
    <% resource.errors.full_messages.each do |msg| %>
      <p><%= msg %></p>
    <% end %>
  </div>
<% end %>
```

This goes in `devise/registrations/new.html.erb` (replace the `render` call) and `devise/registrations/edit.html.erb` (add as part of full restyle).

### Pattern 4: Actionable Error Copy in Rails Models

Rails `full_messages` produces "Field can't be blank" by default. To produce actionable copy ("Title can't be blank — please enter a title before saving"), use model-level custom I18n keys or override `full_message` via locale file. However, for this app's scale, directly overriding in the view (wrapping `full_messages` output) or using Rails custom validation messages in the model is appropriate.

The simplest approach: update validation messages in the model to include action hints. For example, in `Song`:
```ruby
validates :title, presence: { message: "can't be blank — please enter a title before saving" }
```
Rails appends the attribute name prefix automatically: "Title can't be blank — please enter a title before saving."

### Anti-Patterns to Avoid

- **Missing `requestAnimationFrame` for CSS entry transition:** Without it, the element renders already-visible because the browser hasn't painted the initial state with transition classes yet. The transition never fires.
- **Not using `data-turbo-permanent` on toast container:** Without it, Turbo Drive tears down and re-renders the container on every page navigation, destroying in-progress dismissal timers and causing toast flicker.
- **Using CSS `display: none` instead of opacity/translate for hiding:** `display: none` cannot be CSS-transitioned. Use `opacity-0` and `translate-x-full` so Tailwind transition utilities work.
- **Putting `data-controller="flash"` on the container div instead of the individual toast:** The controller should live on each individual toast so multiple toasts can have independent timers.
- **Leaving `pointer-events: auto` on the fixed container:** The container itself should be `pointer-events-none`; individual toasts restore `pointer-events-auto`. This prevents the invisible overlay blocking clicks on page content.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| CSS entry animation | Custom JS class injection timing | `requestAnimationFrame` + Tailwind transition classes | rAF is the correct browser API for "after paint" timing |
| Auto-dismiss after redirect | Rails session flash storing timer ID | Stimulus `connect()` timer (runs after DOM insertion) | Stimulus lifecycle hooks are exactly for this |
| Toast stacking | Custom z-index manager | `flex flex-col gap-2` on fixed container | CSS flex handles ordering naturally |
| Icon SVG | SVG sprite sheet, icon font, npm icon package | Heroicons inline SVG path (copy paste) | Established project pattern; importmap doesn't handle npm icon packs |

---

## Common Pitfalls

### Pitfall 1: `data-turbo-permanent` Container Placement
**What goes wrong:** Toast renders, auto-dismiss timer starts, user navigates (Turbo Drive fires), container is torn down and re-created, timer is lost.
**Why it happens:** Turbo Drive re-renders the full `<body>` on navigation by default.
**How to avoid:** Place `data-turbo-permanent` on the `#flash-container` div. Turbo Drive preserves elements with this attribute across navigations.
**Warning signs:** Toast disappears on navigation before 4 seconds; error toasts dismiss themselves after navigating away.

### Pitfall 2: Devise `edit.html.erb` Is Bare Scaffold
**What goes wrong:** Account edit page looks completely different from the rest of the app — no Tailwind classes, bare `<div class="field">` wrappers, unstyled submit button.
**Why it happens:** Devise generates scaffold HTML that was never styled (unlike `new.html.erb` which was styled earlier).
**How to avoid:** Full restyle of `edit.html.erb` to match `new.html.erb` pattern. Add warm palette inputs, rose-700 submit, remove `<div class="field">` scaffolding.
**Warning signs:** FORM-01 "all inputs on every page" fails if this page is not checked.

### Pitfall 3: `_error_messages.html.erb` Partial Still Referenced
**What goes wrong:** After deleting `devise/shared/_error_messages.html.erb`, registration view still has `render "devise/shared/error_messages"` → ActionView::MissingTemplate error.
**Why it happens:** The partial deletion and the view update are two separate edits that must both happen.
**How to avoid:** Update both `new.html.erb` and `edit.html.erb` to replace `render "devise/shared/error_messages"` with the inline error block before (or atomically with) deleting the partial.
**Warning signs:** Registration form raises a template error on submit with validation failures.

### Pitfall 4: Export Button Error State Copy vs. Job Error Message
**What goes wrong:** `broadcast_error` in the job sends an error message, but the export button partial hardcodes different copy — inconsistency between what the job broadcasts and what the button displays.
**Why it happens:** `_export_button.html.erb` displays `error_message` as passed from the Turbo Stream. The job currently sends messages like "PPTX generation failed. Please try again." — these must be updated at all three `broadcast_error` call sites in `generate_pptx_job.rb` (lines 20, 26, 44).
**How to avoid:** Update all three `broadcast_error` call sites to pass "Export failed — click to try again." consistently.
**Warning signs:** Different error text depending on which code path triggered the failure.

### Pitfall 5: `songs/_failed.html.erb` Copy Is Already Close But Not Exact
**What goes wrong:** Assuming the file already has correct copy and skipping the update.
**Why it happens:** The file already has `"Could not find lyrics for \"<%= title %>\""` — looks close, but the locked copy is `"Couldn't find lyrics for \"[Title]\". Try pasting them manually below."` — different wording and the second sentence already exists as a separate paragraph.
**How to avoid:** Update the `<h3>` copy to match the locked decision exactly and consolidate the message if needed.

---

## Code Examples

### Heroicons SVG Paths (copy inline — no CDN or npm)

```erb
<%# check-circle (success icon) — from heroicons.com, outline style %>
<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 flex-shrink-0">
  <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
</svg>

<%# exclamation-triangle (error icon) — from heroicons.com, outline style %>
<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 flex-shrink-0">
  <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z" />
</svg>

<%# x-mark (close button) — from heroicons.com, outline style %>
<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4">
  <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
</svg>
```

### Stimulus Controller Registration — No Manual Step Needed
```javascript
// index.js — already in place, auto-discovers flash_controller.js as "flash"
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
// Drop flash_controller.js in app/javascript/controllers/ and it's registered automatically
```

### CSS Transition Class Strategy
```
Initial state (applied in HTML):   translate-x-full opacity-0
Transition config (applied in HTML): transition-all duration-300
Visible state (controller removes): translate-x-full opacity-0
Exit state (controller adds):       translate-x-full opacity-0
```
Tailwind config — `transition-all duration-300` covers both `transform` and `opacity` properties in one utility pair.

### Devise Edit Page — Current vs. Target Pattern
```erb
<%# CURRENT (bare scaffold — needs full restyle) %>
<div class="field">
  <p><%= f.label :email %></p>
  <p><%= f.email_field :email, autofocus: true, autocomplete: "email" %></p>
</div>

<%# TARGET (match new.html.erb pattern) %>
<div>
  <%= f.label :email, class: "block text-sm font-medium text-stone-700 mb-1" %>
  <%= f.email_field :email, autofocus: true, autocomplete: "email",
        class: "w-full border border-stone-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-rose-600" %>
</div>
```

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| Two bare flash divs below nav, shifts page layout | Fixed top-right toast, no layout shift | Toast is standard UX; inline flash is outdated |
| `_error_messages.html.erb` default Devise partial (h2 + ul, no styles) | Inline styled error block matching form pattern | Visual consistency across all forms |
| `✗` character as error icon in `_failed.html.erb` | Heroicons `exclamation-triangle` SVG inline | Consistent icon language across the app |

---

## Open Questions

1. **Toast z-index value**
   - What we know: Fixed elements need a z-index to stack above other page content; the deck editor uses no fixed-position overlays that would conflict
   - What's unclear: Whether any Phase 8 deck editor elements (tooltips, dropdowns) will need higher z-index
   - Recommendation: Use `z-50` (Tailwind default 50 = z-index: 50). Safe for Phase 6; revisit in Phase 8 if needed.

2. **Multiple simultaneous toasts**
   - What we know: REQUIREMENTS.md out-of-scope explicitly states "Toast notification stack — Over-engineered for one-action-at-a-time app; single polished flash is right"
   - What's unclear: Rails `flash` can technically hold both `notice` and `alert` simultaneously (e.g., if a controller sets both)
   - Recommendation: Render both if present (the `flex-col gap-2` container handles it visually) but do not build stacking management logic. The app's workflows never set both simultaneously.

3. **Devise `edit.html.erb` account deletion button**
   - What we know: The file contains a "Cancel my account" `button_to` with `data: { turbo_confirm: }` — needs to be kept functional and styled
   - What's unclear: Whether this button should be styled prominently or de-emphasized
   - Recommendation: De-emphasize with `text-sm text-stone-500 hover:text-red-600` — destructive action should be available but not prominent.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Minitest (Rails default) |
| Config file | `test/test_helper.rb` |
| Quick run command | `rails test test/controllers/` |
| Full suite command | `rails test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FORM-01 | Registration edit page renders with warm palette inputs | Integration | `rails test test/controllers/registrations_controller_test.rb` | ✅ (add test case) |
| FORM-02 | Flash partial renders correct classes for notice type | Integration | `rails test test/controllers/decks_controller_test.rb` | ✅ (add assert_select) |
| FORM-02 | Flash partial renders correct classes for alert type | Integration | `rails test test/controllers/registrations_controller_test.rb` | ✅ (add assert_select) |
| FORM-03 | Export error copy matches locked string | Integration | `rails test test/controllers/decks_controller_test.rb` | ✅ (add turbo stream assertion) |
| FORM-03 | Import failed partial renders song title in error copy | View | `rails test test/controllers/songs_controller_test.rb` | ✅ (add assert_select) |

### Sampling Rate
- **Per task commit:** `rails test test/controllers/`
- **Per wave merge:** `rails test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/controllers/registrations_controller_test.rb` — needs test case: "GET edit page returns 200 with warm palette inputs" (covers FORM-01)
- [ ] `test/controllers/decks_controller_test.rb` — needs test case: "flash notice partial includes green-50 class" (covers FORM-02)
- [ ] `test/controllers/songs_controller_test.rb` — needs test case: "failed partial includes song title in error copy" (covers FORM-03)

Note: `registrations_controller_test.rb` already exists — these are additions to the existing file, not new files.

---

## Sources

### Primary (HIGH confidence)
- Codebase direct inspection — `app/views/layouts/application.html.erb`, `app/javascript/controllers/inline_edit_controller.js`, `app/views/decks/_form.html.erb`, `app/views/songs/_form.html.erb`, `app/views/devise/registrations/new.html.erb`, `app/views/devise/registrations/edit.html.erb`, `app/views/devise/shared/_error_messages.html.erb`, `app/views/decks/_export_button.html.erb`, `app/views/songs/_failed.html.erb`, `app/jobs/generate_pptx_job.rb`
- `config/importmap.rb` — confirmed @hotwired/stimulus and @hotwired/stimulus-loading are pinned
- Hotwire/Stimulus documentation (training data, HIGH confidence for established APIs like `connect()`, `values`, targets)
- Turbo documentation — `data-turbo-permanent` attribute behavior (HIGH confidence, stable API)

### Secondary (MEDIUM confidence)
- Heroicons.com SVG paths — standard outline icons, verified by established project pattern in CONTEXT.md
- `requestAnimationFrame` for CSS transition entry — well-established browser pattern for deferred class application

### Tertiary (LOW confidence)
- None — all findings are verifiable from direct codebase inspection or stable documented APIs.

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — zero new dependencies; all tools already present in codebase
- Architecture: HIGH — patterns derived from existing codebase (inline_edit_controller.js, _form.html.erb error blocks)
- Pitfalls: HIGH — identified from direct code inspection (edit.html.erb unstyled, three broadcast_error sites, partial deletion ordering)

**Research date:** 2026-03-15
**Valid until:** 2026-04-15 (stable libraries, no fast-moving dependencies)