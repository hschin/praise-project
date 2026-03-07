# Feature Landscape

**Domain:** Worship presentation / PPTX slide generator for Chinese church teams
**Researched:** 2026-03-07
**Confidence note:** Findings draw from knowledge of ProPresenter, EasyWorship, OpenLP, FreeWorship, and Chinese-language church tech community patterns.

---

## Table Stakes

Features users expect. Missing any of these and the tool feels broken.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Song search by title | Fundamental entry point to any workflow | Low | Must handle CJK characters; English titles also common in Chinese churches |
| Lyrics display with Chinese characters | Core value — projection-ready text | Low | Simplified Chinese (not Traditional) per project scope |
| Pinyin displayed above or below characters | Non-native readers and younger congregants depend on this | Medium | Tone marks required (not just romanization); accuracy is load-bearing |
| One section per slide | Industry standard for live projection readability | Low | Verses, choruses, bridges each get their own slide(s) |
| Slide reordering | Worship leaders adjust song flow at runtime (e.g., repeat chorus) | Medium | Drag-and-drop or up/down controls; applies within a song |
| Slide editing (inline text edit) | Lyric fetch is never 100% accurate — leaders need to fix errors | Medium | Edit-in-place; must not require re-fetching |
| Slide deletion | Remove unwanted sections (intros, outros, spoken sections) | Low | Soft delete or hide is sufficient |
| Service / setlist management | Group songs into a service order | Medium | One service = one PPTX export; songs ordered within a service |
| PPTX export | The deliverable — usable in PowerPoint, Keynote, and projector apps | High | Formatting must survive round-trip; fonts, layout, colors preserved |
| Song library (reuse without re-fetching) | Once processed, songs should not need to be re-fetched | Medium | Shared across team members |
| Visual theme selection | Projection aesthetics matter; dark backgrounds with light text are standard | Medium | Background + font + color scheme; per-service scope |
| User authentication | Multiple team members share access to the library | Low | Email/password sufficient |

---

## Differentiators

Features that give ChurchSlides an advantage over generic tools.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| AI-powered lyric fetch + structuring | Zero manual copy-paste; Claude finds lyrics and segments into sections | High | Web search + Claude API pipeline; biggest time savings in the workflow |
| Automatic pinyin generation | Worship leaders currently add pinyin manually or via Word plugins | High | Context-aware tones from Claude; polyphone disambiguation critical (了/行/重) |
| Section detection (verse/chorus/bridge) | Web-fetched lyrics are often unstructured blocks of text | Medium | Enables correct slide-per-section layout without manual tagging |
| Song title search in Chinese and English | Many songs known by both names (e.g., "10000 Reasons" / "萬萬頌讚") | Low | Fuzzy match or alias storage on Song model |
| Simplified Chinese normalization | Web-sourced lyrics may be Traditional; Claude converts to Simplified | Low-Medium | Part of Claude processing step; flag uncertain conversions |
| Team-shared library | Once one member fetches a song, immediately available to all | Low | Single-tenant shared database; no sync needed |
| Per-service theme (not per-song) | Pick the look once for the whole service | Low | Reduces cognitive load vs. per-song theming |

---

## Anti-Features

Features to deliberately not build in v1.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Scripture slides | Separate data model, version complexity (ESV/NIV/CUV), text licensing | Scope to v2 |
| Announcement / sermon slides | Different workflow; not lyrics-based | Out of scope entirely for v1 |
| Real-time multi-user collaboration | WebSocket complexity unnecessary for small team | Sequential single-user editing; shared library read access is enough |
| Live presentation mode (in-browser projection) | PPTX export achieves the same goal with battle-tested software | Stick to PPTX export |
| Mobile app | Separate codebase; use case fits desktop well | Responsive web later |
| Multi-church / SaaS tenancy | Premature generalization; complicates data isolation | Single church team only for v1 |
| Media library / background image management | Full asset management is a product in itself | Pre-define 3-5 curated theme templates |
| Import from ProPresenter / CCLI SongSelect | Format parsing is brittle and maintenance-heavy | Manual search is entry point; import is v2 |
| Version history / audit trail | Small teams tolerate overwrite; adds DB complexity | Last-write-wins; revisit when teams report pain |

---

## Feature Dependencies

```
User Auth
  └─> Song Library (team-shared; requires identity)
        └─> AI Lyric Fetch + Structuring (populates library)
              └─> Pinyin Generation (part of fetch pipeline; not standalone)
              └─> Section Detection (part of fetch pipeline)
        └─> Service / Setlist Management (draws from library)
              └─> Theme Selection (per-service; requires service to exist)
              └─> Slide Editing (operates on service's slides)
                    └─> Slide Reordering (subset of editing)
                    └─> Slide Deletion (subset of editing)
              └─> PPTX Export (terminal action; requires theme + slides)
```

Key dependency constraints:
- PPTX export has no value without at least one service with songs and slides
- Slide editing requires slides to exist, which requires AI fetch to have run
- Theme selection is prerequisite for PPTX export (a default theme needed if user skips)
- Pinyin generation is NOT a separate user-triggered action — it happens as part of lyric fetch

---

## Chinese-Language Specific Observations

| Concern | Notes | Confidence |
|---------|-------|------------|
| Pinyin tone accuracy | Claude must receive full sentence context to resolve polyphones (e.g., 要 yào vs. yāo, 重 zhòng vs. chóng) | HIGH |
| Simplified vs. Traditional detection | Web-sourced lyrics may be Traditional; must normalize before pinyin generation | HIGH |
| Font choice for CJK projection | Noto Sans SC, Source Han Sans, or Microsoft YaHei render CJK + Latin cleanly at large sizes | MEDIUM |
| Pinyin placement convention | Standard is pinyin above characters (ruby text style); some prefer below; character size must remain dominant | MEDIUM |
| Bilingual song titles | Many songs known by English, Chinese, or transliterated title; store all known aliases | MEDIUM |
| CCLI licensing gaps | CCLI has a Chinese-language catalog but coverage of locally-composed Chinese praise songs is inconsistent; web scraping necessary | MEDIUM |

---

## MVP Recommendation

**Prioritize for v1 (in order):**

1. User authentication (prerequisite for everything; Low complexity)
2. Song search + AI lyric fetch + pinyin generation (the core value loop; do this early to surface Claude API / web scraping issues)
3. Song library persistence (automatic after fetch; Low complexity once fetch works)
4. Slide editing and reordering (leaders need to fix AI output)
5. Service / setlist creation with song ordering
6. Theme selection (3-5 curated themes; blocker for export quality)
7. PPTX export (final deliverable; High complexity)

**Defer:**
- Bulk import / CCLI integration
- Per-slide custom font overrides
- Song metadata (key, artist, CCLI number)
- Search history / recently used songs
