# T01: 06-global-components 01

**Slice:** S06 — **Milestone:** M001

## Description

Build the flash toast system: a Stimulus controller, a toast partial with Heroicons SVG icons, and the layout integration. Replaces the two bare inline flash divs with a fixed top-right toast that animates in/out via CSS transitions.

Purpose: FORM-02 — Flash messages display as rounded cards with a semantic icon and auto-dismiss after a few seconds.
Output: flash_controller.js, shared/_flash_toast.html.erb, updated application.html.erb layout.

## Must-Haves

- [ ] "A flash notice (success) renders as a fixed top-right card with green-50 background and auto-dismisses after ~4 seconds"
- [ ] "A flash alert (error) renders as a fixed top-right card with red-50 background and stays visible until the user clicks the X button"
- [ ] "The toast container survives Turbo Drive navigations — in-progress dismiss timers are not interrupted"
- [ ] "The toast entry animation slides in from the right with a fade — implemented via CSS transitions, no animation library"

## Files

- `test/controllers/decks_controller_test.rb`
- `app/javascript/controllers/flash_controller.js`
- `app/views/shared/_flash_toast.html.erb`
- `app/views/layouts/application.html.erb`
