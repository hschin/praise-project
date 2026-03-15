# Feature Landscape: v1.1 UI Redesign

**Domain:** Worship presentation app — UI/UX redesign milestone
**Researched:** 2026-03-15
**Scope:** What a warm/worshipful redesign looks like in practice for a Chinese church worship slide tool. Based on direct codebase inspection of v1.0 (shipped), analysis of comparable worship software, and UI pattern analysis for small-team ministry tools.
**Confidence note:** HIGH for diagnosis of existing v1.0 gaps (codebase inspected directly). MEDIUM for worshipful visual pattern recommendations (knowledge of ProPresenter, Planning Center, EasyWorship aesthetics, and general ministry app conventions).

---

## Context: What v1.0 Looks Like Today

v1.0 is fully functional but visually generic. A survey of all views reveals:

- **Color palette:** Indigo-600 as primary, gray-50 body, gray-900 text. This is the default Tailwind SaaS palette — identical to thousands of admin dashboards.
- **Components:** Rounded-sm or rounded-lg boxes, no consistent sizing. Some cards use `rounded`, some `rounded-lg`. No warm tones anywhere.
- **Navigation:** White `bg-white border-b border-gray-200` header. Flat text links. No visual weight hierarchy between Decks (primary flow) and Songs (secondary library).
- **Forms:** Consistent `focus:ring-indigo-500` pattern throughout — functional but cold blue. Labels `text-gray-700`. Buttons `bg-indigo-600`.
- **Flash messages:** Flat banner lines (`bg-green-50 border-green-200`) — no icon, no dismiss, no animation. Disappear on next navigation only.
- **Empty states:** Minimal ("No decks yet. Create your first deck." / "No songs yet. Search for a song above to get started"). Functional but provide no warmth or orientation.
- **Loading states:** Spinner in processing card is functional. Export button state machine (idle / generating / ready / error) exists but is plain.
- **Onboarding:** None. A new user lands on an empty decks list with a "New Deck" button. No walkthrough, no contextual cues, no hint of what the app does or how the workflow proceeds.
- **Auth pages:** Bare `max-w-md` form, plain "Praise Project" title, no brand context.

The existing architecture is sound and the Hotwire/Tailwind/Stimulus stack is well-suited for all redesign work. No technology changes are needed — this milestone is purely UI.

---

## Table Stakes

Features users expect from a redesigned worship tool. Missing any of these and the new visual skin will feel like a theme applied over a broken app.

| Feature | Why Expected | Complexity | Current State |
|---------|--------------|------------|---------------|
| Warm color palette (not indigo/gray default) | Generic SaaS palette signals "this isn't built for us"; worship teams use tools like ProPresenter, Planning Center, which have distinct identity | Low | Not present — pure default Tailwind palette |
| Consistent rounded-xl component language | Rounded shapes feel softer, less corporate; consistent rounding across cards, buttons, and inputs reads as intentional design | Low | Inconsistent — some `rounded`, some `rounded-lg`; no unified token |
| Deck list as card grid (not plain list) | Cards communicate "these are your worksessions"; a flat list of links feels like a spreadsheet | Low-Med | Flat `divide-y` list — no card personality |
| Deck creation as the primary nav entry point | The most common action for a worship leader starting their Sunday prep should be the most prominent affordance | Low | "Decks" and "Songs" are equal-weight nav links; no visual primary-action emphasis |
| Polished flash messages with icons and auto-dismiss | Raw banner text at the top of the page is jarring after an action; contextual icons (checkmark for success, warning for error) and auto-dismiss signal care | Medium | Flat banner, no icon, no auto-dismiss, disappears only on navigation |
| Actionable error messages | "Could not find lyrics" must tell the user exactly what to do next — the fallback path (paste lyrics) must be prominently surfaced, not buried in the current error card | Low | Functional but prose-heavy and unstyled |
| Skeleton/spinner conventions on loading states | The import processing card and export button spinners need visual consistency — same spinner size, same label style, same placement | Low | Each built independently — spinner in processing card is sized differently from export button spinner |
| Empty state with call to action on decks index | First time a worship leader logs in, they need immediate orientation: what is this, what should I do first | Low | Single sentence + button, no context |
| Readable typography scale | Headline / body / caption hierarchy must feel deliberate, not default browser / default Tailwind | Low | Text sizes are functional but not tuned as a type scale |
| Auth pages that feel like the product | Sign-in page currently has no brand context; a bare form makes first-time users uncertain they landed in the right place | Low | Bare form, no logo, no warmth |

---

## Differentiators

Features that give the redesigned app a noticeably better feel than "generic SaaS with a palette swap." These are what separate a thoughtful worship tool from a template.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Worship-specific color palette | Earthy warm tones (amber, warm stone, muted gold) rather than corporate indigo. Think candlelight, aged wood, rich fabric — materials that read as reverent rather than productive | Low | Tailwind config change: custom `worship-*` color tokens. No framework changes. |
| Song card "section badge" in library | Cards in the song library should show section count (e.g., "4 sections") or first lyric line — already partially implemented — but styled with a section type badge that communicates structure at a glance | Low | First lyric line preview already exists; needs visual badge treatment |
| "Add song" as inline drawer/panel, not page nav | Opening the "add song" workflow from the deck editor as a slide-in Turbo Frame panel rather than a list in the sidebar avoids the visual clutter of showing the entire library in a narrow column | Medium | Current implementation: song search is already inline in the sidebar. Could be enhanced with a drawer pattern for better use of space. |
| Processing state that communicates "AI is working" | The import spinner says "Importing song..." but doesn't convey that Claude is actively doing something interesting. A slightly warmer card with a subtle pulse animation and copy like "Claude is structuring your lyrics..." sets expectations and reduces abandon-and-refresh behavior | Low-Med | Stimulus controller already handles Turbo Stream updates; copy and visual style change only |
| Empty state with worship context | Rather than "No decks yet", an empty state that says something like "Your Sunday slide deck starts here — search for a song or start a new deck" with a small illustrated icon anchors the purpose of the tool | Low-Med | Copy and a simple SVG icon; no backend changes |
| Deck card with date prominence | Worship leaders think in terms of service dates. The deck card should lead with the date (e.g., "Sunday 15 March") in a prominent typographic position, with the deck title secondary | Low | Currently date is `text-sm text-gray-500 ml-2` — afterthought styling |
| Section labels (verse/chorus/bridge) with color coding | In the slide preview and arrangement panel, section type labels (verse, chorus, bridge) displayed with distinct warm-palette color chips help leaders scan arrangement at a glance | Low | Currently section_type is shown as raw text in the slide preview at 40% opacity |
| Export button as a prominent "done" state | The export button is a small `text-sm px-4 py-2` button in the header. For a download-first workflow, the export action should feel like a major affordance — larger, with a download icon, and the "ready" state should feel celebratory | Low | Button state machine already exists; visual treatment upgrade only |
| Song metadata display (CCLI, key, artist) | v1.1 adds CCLI number, key, and artist/composer fields (META-01/02). These should appear as a secondary metadata row on song cards and song pages — subtle but scannable | Low | Fields being added in this milestone; visual placement is a design decision |
| Onboarding cue on first deck creation | After a user creates their first deck and lands on the empty deck editor, a contextual banner saying "Now add your first song — search the library or import by title" removes the "now what?" moment | Low | No onboarding layer exists today |

---

## Anti-Features

Features to explicitly not build in this milestone, even though they may feel tempting during a redesign.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Dark mode toggle | Doubles the visual system to maintain; adds interaction complexity; users use projector tools in lit rooms, not dark rooms | Ship one warm light theme; revisit dark mode if users ask |
| Per-component animation library (AOS, Animate.css, etc.) | These libraries add kb, introduce timing conflicts with Turbo page transitions, and make the app feel like a marketing site | Use Tailwind's built-in `transition`, `duration-150`, `ease-in-out`; one global `animate-spin` for spinners |
| Custom icon set requiring asset pipeline changes | SVG icon libraries introduce dependency management overhead; Importmap does not handle npm icon packages cleanly | Use Heroicons inline SVG snippets directly in ERB; no icon library dependency |
| Skeleton loading screens for every page | Full skeleton screens require mirroring the layout structure in a placeholder component — high maintenance cost for minor polish | Spinner + contextual copy is sufficient; reserve skeletons for the slide preview panel only if needed |
| Redesigning the Devise registration/confirmation email templates | Email HTML is a separate maintenance surface; not visible to most users (small team that signs up once) | Leave email templates as-is; focus on in-app flows |
| Toast notification stack / snackbar system | A full toast system (multiple concurrent, stacking, dismiss queue) is over-engineered for an app that generates one flash message per action | Upgrade existing flash banner to a single polished auto-dismiss component; not a stack |
| Responsive/mobile-first layout rework | Primary use case is desktop (worship leader at a laptop building slides); mobile responsiveness is out of scope per PROJECT.md | Keep existing max-width containers; ensure nothing is actively broken at tablet width, but don't optimize for mobile |
| Sidebar navigation / rail navigation pattern | A sidebar nav implies the app has many peer sections; this app has two: Decks (primary) and Songs (secondary) | Top navigation bar is correct; de-emphasize Songs link, not add nav complexity |
| Custom Tailwind component library / design system docs | A full component library is overkill for a single-team app at this scale | Establish CSS custom property tokens (colors, radii) in `tailwind.config.js`; that's the full "design system" needed |

---

## Feature Dependencies

These apply specifically to the UI redesign work:

```
Tailwind config (custom color tokens, radius scale)
  └─> All component visual changes (buttons, inputs, cards, nav)
        └─> Form consistency pass (all forms use new tokens)
        └─> Navigation redesign (primary/secondary visual weight)
              └─> Auth pages (same layout and color system)

Flash message component upgrade
  └─> Auto-dismiss Stimulus controller (new small controller)

Empty state designs
  └─> Deck index empty state
  └─> Deck editor empty state (no songs added yet)
  └─> Song library empty state
  └─> Onboarding cue on first deck editor open

Song metadata display (CCLI, key, artist)
  └─> META-01 / META-02 migrations (must land before UI references fields)

Scripture slide UI
  └─> SCRIP-01 data model (must land before UI)
```

Key dependency constraints:
- All component visual work is gated on `tailwind.config.js` custom token definitions — that is the first PR
- Flash message auto-dismiss requires a new `flash_controller.js` Stimulus controller — small, self-contained, does not block anything
- Song metadata display (META-01/02) and scripture slide UI (SCRIP-01) are gated on their respective migrations shipping first; the visual design can be drafted in parallel but not deployed until data exists

---

## Worshipful vs. Generic SaaS: The Key Distinctions

This section directly answers the research question and is written to inform roadmap decisions on visual direction.

### What "worshipful" means in practice

**Color language:** Worship environments use warm, reverent tones — not because of a design trend, but because the physical environments (sanctuaries, lit candles, wood, fabric) create that expectation. Generic SaaS indigo/blue reads as productivity software. Amber, warm stone (Tailwind's `stone` palette), muted gold, and deep warm navy (not cold blue navy) read as appropriate for the domain. The background body color should be warm off-white (`stone-50`) not neutral gray (`gray-50`).

**Typography:** Worship software tends toward slightly larger, more spaced type than productivity tools. Line height is generous. Headings are not crowded. The reading experience should feel calm and deliberate, not dense.

**Borders and depth:** Softer borders (lighter border color, `border-stone-200` not `border-gray-200`), more generous padding inside cards, and subtle box shadows create breathing room. The deck editor's slide preview cards already use `shadow` — this visual approach should extend throughout.

**Iconography tone:** Worship tools use icons sparingly and favor simple outline icons (Heroicons outline set) over filled icons. Dense iconography feels like a dashboard; sparse iconography with clear labels feels focused.

**Interactive states:** Hover states in worship tools should be gentle — a light warm fill (`hover:bg-amber-50`) not a sharp color shift. Focus rings should be warm-colored (amber or warm indigo), not default browser blue.

### What "generic SaaS" looks like in v1.0 (and what to change)

| v1.0 Pattern | Generic SaaS Signal | Worshipful Replacement |
|---|---|---|
| `bg-gray-50` body | Default admin template | `bg-stone-50` or `bg-amber-50/30` warm off-white |
| `text-indigo-600` primary | Default SaaS accent | Custom warm primary: deep amber-brown or warm slate |
| `border-gray-200` everywhere | Default Tailwind border | `border-stone-200` or `border-warm-200` — same lightness, warmer hue |
| `bg-indigo-600` buttons | Default CTA color | Warm primary button: `bg-amber-700` or `bg-stone-700` |
| Flat banner flash messages | Bootstrap-era alert style | Rounded card with icon, auto-dismiss, warm success green |
| Equal-weight nav links | Generic multi-section app | Deck creation prominent; Songs de-emphasized |
| "No decks yet" empty state | Bare scaffolding | Illustrated empty state with workflow context |
| Plain "Praise Project" text logo | Default title | Wordmark with light warmth — even just a styled text mark |

### What ProPresenter and Planning Center do well (transferable patterns)

- **Planning Center** (the dominant worship planning tool in US evangelical churches) uses a warm, human color palette: deep teal-green primary, warm grays, gentle card shadows. Navigation is task-oriented ("Services" is the entry point, not a generic CRUD list).
- **ProPresenter** (projection software) uses a near-black dark theme for its editor to simulate the projection environment. This is NOT recommended for a web app — it works for desktop projection software but feels oppressive in a browser tab during planning.
- Both tools are generous with whitespace. They do not feel dense or information-overloaded even when displaying a full service plan.
- Both tools use card-based navigation for the primary objects (services/presentations), not table rows.
- Both tools surface the most recent/upcoming items prominently — dates are first-class information.

---

## MVP Recommendation for v1.1

**Prioritize (must ship for milestone):**

1. Tailwind config with custom warm palette tokens (`tailwind.config.js`) — enables everything else; Low complexity
2. Navigation visual redesign — Decks as primary, Songs as secondary; `bg-stone-50` body; warm logo wordmark; Low complexity
3. Deck list as card grid with date prominence — replaces flat list; Low-Medium complexity
4. Consistent form system — all inputs, labels, buttons, focus states use new tokens; Low complexity (search/replace CSS classes)
5. Flash message upgrade — rounded card, icon, auto-dismiss Stimulus controller; Medium complexity
6. Empty states with context — deck index, deck editor (no songs), song library; Low complexity (copy + SVG icon)
7. Onboarding cue on first deck — contextual banner after creation; Low complexity
8. Processing / loading state visual polish — consistent spinner, warmer copy on the import card; Low complexity

**Defer to v1.2 or as stretch goals:**

- Song section badge color coding (nice, not critical)
- Export button visual upgrade to prominent "done" affordance (functional now; cosmetic upgrade)
- Auth page illustration or brand artwork (low user-hours impact for a small team that signs up once)
- Deck card section count or song thumbnail preview (requires additional DB query, minor value)

---

## Sources

### Primary (HIGH confidence — direct codebase inspection)
- All views in `/app/views/` inspected: `layouts/application.html.erb`, `decks/index.html.erb`, `decks/show.html.erb`, `decks/_form.html.erb`, `decks/_export_button.html.erb`, `songs/index.html.erb`, `songs/show.html.erb`, `songs/_processing.html.erb`, `songs/_failed.html.erb`, `devise/sessions/new.html.erb`
- `app/assets/stylesheets/application.css` — confirms Tailwind is the only styling system; no custom CSS beyond pinyin toggle
- `app/javascript/controllers/` — confirms Stimulus controller inventory; no existing flash or onboarding controllers

### Secondary (MEDIUM confidence — knowledge of comparable tools)
- Planning Center People / Services visual patterns — card-based service list, warm palette, date prominence
- ProPresenter 7 UI conventions — large projection preview, operator-focused dark mode (explicitly rejected for web app use)
- EasyWorship — older tool; legacy patterns; not recommended as model
- Tailwind UI component library — component patterns for cards, flash messages, empty states

### Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| v1.0 gap diagnosis | HIGH | Based on direct code inspection of all views |
| Worshipful vs generic distinction | MEDIUM | Knowledge of Planning Center, ProPresenter, and ministry app aesthetics; no A/B test data |
| Complexity estimates | HIGH | All changes are CSS class updates + small Stimulus controllers; no new backends or APIs |
| Anti-feature reasoning | HIGH | Based on Importmap constraints (no npm icon packs), Turbo Streams behavior (avoid competing animations), and small-team scope |

---

*Research completed: 2026-03-15*
*Feeds: v1.1 Design milestone roadmap*
