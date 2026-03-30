# S01: Design System Foundation — UAT

**Milestone:** M002
**Written:** 2026-03-28T15:28:56.017Z

## UAT: S01 — Design System Foundation\n\n### Token System\n- [ ] Navigate any page — body renders with warm parchment surface background (not stone-50 grey)\n- [ ] Inspect page head — Newsreader, Inter, and Material Symbols Outlined CDN links present; no Playfair Display link\n\n### Nav Bar\n- [ ] Nav shows Newsreader italic wordmark \"Praise Project\"\n- [ ] Active page (Decks or Songs) shows primary-colored text with bottom underline\n- [ ] \"New Deck\" button renders as dark red gradient\n- [ ] Mail icon visible as Material Symbol (not SVG)\n\n### Icons\n- [ ] Open browser DevTools and run `document.querySelectorAll('svg').length` — returns 0\n- [ ] Flash toast (trigger any action) shows Material Symbols icon, no 1px border\n\n### Typography\n- [ ] Page headings render in Newsreader serif\n- [ ] Body text renders in Inter sans-serif
