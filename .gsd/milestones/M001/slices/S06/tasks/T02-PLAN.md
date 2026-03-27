# T02: 06-global-components 02

**Slice:** S06 — **Milestone:** M001

## Description

Restyle the Devise account edit page (bare scaffold) to match the warm palette established in Phase 5, and replace the bare `_error_messages` partial in both registration views with the inline error block pattern already used by deck and song forms.

Purpose: FORM-01 — All inputs, labels, buttons, and focus states across ALL pages use consistent warm palette styles. The account edit page is the only remaining unstyled form.
Output: edit.html.erb fully restyled, new.html.erb updated with inline errors, _error_messages.html.erb deleted.

## Must-Haves

- [ ] "The account edit page (GET /users/edit) renders with warm palette inputs — stone borders, rose-600 focus rings, rose-700 submit button — identical to the registration new page"
- [ ] "Registration and account edit forms display inline styled error blocks (red-50 bg, red-700 text) when validation fails — not the bare Devise h2+ul scaffold"
- [ ] "No reference to devise/shared/_error_messages exists in any view — the partial is deleted and both consuming views are updated"

## Files

- `test/controllers/registrations_controller_test.rb`
- `app/views/devise/registrations/edit.html.erb`
- `app/views/devise/registrations/new.html.erb`
- `app/views/devise/shared/_error_messages.html.erb`
