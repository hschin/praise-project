# T04: 06-global-components 04

**Slice:** S06 — **Milestone:** M001

## Description

Restyle the three remaining bare-scaffold Devise views (passwords/edit, unlocks/new, confirmations/new) to use the warm stone/rose palette, replace the _error_messages partial render in passwords/new with an inline error block, then delete the now-unreferenced _error_messages.html.erb partial.

Purpose: Gap closure for FORM-01 — "all inputs, labels, buttons, and focus states across ALL pages use consistent warm palette styles." The verification report identified these four views as the only remaining FORM-01 blockers. Fixing them also unblocks deletion of the _error_messages partial (Gap 2 from VERIFICATION.md).
Output: Four Devise views fully styled matching registrations/new.html.erb pattern; _error_messages partial deleted; grep returns zero references.

## Must-Haves

- [ ] "All four remaining Devise views (passwords/edit, passwords/new, unlocks/new, confirmations/new) render with warm stone/rose palette — no bare scaffold HTML (div.field, div.actions, bare h2) remains"
- [ ] "app/views/devise/shared/_error_messages.html.erb is deleted — zero references to devise/shared/error_messages exist anywhere in app/views/"
- [ ] "passwords/new.html.erb displays inline styled error block (red-50 bg, red-700 text) matching registration form pattern — not the bare Devise h2+ul partial"

## Files

- `app/views/devise/passwords/edit.html.erb`
- `app/views/devise/passwords/new.html.erb`
- `app/views/devise/unlocks/new.html.erb`
- `app/views/devise/confirmations/new.html.erb`
- `app/views/devise/shared/_error_messages.html.erb`
