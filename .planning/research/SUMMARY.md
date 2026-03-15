# Project Research Summary

**Project:** ChurchSlides (praise-project) — v1.1 Design Milestone
**Domain:** UI/UX redesign of existing Rails 8 worship slide generator
**Researched:** 2026-03-15
**Confidence:** HIGH — all findings grounded in direct codebase inspection

## Executive Summary

The v1.1 milestone is a visual redesign of a fully functional, shipped app — not a new build. The core problem is that v1.0 used the default Tailwind SaaS palette (indigo primary, gray-50 body, flat banner flash messages), which reads as generic admin software rather than a tool built for worship teams. The redesign goal is to replace that generic visual language with a warm, worshipful identity: earthy amber and stone tones, card-based layouts with date prominence, polished feedback patterns, and onboarding cues that orient new users. No backend changes are required for the visual work; three targeted data additions (META-01/02 for song metadata, SCRIP-01 for scripture slides) are bundled in this milestone and gate their respective UI display components.

The recommended approach is to proceed phase by phase with a strict dependency gate at Phase 1: the Tailwind config custom token definitions must land first, as every subsequent component change depends on those new palette tokens being available. From there, changes cascade — navigation, cards, forms, flash messages, empty states, and finally the most sensitive surface (the deck editor) where Turbo Stream targets, drag-and-drop data contracts, and inline theme styles all coexist. The tech stack requires no changes: Tailwind v4 via importmap, Hotwire (Turbo + Stimulus), and inline SVG icons from Heroicons are exactly the right tools for this scope.

The key risk in this milestone is not visual — it is behavioral. The deck editor and song import flows contain invisible contracts: hardcoded DOM IDs that background jobs broadcast to, `data-drag-handle` and `data-id` attributes that Stimulus controllers depend on, a `.pinyin-hidden` CSS class that lives outside Tailwind, and a deliberate `data: { turbo: false }` on the import form that must not be wrapped in a Turbo Frame. None of these constraints are visible from screenshots. The mitigation is simple: treat the deck show view as the highest-risk surface, defer it to the last redesign phase, and audit all `id=` attributes before modifying any template that a background job references.

---

## Key Findings

### Stack (from STACK.md — v1.0 research, UI-relevant subset)

The stack is locked and no additions are needed for the v1.1 redesign. All UI work is achievable with what is already installed.

**Core technologies relevant to the redesign:**
- **Tailwind CSS v4** (`tailwindcss-rails ~> 4.4`): CSS-first config via `@import "tailwindcss"` in `application.css`. Custom palette tokens go in `tailwind.config.js`. Tailwind v4 uses static content scanning — dynamic class string interpolation is invisible to the build.
- **Turbo + Stimulus (Hotwire)**: All interactive patterns (drag-and-drop, spinners, flash auto-dismiss) use Stimulus controllers. New controllers go in `app/javascript/controllers/` and are auto-registered via importmap.
- **Importmap (no Node/Webpack)**: No npm packages can be added. Icon libraries that require npm are off the table. Heroicons inline SVG in ERB is the correct approach.
- **Solid Cable**: Powers `turbo_stream_from` subscriptions on the deck show and song processing pages. Must run with the full `bin/dev` stack to test async UI updates.

### Expected Features (from FEATURES.md — v1.1 specific, primary source)

**Must have (table stakes) — milestone blockers:**
- Warm color palette (amber, stone, warm off-white) replacing default indigo/gray — enables everything else
- Consistent `rounded-xl` component language across cards, buttons, inputs
- Deck list as card grid with date prominence (date leads, title secondary)
- Deck creation as the primary nav entry point (Songs visually de-emphasized)
- Polished flash messages with icons and auto-dismiss Stimulus controller
- Actionable error messages with prominent fallback paths
- Consistent spinner/loading state conventions across import and export flows
- Empty states with workflow context on deck index, deck editor, and song library
- Readable typography scale (headline/body/caption hierarchy)
- Auth pages with brand context

**Should have (differentiators) — meaningful improvement over bare redesign:**
- Worship-specific color palette with named tokens (`worship-primary`, `worship-accent`) rather than raw Tailwind color references
- Empty state with worship-context copy ("Your Sunday slide deck starts here")
- Processing state copy that conveys AI activity ("Claude is structuring your lyrics...")
- Export button as prominent "done" affordance with download icon
- Song metadata display for CCLI, key, and artist fields (gated on META-01/02 migrations)
- Onboarding cue on first deck editor open ("Now add your first song...")
- Section type labels (verse/chorus/bridge) with color-coded badges in slide preview

**Defer to v1.2:**
- Song card section badge in library (nice, not critical)
- Auth page illustration or brand artwork (small team signs up once)
- Deck card with song count or thumbnail preview (extra DB query, minor value)
- Dark mode (doubles the visual system; users work in lit rooms)
- Responsive/mobile-first layout rework (primary use is desktop)

### Architecture Approach (from ARCHITECTURE.md — v1.0 research, UI-relevant subset)

The app is a multi-frame Rails page, not a SPA. The deck editor uses a 12-column grid with three nested surfaces: song order (outer sortable), slide arrangement per song (inner sortable), and slide preview panel. Turbo Frames handle song search results, slide previews, and inline editing. Turbo Streams handle async job completion. The redesign adds no new components to this architecture — it applies visual changes to existing partials.

**Surfaces the redesign touches:**
1. `layouts/application.html.erb` — navigation bar, flash messages, main container class yield
2. `decks/index.html.erb` — deck card grid and empty state
3. `decks/show.html.erb` — deck editor three-column layout, slide preview, export button, Turbo Stream targets (highest risk)
4. `songs/index.html.erb` — song library, empty state
5. `songs/show.html.erb`, `songs/processing.html.erb`, `songs/_failed.html.erb` — import status and error states
6. `devise/sessions/new.html.erb` — auth page brand treatment
7. `deck_songs/_song_block.html.erb`, `deck_songs/_slide_item.html.erb` — drag-and-drop items (data contract risk)

### Critical Pitfalls (from PITFALLS.md — v1.1 specific, primary source)

1. **Renaming Turbo Stream target DOM IDs** — Five hardcoded broadcast targets exist across the deck and song views (`export_button_#{deck_id}`, `theme_suggestions`, `import_status`, `song_status_#{song.id}`). Renaming or removing these IDs causes silent UI freeze — the background job completes but the browser never knows. Mitigation: audit all `id=` attributes before touching these templates; treat them as a public API; wrap redesign elements around, not instead of, these target `div`s.

2. **Breaking the `data-drag-handle` / `data-id` Sortable contract** — `sortable_controller.js` reads `data-id` on each draggable child and expects `data-drag-handle` on the handle element. Extra wrapper `div`s or restructured markup break drag-and-drop silently (the handle still moves but positions are wrong). Mitigation: carry `data-drag-handle` and `data-id` forward verbatim; do not add wrapper `div`s inside the sortable container's direct children.

3. **Removing `.pinyin-hidden` during stylesheet cleanup** — This one CSS class lives in `application.css` outside Tailwind. `pinyin_toggle_controller.js` adds/removes it. If pruned as "dead code" during a stylesheet consolidation, the pinyin toggle breaks with no visible error. Mitigation: keep the rule; add a comment marking it as consumed by the controller.

4. **Dynamic Tailwind class strings not detected by Tailwind v4** — Tailwind v4 only emits classes that appear as complete strings in scanned files. Classes assembled via string interpolation are silently omitted. Additionally, raw HTML strings in job files (`app/jobs/`) contain Tailwind classes that are not in the default content scan path. Mitigation: always use full class names in conditionals; grep `app/jobs/` for class strings before changing palette tokens; run `rails tailwindcss:build` in production mode before each commit.

5. **Song import form `data: { turbo: false }` must be preserved** — The song import form deliberately opts out of Turbo to trigger a full-page navigation to the processing page, where `redirect_controller.js` connects and waits for the job completion broadcast. Wrapping this form in a modal or Turbo Frame breaks the redirect. Mitigation: keep the import form as a full-page navigation for this milestone.

**Additional moderate risks:**
- Flash message redesign must use `flash.each` (not explicit `:notice`/`:alert` keys) to catch all Devise flash keys including `:error` and `:timedout`
- `content_for(:main_class)` override in `decks/show.html.erb` gives the deck editor full-width layout; replacing it with a fixed container class breaks the three-column grid
- Inline `style=` theme color attributes in the slide preview are user database values — never convert them to Tailwind classes
- Job broadcast HTML strings in `app/jobs/` contain Tailwind class names not visible to the content scanner

---

## Implications for Roadmap

Based on combined research, the v1.1 milestone maps cleanly to four phases with a strict dependency gate at Phase 1.

### Phase 1: Design Foundation (Tailwind tokens + navigation)

**Rationale:** Every visual change in the milestone depends on the custom palette tokens being defined. This phase must land first. Navigation redesign is low-risk (no Turbo Stream targets live in the nav bar) and delivers immediate visible impact.
**Delivers:** `tailwind.config.js` with `worship-*` color tokens, updated `bg-stone-50` body, warm navigation bar with Decks as primary entry point, wordmark treatment, button and input base classes using new tokens.
**Addresses:** Warm color palette, consistent component language, deck creation as primary entry point.
**Avoids:** Tailwind v4 dynamic class string pitfall — define tokens as complete names, never interpolated.
**Research flag:** Standard Tailwind config patterns — no phase research needed.

### Phase 2: Global Components (Flash, forms, typography)

**Rationale:** Flash messages and form elements appear on every page. Doing them after the design foundation (so new tokens are available) but before page-specific layouts means all subsequent phase work inherits the correct base styles without rework.
**Delivers:** Auto-dismiss flash message component with icon mapping and Devise key support, consistent form system (inputs, labels, focus rings using new tokens), typography scale applied globally.
**Addresses:** Polished flash messages, consistent form system, readable typography, Devise flash key coverage.
**Avoids:** Flash/Devise flash key pitfall — use `flash.each` not explicit key checks. Tailwind dynamic class pitfall — full class names in type-to-style mapping.
**Research flag:** Standard patterns — no phase research needed.

### Phase 3: Content Pages (Decks index, songs library, auth, empty states)

**Rationale:** These pages are visually independent from the deck editor's Turbo Stream and drag-and-drop complexity. Card grid for decks index, empty states, onboarding cues, and auth page brand treatment can all be built freely with low regression risk.
**Delivers:** Deck list as card grid with date prominence, empty states with worship-context copy on deck index and song library, onboarding cue on first deck editor open, auth page with brand context.
**Addresses:** Deck card grid, empty states, onboarding cue, auth page brand treatment.
**Avoids:** No Turbo Stream targets on these pages; avoid adding `data-controller` inside sortable containers on the deck index.
**Research flag:** Standard patterns — no phase research needed.

### Phase 4: Deck Editor and Import/Export Polish (highest risk)

**Rationale:** The deck editor (`decks/show.html.erb`) contains every critical pitfall: Turbo Stream targets, nested sortables with data contracts, `content_for(:main_class)`, inline theme colors, and the full-page import form. Deferring this to last ensures earlier phases are stable before touching the highest-risk surface.
**Delivers:** Processing state with AI-copy ("Claude is structuring your lyrics..."), consistent spinner conventions, export button visual upgrade, slide preview section badges, song metadata display (once META-01/02 land), scripture slide display (once SCRIP-01 lands).
**Addresses:** Loading state polish, export "done" affordance, section type visual labels, META-01/02 and SCRIP-01 display components.
**Avoids:** All five critical pitfalls; must audit `id=` attributes before any template change; must preserve `data-drag-handle`, `data-id`, `.pinyin-hidden`, `content_for(:main_class)`, inline `style=` theme attributes, and `data: { turbo: false }` on import form.
**Research flag:** No additional research needed, but this phase warrants a written pre-work checklist of all DOM contracts before coding begins.

### Phase Ordering Rationale

- Phase 1 gates Phases 2-4 because Tailwind token definitions must exist before class names can be applied
- Phases 2 and 3 are largely independent and could be parallelized if multiple contributors are available; sequential ordering recommended for a single developer to avoid style drift
- Phase 4 is last by design — it touches every critical pitfall and benefits from having the full visual system stabilized before high-risk template surgery
- META-01/02 and SCRIP-01 migrations are data-work prerequisites that should land before Phase 4 ships, but can be developed in parallel with Phases 1-3

### Research Flags

Phases likely needing deeper research during planning: none. All v1.1 changes are well-understood CSS class updates, small Stimulus controllers, and ERB partial edits with known constraints.

Phases with standard patterns (skip research-phase):
- **Phase 1:** Tailwind v4 CSS-first config and custom token definitions are well documented
- **Phase 2:** Auto-dismiss Stimulus controller is a well-documented pattern; Devise flash key handling is straightforward once the mapping is known
- **Phase 3:** Card grid layouts and empty state patterns have established Tailwind UI conventions
- **Phase 4:** No new patterns — upgrade existing implementations; the risk is preservation, not discovery

Pre-phase checklist recommended for Phase 4 instead of a research phase: before writing any code in Phase 4, produce a written inventory of all DOM IDs that jobs broadcast to, all `data-drag-handle`/`data-id` elements, and all inline `style=` attributes. This is a 30-minute audit, not a research session.

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack (UI-relevant) | HIGH | Direct Gemfile and stylesheet inspection; no ambiguity for this milestone's scope |
| Features | HIGH | v1.0 views inspected directly; gap diagnosis is factual, not estimated |
| Architecture (UI-relevant) | HIGH | DOM contracts, Turbo Stream targets, and controller dependencies all verified from source |
| Pitfalls | HIGH | Every pitfall grounded in specific file and line number from codebase inspection |

**Overall confidence:** HIGH

### Gaps to Address

- **Worshipful palette validation:** The exact amber/stone color choices for `worship-primary` and `worship-accent` tokens are research-informed recommendations, not validated against actual user preferences. The palette should be reviewed with the worship team before Phase 1 ships. Low cost to adjust at that stage; high cost after Phases 2-4 inherit the tokens.
- **META-01/02 and SCRIP-01 timeline:** The Phase 4 UI components for song metadata and scripture slides are gated on migrations tracked separately. If those migrations slip, Phase 4 should ship without those display components — do not block the visual redesign on data migrations.
- **Async flow testing environment:** Turbo Stream behavior (export button, theme suggestions, song import) can only be validated in a `bin/dev` environment with the Solid Queue worker running. The Phase 4 test checklist must explicitly require this setup.

---

## Sources

### Primary (HIGH confidence — direct codebase inspection)
- All views in `app/views/` — v1.0 gap diagnosis (FEATURES.md)
- `app/javascript/controllers/` — Stimulus controller inventory and DOM contract verification (PITFALLS.md)
- `app/jobs/` — Turbo Stream broadcast target IDs and inline HTML class strings (PITFALLS.md)
- `app/assets/tailwind/application.css` — Tailwind v4 CSS-first config confirmation
- `app/assets/stylesheets/application.css` — `.pinyin-hidden` custom CSS class location
- `Gemfile` / `Gemfile.lock` — stack version confirmation (STACK.md)
- `config/importmap.rb` — Stimulus controller auto-registration and no-npm constraint

### Secondary (MEDIUM confidence — knowledge of comparable tools)
- Planning Center Services visual patterns — card-based service lists, warm palette, date-first information hierarchy
- ProPresenter 7 UI conventions — dark mode evaluated and explicitly rejected for web app context
- Tailwind UI component library — card, flash message, and empty state component patterns

---
*Research completed: 2026-03-15*
*Ready for roadmap: yes*
