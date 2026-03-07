# PraiseProject — Claude Instructions

## Project
A Ruby on Rails web app that generates PowerPoint (.pptx) slides for church worship services.

## Stack
- **Ruby**: 4.0.1 (managed via rbenv)
- **Rails**: 8.1.2
- **Database**: PostgreSQL 18 (via Postgres.app)
- **Frontend**: Hotwire (Turbo + Stimulus), Importmap — no Node/Webpack
- **PPTX generation**: python-pptx via subprocess (Python script in `lib/pptx_generator/`)

## Domain Model
- `Service` — a church service (date, title, church_name)
- `Song` — song library (title, artist, key)
- `Lyric` — lyric sections per song (section: verse/chorus/bridge, order, content)
- `ServiceItem` — join between Service and Song (position, transpose_key)
- `Slide` — individual slides (type: title/verse/chorus/scripture/blank)

## Conventions
- Use PostgreSQL for all environments (no SQLite)
- Background jobs via Solid Queue (built into Rails 8)
- File storage via ActiveStorage
- Test framework: Rails default (Minitest) unless changed
- Keep Python script interface simple: Rails serializes service to JSON, calls script, receives .pptx path back

## Commands
```bash
rails s           # start dev server
rails db:migrate  # run migrations
rails test        # run tests
bin/jobs          # start Solid Queue worker
```
