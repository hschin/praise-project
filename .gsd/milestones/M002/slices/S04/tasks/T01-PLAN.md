---
estimated_steps: 1
estimated_files: 8
skills_used: []
---

# T01: Reskin all song views with editorial search panel, lyric preview rows, and Sanctuary Stone tokens

Reskin songs/index, songs/show, songs/edit, songs/_form, songs/_lyrics, songs/_processing, songs/processing, songs/_failed. Unified search panel (search + import on no-match). Editorial rows with lyric snippets. Delivered as part of single M002 commit.

## Inputs

- `app/assets/tailwind/application.css`

## Expected Output

- `All song views reskinned with Sanctuary Stone tokens`

## Verification

bin/rails test && echo PASS
