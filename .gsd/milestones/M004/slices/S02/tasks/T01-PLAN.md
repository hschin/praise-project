---
estimated_steps: 1
estimated_files: 1
skills_used: []
---

# T01: Preview respects show_pinyin and lines_per_slide

Update _slide_preview.html.erb to: (1) skip ruby annotation rendering when deck.show_pinyin is false, (2) chunk each lyric's content lines into groups of lines_per_slide and render each chunk as a separate slide card.

## Inputs

- `app/models/deck.rb`

## Expected Output

- `app/views/decks/_slide_preview.html.erb`

## Verification

bin/rails test && echo PASS
