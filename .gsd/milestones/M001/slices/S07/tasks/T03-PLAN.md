# T03: 07-content-pages 03

**Slice:** S07 — **Milestone:** M001

## Description

Replace the plain-text empty states in the deck editor arrangement panel and the song library with small icon + copy empty states.

Purpose: EMPTY-02 — deck editors know exactly where to look and what to do when a deck has no songs. EMPTY-03 — new users understand the import workflow without extra orientation.
Output: Targeted edits to two else branches in existing view files. No structural changes to the if branches.

## Must-Haves

- [ ] "A user opening a deck with no songs sees a small icon and the copy 'Your arrangement will appear here. Add a song from the left panel.'"
- [ ] "A user opening the song library with no songs sees the copy 'Import a song above to build your library.'"
- [ ] "The deck editor empty state is inside the sortable div's else branch — the drag-and-drop contract for the if branch is not touched"
- [ ] "The song library empty state replaces only the else branch text — the form and filter above remain unchanged"

## Files

- `app/views/decks/show.html.erb`
- `app/views/songs/index.html.erb`
