# Phase 1: Auth + Foundation - Context

**Gathered:** 2026-03-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Ship a working, styled authentication flow (sign-in, sign-up, password reset) under the "Praise Project" brand, with a consistent app nav shell that persists across all authenticated pages. The core data schema is already in place from the existing codebase. This phase delivers the foundation every subsequent phase builds on.

</domain>

<decisions>
## Implementation Decisions

### Sign-up Policy
- Open signup — anyone with the URL can register
- Email + password only (no name field on registration)
- No invite flow needed for v1

### Auth Page Branding
- App name: **Praise Project** (English)
- Layout: Clean centered card — app name above the form, nothing else
- Form labels and buttons: English only
- No logo, no split layout, no tagline

### App Navigation
- Top navigation bar (not sidebar)
- Layout: "Praise Project" (app name/home link) on the left | Decks | Songs | [user email] | Logout on the right
- All authenticated pages share this nav
- No nav shown on auth pages (sign-in, sign-up, password reset)

### Empty States
- Decks index (no decks): "No decks yet. Create your first deck." + prominent "New Deck" button
- Songs index (no songs): "No songs yet. Search for a song to get started." + search bar
- Simple message + action — no guided onboarding steps

### Claude's Discretion
- Exact Tailwind styling details (colors, spacing, shadows within the established indigo/gray palette)
- Flash message placement and styling
- Mobile responsiveness level
- Solid Queue smoke test implementation details

</decisions>

<specifics>
## Specific Ideas

- App name is "Praise Project" — use this consistently in the nav, auth pages, and page titles
- Existing Tailwind conventions: indigo-600 for primary actions, gray palette for secondary, consistent button classes already in CONVENTIONS.md

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- Devise views already exist in `app/views/devise/` (sessions, registrations, passwords, confirmations) — need Tailwind styling applied, not rebuilt from scratch
- `ApplicationController#after_sign_in_path_for` already routes to `decks_path` after login
- `before_action :authenticate_user!` pattern established in DecksController — extend to SongsController

### Established Patterns
- Tailwind button style: `"bg-indigo-600 text-white text-sm px-4 py-2 rounded hover:bg-indigo-700"`
- Form fields: `"w-full border border-gray-300 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"`
- Flash: `:notice` (green/success), `:alert` (red/failure) — rendered in `layouts/application.html.erb`
- Container: `max-w-5xl mx-auto px-6 py-8` in `<main>`

### Integration Points
- `app/views/layouts/application.html.erb` — add nav bar here; already renders flash messages
- `app/views/devise/sessions/new.html.erb` — primary auth page to style
- `app/views/devise/registrations/new.html.erb` — sign-up page to style
- `app/views/devise/passwords/new.html.erb` — password reset page to style
- `config/routes.rb` — already has `devise_for :users` and `root "decks#index"`
- `bin/jobs` — already in Procfile.dev for Solid Queue worker

### Schema Status
- All tables exist and are complete: users, decks, deck_songs, songs, lyrics, slides
- Devise columns fully present: encrypted_password, reset_password_token, remember_created_at
- No schema changes needed in Phase 1 — foundation is already laid

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 01-auth-foundation*
*Context gathered: 2026-03-08*
