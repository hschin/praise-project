# Phase 6: Global Components - Context

**Gathered:** 2026-03-15
**Status:** Ready for planning

<domain>
## Phase Boundary

Polish flash messages, form inputs, and error feedback so every page in the app uses the warm palette consistently. Covers: flash toast system (new Stimulus controller), Devise error display, and error copy improvements for import/export/form flows.

Does NOT include: empty states (Phase 7), deck editor polish (Phase 8), auth page brand treatment (Phase 7).

</domain>

<decisions>
## Implementation Decisions

### Flash message behavior

- **Position**: Fixed top-right toast — floats in the corner, does not shift page content
- **Success/notice**: Auto-dismisses after ~4 seconds
- **Error/alert**: Stays visible until user manually dismisses with an X button
- **Animation**: Fade + slide in from right using CSS transitions only — no animation library
- **Implementation**: New Stimulus controller (`flash_controller.js`) handles auto-dismiss timer and X button click

### Flash message icon design

- **Icon set**: Heroicons inline SVG (established pattern — no npm, copy SVG inline)
  - Success: `check-circle` icon
  - Error: `exclamation-triangle` icon
- **Colors**: Semantic — green for success, red for error
  - Success: `green-50` bg, `green-700` text/icon
  - Error: `red-50` bg, `red-700` text/icon
- **Types**: Two only — `notice` (success) and `alert` (error). No neutral/info type.

### Devise error messages

- **Auth failures** (wrong password, unconfirmed email): Devise already routes these as `alert` flash — they flow through the new toast system automatically. No change needed to controller.
- **Registration model errors** (password too short, email taken): Styled inline error block on the registration form — `red-50` bg, `red-700` text, same pattern as `decks/_form.html.erb` and `songs/_form.html.erb`.
- **`devise/shared/_error_messages.html.erb`**: Remove entirely. Auth errors go through toast; registration errors get inline block treatment directly in the registration view.

### Error copy specificity (FORM-03)

- **Export failure** (`_export_button.html.erb` `:error` state): Copy → "Export failed — click to try again." Points user to the Re-export button already present in that state.
  - Update `GeneratePptxJob#broadcast_error` calls to use this copy consistently.
- **Import failure** (`songs/_failed.html.erb`): Include song title in the message → "Couldn't find lyrics for \"[Title]\". Try pasting them manually below."
- **Theme and song save errors**: Ensure inline form error blocks (already styled) display actionable copy — not just bare Rails field names. Example: "Title can't be blank — please enter a title before saving."
  - Claude's discretion on exact copy for each form's error states.

### Claude's Discretion

- Exact CSS transition values for the toast slide-in animation
- Toast z-index and stacking behavior
- Exact wording for theme/song save validation errors
- Whether to use a `data-controller="flash"` wrapper in the layout or a dedicated toast partial

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets

- `app/views/layouts/application.html.erb:49-54` — current flash block (two bare divs). Replace with toast partial + Stimulus controller target.
- `app/views/decks/_form.html.erb` and `app/views/songs/_form.html.erb` — already have styled inline error blocks (`red-50 border-red-200 text-red-700 rounded-lg p-3`). Use as the reference pattern for registration form errors.
- `app/javascript/controllers/inline_edit_controller.js` — example of an existing Stimulus controller using `eagerLoadControllersFrom` auto-discovery. New `flash_controller.js` follows the same pattern.
- `app/views/decks/_export_button.html.erb:22-27` — `:error` state renders `error_message` as `text-xs text-red-500`. Needs copy update + styling uplift.
- `app/views/songs/_failed.html.erb` — import failure partial with existing copy to update.
- `app/jobs/generate_pptx_job.rb:20,26,44` — three `broadcast_error` call sites where copy needs updating.

### Established Patterns

- Stimulus controllers: `app/javascript/controllers/` — auto-discovered via `eagerLoadControllersFrom`. New `flash_controller.js` drops in here with no manual registration.
- Heroicons inline SVG: per REQUIREMENTS.md out-of-scope note ("use inline Heroicons SVG"). Copy SVG path directly into ERB.
- Form error blocks: `red-50 border border-red-200 text-red-700 text-sm rounded-lg p-3` — already consistent across deck and song forms.
- Primary action color: `rose-700` (established in Phase 5; X close button should use `text-stone-400 hover:text-stone-600` to not compete).

### Integration Points

- `app/views/layouts/application.html.erb` — the flash block is the primary integration point for the new toast system. The Turbo `data-turbo-permanent` attribute may be needed on the toast container to survive Turbo Drive navigations.
- `app/views/devise/registrations/new.html.erb` — add inline error block here (currently uses the bare `_error_messages` partial).
- `app/views/devise/registrations/edit.html.erb` — same inline error block treatment.
- **DOM contract**: `export_button_#{deck.id}` target ID in `_export_button.html.erb` must not change — it's a Turbo Stream target.

</code_context>

<specifics>
## Specific Ideas

- Toast position: fixed top-right — user explicitly chose this over the current inline-below-nav position.
- Errors stay until manually closed: user wants error messages to persist so they aren't missed if the user looks away.
- "Export failed — click to try again" — user chose the simpler, action-pointing copy over a diagnostic message.
- Import copy should include the song title: "Couldn't find lyrics for \"[Title]\"." — more personal and scannable.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within Phase 6 scope.

</deferred>

---

*Phase: 06-global-components*
*Context gathered: 2026-03-15*
