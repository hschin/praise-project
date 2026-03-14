---
phase: 02-lyrics-pipeline
plan: 06
type: human-verification
completed: 2026-03-11
---

# Phase 2 Plan 6: End-to-End Verification Summary

## Result: APPROVED

All 7 browser tests passed after bug fixes.

## Bugs Fixed During Verification

### 1. CSRF token failure on manual paste form
**Symptom:** "Can't verify CSRF token authenticity" when submitting the paste form after a failed search.
**Cause:** The `_failed.html.erb` partial is broadcast via Turbo Stream outside a request context, so the CSRF token embedded in the form didn't match the user's session.
**Fix:** Removed `data: { turbo: false }` from the form — Turbo form submissions send the token via the `X-CSRF-Token` header (from the page's `<meta name="csrf-token">` tag), which is always valid.

### 2. Claude service always raising `NoMethodError: undefined method 'text' for nil`
**Symptom:** All imports (both web search and manual paste) silently failed — the rescue block broadcast the failed state for every import attempt.
**Cause:** `response.content.reverse.find { |b| b.type == "text" }` always returned nil. In `anthropic` gem 1.23.0, `TextBlock#type` returns the Symbol `:text`, not the String `"text"`. String/symbol comparison is always false in Ruby.
**Fix:** Changed to `b.type == :text`.

### 3. `ANTHROPIC_API_KEY` not loaded from `.env`
**Symptom:** Service silently used mock response in production-like testing because key appeared missing.
**Cause:** No `dotenv-rails` gem — `.env` file was never loaded by the Rails process.
**Fix:** Key must be exported in the shell before starting `bin/dev` (e.g. `export $(cat .env | xargs)`). Noted for onboarding.

### 4. Claude prefixing JSON response with natural language text
**Symptom:** `JSON::ParserError: unexpected character: 'Perfect!'` — Claude ignored "raw JSON only" instruction when web search tool was in use.
**Cause:** After completing tool use, Claude added conversational preamble before the JSON body.
**Fix:** Added assistant prefill `{ role: "assistant", content: "{" }` to force the response to begin as a JSON object. Parse concatenates the prefill back: `JSON.parse("{" + text_block.text)`.

## Verified Tests

1. ✓ Web search recall — imported 我願意 with correct Simplified Chinese + tone-marked pinyin, English section headers
2. ✓ Pinyin toggle — hide/show works correctly
3. ✓ Failed import + manual paste — fake title shows red error state; pasting lyrics processes and completes on the same page
4. ✓ Manual paste disclosure visible on index without a prior failure
5. ✓ Library search — partial title filter works; cards show first lyric line
6. ✓ Edit song — section labels and lyric text update correctly
7. ✓ Hard refresh during import — page shows correct current state

## Phase 2 Success Criteria: MET

1. ✓ User searches a song title and lyrics appear via background job with Turbo Stream status
2. ✓ Lyrics display with Simplified Chinese + tone-marked pinyin, sectioned into verse/chorus/bridge
3. ✓ User can paste raw lyrics manually when search fails
4. ✓ Imported song is visible in the shared library
5. ✓ User can browse, search, and edit a saved song's lyrics and pinyin
