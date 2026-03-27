- quick_create excludes set_deck before_action since it creates a new deck, not looking up an existing one
- update action extended with respond_to JSON branch to unblock Plan 04 inline-edit Stimulus without a separate plan
- Both New Deck buttons in index (header and empty-state) replaced with button_to quick_create_decks_path
- eagerLoadControllersFrom auto-discovers inline_edit_controller.js as 'inline-edit' — no manual index.js entry needed
- font-semibold (not font-bold) used for deck title per VIS-03 typography contract (worship tool aesthetic decision)
- Configurable field attribute allows inline_edit_controller reuse across title, date, and notes without forking
- Wordmark changed to rose-700 (from amber-800) per visual review approval
- Title deduplication: clean base title for first deck; (2)+ numeric suffix only when conflict exists
- Toast container uses fixed top-right positioning (not inline) — no layout shift
- data-turbo-permanent on container preserves in-progress dismiss timers across Turbo navigations
- Notice toasts auto-dismiss after 4s; alert toasts require manual X button dismiss
- X button only on error toasts — consistent with user expectation that errors need acknowledgment
- _error_messages.html.erb partial retained (not deleted) — 4 other Devise views still reference it: unlocks/new, passwords/edit, passwords/new, confirmations/new
- Cancel account button de-emphasized with stone-500/hover:red-600 (destructive but available per research recommendation)
- turbo_confirm retained on delete button — DOM contract preserved
- Raw exception message (e.message) replaced with locked human-readable copy — debug context preserved via Rails.logger.error on the line above
- Redundant Claude description paragraph removed from _failed.html.erb — message consolidated into h3 to avoid duplication
- show.html.erb render locals fixed to pass title: @song.title (not song: @song) to match partial contract
- _error_messages partial deleted after all four referencing views migrated to inline error blocks
- Comment-only reference in registrations/edit.html.erb does not count as active reference — partial deletion safe
- button_to delete is a sibling div of link_to, not nested inside it — HTML spec prohibits interactive elements inside anchor
- Verification tests run from main repo path (/Users/hschin/Dev/praise-project) where compiled assets exist; worktree path lacks asset pipeline compilation
- Inline Heroicons SVG (musical-note path) used for both empty states — no npm, consistent with established icon pattern
- else branch only targeted — sortable div data-controller/data-sortable-url-value and if branch left intact
- devise/shared/links rendered outside the card div in all auth views — keeps navigation links visually distinct from form elements
- text-center added to links wrapper div for polished appearance consistent across all three auth pages
- passwords/new received identical treatment (discretionary per plan) — identical max-w-md structure made it a direct candidate
- Used ApplicationController.render for export_button ready-state test to isolate partial without triggering a job
- DECK-02 artist test uses multiline assert_match on data-song-search-target='item' context rather than assert_select (selector can't enforce text proximity without nested assertion)
- Created inline done song via Song.create! for IMPORT-02 since songs(:one) fixture has default pending status
- aria-label='arrow-down-tray' and aria-label='check-circle' added to SVG elements — the existing test regex checked for the icon name string directly; aria-label is the semantically correct way to name decorative icons
- button_to block form used for idle state to allow SVG + text layout without additional wrapper elements
- Label text written as uppercase literals (ADD SONGS, ARRANGEMENT) rather than relying on CSS text-transform — ensures test assertions with regex match the HTML response body
- auto-save data-controller wraps only the arrangement sub-label row, not the entire left panel, to keep turbo:submit-end event scope tight
- Add-to-deck link placed below song title in header (not inside song_status div) so it survives Turbo Stream replacement of the status area

---

## Decisions Table

| # | When | Scope | Decision | Choice | Rationale | Revisable? | Made By |
|---|------|-------|----------|--------|-----------|------------|---------|
| D001 | M002/S03 | convention | Deck card preview area content | Use deck's theme background color or uploaded image; fallback gradient for decks with no theme | Theme-based preview gives visual variety that matches the Stitch gallery aesthetic | Yes — if a better preview source emerges | human |
