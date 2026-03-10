---
phase: 2
slug: lyrics-pipeline
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-10
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Minitest (Rails default) |
| **Config file** | `test/test_helper.rb` |
| **Quick run command** | `rails test test/models/ test/jobs/` |
| **Full suite command** | `rails test` |
| **Estimated runtime** | ~15 seconds (all stubs — no real API calls) |

---

## Sampling Rate

- **After every task commit:** Run `rails test test/models/ test/jobs/`
- **After every plan wave:** Run `rails test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 15 seconds

---

## API Stubbing Strategy

All Claude and SerpAPI calls MUST be stubbed in tests — no real API calls in the test suite.

Use Minitest's built-in `stub` method:
```ruby
ClaudeLyricsService.stub(:call, { sections: [...], unknown: false }) do
  ImportSongJob.new.perform(song.id)
end
```

No VCR cassettes, no mocha gem — keep it simple with stdlib stubs.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| SONG-01-job | 02 | 0 | SONG-01 | unit (job) | `rails test test/jobs/import_song_job_test.rb` | ❌ W0 | ⬜ pending |
| SONG-01-claude | 02 | 0 | SONG-01 | unit (service) | `rails test test/services/claude_lyrics_service_test.rb` | ❌ W0 | ⬜ pending |
| SONG-01-search | 02 | 0 | SONG-01 | unit (service) | `rails test test/services/lyrics_search_service_test.rb` | ❌ W0 | ⬜ pending |
| SONG-02-sections | 02 | 0 | SONG-02 | unit (model) | `rails test test/models/lyric_test.rb` | ✅ (empty, needs tests) | ⬜ pending |
| SONG-03-pinyin | 02 | 0 | SONG-03 | unit (model) | `rails test test/models/lyric_test.rb` | ✅ (empty, needs tests) | ⬜ pending |
| SONG-04-manual | 02 | 0 | SONG-04 | unit (job) | `rails test test/jobs/import_song_job_test.rb` | ❌ W0 | ⬜ pending |
| LIB-01-import | 02 | 0 | LIB-01 | integration | `rails test test/controllers/songs_controller_test.rb` | ✅ (needs extension) | ⬜ pending |
| LIB-02-search | 02 | 0 | LIB-02 | integration | `rails test test/controllers/songs_controller_test.rb` | ✅ (needs test added) | ⬜ pending |
| LIB-03-edit | 02 | 0 | LIB-03 | integration | `rails test test/controllers/songs_controller_test.rb` | ✅ (needs test added) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/jobs/import_song_job_test.rb` — covers SONG-01 (search path) and SONG-04 (manual paste path)
- [ ] `test/services/claude_lyrics_service_test.rb` — covers SONG-01 with stubbed Anthropic client
- [ ] `test/services/lyrics_search_service_test.rb` — covers SONG-01 with stubbed SerpAPI client
- [ ] `test/services/lyrics_scraper_service_test.rb` — covers SONG-01 scraper fallback with stubbed Faraday/Nokogiri
- [ ] `test/models/lyric_test.rb` — add tests for SONG-02 (section_type validation) and SONG-03 (pinyin presence)
- [ ] `test/fixtures/lyrics.yml` — update from `MyString` placeholders to realistic Chinese worship song data

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Turbo Stream progress steps update live in browser | SONG-01 | Requires browser + live job execution | Start `bin/dev`, search a song, watch show page progress steps update in real time |
| Pinyin toggle shows/hides correctly | SONG-02/03 | Requires browser rendering of HTML ruby elements | Visit song show page, click toggle, confirm pinyin appears/disappears above characters |
| Claude returns correct pinyin for actual songs | SONG-03 | Requires live Claude API call | Search a known Chinese worship song (e.g. 讚美之泉), verify tone marks are correct |
| SerpAPI returns scrapeable lyrics pages | SONG-01 | Requires live SerpAPI call | Run spike: query SerpAPI with 3 Chinese worship song titles, confirm top results are static HTML |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 15s (all stubs — no real API calls in suite)
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
