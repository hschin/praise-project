# S06: Global Components

**Goal:** Build the flash toast system: a Stimulus controller, a toast partial with Heroicons SVG icons, and the layout integration.
**Demo:** Build the flash toast system: a Stimulus controller, a toast partial with Heroicons SVG icons, and the layout integration.

## Must-Haves


## Tasks

- [x] **T01: 06-global-components 01** `est:3min`
  - Build the flash toast system: a Stimulus controller, a toast partial with Heroicons SVG icons, and the layout integration. Replaces the two bare inline flash divs with a fixed top-right toast that animates in/out via CSS transitions.

Purpose: FORM-02 — Flash messages display as rounded cards with a semantic icon and auto-dismiss after a few seconds.
Output: flash_controller.js, shared/_flash_toast.html.erb, updated application.html.erb layout.
- [x] **T02: 06-global-components 02** `est:10min`
  - Restyle the Devise account edit page (bare scaffold) to match the warm palette established in Phase 5, and replace the bare `_error_messages` partial in both registration views with the inline error block pattern already used by deck and song forms.

Purpose: FORM-01 — All inputs, labels, buttons, and focus states across ALL pages use consistent warm palette styles. The account edit page is the only remaining unstyled form.
Output: edit.html.erb fully restyled, new.html.erb updated with inline errors, _error_messages.html.erb deleted.
- [x] **T03: 06-global-components 03** `est:12min`
  - Update error copy strings across three surfaces: the PPTX export job (three broadcast_error call sites), the export button error state partial, and the import failed partial. Replaces generic/inconsistent error messages with specific, actionable copy per the locked user decisions.

Purpose: FORM-03 — Import and export error messages include a clear description of what went wrong and a specific next step.
Output: Updated generate_pptx_job.rb, _export_button.html.erb, _failed.html.erb.
- [x] **T04: 06-global-components 04** `est:2min`
  - Restyle the three remaining bare-scaffold Devise views (passwords/edit, unlocks/new, confirmations/new) to use the warm stone/rose palette, replace the _error_messages partial render in passwords/new with an inline error block, then delete the now-unreferenced _error_messages.html.erb partial.

Purpose: Gap closure for FORM-01 — "all inputs, labels, buttons, and focus states across ALL pages use consistent warm palette styles." The verification report identified these four views as the only remaining FORM-01 blockers. Fixing them also unblocks deletion of the _error_messages partial (Gap 2 from VERIFICATION.md).
Output: Four Devise views fully styled matching registrations/new.html.erb pattern; _error_messages partial deleted; grep returns zero references.

## Files Likely Touched

- `test/controllers/decks_controller_test.rb`
- `app/javascript/controllers/flash_controller.js`
- `app/views/shared/_flash_toast.html.erb`
- `app/views/layouts/application.html.erb`
- `test/controllers/registrations_controller_test.rb`
- `app/views/devise/registrations/edit.html.erb`
- `app/views/devise/registrations/new.html.erb`
- `app/views/devise/shared/_error_messages.html.erb`
- `test/controllers/songs_controller_test.rb`
- `app/jobs/generate_pptx_job.rb`
- `app/views/decks/_export_button.html.erb`
- `app/views/songs/_failed.html.erb`
- `app/views/devise/passwords/edit.html.erb`
- `app/views/devise/passwords/new.html.erb`
- `app/views/devise/unlocks/new.html.erb`
- `app/views/devise/confirmations/new.html.erb`
- `app/views/devise/shared/_error_messages.html.erb`
