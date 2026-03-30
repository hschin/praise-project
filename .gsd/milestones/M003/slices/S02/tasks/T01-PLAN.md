---
estimated_steps: 1
estimated_files: 5
skills_used: []
---

# T01: AI suggestions polish — dotenv, song-aware prompts, vertical cards, images throughout

Add dotenv-rails gem so .env keys load in development. Add song context to ClaudeThemeService prompt. Switch suggestion cards to vertical layout with full-width images. Show background image in applied theme card and theme form. Fall back to unsplash_url in slide preview. Clear unsplash_url on Remove.

## Inputs

- None specified.

## Expected Output

- `Gemfile`
- `app/services/claude_theme_service.rb`
- `app/views/themes/_suggestion_row.html.erb`
- `app/views/themes/_suggestion_card.html.erb`
- `app/views/themes/_applied_theme.html.erb`
- `app/views/themes/_form.html.erb`
- `app/views/decks/_slide_preview.html.erb`
- `app/controllers/themes_controller.rb`

## Verification

bin/rails test && echo PASS
