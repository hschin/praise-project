# T04: 07-content-pages 04

**Slice:** S07 — **Milestone:** M001

## Description

Apply brand treatment to the Devise auth pages: replace font-bold with font-serif text-rose-700 on the wordmark heading, and wrap each form in a white card matching the established card pattern.

Purpose: AUTH-01 — auth pages feel like the product (warm palette, brand wordmark) rather than a generic Devise scaffold.
Output: Updated sessions/new.html.erb, registrations/new.html.erb, and passwords/new.html.erb.

## Must-Haves

- [ ] "The sign-in page shows the Praise Project wordmark in font-serif text-rose-700, matching the nav wordmark"
- [ ] "The sign-in form is visually contained in a white card with rounded-xl border on a stone-50 background"
- [ ] "The sign-up page has the same wordmark and card treatment as sign-in"
- [ ] "The shared links (Forgot password? / Sign up) appear below the card, not inside it"
- [ ] "The passwords/new page receives the same card treatment for visual consistency (Claude's discretion)"

## Files

- `app/views/devise/sessions/new.html.erb`
- `app/views/devise/registrations/new.html.erb`
- `app/views/devise/passwords/new.html.erb`
