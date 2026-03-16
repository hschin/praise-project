# Phase 8: Deck Editor and Import Polish - Research

**Researched:** 2026-03-16
**Domain:** Rails ERB view polish — Tailwind CSS chip styling, Heroicon inline SVG, Turbo Stream targets, auto-save Stimulus, post-import redirect flow
**Confidence:** HIGH

## Summary

Phase 8 is a pure polish phase. Every file that needs changing already exists; no new routes, models, jobs, or controllers are required (with one exception: `ImportSongJob` already handles `deck_id` auto-add and redirect — confirmed in code). The work is almost entirely ERB template edits and small CSS class changes.

The main decisions are locked in CONTEXT.md. The three areas with genuine discretion (chip color mapping, auto-save indicator CSS, `deck_id` auto-add placement) have clear answers based on what already exists. The job already does the auto-add. The `group-hover` Stimulus pattern is already used in the Phase 7 deck-index delete button. Flash messages already work via Turbo-permanent containers.

**Primary recommendation:** Treat this as a surgical template-edit phase. Identify each file, its current state, its target state, and change only the CSS and copy — do not touch data attributes, DOM IDs, or `data-controller` values.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Export button idle state (DECK-03)**
- Keep same rose-700 size and padding as existing button
- Add Heroicon `arrow-down-tray` icon to the left of "Export PPTX" text
- No size change — consistent with other action buttons

**Export button ready state (DECK-03)**
- Upgrade from plain link to a proper button: green-600 bg, white text
- Add Heroicon `check-circle` icon to the left of "Download .pptx"
- "Re-export" stays as a small text link below the button
- Exact layout:
  ```
  [ ✓ Download .pptx ]  ← green-600 button
    Re-export           ← small text link below
  ```

**Export button error state (DECK-03)**
- Add specific copy: "Export failed — click to try again."
- (GeneratePptxJob already broadcasts this exact message — confirmed in code)

**Export button generating state**
- Keep as-is: spinner + "Generating..." is clear enough

**Panel labels (DECK-04)**
- Left panel: two sub-labels within the same column
  - "ADD SONGS" above the search/library area
  - "ARRANGEMENT" above the sortable slide list
- Middle panel: keep "Slide Preview" + "— approximate" note
- Right panel: keep "Theme"

**Post-import CTA from deck editor (IMPORT-02)**
- When `deck_id` param present: auto-add song to deck and redirect to deck editor (ALREADY IMPLEMENTED in `ImportSongJob` — no code change needed)
- Flash message on return: "[Song Title] imported and added to your deck."
- Song appears already in the left panel arrangement

**Post-import CTA from library (IMPORT-02)**
- When no `deck_id`: user lands on song show page as normal
- Add text link below song title: "Add this song to a deck →" linking to `decks_path`
- No dropdown, no auto-selection

**Import processing copy (IMPORT-01)**
- Update spinner label to: "Claude is structuring your lyrics..."
- Keep step indicators but update labels:
  - "Searching for lyrics" (was "Searching web")
  - "Generating pinyin" (unchanged)

**Section type chips (DECK-01)**
- Upgrade from plain `text-rose-700` label to styled chip (small badge with bg color)
- Verse / Chorus / Bridge each get a different warm chip color
- Claude's discretion on exact color mapping

**Pencil icon on deck title (DECK-05)**
- Change pencil icon from always-visible to hover-only
- Use `group-hover:opacity-100` (container already has `group` class — confirmed in code)

**Auto-save indicator (DECK-06)**
- Small, subtle indicator after arrangement or slide changes
- Claude's discretion on exact placement

**Song card artist metadata (DECK-02)**
- `_song_block.html.erb`: artist already rendered — NO CHANGE NEEDED
- Library panel search list items: add artist as secondary text below song title (currently only shows `song.title`)

### Claude's Discretion

- Exact chip color mapping for verse / chorus / bridge (stay within warm palette: amber, rose, stone variants)
- Exact CSS for auto-save indicator (fade-in/out timing, placement)
- Which Devise views beyond sign-in/sign-up to apply card treatment
- Whether `deck_id` auto-add logic lives in the job callback or the controller redirect

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| DECK-01 | Slide panel labels section types (verse/chorus/bridge) with distinct warm color-coded chips | `_slide_item.html.erb` line 9: `text-xs font-semibold uppercase tracking-wider text-rose-700` — wrap in chip with bg color per section_type |
| DECK-02 | Song cards in library and deck editor display artist/composer as secondary metadata | `_song_block.html.erb` already shows artist. Library panel list items in `decks/show.html.erb` lines 121-125 only show `song.title` — add `song.artist` below |
| DECK-03 | PPTX export button is a prominent "done" affordance — download icon, celebratory ready state | `_export_button.html.erb` has all state branches — update idle (add icon), ready (green button + check-circle), error (add copy) |
| DECK-04 | Deck editor displays clear panel labels so users understand the three-column layout | `decks/show.html.erb` line 82: left panel has single "Arrangement" h2 — split into two sub-labels; middle/right panels already labeled correctly |
| DECK-05 | Inline-editable deck title shows pencil icon on hover | `decks/show.html.erb` lines 13-20: pencil button is always visible — add `opacity-0 group-hover:opacity-100` to the button |
| DECK-06 | Deck editor shows subtle auto-save indicator after arrangement or slide changes | Requires a new auto-save Stimulus controller or extension of existing `inline-edit` controller; Turbo form responses already exist |
| IMPORT-01 | Import processing screen shows contextual copy reflecting AI activity | `_processing.html.erb` line 4: "Importing song..." and line 10: "Searching web" — update both strings |
| IMPORT-02 | After import completes, user is prompted to add the song to a deck | (a) `deck_id` path: already auto-adds in `ImportSongJob` — add flash message; (b) no-deck path: add "Add this song to a deck →" link to `songs/show.html.erb` |
</phase_requirements>

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Tailwind CSS | Embedded in asset pipeline | Utility class chip styling | Already used throughout; warm palette tokens already defined |
| Heroicons (inline SVG) | N/A — copy-paste SVG paths | Download icon, check-circle icon | Established pattern — no npm, no icon library |
| Hotwire Turbo | Built into Rails 8 | Stream updates, Turbo.visit redirect | Powers all async updates already |
| Stimulus | Built into Rails 8 | Auto-save indicator, group-hover behavior | Controllers auto-discovered in `app/javascript/controllers/` |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `flash_controller.js` | Existing | Flash auto-dismiss | For the "[Song Title] imported" flash from IMPORT-02 deck_id path |
| `redirect_controller.js` | Existing | Turbo.visit after import | Already used in `ImportSongJob#broadcast_done` — no changes needed |
| `inline_edit_controller.js` | Existing | Inline title/date/notes editing | Already handles save — auto-save indicator can hook into existing save callback |

### Heroicon SVG Paths Needed

**arrow-down-tray** (for export idle state):
```html
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4">
  <path d="M10.75 2.75a.75.75 0 0 0-1.5 0v8.614L6.295 8.235a.75.75 0 1 0-1.09 1.03l4.25 4.5a.75.75 0 0 0 1.09 0l4.25-4.5a.75.75 0 0 0-1.09-1.03l-2.955 3.129V2.75Z"/>
  <path d="M3.5 12.75a.75.75 0 0 0-1.5 0v2.5A2.75 2.75 0 0 0 4.75 18h10.5A2.75 2.75 0 0 0 18 15.25v-2.5a.75.75 0 0 0-1.5 0v2.5c0 .69-.56 1.25-1.25 1.25H4.75c-.69 0-1.25-.56-1.25-1.25v-2.5Z"/>
</svg>
```

**check-circle** (for export ready state):
```html
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4">
  <path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z" clip-rule="evenodd"/>
</svg>
```

**Installation:** None — inline SVG only.

---

## Architecture Patterns

### Files to Change (Complete Inventory)

| File | Requirement(s) | Change Type |
|------|---------------|-------------|
| `app/views/decks/_export_button.html.erb` | DECK-03 | Update `:idle`, `:ready`, `:error` branch markup |
| `app/views/deck_songs/_slide_item.html.erb` | DECK-01 | Replace text-only section label with chip badge |
| `app/views/decks/show.html.erb` | DECK-02, DECK-04, DECK-05, DECK-06 | Split panel label, add artist to library list, pencil hover-only, auto-save indicator |
| `app/views/songs/_processing.html.erb` | IMPORT-01 | Update spinner copy and "Searching web" step label |
| `app/views/songs/show.html.erb` | IMPORT-02 | Add "Add this song to a deck →" link |
| `app/javascript/controllers/auto_save_controller.js` | DECK-06 | New Stimulus controller (or extend inline_edit) |

**No changes needed:**
- `_song_block.html.erb` — artist already shown (confirmed)
- `import_song_job.rb` — auto-add with `deck_id` already implemented (confirmed, lines 21-29)
- `generate_pptx_job.rb` — already broadcasts "Export failed — click to try again." (confirmed, line 20)
- All routes — no new routes required
- All models — no schema changes

### Pattern 1: Section Type Chip

**What:** Wrap the existing section-type text in a small colored badge. Each section type maps to a different warm background/text combination.
**When to use:** Wherever `localized_section_type(lyric.section_type)` appears in arrangement context.

**Color mapping (Claude's discretion — recommendation):**
- `verse` / `主歌` → amber-100 bg / amber-700 text
- `chorus` / `副歌` → rose-100 bg / rose-700 text
- `bridge` / `桥段` → stone-200 bg / stone-700 text
- `pre-chorus` / `前副歌` → orange-100 bg / orange-700 text
- All other (intro, outro, tag) → stone-100 bg / stone-500 text

**Lookup approach:** Use a helper method or inline conditional mapping in ERB. A helper is cleaner for the planner to implement.

**Example:**
```erb
<%# In _slide_item.html.erb — replace the existing <p> element %>
<%
  chip_classes = case lyric.section_type.to_s.downcase
    when "verse", "主歌"    then "bg-amber-100 text-amber-700"
    when "chorus", "副歌"   then "bg-rose-100 text-rose-700"
    when "bridge", "桥段"   then "bg-stone-200 text-stone-700"
    when "pre-chorus", "前副歌" then "bg-orange-100 text-orange-700"
    else "bg-stone-100 text-stone-500"
  end
%>
<span class="inline-block text-xs font-semibold uppercase tracking-wider px-2 py-0.5 rounded-full mb-1 <%= chip_classes %>">
  <%= localized_section_type(lyric.section_type) %>
</span>
```

### Pattern 2: Hover-Only Pencil Icon

**What:** The pencil button in the deck title header is always visible. Change it to `opacity-0 group-hover:opacity-100 transition-opacity`.
**When to use:** Any element inside a `group`-classed container that should reveal on hover.

The title container already uses `class="group"` at line 6 of `decks/show.html.erb`. The button needs:
```erb
class="text-stone-400 hover:text-rose-700 opacity-0 group-hover:opacity-100 transition-opacity"
```

Note: Only the main title pencil (line 13-20) should be hover-only. The date and notes pencils at lines 34 and 57 already use `text-stone-300` and are visually de-emphasized — leave those as-is unless they also need hover treatment (not required by DECK-05).

### Pattern 3: Auto-Save Indicator (DECK-06)

**What:** A subtle "Saved" text that appears briefly after arrangement or slide changes.
**Recommended approach:** A new minimal Stimulus controller (`auto-save`) that listens for `turbo:submit-end` on the form/buttons and toggles a CSS class to fade text in, then out via a setTimeout.

**Placement recommendation:** Inline with the "ARRANGEMENT" sub-label (above the sortable list), right-aligned. Matches the CONTEXT.md suggestion of "small 'Saved' text that fades in/out near the Arrangement sub-label."

```erb
<%# Near the ARRANGEMENT sub-label in show.html.erb %>
<div class="flex items-center justify-between">
  <h2 class="text-xs font-semibold uppercase tracking-wider text-stone-400">Arrangement</h2>
  <span data-auto-save-target="indicator"
        class="text-xs text-stone-400 opacity-0 transition-opacity duration-300">Saved</span>
</div>
```

```javascript
// app/javascript/controllers/auto_save_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["indicator"]

  show() {
    this.indicatorTarget.classList.remove("opacity-0")
    this.indicatorTarget.classList.add("opacity-100")
    clearTimeout(this._timer)
    this._timer = setTimeout(() => {
      this.indicatorTarget.classList.remove("opacity-100")
      this.indicatorTarget.classList.add("opacity-0")
    }, 2000)
  }
}
```

The sortable controller and arrangement buttons already POST via Turbo; triggering `show()` can be done by adding `data-action="turbo:submit-end->auto-save#show"` on the container or from the sortable controller's success callback.

### Pattern 4: Panel Label Split (DECK-04)

**Current state:** Left panel has one `<h2>Arrangement</h2>` above the whole column.
**Target state:** Two separate sub-labels, "ADD SONGS" above the search area and "ARRANGEMENT" above the sortable list.

The current structure in `decks/show.html.erb`:
- Line 82: `<h2>Arrangement</h2>`
- Lines 84-102: sortable song list
- Lines 104-160: "Add a song" section (search + import form)

The sub-labels should be placed immediately above each respective section, using existing class `text-xs font-semibold uppercase tracking-wider text-stone-400`.

### Pattern 5: Post-Import "Add to Deck" Link (IMPORT-02)

**What:** On `songs/show.html.erb`, when a song is `done?`, add a text link below the title.
**Current state:** Line 5 shows the title, line 6 shows "Back to Library". There is no "add to deck" prompt.
**Target state:** Add below the title heading:

```erb
<p class="text-sm text-stone-500 mt-1">
  <%= link_to "Add this song to a deck →", decks_path, class: "text-rose-700 hover:underline" %>
</p>
```

This should appear unconditionally when a song is `done?` (not just after fresh import), as the requirement says "after song import completes."

### Anti-Patterns to Avoid

- **Renaming DOM IDs:** `export_button_#{deck.id}`, `import_status`, `song_status_#{song.id}` — these are Turbo Stream targets. Renaming causes silent update failures.
- **Adding wrapper divs inside sortable containers:** The `data-drag-handle` and `data-id` attributes on direct children of `data-controller="sortable"` must remain. Do not add wrapper elements between the sortable container and the `data-id` elements.
- **Touching `data: { turbo: false }` on import forms:** The import form is a full-page navigation by contract. Do not convert to Turbo Frame or Turbo Stream.
- **Using npm for icons:** Importmap does not handle npm icon packs. Inline SVG only.
- **Removing `.pinyin-hidden` CSS class:** It lives outside Tailwind in `application.css` and is used by `pinyin_toggle_controller.js`.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Auto-redirect after import job | Custom polling or WebSocket | `redirect_controller.js` (already exists) | Triggers `Turbo.visit` on connect — already used in `ImportSongJob#broadcast_done` |
| Icon rendering | Icon font, npm sprite | Inline Heroicons SVG | Importmap incompatible with npm icon libraries |
| Flash after deck redirect | Custom JS flash injection | Rails `flash[:notice]` + existing `flash_controller.js` | Flash is already auto-dismissed with turbo-permanent; just set `flash[:notice]` before redirect |
| Section-type color mapping | CSS class per section in a Stimulus controller | ERB conditional (inline or helper) | No JS needed — section type is known at render time |

**Key insight:** The import flow's `deck_id` path is already fully implemented in `ImportSongJob` (lines 21-29: creates `DeckSong`, builds `redirect_url = deck_path`). IMPORT-02 for the deck_id case requires only adding a flash message at the point of redirect, not new auto-add logic.

---

## Common Pitfalls

### Pitfall 1: Flash Message on Job-Triggered Redirect
**What goes wrong:** `ImportSongJob` calls `Turbo.visit` client-side via `redirect_controller.js`. Rails flash is set on the server per-request, not per-job. Setting `flash[:notice]` inside the job has no effect because the job runs in a background thread with no HTTP request context.
**Why it happens:** Flash is part of the session, which is HTTP-request-scoped. Background jobs have no session.
**How to avoid:** Pass the flash message as a query parameter or embed it in the redirect URL, then render it from a view. Alternatively, include the flash HTML directly in the Turbo Stream broadcast HTML instead of relying on Rails flash. The simplest approach: include the success message in the `broadcast_done` HTML payload alongside the redirect controller div.
**Warning signs:** Flash never appears after job-triggered redirects even though the code sets it.

### Pitfall 2: group-hover Opacity on Nested Groups
**What goes wrong:** Adding `group-hover:opacity-100` to the pencil button works only if the `group` class is on a direct ancestor of the button, not a sibling or cousin. If the button is wrapped in a new container without `group`, hover does nothing.
**Why it happens:** Tailwind's `group-hover` variant applies when the closest `group`-classed ancestor is hovered.
**How to avoid:** Verify the `group` class is on the container that wraps the button. In `decks/show.html.erb`, the `group` class is on the outer `<div data-controller="inline-edit">` at line 6 — confirm the pencil button remains a direct descendant of this div, not moved to a sibling.
**Warning signs:** Pencil never appears on hover in browser.

### Pitfall 3: Turbo Stream Update Breaks if Export Button ID Changes
**What goes wrong:** `GeneratePptxJob` broadcasts to `target: "export_button_#{deck_id}"`. If `_export_button.html.erb` renames the wrapper div's `id`, the stream update replaces nothing and the button stays in generating state.
**Why it happens:** Turbo Stream `update` action matches by DOM ID. Mismatch = silent failure.
**How to avoid:** The wrapper `<div id="export_button_<%= deck.id %>">` at line 5 of `_export_button.html.erb` must not be renamed or removed. All changes must happen inside this wrapper.

### Pitfall 4: Auto-Save Controller Not Triggered by button_to POSTs
**What goes wrong:** The arrangement buttons ("+ Repeat", "Remove") use `button_to` which renders `<form>` elements processed by Turbo. `turbo:submit-end` fires on the form, not on the button's containing div.
**Why it happens:** Event delegation requires the correct event target. If the `data-controller="auto-save"` is too far up the DOM tree, `turbo:submit-end` may not bubble to it in all browsers.
**How to avoid:** Attach the `auto-save` controller to the `data-controller="sortable"` container div (the arrangement list), and listen for `turbo:submit-end` on that element. The Sortable controller's `reorderComplete` or `dragend` can also call a cross-controller method via Stimulus outlets.

### Pitfall 5: Artist Data Not Available in Library List
**What goes wrong:** The library panel in `decks/show.html.erb` queries `Song.where(import_status: "done").order(:title)` inline (line 116). Artist is already on the Song model (`song.artist`), but the ERB list items only render `song.title`. Adding `song.artist` is straightforward — but if artist is blank, must render gracefully.
**How to avoid:** Use `.presence || nil` and conditionally render artist only when present (avoid showing an empty line or "—" under every song title in the search list).

---

## Code Examples

### Export Button: Idle State with Icon

```erb
<%# Source: CONTEXT.md + existing _export_button.html.erb %>
<% else %>
  <%# :idle — default %>
  <%= button_to export_deck_path(deck), method: :post,
      class: "bg-rose-700 text-white text-sm px-4 py-2 rounded-lg hover:bg-rose-800 cursor-pointer flex items-center gap-2" do %>
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4">
      <path d="M10.75 2.75a.75.75 0 0 0-1.5 0v8.614L6.295 8.235a.75.75 0 1 0-1.09 1.03l4.25 4.5a.75.75 0 0 0 1.09 0l4.25-4.5a.75.75 0 0 0-1.09-1.03l-2.955 3.129V2.75Z"/>
      <path d="M3.5 12.75a.75.75 0 0 0-1.5 0v2.5A2.75 2.75 0 0 0 4.75 18h10.5A2.75 2.75 0 0 0 18 15.25v-2.5a.75.75 0 0 0-1.5 0v2.5c0 .69-.56 1.25-1.25 1.25H4.75c-.69 0-1.25-.56-1.25-1.25v-2.5Z"/>
    </svg>
    Export PPTX
  <% end %>
<% end %>
```

### Export Button: Ready State with Check-Circle

```erb
<%# Source: CONTEXT.md layout spec %>
<% elsif state == :ready %>
  <div>
    <%= link_to download_export_deck_path(deck, token: token),
        class: "bg-green-600 text-white text-sm px-4 py-2 rounded-lg hover:bg-green-700 inline-flex items-center gap-2" do %>
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4">
        <path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z" clip-rule="evenodd"/>
      </svg>
      Download .pptx
    <% end %>
    <div class="mt-1">
      <%= button_to "Re-export", export_deck_path(deck), method: :post,
          class: "text-xs text-stone-400 hover:underline bg-transparent border-none cursor-pointer" %>
    </div>
  </div>
```

### Import Processing: Updated Copy

```erb
<%# Source: CONTEXT.md IMPORT-01 spec — replaces _processing.html.erb %>
<span class="text-sm font-medium text-stone-700">Claude is structuring your lyrics...</span>
<%
  steps = [
    ["Searching for lyrics",  %w[searching generating].include?(step)],
    ["Generating pinyin",     step == "generating"]
  ]
%>
```

### Post-Import Link on Song Show Page

```erb
<%# Source: CONTEXT.md IMPORT-02 spec — add to songs/show.html.erb below title %>
<% if @song.done? %>
  <p class="text-sm text-stone-500 mt-1">
    <%= link_to "Add this song to a deck →", decks_path, class: "text-rose-700 hover:underline" %>
  </p>
<% end %>
```

### Flash Message for deck_id Import Path

```erb
<%# Source: CONTEXT.md IMPORT-02 spec %>
<%# Strategy: embed flash copy in broadcast_done HTML instead of Rails flash %>
<%# In ImportSongJob#broadcast_done when deck_id present: %>
html: %(<div data-controller="redirect" data-redirect-url-value="#{redirect_url}?notice=#{CGI.escape("#{title} imported and added to your deck.")}"></div>)
```

Then in `decks/show.html.erb` or application layout, read `params[:notice]` as a flash alternative, or — simpler — use Rails `flash.now` inside a Turbo Stream partial that also renders the flash container. The cleanest option given the existing setup: pass the flash notice as a URL param on the redirect URL and render it client-side via the existing flash_controller connected to a `notice` query param on page load. However, the **simplest approach** that matches existing patterns: use `flash[:notice]` directly from the `DecksController#show` action when `params[:notice]` is present, or pass a `notice` query param and render it in the view.

**Recommendation for IMPORT-02 deck_id flash:** Keep the job redirect to `deck_path(deck_id)` and use Turbo `flash` through the controller. The redirect itself causes a full Turbo Drive navigation to `DecksController#show`, which sets no flash. The simplest fix: use a `notice` query parameter in the redirect URL, and read it in the `DecksController#show` view (or layout) to trigger the flash controller. This avoids job-layer complexity.

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| Export ready: plain `link_to` with arrow text | Green button with check-circle icon | More distinct from idle; feels like an "achievement" |
| Section type: plain `text-rose-700` text | Color-coded chip badge per type | Scannable at a glance — verse vs. chorus vs. bridge |
| Pencil always visible | Pencil on group-hover | Reduces visual noise; mirrors Phase 7 delete button pattern |
| "Importing song..." copy | "Claude is structuring your lyrics..." | Accurate — sets correct expectation |

**No deprecated approaches in this phase.** All patterns (inline SVG, group-hover, Turbo Stream targets) are current.

---

## Open Questions

1. **Flash message delivery for deck_id import redirect**
   - What we know: `ImportSongJob` already redirects via client-side `Turbo.visit(deck_path)`, not a server redirect
   - What's unclear: Best mechanism for delivering "[Title] imported and added to your deck." flash given no server session context in the job
   - Recommendation: Use a `notice` query param in the redirect URL (`deck_path(deck_id, notice: "#{title} imported...")`) and read it in the `DecksController#show` action or layout to set a flash-equivalent. This is a one-line addition to the controller and keeps the job stateless.

2. **Auto-save indicator trigger mechanism**
   - What we know: Arrangement changes go through `button_to` POSTs to `update_arrangement_deck_deck_song_path`; sort order goes through the `sortable_controller.js`
   - What's unclear: Whether to trigger `show()` from a Stimulus `turbo:submit-end` event listener or from a custom event dispatched by `sortable_controller.js`
   - Recommendation: Use `turbo:submit-end` on the arrangement container div — it catches all `button_to` responses without modifying the sortable controller.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Minitest (Rails default) |
| Config file | `test/test_helper.rb` |
| Quick run command | `rails test test/controllers/decks_controller_test.rb test/controllers/songs_controller_test.rb` |
| Full suite command | `rails test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DECK-01 | Slide items render chip with section-type-specific bg class | unit/integration | `rails test test/controllers/decks_controller_test.rb -n test_deck_show_renders_section_chip_for_slide_items` | ❌ Wave 0 |
| DECK-02 | Library panel list items show artist below song title | integration | `rails test test/controllers/decks_controller_test.rb -n test_deck_show_renders_artist_in_library_panel` | ❌ Wave 0 |
| DECK-03 | Export idle button contains download icon SVG | integration | `rails test test/controllers/decks_controller_test.rb -n test_export_button_idle_renders_download_icon` | ❌ Wave 0 |
| DECK-03 | Export ready state renders green-600 button with check-circle | integration | `rails test test/controllers/decks_controller_test.rb -n test_export_button_ready_renders_green_button` | ❌ Wave 0 |
| DECK-04 | Left panel contains "ADD SONGS" and "ARRANGEMENT" sub-labels | integration | `rails test test/controllers/decks_controller_test.rb -n test_deck_show_panel_labels` | ❌ Wave 0 |
| DECK-05 | Deck title pencil button has opacity-0 group-hover class | integration | `rails test test/controllers/decks_controller_test.rb -n test_deck_title_pencil_hover_only` | ❌ Wave 0 |
| DECK-06 | Deck show page contains auto-save indicator element | integration | `rails test test/controllers/decks_controller_test.rb -n test_deck_show_renders_auto_save_indicator` | ❌ Wave 0 |
| IMPORT-01 | Processing page renders "Claude is structuring your lyrics..." | integration | `rails test test/controllers/songs_controller_test.rb -n test_processing_page_renders_claude_copy` | ❌ Wave 0 |
| IMPORT-02 | Song show page (done) renders "Add this song to a deck" link | integration | `rails test test/controllers/songs_controller_test.rb -n test_song_show_done_renders_add_to_deck_link` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `rails test test/controllers/decks_controller_test.rb test/controllers/songs_controller_test.rb`
- **Per wave merge:** `rails test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/controllers/decks_controller_test.rb` — add tests for DECK-01, DECK-02, DECK-03, DECK-04, DECK-05, DECK-06 (extend existing file)
- [ ] `test/controllers/songs_controller_test.rb` — add tests for IMPORT-01, IMPORT-02 (extend existing file)

*(Both test files exist; new test cases needed within them.)*

---

## Sources

### Primary (HIGH confidence)
- Direct code inspection: `app/views/decks/_export_button.html.erb` — confirmed all 4 state branches
- Direct code inspection: `app/views/deck_songs/_slide_item.html.erb` — confirmed `text-rose-700` section label
- Direct code inspection: `app/views/deck_songs/_song_block.html.erb` — confirmed artist already rendered
- Direct code inspection: `app/views/songs/_processing.html.erb` — confirmed "Importing song..." and "Searching web" copy
- Direct code inspection: `app/views/decks/show.html.erb` — confirmed `group` class, single "Arrangement" label, library list items, panel structure
- Direct code inspection: `app/jobs/import_song_job.rb` — confirmed deck_id auto-add logic at lines 21-29 (already fully implemented)
- Direct code inspection: `app/jobs/generate_pptx_job.rb` — confirmed "Export failed — click to try again." at line 20 (already correct)
- Direct code inspection: `app/javascript/controllers/redirect_controller.js` — confirmed Turbo.visit pattern
- CONTEXT.md — locked decisions and exact copy strings

### Secondary (MEDIUM confidence)
- Tailwind CSS group-hover docs: `group` parent class + `group-hover:` modifier on descendant — standard documented pattern
- Heroicon SVG paths: standard Heroicons v2 20px solid icon set (arrow-down-tray, check-circle)

### Tertiary (LOW confidence)
- Auto-save `turbo:submit-end` event: Hotwire Turbo fires this custom event on form submit completion — documented in Turbo source; implementation detail of timing may vary

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all libraries already in use; no new dependencies
- Architecture: HIGH — all files identified by direct code inspection; no ambiguity
- Pitfalls: HIGH for DOM contracts (verified in code), MEDIUM for flash/job interaction (standard Rails limitation, well-documented)
- Validation: HIGH — existing test infrastructure; test file locations confirmed

**Research date:** 2026-03-16
**Valid until:** 2026-04-15 (stable Rails/Tailwind/Turbo — 30 days)
