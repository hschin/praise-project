---
phase: 04-pptx-export
plan: 01
subsystem: infra
tags: [python, python-pptx, pptx, cjk, noto-sans, font-embedding, zipfile]

# Dependency graph
requires: []
provides:
  - "lib/pptx_generator/generate.py — Python script that converts deck JSON to .pptx"
  - "lib/pptx_generator/fonts/NotoSansSC-Regular.ttf — bundled CJK font embedded in every output"
  - "lib/pptx_generator/requirements.txt — python-pptx + Pillow dependency declaration"
affects: [04-02, 04-03]

# Tech tracking
tech-stack:
  added: [python-pptx==1.0.2, Pillow, fonttools (dev-only for OTF->TTF conversion), Noto Sans SC TTF]
  patterns:
    - "Python subprocess interface: Rails serializes deck to JSON -> stdin, script writes .pptx to output_path"
    - "ZIP post-processing: after python-pptx saves .pptx, reopen as ZIP to inject font binary into ppt/fonts/"
    - "East Asian font XML slot: set a:ea typeface on each run so PowerPoint routes CJK glyphs to Noto Sans SC"

key-files:
  created:
    - lib/pptx_generator/generate.py
    - lib/pptx_generator/fonts/NotoSansSC-Regular.ttf
    - lib/pptx_generator/requirements.txt
    - lib/pptx_generator/test_generate.py
  modified: []

key-decisions:
  - "Font embedding via ZIP post-processing: after python-pptx saves .pptx, reopen as zipfile to inject TTF binary into ppt/fonts/ — most reliable approach, independent of python-pptx API support"
  - "OTF->TTF conversion: downloaded NotoSansCJKsc-Regular.otf from Google Fonts GitHub, converted to TTF via fonttools so the FONT_PATH reference in generate.py works with zipfile injection"
  - "East Asian font XML slot required: set a:ea typeface element on every run rPr so Windows PowerPoint routes CJK glyphs to Noto Sans SC (Latin slot alone is insufficient)"

patterns-established:
  - "Pattern 1: JSON stdin -> Python subprocess -> .pptx output_path (no temp files passed on CLI)"
  - "Pattern 2: embed_cjk_font() ZIP post-processing runs immediately after prs.save() — always in main()"
  - "Pattern 3: pinyin appears as separate smaller paragraphs (60% pt size) above Chinese content in the same text box"

requirements-completed: [EXPORT-01, EXPORT-02]

# Metrics
duration: 3min
completed: 2026-03-14
---

# Phase 4 Plan 01: PPTX Generation Script Summary

**Python script reads deck JSON from stdin, writes .pptx with Noto Sans SC CJK font physically embedded in the archive via ZIP post-processing — renders Chinese text on Windows projectors without font installation**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-14T06:49:48Z
- **Completed:** 2026-03-14T06:52:36Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- Bundled Noto Sans SC TTF (16MB, full Simplified Chinese coverage) in lib/pptx_generator/fonts/
- generate.py reads deck JSON from stdin, creates 16:9 .pptx with one slide per lyric block, applies theme background/text colors and font sizes
- Font physically embedded into every .pptx output via ZIP post-processing (ppt/fonts/), with Content_Types.xml and presentation.xml.rels updated
- Pinyin rendered above Chinese text at 60% of Chinese font size; omitted when blank
- 6 unit tests covering slide count, font embedding, multi-song, invalid path exit code, blank pinyin, exit 0

## Task Commits

Each task was committed atomically:

1. **Task 1: Download Noto Sans SC font and create requirements.txt** - `efccba8` (chore)
2. **Task 2 RED: Failing tests for PPTX generation** - `1b36e93` (test)
3. **Task 2 GREEN: Implement generate.py** - `89318b6` (feat)

**Plan metadata:** _(docs commit — see below)_

_Note: TDD tasks may have multiple commits (test -> feat -> refactor)_

## Files Created/Modified
- `lib/pptx_generator/generate.py` - Python script: stdin JSON -> .pptx with embedded CJK font
- `lib/pptx_generator/fonts/NotoSansSC-Regular.ttf` - Noto Sans SC TTF (16MB), committed to repo
- `lib/pptx_generator/requirements.txt` - python-pptx==1.0.2 and Pillow>=10.0.0
- `lib/pptx_generator/test_generate.py` - 6 unit tests (TDD RED then GREEN)

## Decisions Made
- Font embedding uses ZIP post-processing rather than python-pptx API: after prs.save(), reopen .pptx as a zipfile and inject the TTF binary into ppt/fonts/. This approach is stable across python-pptx versions.
- East Asian font XML slot (a:ea element) set on every run in addition to run.font.name, ensuring Windows PowerPoint correctly routes CJK glyphs to Noto Sans SC.
- NotoSansCJKsc-Regular OTF downloaded from Google Fonts GitHub and converted to TTF via fonttools — python-pptx's zipfile injection works with both, but TTF matches the extension expected in FONT_PATH/FONT_ZIP_NAME.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] OTF to TTF conversion via fonttools**
- **Found during:** Task 1 (font download)
- **Issue:** Plan specified a `.ttf` file but Google Fonts GitHub delivers an `.otf`. The script's FONT_PATH and FONT_ZIP_NAME both reference `.ttf`, so a raw OTF would cause a file-not-found error at runtime.
- **Fix:** Installed fonttools via pip3, used TTFont to convert OTF -> TTF. Removed intermediate OTF.
- **Files modified:** lib/pptx_generator/fonts/NotoSansSC-Regular.ttf (created from OTF)
- **Verification:** `file` command confirms OpenType/TrueType, smoke test passes, font embedded in ZIP
- **Committed in:** efccba8 (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking — OTF->TTF conversion)
**Impact on plan:** Necessary for correct execution. No scope creep.

## Issues Encountered
None beyond the OTF->TTF conversion documented above.

## User Setup Required
None - no external service configuration required. python-pptx and Pillow must be installed (`pip install -r lib/pptx_generator/requirements.txt`) before the Rails job calls the script.

## Next Phase Readiness
- generate.py is the core technical deliverable Plan 02 depends on (GeneratePptxJob calls this script)
- Script interface is exactly as specified: stdin JSON -> output_path .pptx, exit 0/1
- CJK font embedding verified via zipfile assertion in smoke test

---
*Phase: 04-pptx-export*
*Completed: 2026-03-14*
