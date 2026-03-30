# S01: Toast Redesign & Drag-and-Drop Fixes

**Goal:** Match Stitch toast design; fix section drag interference between song-order and sortable controllers
**Demo:** After this: Drag a section to reorder → reload → order persists. Trigger a flash message → see white card toast.

## Tasks
- [x] **T01: Flash toast redesigned to match Stitch — white card, icon badge, Newsreader title, accent bar** — Rewrite _flash_toast.html.erb with white card, circular icon badge, Newsreader serif title, accent bar. Update tests.
  - Estimate: 20m
  - Files: app/views/shared/_flash_toast.html.erb, test/controllers/decks_controller_test.rb
  - Verify: bin/rails test && echo PASS
- [x] **T02: Fixed section drag broken by native drag interference from song-order controller** — song_order_controller._onPointerdown was calling closest('[data-id]') and hitting nested slide items, setting draggable=false on them. sortable_controller used native drag events which respect draggable attribute. Fix both.
  - Estimate: 30m
  - Files: app/javascript/controllers/song_order_controller.js, app/javascript/controllers/sortable_controller.js
  - Verify: bin/rails test && echo PASS
