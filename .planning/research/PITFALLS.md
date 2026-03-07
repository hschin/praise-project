# Pitfalls Research

**Domain:** Rails + python-pptx + Claude API + web lyrics scraping for Chinese church worship slides
**Researched:** 2026-03-07

---

## Critical Pitfalls

These will cause silent failures or user-visible breakage if not addressed from day one.

---

### 1. CJK Characters Render as Rectangles in PPTX

**Risk:** HIGH — will work on developer's Mac, break on church's Windows projector

**What happens:** `python-pptx` sets only the Latin font slot (`<a:latin>`). Chinese characters fall through to the system's CJK fallback font. On Windows with a clean install, there may be no CJK fallback — characters render as empty rectangles (□□□).

**Warning signs:**
- Slides look fine in Preview/macOS but wrong on the projector
- Characters show as □ in PowerPoint on Windows
- Test on a fresh Windows VM reveals the issue

**Prevention:**
- Set the east-Asian font slot explicitly in python-pptx via raw XML manipulation:
  ```python
  from pptx.oxml.ns import qn
  run._r.get_or_add_rPr().set(qn('a:eastAsianFont'), 'Noto Sans SC')
  ```
- Bundle the font file in the Docker image: `apt-get install fonts-noto-cjk`
- Include a Windows test step before considering PPTX export complete

**Phase:** Address in Phase 4 (PPTX generation) — before any demo to worship team.

---

### 2. Pinyin Tone Marks Wrong for Polyphonic Characters (多音字)

**Risk:** HIGH — worship leaders will distrust the tool if pinyin is wrong

**What happens:** Characters like 还(hái/huán), 长(cháng/zhǎng), 行(xíng/háng), 和(hé/hè/huó/huò), 重(zhòng/chóng), 中(zhōng/zhòng) have multiple readings. Without sentence context, any pinyin library guesses based on frequency — correct for everyday prose, wrong for the specific usage in hymn lyrics.

**Warning signs:**
- Common worship words with wrong tones (e.g., "赞美" with wrong tones)
- Congregation members correcting slides during service
- Polyphones showing the default/majority reading regardless of context

**Prevention:**
- Send Claude the full lyric section (not character-by-character) — sentence context is essential
- Store a `pinyin_reviewed` boolean on `Lyric`; display "needs review" flag in the editor for first-time imports
- Build inline pinyin editing into the slide editor (Phase 3) before PPTX export (Phase 4)
- Consider running a secondary verification pass where Claude checks its own pinyin output

**Phase:** Address in Phase 2 (lyrics pipeline) for prompt design; Phase 3 for review UI.

---

### 3. Ruby → Python Subprocess Silent Failure

**Risk:** HIGH — jobs fail with no feedback to user

**What happens:** The current python-pptx stub calls the Python script via subprocess. If the script crashes, Rails receives raw stderr with no structured error. The `PptxGenerateJob` silently fails; the export button never becomes a download link; the user has no idea what happened.

**Warning signs:**
- Jobs completing in Solid Queue but no file appearing
- `Open3.capture2e` returning non-zero exit code that's never checked
- Log noise from Python but no Rails-level error

**Prevention:**
- Define a JSON protocol contract for the subprocess stdout:
  ```json
  { "status": "ok", "file_path": "/tmp/deck_123.pptx" }
  { "status": "error", "message": "Font not found: Noto Sans SC", "traceback": "..." }
  ```
- Use `Open3.capture3` and check exit status explicitly
- Add a health-check mode: `ruby -e "system('python3 generator.py --health')"` at boot
- Surface errors to the user via Turbo Streams: "Export failed: [reason]. Try again."

**Phase:** Address in Phase 4 (PPTX generation) — build the protocol before writing generation logic.

---

### 4. Claude API Timeout Blocks Web Requests

**Risk:** HIGH — app becomes unresponsive; Thruster kills requests after 60s

**What happens:** Pinyin annotation + section detection for a full song can take 10-30 seconds. Running this synchronously in a controller will cause gateway timeouts. Users see a white screen or 504.

**Warning signs:**
- Lyric import takes >5 seconds
- Occasional 504 errors on song import
- Heroku/Fly.io request timeout errors in logs

**Prevention:**
- Use background jobs from day one (Phase 2) — `LyricFetchJob` → `LyricEnrichJob`
- Never call Claude API inline in a controller action
- Set explicit Claude API timeout: `timeout: 30` in the anthropic gem config
- Implement retry with exponential backoff (Solid Queue supports this natively)
- Broadcast job status via Turbo Streams: "Importing lyrics..." → "Ready"

**Phase:** Architecture decision in Phase 2 — must be designed in before writing any Claude integration.

---

### 5. Mixed Script Layout Breaks PPTX Text Boxes

**Risk:** HIGH — pinyin + Chinese two-line layout is non-trivial in python-pptx

**What happens:** PPTX has no native ruby/furigana API (the HTML `<ruby>` equivalent). Naively putting pinyin and Chinese in the same text box causes auto-fit to clip text or overlap. Font size relationships between pinyin and Chinese characters are fragile.

**Warning signs:**
- Pinyin and characters overlap in some slides
- Auto-fit truncates text on longer sections
- Layout looks different across PowerPoint versions

**Prevention:**
- Use two stacked text boxes per slide: top box for pinyin (smaller font), bottom box for Chinese characters (larger font) — fixed Y positions, no auto-fit
- Set `text_frame.word_wrap = True` and disable auto-size
- Define explicit font size ratio: e.g., pinyin at 50% of Chinese character size
- Test with the longest verse in your song library to validate layout

**Phase:** Address in Phase 4 during PptxBuilder implementation.

---

## Moderate Pitfalls

---

### 6. Web Scraper Fragility

**Risk:** MEDIUM — lyrics source breaks without warning

**What happens:** Lyrics sites change their HTML structure, add anti-scraping measures (Cloudflare, JS rendering), or go offline. A scraper that works today may return empty results next week.

**Prevention:**
- Use SerpAPI (returns structured results, not raw HTML) as the search layer
- Store scraped lyrics in the Song library immediately after first successful fetch — subsequent loads never re-scrape
- Add a "lyrics unavailable" UI state + manual paste fallback (user can paste raw lyrics)
- Monitor for empty-lyrics returns and alert (Solid Queue job failure logging)

**Phase:** Build paste fallback in Phase 2.

---

### 7. Claude Hallucinating Lyrics

**Risk:** MEDIUM — especially for obscure Chinese worship songs

**What happens:** Claude may not have a given Chinese worship song in training data. If asked to "generate lyrics," it may produce plausible-sounding but incorrect text. This is a worship tool — incorrect lyrics are unacceptable.

**Prevention:**
- Claude's role is **structuring and annotating**, not generating lyrics — always provide fetched raw lyrics as input
- Include explicit instruction in the prompt: "Do not generate or invent any lyrics. Only structure what is provided."
- Show raw fetched lyrics alongside structured output in the editor so worship leaders can compare
- Flag confidence level when Claude's output diverges from input length by >10%

**Phase:** Prompt design in Phase 2.

---

### 8. Dockerfile Missing Python and CJK Fonts

**Risk:** MEDIUM — PPTX generation works locally but fails in production

**What happens:** Developer's machine has Python and CJK fonts installed. Docker image in production does not. `PptxGenerateJob` fails in production with "python3: command not found" or blank character boxes.

**Prevention:**
```dockerfile
RUN apt-get update && apt-get install -y python3 python3-pip fonts-noto-cjk
RUN pip3 install python-pptx
```
Add this to Dockerfile before Phase 4 ships.

**Phase:** Address at start of Phase 4.

---

### 9. Slide Model as Dual Source of Truth

**Risk:** MEDIUM — data sync bugs between `DeckSong.arrangement` and `Slide` records

**What happens:** If `Slide` records and `DeckSong.arrangement` can get out of sync, reordering a slide updates one but not the other. PPTX export uses one source; the UI uses the other. Slides appear in the wrong order in the exported file.

**Prevention:**
- `Slide` records should be a **derived projection** of `DeckSong.arrangement`, not independently editable
- When arrangement changes, regenerate slide records from arrangement (not vice versa)
- Never update `Slide.position` directly — always go through `DeckSong.arrangement`

**Phase:** Data model design in Phase 1/2.

---

### 10. Solid Queue Worker Not Running in Production

**Risk:** MEDIUM — jobs queue up but never execute; no user-visible error

**What happens:** In development, `bin/dev` starts the worker. In production on a single-dyno setup, there may be no worker process. All jobs (lyric import, PPTX generation) queue silently and never run.

**Prevention:**
- Verify `Procfile` or Dockerfile includes a worker process: `worker: bundle exec rails solid_queue:work`
- Add a jobs health check endpoint: `/health/queue` that checks for jobs stuck in queue >5 minutes
- Include Solid Queue dashboard (or log monitoring) in production setup

**Phase:** Infrastructure validation before Phase 2 goes live.

---

## Minor Pitfalls

---

### 11. Traditional Chinese Lyrics from Web Sources

**Risk:** LOW-MEDIUM — pinyin generated for Traditional characters will be wrong

**Prevention:** Add a Simplified/Traditional detection step in `LyricsEnricher`. Ask Claude to identify and convert Traditional characters before generating pinyin. Store a `traditional_converted` flag on Song for review.

---

### 12. Theme Background Image File Size

**Risk:** LOW — large background images slow PPTX download and inflate file size

**Prevention:** Enforce max image upload size (2MB). Convert to JPEG at 1920x1080 on upload. Use Active Storage variants.

---

### 13. Song Title Ambiguity

**Risk:** LOW — two songs with same title, or Chinese title matches English title incorrectly

**Prevention:** Show lyrics preview before saving to library. Allow duplicate detection by content fingerprint, not just title.
