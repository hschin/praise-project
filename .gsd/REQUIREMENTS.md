# Requirements

This file is the explicit capability and coverage contract for the project.

## Active

### R001 — Sanctuary Stone color token system replaces all stone/rose utility classes
- Class: core-capability
- Status: active
- Description: The full Sanctuary Stone color palette (surface, surface-container-low, surface-container-highest, on-surface, primary #93000b, tertiary #00497f, etc.) is defined as Tailwind v4 @theme tokens and used throughout all views. No raw stone-*/rose-* utility classes remain for structural styling.
- Why it matters: The entire visual identity depends on consistent token usage — mixing old and new colors creates a jarring experience.
- Source: user
- Primary owning slice: M002/S01
- Supporting slices: M002/S02, M002/S03, M002/S04, M002/S05
- Validation: unmapped
- Notes: Tokens defined in app/assets/tailwind/application.css via @theme directive

### R002 — Newsreader + Inter typography replaces Playfair Display throughout
- Class: core-capability
- Status: active
- Description: Newsreader (serif) is used for headlines, logos, and editorial moments. Inter (sans-serif) is used for body text, labels, and UI elements. Playfair Display is fully removed.
- Why it matters: Typography is the most visible element of the editorial identity — inconsistent fonts break the "Liturgical Canvas" aesthetic.
- Source: user
- Primary owning slice: M002/S01
- Supporting slices: M002/S02, M002/S03, M002/S04, M002/S05
- Validation: unmapped
- Notes: Both fonts loaded from Google Fonts CDN

### R003 — Google Material Symbols web font replaces inline Heroicon SVGs
- Class: core-capability
- Status: active
- Description: All inline Heroicon SVGs in views are replaced with Google Material Symbols Outlined web font icons. The Material Symbols stylesheet is loaded in the application layout.
- Why it matters: Consistent icon language across all screens; matches the Stitch designs exactly.
- Source: user
- Primary owning slice: M002/S01
- Supporting slices: M002/S02, M002/S03, M002/S04, M002/S05
- Validation: unmapped
- Notes: Uses material-symbols-outlined class with data-icon attributes

### R004 — No-line rule: no 1px solid borders for sectioning; depth via tonal layering
- Class: core-capability
- Status: active
- Description: Structural boundaries are defined solely through background color shifts (surface token hierarchy) and negative space. 1px solid borders are strictly prohibited for sectioning. Ghost borders (outline-variant at 20% opacity) are permitted for accessibility when needed.
- Why it matters: The "No-Line Rule" is the signature aesthetic principle of the Sanctuary Stone design system — violating it breaks the premium editorial feel.
- Source: user
- Primary owning slice: M002/S02
- Supporting slices: M002/S03, M002/S04, M002/S05
- Validation: unmapped
- Notes: ~70 border references across 23 ERB files need migration

### R005 — Gradient CTA buttons on main actions
- Class: core-capability
- Status: active
- Description: Primary call-to-action buttons use a linear gradient from primary (#93000b) to primary-container (#b91c1c) with on-primary (#ffffff) text. Hover shifts to primary-container. Active state uses scale-[0.98].
- Why it matters: The gradient CTA adds "soul" to the button that a flat color cannot — it's a deliberate design decision from the DESIGN.md.
- Source: user
- Primary owning slice: M002/S02
- Supporting slices: M002/S03, M002/S04, M002/S05
- Validation: unmapped
- Notes: Applies to Sign In, New Deck, Import, Export, Apply Theme, Get AI Suggestions

### R006 — Auth views match Stitch login design
- Class: core-capability
- Status: active
- Description: All Devise views (sign in, sign up, forgot password, reset password, account settings) use the Sanctuary Stone auth treatment: centered card on surface background, atmospheric blur blobs, bottom-line inputs (no boxed borders), gradient submit button, "Digital Liturgy" tagline footer.
- Why it matters: Auth is the first touchpoint — it must set the tone for the entire app.
- Source: user
- Primary owning slice: M002/S02
- Supporting slices: none
- Validation: unmapped
- Notes: Stitch only designed login; other auth views extrapolate from the same pattern

### R007 — Decks index shows deck cards with 16:9 theme-based preview area
- Class: core-capability
- Status: active
- Description: Each deck card on the index page displays a 16:9 preview area showing the deck's theme background color or uploaded background image, with a fallback gradient for decks without themes. Cards use Newsreader serif titles, song count badge, hover-reveal delete button.
- Why it matters: The preview area gives the deck index a visual, gallery-like quality matching the Stitch design — plain text cards feel utilitarian.
- Source: user
- Primary owning slice: M002/S03
- Supporting slices: none
- Validation: unmapped
- Notes: Fallback gradient for decks with no theme applied

### R008 — Song library matches Stitch design
- Class: core-capability
- Status: active
- Description: Song library page uses Newsreader serif "Song Library" headline, unified search panel on surface-container-low background, song list rows with lyric preview snippets in italic, "Added X ago" timestamps, collapsible "Paste lyrics manually" section, and scriptural footer quote.
- Why it matters: The song library is a frequently used page — it must feel like the editorial sanctuary, not a data table.
- Source: user
- Primary owning slice: M002/S04
- Supporting slices: none
- Validation: unmapped
- Notes: Unified search merges current library filter + import into one input

### R009 — Deck editor uses Sanctuary Stone tokens with redesigned theme panel
- Class: core-capability
- Status: active
- Description: The 3-column deck editor uses Sanctuary Stone tokens throughout. Theme panel has Solid Color/Image segmented toggle, color circle swatches for background and text colors, font size dropdown, gradient "Get AI Suggestions" button. Arrangement panel uses tonal layering with drag handles and repeat badges. Slide previews have numbered badges.
- Why it matters: The deck editor is where users spend the most time — it's the core creative workspace and must embody the Sanctuary Stone identity.
- Source: user
- Primary owning slice: M002/S05
- Supporting slices: none
- Validation: unmapped
- Notes: Must preserve all existing Stimulus controller behavior (inline_edit, sortable, song_search, color_picker, auto_save)

### R010 — Navigation bar matches Stitch design
- Class: core-capability
- Status: active
- Description: Top navigation uses Newsreader italic wordmark, active page indicated by primary-colored text with bottom border, Material Symbols mail icon, gradient "New Deck" button, user avatar placeholder, and frosted glass effect (backdrop-blur).
- Why it matters: The nav is on every authenticated page — it's the most repeated UI element.
- Source: user
- Primary owning slice: M002/S01
- Supporting slices: none
- Validation: unmapped
- Notes: No sidebar — navigation stays horizontal top bar only

### R011 — Ambient shadows only, frosted glass nav
- Class: core-capability
- Status: active
- Description: Drop shadows use 0 10px 40px rgba(31,27,23,0.06) — a 6% opacity tint of on-surface, not pure black. Standard CSS box shadows are prohibited. Nav uses semi-transparent surface with 12px backdrop-blur for frosted glass effect.
- Why it matters: Shadow quality is a major factor in the premium feel — cheap shadows break the Sanctuary Stone aesthetic.
- Source: user
- Primary owning slice: M002/S01
- Supporting slices: M002/S02, M002/S03, M002/S04, M002/S05
- Validation: unmapped
- Notes: DESIGN.md specifies exact shadow values

### R012 — All flash messages, error states, and processing screens use Sanctuary Stone tokens
- Class: core-capability
- Status: active
- Description: Flash toast messages, auth error displays, song processing/failed states, and empty states all use Sanctuary Stone color tokens and typography. No raw stone/rose classes remain in these components.
- Why it matters: Transient states (loading, errors, toasts) are easy to miss during a reskin — inconsistency here is jarring.
- Source: inferred
- Primary owning slice: M002/S03
- Supporting slices: M002/S04
- Validation: unmapped
- Notes: Includes shared/_flash_toast, shared/_auth_errors, songs/_processing, songs/_failed

## Deferred

### R013 — Left sidebar navigation (Library/Recent/Collections/Drafts)
- Class: core-capability
- Status: deferred
- Description: A left sidebar with Library, Recent, Collections, and Drafts navigation items as shown in the Stitch designs.
- Why it matters: Provides a richer navigation model for managing a growing repertoire.
- Source: user
- Primary owning slice: none
- Supporting slices: none
- Validation: unmapped
- Notes: User explicitly skipped — Collections/Drafts/Recent are not real features yet

### R014 — Grid/List view toggle on decks index
- Class: core-capability
- Status: deferred
- Description: A toggle between grid and list views for the decks index page.
- Why it matters: Alternative view modes for users with many decks.
- Source: user
- Primary owning slice: none
- Supporting slices: none
- Validation: unmapped
- Notes: User explicitly skipped for this milestone

### R015 — Global Slide Master and Manage Transitions in deck editor
- Class: core-capability
- Status: deferred
- Description: Global Slide Master and Manage Transitions action buttons in the deck editor theme panel.
- Why it matters: Advanced presentation control features for the future.
- Source: user
- Primary owning slice: none
- Supporting slices: none
- Validation: unmapped
- Notes: User explicitly skipped — features not implemented yet

## Out of Scope

None for this milestone.

## Traceability

| ID | Class | Status | Primary owner | Supporting | Proof |
|---|---|---|---|---|---|
| R001 | core-capability | active | M002/S01 | M002/S02-S05 | unmapped |
| R002 | core-capability | active | M002/S01 | M002/S02-S05 | unmapped |
| R003 | core-capability | active | M002/S01 | M002/S02-S05 | unmapped |
| R004 | core-capability | active | M002/S02 | M002/S03-S05 | unmapped |
| R005 | core-capability | active | M002/S02 | M002/S03-S05 | unmapped |
| R006 | core-capability | active | M002/S02 | none | unmapped |
| R007 | core-capability | active | M002/S03 | none | unmapped |
| R008 | core-capability | active | M002/S04 | none | unmapped |
| R009 | core-capability | active | M002/S05 | none | unmapped |
| R010 | core-capability | active | M002/S01 | none | unmapped |
| R011 | core-capability | active | M002/S01 | M002/S02-S05 | unmapped |
| R012 | core-capability | active | M002/S03 | M002/S04 | unmapped |
| R013 | core-capability | deferred | none | none | unmapped |
| R014 | core-capability | deferred | none | none | unmapped |
| R015 | core-capability | deferred | none | none | unmapped |

## Coverage Summary

- Active requirements: 12
- Mapped to slices: 12
- Validated: 0
- Unmapped active requirements: 0
