# Deferred Items — Phase 03 Deck Editor

## Pre-existing Test Failures (Out of Scope)

### 1. DecksControllerTest#test_deck_show_page_renders_slide_preview_divs_for_arrangement_entries
- **File:** test/controllers/decks_controller_test.rb:37
- **Status:** Pre-existing failure (confirmed via git stash check)
- **Reason:** The `.slide-preview` CSS class is not yet rendered in decks/show.html.erb
- **Scope:** SLIDE-04 requirement — belongs to a future plan

### 2. GenerateThemeSuggestionsJobTest#test_job_enqueues_without_error
- **File:** test/jobs/generate_theme_suggestions_job_test.rb:8
- **Status:** Pre-existing failure — job class does not yet exist
- **Reason:** GenerateThemeSuggestionsJob is a Plan 05 artifact (AI theme suggestions)
- **Scope:** Plan 05 — will be implemented there
