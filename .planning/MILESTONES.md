# Milestones

## v1.0 MVP (Shipped: 2026-03-15)

**Phases completed:** 4 phases, 17 plans
**Timeline:** 2026-03-07 → 2026-03-15 (8 days)
**Stats:** 106 commits, 205 files changed, +18,772 lines, ~4,200 LOC (Ruby + Python + ERB)

**Key accomplishments:**
- Devise auth with email/password signup, session persistence, and password reset via email
- 3-stage AI lyrics import pipeline — Claude recall → SerpAPI search → Nokogiri scrape, with Turbo Stream live status
- Auto-generated tone-marked pinyin for all Chinese lyrics, sectioned into verse/chorus/bridge by Claude
- Interactive deck editor with SortableJS drag-and-drop song and slide arrangement, inline repeat/delete
- AI theme suggestions via Claude Haiku — 5 themes with Unsplash background photos per deck title
- Python PPTX generator with embedded Noto Sans SC CJK font — renders Chinese on Windows projectors without font installation

**Archive:**
- `.planning/milestones/v1.0-ROADMAP.md`
- `.planning/milestones/v1.0-REQUIREMENTS.md`
- `.planning/milestones/v1.0-MILESTONE-AUDIT.md`

---
