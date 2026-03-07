# PraiseProject

A Ruby on Rails web app that generates PowerPoint (.pptx) slide decks for Chinese church worship services. Lyrics are imported via LLM (Claude API), structured into sections, and exported as presentation-ready PPTX files with Simplified Chinese characters and pinyin.

## Stack

- **Ruby** 4.0.1 / **Rails** 8.1.2
- **PostgreSQL** 18
- **Hotwire** (Turbo + Stimulus) — no Node/Webpack
- **Devise** — user authentication
- **python-pptx** — PPTX file generation (requires Python 3)
- **Claude API** — lyrics import and structuring

## Domain

| Model | Description |
|---|---|
| `User` | Worship leader account |
| `Deck` | A slide deck for a specific service date |
| `Song` | Reusable song in the library |
| `Lyric` | A section of a song (verse, chorus, bridge) with pinyin |
| `DeckSong` | A song added to a deck, with its performance arrangement |
| `Slide` | An individual slide generated from a lyric section |

## Setup

```bash
bundle install
rails db:create db:migrate
rails server
```

### Requirements
- Ruby 4.0.1 (via rbenv)
- PostgreSQL 18
- Python 3 with `python-pptx` (`pip install python-pptx`) and `pypinyin` (`pip install pypinyin`)
- Claude API key set as `ANTHROPIC_API_KEY` in environment

## Running Tests

```bash
rails test
```

## Deployment

Configured for [Kamal](https://kamal-deploy.org) — see `config/deploy.yml`.
