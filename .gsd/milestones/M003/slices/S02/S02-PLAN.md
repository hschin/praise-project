# S02: AI Theme Suggestions Polish

**Goal:** Song-aware AI theme suggestions, vertical card layout, background images visible throughout theme panel and slide preview, dotenv fix
**Demo:** After this: Get AI Suggestions → 5 vertical cards with Unsplash photos named after song themes. Apply one → see photo in theme panel and slide preview.

## Tasks
- [x] **T01: AI suggestions now song-aware with vertical cards and background images visible throughout** — Add dotenv-rails gem so .env keys load in development. Add song context to ClaudeThemeService prompt. Switch suggestion cards to vertical layout with full-width images. Show background image in applied theme card and theme form. Fall back to unsplash_url in slide preview. Clear unsplash_url on Remove.
  - Estimate: 45m
  - Files: Gemfile, app/services/claude_theme_service.rb, app/views/themes/, app/views/decks/_slide_preview.html.erb, app/controllers/themes_controller.rb
  - Verify: bin/rails test && echo PASS
