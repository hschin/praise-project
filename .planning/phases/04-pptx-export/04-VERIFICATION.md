---
phase: 04-pptx-export
verified: 2026-03-15T00:00:00Z
status: human_needed
score: 11/11 automated must-haves verified
human_verification:
  - test: "Open downloaded .pptx on Windows projector or Windows PowerPoint"
    expected: "Chinese characters render visibly (not empty rectangles or boxes)"
    why_human: "CJK font embedding can only be validated visually on Windows — macOS renders system fonts as fallback masking missing embedded fonts"
  - test: "Click Export PPTX on a deck with Chinese lyrics in a real browser"
    expected: "Button changes to Generating... immediately, then updates to Download link via Turbo Stream after job completes"
    why_human: "Real-time Turbo Stream behavior and Solid Queue worker interaction cannot be verified statically"
  - test: "Click Download .pptx, open the file in PowerPoint or Keynote"
    expected: "File opens without corruption, slides visible, theme background/text colors applied"
    why_human: "File integrity and color rendering must be confirmed visually with presentation software"
---

# Phase 4: PPTX Export Verification Report

**Phase Goal:** Users can download a complete, presentation-ready .pptx file that renders Chinese characters and pinyin correctly on any projector
**Verified:** 2026-03-15
**Status:** human_needed (all automated checks pass; 3 items need human confirmation)
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Python script accepts JSON payload from stdin and writes a .pptx to output path | VERIFIED | Smoke test passed: 1 slide generated, exit 0 |
| 2 | Generated .pptx has CJK font physically embedded in the archive | VERIFIED | `ppt/fonts/NotoSansSC-Regular.ttf` confirmed in ZIP namelist |
| 3 | Pinyin appears above Chinese text at smaller font size | VERIFIED | Para 0: pinyin at 22pt; Para 1: Chinese at 36pt (ratio 0.61) |
| 4 | Theme background color, text color, and font size applied per JSON | VERIFIED | Code paths confirmed; solid fill background, hex_to_rgb for text, FONT_SIZE_MAP lookup |
| 5 | Background image embedded if provided as base64 | VERIFIED | add_picture with decoded base64 bytes; temp file cleaned up |
| 6 | Script exits 0 on success, non-zero on failure | VERIFIED | Invalid output dir: `Exit: 1`; smoke test: exit 0 |
| 7 | Blank pinyin is omitted entirely | VERIFIED | Test with `pinyin=""`: only Chinese text present in output |
| 8 | East Asian font XML slot set on all runs (Windows CJK routing) | VERIFIED | `a:ea typeface="Noto Sans SC"` confirmed on both pinyin and Chinese runs |
| 9 | Export button changes to Generating... then Download link (Turbo Stream) | VERIFIED (automated) | Controller returns :generating Turbo Stream; job broadcasts :ready with token |
| 10 | .pptx served as download attachment (Content-Disposition: attachment) | VERIFIED | `send_file` with `disposition: "attachment"` in download_export action |
| 11 | User can re-export by clicking the button again | VERIFIED | :ready and :error states both render Export/Re-export button pointing to export_deck_path |

**Score:** 11/11 truths verified (automated); 3 items deferred to human

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/pptx_generator/generate.py` | PPTX generation entry point | VERIFIED | 207 lines, substantive; reads stdin, creates slides, embeds font, exits cleanly |
| `lib/pptx_generator/fonts/NotoSansSC-Regular.ttf` | CJK font bundled with script | VERIFIED | 16MB TTF; confirmed embedded in .pptx output via zipfile check |
| `lib/pptx_generator/requirements.txt` | python-pptx dependency declaration | VERIFIED | Contains `python-pptx==1.0.2` and `Pillow>=10.0.0` |
| `app/jobs/generate_pptx_job.rb` | Background job: build_payload, Open3 call, broadcast | VERIFIED | 87 lines; perform, build_payload, broadcast_error all implemented |
| `app/controllers/decks_controller.rb` | export + download_export actions | VERIFIED | Both actions implemented; before_action covers both |
| `app/views/decks/_export_button.html.erb` | Reusable partial with 4 states | VERIFIED | :idle, :generating, :ready, :error all handled; re-export present |
| `app/views/decks/show.html.erb` | turbo_stream_from export channel + partial render | VERIFIED | Line 14: render partial; line 151: turbo_stream_from deck_export |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `lib/pptx_generator/generate.py` | `lib/pptx_generator/fonts/NotoSansSC-Regular.ttf` | `zipfile` post-processing: font injected into `ppt/fonts/` | WIRED | `embed_cjk_font()` opens .pptx as ZIP, writes font binary, patches Content_Types.xml and presentation.xml.rels |
| stdin JSON | generate.py slide loop | `json.loads(sys.stdin.read())` | WIRED | Line 176: `payload = json.loads(sys.stdin.read())` confirmed |
| `app/controllers/decks_controller.rb#export` | GeneratePptxJob | `GeneratePptxJob.perform_later(@deck.id)` | WIRED | Line 43 of controller |
| `app/jobs/generate_pptx_job.rb` | `lib/pptx_generator/generate.py` | `Open3.capture3` subprocess with `stdin_data` | WIRED | Line 16: `Open3.capture3("python3", PYTHON_SCRIPT, stdin_data: payload.to_json)` (plan said capture2e; capture3 is equivalent/superset) |
| `app/jobs/generate_pptx_job.rb` | Turbo Stream `deck_export_{deck_id}` | `broadcast_update_to` with `_export_button` partial | WIRED | Lines 36-41 (success) and 80-85 (error) both broadcast to `deck_export_#{deck_id}` |
| `app/views/decks/show.html.erb` | `app/views/decks/_export_button.html.erb` | render partial, `turbo_stream_from` targeting `export_button_{deck.id}` | WIRED | Line 14: render partial; line 151: turbo_stream_from export channel |

### Requirements Coverage

| Requirement | Source Plans | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| EXPORT-01 | 04-01, 04-02, 04-03 | User can download a deck as a .pptx file with Chinese characters, pinyin, and theme applied | SATISFIED | Python script produces valid .pptx; font embedded; pinyin layout correct; theme colors applied |
| EXPORT-02 | 04-01, 04-02, 04-03 | PPTX generation runs as a background job with Generating... status; button becomes download link when ready | SATISFIED | GeneratePptxJob enqueued by controller; Turbo Stream state machine: :generating -> :ready/:error |
| EXPORT-03 | 04-02, 04-03 | User can re-export a deck after making edits | SATISFIED | :ready and :error states both render re-export button; each export generates a fresh token/temp file |

No orphaned requirements — all three EXPORT IDs are claimed and implemented.

### Anti-Patterns Found

None. Scanned `generate.py`, `generate_pptx_job.rb`, `decks_controller.rb`, and `_export_button.html.erb` for TODO, FIXME, placeholder comments, empty return values, and console-only handlers. Zero findings.

### Minor Implementation Note (Non-Blocking)

Plan 04-02 specified `Open3.capture2e` in the key_link pattern; implementation uses `Open3.capture3`. `capture3` captures stdout, stderr, and exit status — a superset of `capture2e` (which merges stderr into stdout). The implementation is correct and more capable. This is not a gap.

### Human Verification Required

#### 1. Windows CJK Rendering

**Test:** Open a downloaded .pptx on Windows PowerPoint (or a Windows projector)
**Expected:** Chinese characters are visible as proper glyphs, not empty rectangles or boxes
**Why human:** macOS falls back to system fonts when an embedded font is unrecognized, masking any embedding failures. Only a Windows render confirms the ZIP injection approach works on the target platform. (Note: human in 04-03 verified on Mac Keynote/PowerPoint — Windows confirmation is the remaining risk item.)

#### 2. Live Turbo Stream Export Flow

**Test:** With Solid Queue worker running, click "Export PPTX" on a deck with Chinese lyrics in a real browser
**Expected:** Button immediately shows "Generating..." with spinner, then updates to "Download .pptx →" link within ~15 seconds
**Why human:** Turbo Stream delivery over Action Cable WebSocket cannot be verified via static code inspection

#### 3. Downloaded File Integrity and Visual Quality

**Test:** Click "Download .pptx →", open the file in PowerPoint or Keynote
**Expected:** File opens without errors; slides visible; background and text colors match deck theme; pinyin layout above Chinese lines
**Why human:** File corruption and visual rendering of colors require presentation software to confirm

### Gaps Summary

No gaps. All automated must-haves verified at all three levels (exists, substantive, wired). Requirements EXPORT-01 through EXPORT-03 are fully satisfied by implemented code.

Phase goal is achieved from a code-completeness standpoint. Three human verification items remain, primarily around live browser behavior and Windows rendering — these are validation items, not implementation gaps.

---

_Verified: 2026-03-15_
_Verifier: Claude (gsd-verifier)_
