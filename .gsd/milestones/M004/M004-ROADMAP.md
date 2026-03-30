# M004: 

## Vision
Give worship leaders two key display controls on each deck: whether pinyin appears on slides, and how many lyric lines show per slide. Both settings affect the in-editor preview and the exported PPTX.

## Slice Overview
| ID | Slice | Risk | Depends | Done | After this |
|----|-------|------|---------|------|------------|
| S01 | Deck Settings — DB & Panel | low | — | ✅ | Open deck editor → see Settings panel below Theme → toggle Show Pinyin off → save → reload → setting persists. Change Lines per Slide to 2 → save → reload → persists. |
| S02 | Preview & PPTX Respect Settings | medium | S01 | ✅ | Toggle Show Pinyin off → slide preview hides pinyin instantly. Set Lines per Slide to 2 → a 4-line chorus splits into 2 preview cards. Export PPTX → same split and pinyin setting in file. |
