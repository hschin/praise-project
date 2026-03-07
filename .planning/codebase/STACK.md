# Technology Stack

**Analysis Date:** 2026-03-07

## Languages

**Primary:**
- Ruby 4.0.1 - All application logic, models, controllers, views
- ERB - HTML templating (Rails views in `app/views/`)

**Secondary:**
- Python 3 - PPTX file generation via `python-pptx` subprocess (planned, `lib/pptx_generator/` — directory not yet created)
- JavaScript (ESM) - Hotwire Stimulus controllers in `app/javascript/controllers/`
- CSS - Tailwind utility classes (JIT via `tailwindcss-rails`)

## Runtime

**Environment:**
- Ruby 4.0.1 — managed via rbenv, declared in `.ruby-version`

**Package Manager:**
- Bundler — Ruby gems via `Gemfile` / `Gemfile.lock`
- Importmap — JavaScript packages pinned in `config/importmap.rb`, no npm/Node required
- Lockfile: `Gemfile.lock` present and committed

## Frameworks

**Core:**
- Rails 8.1.2 - Full-stack MVC web framework

**Frontend:**
- Hotwire Turbo 2.0.23 (`turbo-rails`) - SPA-like page navigation without full reloads
- Hotwire Stimulus 1.3.4 (`stimulus-rails`) - Modest JS controllers
- Tailwind CSS 4.2.0 (`tailwindcss-rails` 4.4.0) - Utility-first CSS, JIT build via `bin/rails tailwindcss:watch`
- Propshaft 1.3.1 - Modern asset pipeline (replaces Sprockets)
- Importmap-rails 2.2.3 - ESM import maps, no bundler/Node

**Background Jobs:**
- Solid Queue 1.3.2 - DB-backed job queue (PostgreSQL), replaces Redis/Sidekiq
- Solid Cable 3.0.12 - DB-backed Action Cable adapter for production WebSockets
- Solid Cache 1.0.10 - DB-backed Rails cache store for production

**Testing:**
- Minitest - Rails default unit/integration test framework
- Capybara 3.40.0 - System/browser test DSL
- Selenium WebDriver 4.41.0 - Browser automation for system tests

**Build/Dev:**
- Kamal 2.10.1 - Docker-based deployment tool, config at `config/deploy.yml`
- Thruster 0.1.19 - HTTP asset caching/compression proxy wrapping Puma
- Bootsnap 1.23.0 - Boot-time caching for faster startup

## Key Dependencies

**Critical:**
- `devise` 5.0.2 - User authentication (email/password, password reset, remember me)
- `pg` ~1.1 - PostgreSQL adapter for Active Record
- `jbuilder` 2.14.1 - JSON view templates for API responses
- `image_processing` ~1.2 - Active Storage image variant transforms (requires libvips)

**Infrastructure:**
- `puma` 7.2.0 - Multi-threaded application server
- `solid_queue` 1.3.2 - Background job processing without Redis
- `solid_cache` 1.0.10 - Cache store backed by primary PostgreSQL database
- `solid_cable` 3.0.12 - Action Cable backed by separate PostgreSQL database

**Security/Dev Tools:**
- `brakeman` - Static analysis for Rails security vulnerabilities (dev/test only)
- `bundler-audit` - Scans gems for known CVEs (dev/test only)
- `rubocop-rails-omakase` - Omakase Rails style linting (dev/test only)

## Configuration

**Environment:**
- Secrets managed via Rails encrypted credentials: `config/credentials.yml.enc` + `config/master.key`
- Production database password: `PRAISE_PROJECT_DATABASE_PASSWORD` env var
- Production master key: `RAILS_MASTER_KEY` env var (injected via Kamal)
- Claude API key: `ANTHROPIC_API_KEY` env var (required, not yet wired up in code)
- `.env*` files are gitignored

**Build:**
- `config/application.rb` - Application-level config, Rails 8.1 defaults
- `config/environments/production.rb` - Production: solid_cache, solid_queue, local ActiveStorage
- `config/deploy.yml` - Kamal deployment config (Docker registry, server IP, volumes)
- `config/database.yml` - PostgreSQL for all environments; production uses 4 databases (primary, cache, queue, cable)
- `Dockerfile` - Multi-stage production image, Ruby 4.0.1-slim base, amd64 target
- `Procfile.dev` - Dev process manager: `web` (rails server) + `css` (tailwindcss:watch)

## Platform Requirements

**Development:**
- Ruby 4.0.1 via rbenv
- PostgreSQL 18 (Postgres.app on macOS)
- Python 3 with `python-pptx` and `pypinyin` packages
- No Node.js required

**Production:**
- Docker container (via Kamal)
- PostgreSQL server (external or accessory)
- libvips for image processing
- libjemalloc2 for reduced memory usage

---

*Stack analysis: 2026-03-07*
