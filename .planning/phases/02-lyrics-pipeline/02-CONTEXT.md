# Phase 2: Lyrics Pipeline - Context

**Gathered:** 2026-03-09
**Status:** Ready for planning

<domain>
## Phase Boundary

Users search for a worship song by title → background job fetches and structures Chinese lyrics with tone-marked pinyin via Claude → song saved to shared team library. Users can browse, search, and edit saved songs. Manual paste available as fallback when search fails.

</domain>

<decisions>
## Implementation Decisions

### Job Feedback & Loading UX
- After search submit: redirect to the song's show page in a "processing" state (not stay on index)
- Processing state shows progress steps: "Searching web → Fetching lyrics → Generating pinyin → Done"
- Job failure: show page displays a red error state with a "Try manual paste" link/button
- On success: brief green border (2 seconds) before settling into the normal song view

### Chinese + Pinyin Display
- Pinyin rendered ruby-style: above each Chinese character (not on a separate line)
- Pinyin toggle: show/hide button on the song view — pinyin on by default
- Sections stacked vertically, each with a labeled header (English: Verse 1, Chorus, Bridge, etc.)
- Chinese + pinyin always shown together when pinyin is toggled on — no read-only-without-pinyin mode

### Manual Paste Fallback
- Always visible as a secondary option on the search form (not hidden behind failure state)
- User pastes any format — Claude handles both raw and pre-labeled lyrics
- Same background job pipeline runs — just skips the search/scrape step
- If a song's import job already failed, pasting replaces that song's lyrics in place (no duplicate created)

### Library Browse & Editing
- Song card on index shows: title + first lyric line preview (not section count)
- Library search: the existing search bar on Songs index, searches by title (no separate search page)
- Editable fields: lyrics text, pinyin, and section labels — all three
- Edit view: standard separate edit page per song (not inline editing on show page)

### Claude's Discretion
- Exact Tailwind styling for the processing/error/success states on the song show page
- Progress step animation details (step indicators, transitions)
- How search-by-title filters results (client-side vs. server-side, debounce vs. on-submit)
- Pinyin toggle implementation (Stimulus controller, cookie vs. in-memory state)
- Edit form layout for lyrics sections with pinyin fields

</decisions>

<specifics>
## Specific Ideas

- Progress steps should make it clear to the user what's happening — the app does multiple things in the background (search, scrape, Claude call) and showing stages builds trust
- The pinyin toggle is important for the worship leader who wants to see how a slide looks without pinyin during review
- Song cards showing the first lyric line helps distinguish songs with similar or identical titles (common in Chinese worship music)

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Song` model (`app/models/song.rb`): exists with title, artist, default_key columns — ready to use
- `Lyric` model (`app/models/lyric.rb`): exists with section_type, position, content columns — already ordered by position
- `SongsController` (`app/controllers/songs_controller.rb`): full RESTful CRUD, `before_action :authenticate_user!` already in place
- `app/views/songs/`: existing index, show, new, edit, `_form` partial — to be extended, not rebuilt
- `ApplicationJob` (`app/jobs/application_job.rb`): Solid Queue base class, ready to subclass
- Turbo (Hotwire): available for Turbo Stream updates on the song show page
- Stimulus: available for pinyin toggle controller

### Established Patterns
- Background jobs: `NameJob < ApplicationJob`, enqueued with `perform_later` — confirmed working (Phase 1)
- Turbo Stream: Turbo Rails available; use `turbo_stream_from` on show page + `broadcast_replace_to` from job
- Flash messages: `:notice` (green), `:alert` (red) in layout — don't use for job status (use Turbo Stream instead)
- Button style: `"bg-indigo-600 text-white text-sm px-4 py-2 rounded hover:bg-indigo-700"`
- Form fields: `"w-full border border-gray-300 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"`
- Ownership: `Song` is shared (no user scoping) — `current_user.decks` pattern does NOT apply to songs

### Integration Points
- `app/views/songs/index.html.erb`: search form already present (from Phase 1 empty state) — needs to wire to job dispatch
- `config/routes.rb`: `resources :songs` already defined — may need a custom action for search dispatch
- `ANTHROPIC_API_KEY`: env var already referenced in stack; needs wiring in the import job
- `app/views/layouts/application.html.erb`: nav already has "Songs" link pointing to songs index

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 02-lyrics-pipeline*
*Context gathered: 2026-03-09*
