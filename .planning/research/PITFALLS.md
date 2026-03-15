# Domain Pitfalls

**Domain:** UI redesign on existing Rails 8 + Hotwire (Turbo + Stimulus) + Tailwind v4 app
**Researched:** 2026-03-15
**Confidence:** HIGH — all pitfalls grounded in direct codebase inspection, not assumptions

---

## Critical Pitfalls

Mistakes that cause silent breakage of existing functionality or require rewrites to fix.

---

### Pitfall 1: Renaming Turbo Stream Target DOM IDs

**What goes wrong:** Three background jobs broadcast Turbo Stream updates that target hardcoded DOM IDs. If a redesign renames or removes those IDs in the ERB templates, the broadcast lands on a missing target and the UI never updates — no error, no feedback, silent failure.

**Root cause:** The contract between job and template is invisible — it lives only in the string literals.

| Job | Broadcast target | Template location |
|-----|-----------------|-------------------|
| `GeneratePptxJob` | `export_button_#{deck_id}` | `decks/_export_button.html.erb` line 5 |
| `GeneratePptxJob` (error) | `export_button_#{deck_id}` | same |
| `GenerateThemeSuggestionsJob` | `theme_suggestions` | `decks/show.html.erb` line 175 |
| `ImportSongJob` (step/done/fail) | `import_status` | `songs/processing.html.erb` line 13 |
| `ImportSongJob` | `song_status_#{song.id}` | `songs/show.html.erb` line 9 |

**Consequences:**
- Export button stays in "Generating..." state forever after PPTX finishes
- Theme suggestions spinner never resolves
- Song import page never transitions from "Importing song..."

**Prevention:** Before touching any of these templates, write a list of every `id=` attribute that appears as a `target:` in a job broadcast. Treat these IDs as a public API — change both sides atomically, or keep them as a stable internal wrapper `div` that the redesign decorates around, not replaces.

**Detection warning signs:**
- Clicking "Export PPTX" shows spinner indefinitely after redesign
- "Get AI Suggestions" button never populates suggestions panel
- Song import page frozen after Solid Queue worker completes the job

**Phase:** Any phase touching `decks/show.html.erb`, `decks/_export_button.html.erb`, `songs/processing.html.erb`, or `songs/show.html.erb`.

---

### Pitfall 2: Breaking the `data-drag-handle` and `data-id` Contract in Sortable Items

**What goes wrong:** `sortable_controller.js` relies on two conventions: every draggable item has a `data-id` attribute, and the drag handle is the element with `data-drag-handle`. It also reads `this.element.children` to reconstruct arrangement order. If redesign wraps items in an extra wrapper `div` or moves the drag handle into a nested component without `data-drag-handle`, the controller silently stops working.

**Root cause:** The controller reads structural assumptions about the DOM — direct children, presence of a specific data attribute — that are invisible to designers working from screenshots.

**Consequences:**
- Drag-and-drop reordering stops working for both songs (deck-level) and slides (within song blocks)
- `onEnd` callback fires with stale positions or undefined IDs
- PATCH request to `reorder` or `update_arrangement` sends wrong data, arrangement silently corrupts

**Prevention:** The `data-drag-handle` and `data-id` attributes must survive redesign. When rebuilding `_song_block.html.erb` and `_slide_item.html.erb`, carry these attributes forward verbatim on the same elements. Do not change the direct-children relationship on the sortable container.

**Detection warning signs:**
- Drag handle visible but dragging does nothing
- Reordering songs changes display order but next page load reverts
- Console error: `Cannot set properties of undefined (setting 'id')`

**Phase:** Any phase touching `deck_songs/_song_block.html.erb` or `deck_songs/_slide_item.html.erb`.

---

### Pitfall 3: Removing or Renaming the `.pinyin-hidden` CSS Class

**What goes wrong:** `pinyin_toggle_controller.js` adds/removes the class `pinyin-hidden` on a container element. This class is defined in `app/assets/stylesheets/application.css` (not in Tailwind). If a redesign removes this CSS rule while cleaning up stylesheets, or renames the class to match Tailwind conventions, the toggle stops hiding pinyin.

**Root cause:** One custom CSS class (`pinyin-hidden`) lives outside Tailwind. It is easy to miss during a stylesheet consolidation.

**Consequences:**
- "Show/Hide Pinyin" toggle appears functional (button text changes) but pinyin `<rt>` elements remain visible
- The slide preview loses its pinyin-hiding capability

**Prevention:** Keep `app/assets/stylesheets/application.css` with the `.pinyin-hidden` rule intact, or explicitly migrate it as part of any stylesheet change — never delete it as cleanup. Document that this class is consumed by `pinyin_toggle_controller.js`.

**Detection warning signs:**
- Toggle button text changes but pinyin does not disappear
- `<rt>` elements visible in the DOM with `pinyin-hidden` class present on ancestor

**Phase:** Any phase that consolidates or restructures stylesheets.

---

### Pitfall 4: Tailwind v4 Content Detection Missing Dynamic Class Strings

**What goes wrong:** This app uses `tailwindcss-rails ~> 4.4` which is Tailwind v4. Tailwind v4 uses CSS-first config (`@import "tailwindcss"` — confirmed in `app/assets/tailwind/application.css`). In v4, class detection is content-aware: only classes that appear as complete strings in scanned files are emitted. Classes assembled from string interpolation are invisible.

**Root cause:** Several templates construct class names at runtime. Known examples:
- `decks/show.html.erb` line 114: `font_cqw = { "small" => "2.8", "large" => "4.5" }.fetch(...)` — these strings are used in inline `style=`, not Tailwind classes, so this specific case is safe. But the pattern invites similar mistakes with Tailwind classes.
- Any redesign that introduces `"text-#{color}"` or `"bg-#{variant}"` string patterns will produce classes Tailwind never emits.

**Consequences:**
- Class silently missing from output CSS in production (Tailwind processes files at build time, not runtime)
- Element renders without the expected color, size, or spacing
- Works in development only if CSS is rebuilt on every change; breaks on first deploy

**Prevention:**
- Never construct Tailwind class names via string interpolation. Use full class names in conditionals: `condition ? "bg-red-500" : "bg-green-500"`.
- For conditional class switching in controllers (JavaScript side), always use full class names in the Stimulus controller source, not template literals.
- Use a safelist block in Tailwind v4 config if truly dynamic classes are required.
- After any major template change, do a production-mode CSS build (`rails tailwindcss:build`) and visually verify the affected page before committing.

**Detection warning signs:**
- Style present in development but absent after deploy
- `class="bg-indigo-600"` in page source but no matching rule in network tab CSS

**Phase:** All redesign phases. Highest risk when introducing new color palette or new conditional class sets.

---

### Pitfall 5: Navigation Restructuring Breaks `data: { turbo: false }` Import Form

**What goes wrong:** The song import form in `decks/show.html.erb` is deliberately marked `data: { turbo: false }`. This does a full-page navigation to `songs#processing`, which uses `turbo_stream_from` and `redirect_controller` to poll and redirect when done. If redesign moves this form into a modal, a Turbo Frame, or changes the navigation target without preserving the full-page navigation behavior, the broadcast-driven redirect breaks.

**Root cause:** `redirect_controller.js` calls `Turbo.visit(this.urlValue)` on connect. This works when the controller mounts in a full-page context. Inside a Turbo Frame, `Turbo.visit` navigates the top-level frame, which may or may not be the intended behavior. Inside a modal, the element may be destroyed before the controller connects.

**Consequences:**
- Song import appears to complete (job runs) but user is stuck on the form with no feedback
- `redirect_controller` connects inside a Turbo Frame and navigates only the frame instead of the page
- Modal dismissed before broadcast arrives, controller never connects

**Prevention:** Keep the song import flow as a full-page navigation for v1.1. If redesign wraps the import trigger in a modal or slide-out panel, ensure the form still targets a full-page response (preserve `data: { turbo: false }`), or redesign the entire flow with explicit awareness of the `redirect_controller` dependency.

**Detection warning signs:**
- Clicking "Import" submits successfully but the processing page never appears
- Song import job completes in logs but UI shows nothing
- After import, page does not redirect to the deck

**Phase:** Any phase that restructures the deck show layout or adds modal/panel patterns to song import.

---

## Moderate Pitfalls

---

### Pitfall 6: Adding New Stimulus Controllers That Conflict With Existing Ones

**What goes wrong:** Rails auto-registers all controllers in `app/javascript/controllers/` using `stimulus-loading`. A redesign adding new controllers is fine, but the app also uses SortableJS initialized inside `sortable_controller`. If a new UI pattern attaches a second `data-controller="sortable"` to an element that is already a child of another sortable, the two SortableJS instances conflict — drop events fire twice or in wrong order.

**Root cause:** Stimulus controller naming is global; the sortable controller uses `this.element.children` to read positions. Nested sortables require explicit `group` configuration in SortableJS.

**Consequences:**
- Dragging a slide item fires both the inner and outer sortable's `onEnd`
- PATCH requests sent twice with conflicting positions
- Arrangement JSONB gets corrupted

**Prevention:** The deck show page already has two nested sortable levels (song order outer, slide arrangement inner — in `_song_block.html.erb` lines 28-31 and the inner `div` lines 29-32). Do not add a third level without configuring SortableJS `group` options. When adding new draggable areas, audit whether they are inside an existing sortable container.

**Phase:** Any phase adding new drag-and-drop UI or restructuring the deck show three-column layout.

---

### Pitfall 7: Replacing `content_for(:main_class)` Without Accounting for Page-Specific Overrides

**What goes wrong:** The application layout uses a `content_for(:main_class)` yield to allow individual pages to override the main container class. `decks/show.html.erb` sets `content_for :main_class, 'w-full px-6 py-8'` to go full-width (the deck editor needs all available space). If a redesign replaces this mechanism with a fixed layout class or a CSS container, the deck show page loses its full-width layout.

**Root cause:** The override is a one-line comment at the top of the view that is easy to miss or remove as "old code."

**Consequences:**
- Deck editor constrained to `max-w-5xl` like all other pages
- Three-column layout (`grid-cols-12`) cramped and unusable

**Prevention:** Preserve the `content_for(:main_class)` mechanism or replace it with an equivalent override pattern. When redesigning the layout, verify the deck show page specifically at full browser width.

**Phase:** Phase redesigning `layouts/application.html.erb` or the main container structure.

---

### Pitfall 8: Flash Message Redesign Conflicts With Devise's Flash Keys

**What goes wrong:** Devise uses both `:notice` and `:alert` flash keys, but also adds `:error` in some code paths and uses `:timedout` for session expiry. The current layout checks only `if notice` and `if alert`. A redesign adding support for `:error`, `:success`, or other semantic flash types may not wire up Devise's actual keys, causing Devise errors to appear as raw yellow Rails debug output.

**Root cause:** Devise flash key behavior is not documented prominently and varies by Devise version.

**Consequences:**
- Password reset failure shows no visible error message
- Session timeout shows generic Rails error instead of styled message
- Custom error flash types silently swallowed

**Prevention:** When redesigning flash messages, map Devise's actual keys. At minimum: `notice`, `alert`. Consider wrapping both under a semantic-agnostic loop: `flash.each do |type, message|`. Use a type-to-style mapping for color.

**Phase:** Phase redesigning flash messages and global notification UI.

---

### Pitfall 9: Inline `style=` Attributes for Theme Colors Are Not Tailwind — Do Not Replace With Classes

**What goes wrong:** The slide preview in `decks/show.html.erb` uses inline `style=` attributes for dynamic theme colors (`background-color: #{theme.background_color}`, `color: #{theme.text_color}`). These are user-supplied hex values stored in the database — they cannot be Tailwind classes. A redesign that tries to "clean up" inline styles by converting them to Tailwind classes will break theme rendering entirely.

**Root cause:** Designers unfamiliar with the data model may see `style="background-color: #..."` as a code smell and attempt to replace it with `class="bg-indigo-600"`.

**Consequences:**
- Slide preview ignores user's custom theme colors and shows hardcoded Tailwind values
- PPTX export unaffected (uses database values directly in Python), so desktop output and preview diverge

**Prevention:** Never convert dynamic user data (colors, font sizes) from inline styles to Tailwind utility classes. These values must remain inline. The `style=` attributes in `decks/show.html.erb` (lines 112-115, 131) are intentional and correct.

**Phase:** Any phase touching the slide preview or theme display sections of deck show.

---

### Pitfall 10: `turbo_stream_from` Requires ActionCable — Verify Solid Cable in Redesign Environments

**What goes wrong:** The deck show page subscribes to two live channels via `turbo_stream_from`. These use Solid Cable (not Redis). If a redesign spin-up (staging server, preview deploy) does not run a Solid Queue worker and does not configure Solid Cable correctly, the export and theme suggestion streams silently never arrive. The bug manifests as an apparent redesign regression when it is actually an infrastructure issue.

**Root cause:** Solid Cable uses the database as the cable backend. In preview environments that share a database but don't run the full process stack, broadcasts are queued and never consumed.

**Prevention:** When evaluating redesign changes, always test in an environment with the full `bin/dev` process stack (web + worker). Do not evaluate Turbo Stream behavior in a static screenshot or a server started with `rails s` alone (no worker).

**Phase:** Infrastructure awareness for all testing phases. Note at start of every phase touching `decks/show.html.erb`.

---

## Minor Pitfalls

---

### Pitfall 11: Removing `hello_controller.js` Breaks Nothing But Creates Import Error

**What goes wrong:** `hello_controller.js` exists in `app/javascript/controllers/` and is auto-registered. It is scaffolding not used anywhere. If it is deleted during a cleanup phase without also removing or regenerating `index.js`, the auto-loader may throw a module not found error in the browser console — harmless but confusing.

**Prevention:** When removing scaffold controllers, run `bin/importmap audit` after deletion.

---

### Pitfall 12: Changing Button `type` Implicitly Breaks `button_to` Turbo Method

**What goes wrong:** `button_to` in Rails generates a single-button form. It relies on the button being `type="submit"`. If a redesign wraps a `button_to` output in a component that renders its own `<button>` element, the result has two nested forms or two submit buttons, causing unexpected behavior with `data: { turbo_method: :delete }`.

**Prevention:** When building UI components for action buttons, use ERB partials or `content_tag` helpers, not new `<button>` wrappers around existing `button_to` calls.

---

### Pitfall 13: `animate-spin` and Other Tailwind Utility Classes Used in Job-Broadcast HTML Strings

**What goes wrong:** `GenerateThemeSuggestionsJob` broadcasts raw HTML strings containing Tailwind classes directly: `class="text-xs text-red-400 py-2"`. If the redesign renames or removes these utility classes from the Tailwind source, the broadcast HTML renders without the expected styles — and there is no compile-time check because the strings live in Ruby job files, not scanned ERB templates.

**Prevention:** When changing Tailwind class names during a redesign (e.g., switching from `text-red-400` to a custom semantic token), grep for Tailwind class strings in `app/jobs/` and `app/controllers/`. These files are not scanned by the Tailwind content detector by default in Tailwind v4 unless explicitly added to the source list.

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Navigation bar redesign | Turbo Stream target IDs in deck/song views are nearby and easy to accidentally disturb | Audit all `id=` attributes before touching layout |
| Color palette and typography | Dynamic theme colors via `style=` must stay inline; palette only applies to static UI chrome | Separate "theme UI" from "deck theme colors" conceptually |
| Deck show layout restructure | Sortable data contracts, `content_for(:main_class)`, and all three Turbo channel targets live here | Touch last, test heavily |
| Flash / notification redesign | Devise flash keys may differ from app flash keys | Use `flash.each` instead of explicit key checks |
| Empty states / onboarding cues | These are new DOM elements; low risk of regression | Fine to build freely, but avoid adding `data-controller` inside sortable containers |
| Song import flow | `data: { turbo: false }` and `redirect_controller` are load-bearing; full-page navigation is intentional | Do not wrap import form in Turbo Frame or modal without redesigning the entire flow |
| Stylesheet consolidation | `.pinyin-hidden` class and any classes in job-broadcast HTML strings are outside Tailwind scan | Grep for class names in `.rb` files before pruning CSS |

---

## Sources

All findings are based on direct inspection of the following codebase files (HIGH confidence — no external sources required):

- `app/assets/tailwind/application.css` — confirms Tailwind v4 CSS-first config
- `app/assets/stylesheets/application.css` — confirms `.pinyin-hidden` lives outside Tailwind
- `app/javascript/controllers/sortable_controller.js` — drag handle and data-id contract
- `app/javascript/controllers/pinyin_toggle_controller.js` — `.pinyin-hidden` class dependency
- `app/javascript/controllers/redirect_controller.js` — `Turbo.visit` on connect
- `app/jobs/generate_pptx_job.rb` — hardcoded `export_button_#{deck_id}` target
- `app/jobs/import_song_job.rb` — hardcoded `import_status` target; raw HTML with Tailwind classes in broadcasts
- `app/jobs/generate_theme_suggestions_job.rb` — hardcoded `theme_suggestions` target; raw HTML with Tailwind classes
- `app/views/decks/show.html.erb` — `turbo_stream_from` subscriptions, `content_for(:main_class)`, inline style= theme colors, nested sortable setup
- `app/views/decks/_export_button.html.erb` — `id="export_button_#{deck.id}"` target
- `app/views/songs/processing.html.erb` — `id="import_status"` target
- `app/views/songs/show.html.erb` — `id="song_status_#{@song.id}"` target
- `app/views/deck_songs/_song_block.html.erb` — `data-drag-handle`, `data-id`, nested sortable
- `app/views/deck_songs/_slide_item.html.erb` — `data-drag-handle`, `data-id`
- `app/views/layouts/application.html.erb` — flash rendering, `content_for(:main_class)` yield
- `Gemfile` — confirms `tailwindcss-rails ~> 4.4`, `turbo-rails`, `solid_cable`
- `config/importmap.rb` — confirms auto-loaded controllers from `app/javascript/controllers/`
- `config/routes.rb` — all route paths used in action links and job redirects
