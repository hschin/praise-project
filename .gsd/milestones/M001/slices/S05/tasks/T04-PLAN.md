# T04: 05-design-foundation 04

**Slice:** S05 — **Milestone:** M001

## Description

Create the Stimulus inline-edit controller and wire it into the deck editor header so users can click a pencil icon to rename the deck title in-place without leaving the page.

Purpose: NAV-04 — The deck title created by quick_create needs to be immediately editable from the editor. The inline-edit affordance (pencil icon on hover) is the UX contract that makes this feel seamless.
Output: inline_edit_controller.js, registration in index.js, updated deck show header.

## Must-Haves

- [ ] "The deck editor header shows the deck title as readable text with a pencil icon that appears on hover"
- [ ] "Clicking the pencil icon reveals an inline input field pre-filled with the current title"
- [ ] "Editing the title and pressing Enter or blurring the input PATCHes the new title to the server and updates the display without a full page reload"
- [ ] "Pressing Escape cancels the edit and restores the original title display"
- [ ] "The inline-edit header uses the VIS-03 typography scale (text-2xl font-semibold leading-snug)"

## Files

- `app/javascript/controllers/inline_edit_controller.js`
- `app/javascript/controllers/index.js`
- `app/views/decks/show.html.erb`
