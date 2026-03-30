---
estimated_steps: 1
estimated_files: 2
skills_used: []
---

# T02: Fix section drag-and-drop broken by native drag interference

song_order_controller._onPointerdown was calling closest('[data-id]') and hitting nested slide items, setting draggable=false on them. sortable_controller used native drag events which respect draggable attribute. Fix both.

## Inputs

- None specified.

## Expected Output

- `app/javascript/controllers/song_order_controller.js`
- `app/javascript/controllers/sortable_controller.js`

## Verification

bin/rails test && echo PASS
