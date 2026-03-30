---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T01: Import status page polish

Rewrite processing.html.erb and _processing.html.erb with step indicators, progress bar, contextual labels. broadcast_done sends done step before redirect div.

## Inputs

- None specified.

## Expected Output

- `app/views/songs/processing.html.erb`
- `app/views/songs/_processing.html.erb`

## Verification

bin/rails test && echo PASS
