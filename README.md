# PraiseProject

A Ruby on Rails web app that generates PowerPoint slide decks for Chinese church worship services. Import songs via AI, arrange them into service decks, customise visual themes, and export projection-ready `.pptx` files with Chinese lyrics and tone-marked pinyin.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Local Setup](#local-setup)
- [Environment Variables](#environment-variables)
- [Running the App](#running-the-app)
- [Project Structure](#project-structure)
- [Domain Model](#domain-model)
- [Key Concepts](#key-concepts)
- [Running Tests](#running-tests)
- [Contributing](#contributing)
- [Deployment](#deployment)

---

## Features

- **AI Song Import** — search for Chinese worship songs by title/artist, or paste lyrics directly; Claude fetches and structures lyrics into labelled sections (Verse, Chorus, Bridge, etc.) with tone-marked pinyin
- **Deck Builder** — arrange songs into a service deck with drag-to-reorder, custom arrangement per song (repeat a chorus, skip an intro), and transposition keys
- **PPTX Export** — generates a widescreen 16:9 PowerPoint file with embedded Noto Sans SC font (renders on Windows projectors without installation)
- **AI Theme Suggestions** — Claude + Unsplash suggest 5 visually distinct colour/photo themes per deck
- **Admin Dashboard** — view global stats, all decks, and export history
- **Real-time Updates** — job progress (lyrics importing, PPTX generation) streams back to the browser via Turbo Streams

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Ruby 4.0.1 |
| Framework | Rails 8.1.3 |
| Database | PostgreSQL 18 |
| Frontend | Hotwire (Turbo + Stimulus), Importmap |
| CSS | Tailwind CSS 4 |
| Auth | Devise 5 |
| Background Jobs | Solid Queue (database-backed, no Redis) |
| Caching | Solid Cache (database-backed) |
| PPTX Generation | python-pptx 1.0.2 via subprocess |
| AI / LLM | Anthropic Claude API (Sonnet for lyrics, Haiku for themes) |
| Photo Search | Unsplash API |
| Web Server | Puma + Thruster |
| Asset Pipeline | Propshaft |
| CI | GitHub Actions |
| Hosting | AWS ECS Fargate |

---

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Ruby | 4.0.1 | Use [rbenv](https://github.com/rbenv/rbenv) |
| Bundler | latest | `gem install bundler` |
| PostgreSQL | 16+ | [Postgres.app](https://postgresapp.com) recommended on macOS |
| Python | 3.11+ | For PPTX generation |
| Foreman | latest | `gem install foreman` — runs multi-process dev server |

---

## Local Setup

```bash
# 1. Clone the repo
git clone https://github.com/hschin/praise-project.git
cd praise-project

# 2. Install Ruby dependencies
bundle install

# 3. Install Python dependencies
pip install python-pptx pillow

# 4. Copy and fill in environment variables (see next section)
cp .env.example .env

# 5. Create and seed the database
bin/rails db:prepare

# 6. Start the dev server
bin/dev
```

`bin/dev` starts three processes via Foreman:
- `web` — Rails server on `localhost:3000`
- `css` — Tailwind CSS watcher
- `jobs` — Solid Queue worker

---

## Environment Variables

Create a `.env` file in the project root (not committed):

```bash
# Required — Anthropic Claude API (lyrics import + theme generation)
ANTHROPIC_API_KEY=sk-ant-...

# Required — Unsplash API (AI theme photo suggestions)
UNSPLASH_ACCESS_KEY=...
```

### Getting API Keys

**Anthropic API Key**
1. Sign up at [console.anthropic.com](https://console.anthropic.com)
2. Go to **API Keys** → **Create Key**
3. Add it as `ANTHROPIC_API_KEY` in your `.env`

**Unsplash Access Key**
1. Sign up at [unsplash.com/developers](https://unsplash.com/developers)
2. Create a new application
3. Copy the **Access Key** and add it as `UNSPLASH_ACCESS_KEY` in your `.env`

---

## Running the App

```bash
# Start everything (web + CSS watcher + job worker)
bin/dev

# Or start each process individually:
bin/rails server          # web server
bin/jobs                  # Solid Queue worker (required for imports + exports)
```

Visit `http://localhost:3000`. Sign up for an account, then start importing songs.

### Common Commands

```bash
bin/rails db:migrate      # run pending migrations
bin/rails db:seed         # seed initial data (if any)
bin/rails test            # run test suite
bin/rails console         # open Rails console
bin/brakeman --no-pager   # security scan
bin/rubocop               # lint check
```

---

## Project Structure

```
app/
├── controllers/
│   ├── decks_controller.rb         # Deck CRUD, export, download
│   ├── songs_controller.rb         # Song import workflow
│   ├── deck_songs_controller.rb    # Add/reorder/arrange songs in a deck
│   ├── themes_controller.rb        # Theme creation + AI suggestions
│   └── admin_controller.rb         # Admin dashboard
├── models/
│   ├── deck.rb
│   ├── song.rb
│   ├── lyric.rb
│   ├── deck_song.rb
│   ├── slide.rb
│   ├── theme.rb
│   └── export.rb
├── services/
│   ├── claude_lyrics_service.rb    # Claude API: search + import lyrics
│   └── claude_theme_service.rb     # Claude API: theme suggestions
├── jobs/
│   ├── import_song_job.rb          # Async: fetch + create song/lyrics
│   ├── search_song_job.rb          # Async: find song candidates
│   ├── generate_pptx_job.rb        # Async: run Python PPTX script
│   └── generate_theme_suggestions_job.rb
└── views/                          # Hotwire/Turbo stream views

lib/
└── pptx_generator/
    └── generate.py                 # Python script: renders .pptx

config/
├── routes.rb
├── brakeman.ignore
└── recurring.yml                   # Solid Queue recurring tasks

.github/workflows/
├── ci.yml                          # Test, lint, security scan
└── deploy.yml                      # Build + push to AWS ECS
```

---

## Domain Model

```
User
 └─ has_many Decks
     ├─ belongs_to Theme (optional)
     └─ has_many DeckSongs
         └─ belongs_to Song
             └─ has_many Lyrics (sections)

Export          — tracks PPTX generation and download events per Deck
Slide           — generated slides per DeckSong (from Lyrics)
Theme           — visual config: background colour/image, text colour, font size
```

### Models at a Glance

| Model | Key Fields |
|---|---|
| `User` | email, admin (boolean) |
| `Deck` | title, date, notes, show_pinyin, lines_per_slide |
| `Song` | title, artist, english_title, default_key, import_status |
| `Lyric` | section_type (Verse/Chorus/Bridge/…), content, pinyin, position |
| `DeckSong` | position, key (transposition), arrangement (jsonb: ordered lyric IDs) |
| `Slide` | section_type, content, pinyin, position |
| `Theme` | name, background_color, text_color, font_size, unsplash_url |
| `Export` | event (generated/downloaded) |

---

## Key Concepts

### Song Import Flow

1. User enters song title/artist (or pastes raw lyrics) → `SongsController#import`
2. `SearchSongJob` calls `ClaudeLyricsService.search()` — Claude uses web search to find candidates
3. User selects a candidate → `SongsController#confirm_import`
4. `ImportSongJob` calls `ClaudeLyricsService.import()` — Claude structures lyrics into sections with tone-marked pinyin
5. Song + Lyric records created; duplicate detection via Jaccard similarity (≥ 0.82 threshold)
6. Status updates stream to the browser in real time via Turbo Streams

### PPTX Export Flow

1. User clicks Export on a deck → `DecksController#export`
2. `GeneratePptxJob` serialises the deck (songs, lyrics, theme) to JSON
3. JSON is piped to `lib/pptx_generator/generate.py` via subprocess
4. Python builds the `.pptx` using python-pptx with embedded Noto Sans SC font
5. Output file path is cached with a short-lived token
6. Browser receives a download link via Turbo Stream

### AI Theme Suggestions

1. User requests suggestions → `ThemesController#suggest`
2. `GenerateThemeSuggestionsJob` sends song titles + lyric snippets to Claude Haiku
3. Claude returns 5 theme objects (name, hex colours, font size, Unsplash query)
4. Job fetches a photo for each Unsplash query
5. Theme carousel streams back to the browser

---

## Running Tests

```bash
# Prepare the test database
bin/rails db:test:prepare

# Run all tests
bin/rails test

# Run a specific file
bin/rails test test/models/song_test.rb

# Run a specific test by line number
bin/rails test test/models/song_test.rb:42
```

### CI Checks

The GitHub Actions CI pipeline runs on every push to `main` and all PRs:

| Job | What it checks |
|---|---|
| `scan_ruby` | Brakeman security scan |
| `scan_js` | `importmap audit` for JS vulnerability advisories |
| `lint` | RuboCop style checks |
| `test` | Full Minitest suite against a real PostgreSQL instance |

All four must pass before merging.

---

## Contributing

1. Fork the repo and create a feature branch from `main`
2. Run `bin/setup` to get a clean local environment
3. Make your changes — keep commits small and focused
4. Ensure all checks pass locally before pushing:
   ```bash
   bin/rails test
   bin/rubocop
   bin/brakeman --no-pager --ignore-config config/brakeman.ignore
   ```
5. Open a pull request against `main`

### Code Style

- RuboCop is enforced in CI — run `bin/rubocop -a` to auto-fix most violations
- No Node/Webpack — keep frontend in Hotwire/Stimulus and vanilla JS via Importmap
- Background work goes in a Job; AI/API calls go in a Service
- All database environments use PostgreSQL — no SQLite

---

## Deployment

The app is deployed to **AWS ECS Fargate** (ap-southeast-1) via GitHub Actions on every push to `main`.

### Pipeline

1. Docker image built and pushed to Amazon ECR
2. ECS service updated with the new task definition (waits for stability)
3. One-off ECS task runs `bin/rails db:migrate` after containers are healthy

### AWS Infrastructure

| Resource | Details |
|---|---|
| Region | `ap-southeast-1` |
| ECS Cluster | `praise-project-cluster` |
| ECS Service | `praise-project-service` (Fargate, 512 CPU / 1024 MB) |
| ECR Repository | `ACCOUNT_ID.dkr.ecr.ap-southeast-1.amazonaws.com/praise-project` |
| ALB | `<alb-dns-prefix>.ap-southeast-1.elb.amazonaws.com` |
| ALB Target Group | `praise-project-tg-3000` (port 3000, health check: `GET /health`) |
| RDS | PostgreSQL on `<rds-endpoint>` |
| S3 Bucket | `praise-project-uploads-ACCOUNT_ID` (ActiveStorage uploads) |
| ACM Certificate | `*.hschin.com` (ap-southeast-1) |

### Secrets Management

All production secrets are stored in **AWS SSM Parameter Store** under `/praise-project/` and injected into the ECS task at launch — nothing is baked into the image.

| SSM Parameter | Description |
|---|---|
| `/praise-project/RAILS_MASTER_KEY` | Decrypts `config/credentials.yml.enc` |
| `/praise-project/DATABASE_URL` | PostgreSQL connection string |
| `/praise-project/ANTHROPIC_API_KEY` | Claude API key |
| `/praise-project/APP_HOST` | Public hostname (`praise-project.hschin.com`) |
| `/praise-project/S3_BUCKET` | ActiveStorage bucket name |
| `/praise-project/UNSPLASH_ACCESS_KEY` | Unsplash API key |

To add a new secret:
```bash
aws ssm put-parameter \
  --name "/praise-project/NEW_KEY" \
  --value "..." \
  --type SecureString \
  --region ap-southeast-1 \
  --profile excide
```
Then add it to the `secrets` array in `aws/task-definition.json` and push to `main`.

### IAM Roles

Two roles are required — both are created by `aws/setup.sh`:

| Role | Purpose |
|---|---|
| `praise-project-execution-role` | Used by the ECS agent to pull the ECR image and fetch SSM secrets at task launch |
| `praise-project-task-role` | Used by the running Rails app for S3 read/write access |

GitHub Actions authenticates to AWS via **OIDC** (no long-lived access keys).

### Required GitHub Actions Secrets

| Secret | Description |
|---|---|
| `AWS_ROLE_ARN` | OIDC IAM role ARN for ECR/ECS access |
| `AWS_REGION` | `ap-southeast-1` |
| `ECR_REPOSITORY` | `praise-project` |
| `CONTAINER_NAME` | `praise-project` |
| `ECS_SERVICE` | `praise-project-service` |
| `ECS_CLUSTER` | `praise-project-cluster` |
| `ECS_TASK_DEFINITION` | `praise-project` |
| `ECS_SUBNETS` | `<subnet-1a>,<subnet-1c>,<subnet-1b>` |
| `ECS_SECURITY_GROUPS` | `<ecs-sg>` |

### Health Check

The app exposes a rich health endpoint at `GET /health` (used by the ALB):

```json
{
  "status": "ok",
  "checks": {
    "database": true,
    "queue": true,
    "storage": true
  },
  "timestamp": "2026-05-02T12:00:00Z",
  "version": "unknown"
}
```

Returns `200 OK` when all checks pass, `503 Service Unavailable` when any fail. The ALB stops routing to a task if this endpoint returns non-2xx.

### Observability

CloudWatch is set up via `aws/observability.sh`. Run it with:

```bash
ALERT_EMAIL=you@example.com AWS_PROFILE=excide bash aws/observability.sh
```

| What | Detail |
|---|---|
| **Alarms** (7) | No healthy hosts, 5xx error rate, response time > 5s, ECS CPU > 80%, ECS memory > 85%, RDS connections ≥ 4, RDS free storage < 1 GB |
| **Notifications** | SNS topic `praise-project-alerts` → email |
| **Container Insights** | Enabled on `praise-project-cluster` — per-task CPU/memory graphs |
| **Log metric filters** | `RailsErrors`, `Http5xxResponses`, `PptxScriptFailures` in namespace `PraiseProject` |
| **Dashboard** | [CloudWatch → praise-project](https://ap-southeast-1.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-1#dashboards:name=praise-project) |
| **Log group** | `/ecs/praise-project` |

### Re-running Infrastructure Setup

Initial AWS infrastructure (VPC, RDS, IAM, ECR, ECS, ALB) is provisioned by:

```bash
AWS_PROFILE=excide bash aws/setup.sh
```

Safe to re-run — all resources use idempotent create-or-skip logic.

> `config/deploy.yml` (Kamal) and `render.yaml` are retained for reference but are not the active deployment targets.
