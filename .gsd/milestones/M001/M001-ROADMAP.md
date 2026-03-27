# M001: v1.1 Design

**Vision:** Replace the generic SaaS feel with a warm, worshipful visual identity and streamline the UI so non-technical worship leaders can navigate the deck creation flow without confusion.

## Success Criteria


## Slices

- [x] **S01: Auth + Foundation — completed 2026 03 07** `risk:medium` `depends:[]`
  > After this: Team members can securely access the app and the core data schema is stable for all subsequent features
- [x] **S02: Lyrics Pipeline — completed 2026 03 14** `risk:medium` `depends:[S01]`
  > After this: Users can search for any worship song and receive structured Chinese lyrics with tone-marked pinyin, saved to a shared team library
- [x] **S03: Deck Editor — completed 2026 03 13** `risk:medium` `depends:[S02]`
  > After this: Users can assemble a complete service deck — adding songs, arranging slides, editing text, and choosing a visual theme — ready for export
- [x] **S04: PPTX Export — completed 2026 03 14** `risk:medium` `depends:[S03]`
  > After this: Users can download a complete, presentation-ready .pptx file that renders Chinese characters and pinyin correctly on any projector
- [x] **S05: Design Foundation** `risk:medium` `depends:[S04]`
  > After this: Warm amber/stone palette, styled wordmark, restructured nav with Decks primary, quick-create deck flow, and inline-editable title.
- [x] **S06: Global Components** `risk:medium` `depends:[S05]`
  > After this: Flash toast system with auto-dismiss, consistent form styles across all pages, and actionable error messages.
- [x] **S07: Content Pages** `risk:medium` `depends:[S06]`
  > After this: Deck index as card grid, empty states with context, and auth pages with warm palette and brand wordmark.
- [x] **S08: Deck Editor and Import Polish** `risk:high` `depends:[S07]`
  > After this: Section chips, export button icons, panel labels, auto-save, artist display, and import processing copy — all DOM contracts preserved.
