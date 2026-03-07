# Stack Research

**Domain:** Ruby on Rails worship PPTX generator with Claude API + lyrics retrieval
**Researched:** 2026-03-07
**Confidence:** HIGH — based on direct codebase inspection of existing praise-project

---

## Confirmed Existing Stack

Already locked in `Gemfile.lock` and running:

| Component | Version | Notes |
|-----------|---------|-------|
| Ruby | 4.0.1 | Confirmed in `.ruby-version` |
| Rails | 8.1.2 | Confirmed in `Gemfile.lock` |
| PostgreSQL | 18 | Confirmed in `database.yml` |
| Devise | 5.0.2 | Auth — already in Gemfile |
| Solid Queue | current | Background jobs — already in Gemfile |
| Tailwind CSS | 4 | Styling — already in Gemfile |
| Turbo + Stimulus (Hotwire) | current | UI framework — already in Gemfile |
| Importmap | current | No Node.js/webpack — rules out React |

---

## Critical Gaps (Must Add)

### 1. Claude API Ruby Gem — MISSING

`ANTHROPIC_API_KEY` is documented in the project but no `anthropic` gem is installed.

```ruby
gem "anthropic"  # Add to Gemfile
```

**Why:** Required for all LLM calls — lyric recall, structuring, and pinyin generation.

**Confidence:** HIGH — confirmed by Gemfile inspection.

---

### 2. PPTX Generation — python-pptx via subprocess

**Decision: python-pptx (Python) called via Ruby subprocess — NOT a Ruby gem.**

| Option | Verdict | Reason |
|--------|---------|--------|
| `caracal` | Reject | Generates DOCX, not PPTX |
| `ruby-pptx` | Reject | Immature; poor CJK character support; unmaintained |
| `caxlsx` | Reject | Excel spreadsheets, not PowerPoint |
| `python-pptx` via subprocess | Use this | Mature, actively maintained, full CJK support, handles background images and custom fonts |

**Implementation:** `lib/pptx_generator/generator.py` called from `PptxBuilder` service via `Open3.capture3`. JSON protocol on stdout for error handling.

**Requirement:** Dockerfile must add Python 3 + `pip install python-pptx`. Already stubbed in codebase.

**Confidence:** HIGH.

---

### 3. Lyrics Retrieval — Claude First, Scrapers Fallback

**Decision: Two-stage pipeline. No external search API.**

```
Stage 1: Ask Claude
  → "Do you know the lyrics to [song title]?
     If yes, return structured sections with pinyin.
     If not, say so — do not guess."
  → If Claude knows → done (one API call, zero scraping)

Stage 2: Fallback scrapers (only when Claude doesn't know)
  → Nokogiri scrapes 2-3 curated Chinese worship sites:
      - 赞美之泉 (Stream of Praise) — mainstream Chinese praise
      - 普世颂扬 — contemporary Chinese worship
      - [additional site TBD based on team's repertoire]
  → Raw lyrics text sent back to Claude to structure + add pinyin
```

**Why Claude first:** Claude knows most major Chinese worship songs (赞美之泉 catalog, classic hymns, mainstream contemporary praise). Scrapers only needed for obscure or locally-written songs.

**Why no search API:** Avoids SerpAPI cost (~$50/month) and Google CSE setup. Google Custom Search returns URLs + snippets — you still need Nokogiri to parse the page. Hardcoded scrapers for known sites are simpler and more reliable for a predictable song repertoire.

**Confidence:** MEDIUM-HIGH. Claude coverage is good for mainstream Chinese worship; scrapers cover the gap. Manual paste remains available for anything scrapers miss.

---

### 4. Pinyin Generation — Claude API (inline with lyrics recall)

**Decision: Claude generates pinyin as part of the same lyric structuring call. No pinyin gem.**

| Option | Verdict | Reason |
|--------|---------|--------|
| `ruby-pinyin` | Reject | Context-blind dictionary lookup; fails on polyphonic characters |
| `pypinyin` (Python) | Reject | Frequency-based; incorrect on rare hymn vocabulary |
| Claude API (inline) | Use this | Context-aware tone assignment; handles 多音字 with sentence context |

**Schema note:** `lyrics.pinyin` column already exists in schema — ready to receive Claude output.

**Prompt design:** Send full lyric section (not character-by-character) for sentence context.

**Confidence:** HIGH.

---

## Full Recommended Stack

| Layer | Choice | Notes |
|-------|--------|-------|
| Web framework | Rails 8.1.2 | Already installed |
| Auth | Devise 5.0.2 | Already installed |
| UI framework | Turbo Frames + Stimulus | Already installed via Hotwire |
| Background jobs | Solid Queue | Already installed |
| Database | PostgreSQL 18 | Already installed |
| Styling | Tailwind CSS 4 | Already installed |
| Claude API | `gem "anthropic"` | **Must add to Gemfile** |
| PPTX generation | python-pptx (Python subprocess) | **Must configure Dockerfile** |
| Lyrics retrieval (primary) | Claude API recall | No extra dependencies |
| Lyrics retrieval (fallback) | Nokogiri scrapers (2-3 curated sites) | Nokogiri already a transitive dep |
| Pinyin | Claude API (inline with lyrics) | No separate gem needed |
| File delivery | Active Storage | Built into Rails; local disk or S3 for .pptx files |
| CJK fonts | Noto Sans SC / Source Han Sans | Must include in Dockerfile |

---

## What NOT to Use

| Technology | Why Not |
|-----------|---------|
| React / Vue | Importmap-only setup rules out npm-dependent frameworks |
| `caracal` | DOCX not PPTX |
| `ruby-pptx` | Immature, poor CJK support |
| `ruby-pinyin` / `pypinyin` | Context-blind; fails on polyphonic worship song characters |
| SerpAPI / Google Custom Search | Adds cost and complexity; Claude + targeted scrapers cover the use case |
| Sidekiq | Solid Queue is already installed and sufficient |
| Redis | Not needed with Solid Queue (uses PostgreSQL as queue backend) |

---

## Deployment Notes

- Dockerfile must install: Python 3, pip, `python-pptx`, CJK font packages (`fonts-noto-cjk`)
- Single server sufficient for one-church team scale
- Active Storage: local disk initially; switch to S3 if needed

---

## Confidence Summary

| Decision | Confidence | Basis |
|----------|------------|-------|
| python-pptx for PPTX | HIGH | Only viable option with full CJK support; codebase already has stub |
| Claude for pinyin | HIGH | Polyphone problem makes gem-based approach unreliable |
| `gem "anthropic"` missing | HIGH | Direct Gemfile inspection |
| Claude-first lyrics recall | MEDIUM-HIGH | Good coverage for mainstream Chinese worship; scrapers cover gap |
| Hardcoded scrapers as fallback | MEDIUM | Reliable for known sites; needs site-specific parsing |
| Solid Queue for jobs | HIGH | Already in Gemfile; correct for this scale |
