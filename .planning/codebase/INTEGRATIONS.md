# Integrations

## External APIs

### Anthropic Claude API
- **Purpose**: Lyric import / AI-assisted content generation
- **Env var**: `ANTHROPIC_API_KEY`
- **Location**: Referenced in application code (lyric import feature)

### python-pptx (subprocess)
- **Purpose**: PPTX generation
- **Status**: Planned — `lib/pptx_generator/` (not yet implemented)
- **Mechanism**: Called via subprocess from Ruby

## Databases

### PostgreSQL 18 (via Active Record)
- **Adapter**: `postgresql`
- **Connections**: 4 databases configured
  - `primary` — main application data
  - `cache` — Solid Cache
  - `queue` — Solid Queue
  - `cable` — Action Cable
- **Env var**: `PRAISE_PROJECT_DATABASE_PASSWORD`

## File Storage

### Active Storage
- **Default**: Local disk
- **Alternatives**: AWS S3 and GCS configs present but commented out

## Authentication

### Devise 5.0.2
- **Type**: Self-hosted, email/password
- **OAuth**: Not configured
- **Location**: Standard Devise setup

## Background Jobs

### Solid Queue
- **Type**: DB-backed (no Redis required)
- **Config**: `config/queue.yml`

## CI/CD

### GitHub Actions
- **Jobs**: 5 jobs defined
- **Deployment**: Kamal → Docker

## Email

- SMTP not configured (commented out)

## Required Environment Variables

| Variable | Purpose |
|----------|---------|
| `ANTHROPIC_API_KEY` | Claude API access |
| `RAILS_MASTER_KEY` | Rails credentials decryption |
| `PRAISE_PROJECT_DATABASE_PASSWORD` | PostgreSQL auth |
