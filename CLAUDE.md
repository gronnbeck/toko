# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Application

**Toko** is a Rails 8.1 application using Ruby 4.0.1. It uses SQLite for all environments (including production via Docker volumes), with separate databases for cache, queue, and Action Cable (via Solid Cache, Solid Queue, Solid Cable).

## Commands

```bash
bin/setup          # Install deps, prepare database
bin/dev            # Start development server
bin/rails test     # Run all tests
bin/rails test test/models/foo_test.rb        # Run a single test file
bin/rails test test/models/foo_test.rb:42     # Run a single test by line
bin/rails test:system   # Run system tests (Capybara/Selenium)
bin/rubocop        # Lint Ruby (omakase style)
bin/brakeman       # Static security analysis
bin/bundler-audit  # Gem vulnerability audit
bin/importmap audit # JS dependency audit
bin/ci             # Run full CI suite locally
```

Database:
```bash
bin/rails db:migrate
bin/rails db:seed:replant   # Reset and re-seed (also run in CI)
```

## Development Process

Red-Green-Commit cycle: write a failing test → implement → make it pass → commit. Each cycle produces its own commit; many small commits is the goal.

Before every commit, run `bin/ci` to ensure the full CI suite passes. Also run `rubycritic` on the files changed in that commit. The goal is an A or B rating for every file, including tests. Fix any C/D/F rated files before committing.

## Code Conventions

- Files and test files: ~120 lines max
- Max 7 methods per file (public + private combined)
- Prefer `module_function` and class methods over instance methods
- Most logic lives in service objects following the `ModuleName::ClassName.call` pattern (see below)

### Service Pattern

Services live in `app/services/` and use `module_function` so `.call` works without instantiation:

```ruby
# app/services/orders/create.rb
module Orders
  module Create
    module_function

    def call(attrs:)
      # ...
    end

    private_class_method :some_helper
  end
end

# Usage
Orders::Create.call(attrs: params)
```

Private helpers are defined as regular `module_function` methods and then hidden with `private_class_method`.

## Architecture

### Two main components

**1. The Server** (this Rails app) is the central source of truth. It stores all information about agents, tasks, and configuration. The server exposes an API that the harness gateway consumes.

**2. The Harness Gateway** (`harness/`) is a separate binary that reads a config file, polls the server for work, and spawns and controls agents to execute tasks. It is the runtime layer — the server is the brain, the harness gateway is the muscle.

```
[ Server (Rails) ] <--HTTP--> [ Harness Gateway ] --> [ Agent processes ]
   agents, tasks                  config.yml             spawned per task
   state, history
  /api/v1/tasks
```

The harness gateway is intentionally decoupled from the server — it only knows what the server tells it via the API.

**Running the harness gateway:**
```bash
bin/harness harness/settings.yml   # uses gitignored settings.yml with local agent tokens
```

**toko CLI** — talks to the server on behalf of an agent, configured via env vars:
```bash
TOKO_URL=http://localhost:3360 TOKO_AGENT_TOKEN=<uuid> bin/toko tasks list
TOKO_URL=http://localhost:3360 TOKO_AGENT_TOKEN=<uuid> bin/toko tasks claim <id>
TOKO_URL=http://localhost:3360 TOKO_AGENT_TOKEN=<uuid> bin/toko tasks complete <id>
TOKO_URL=http://localhost:3360 TOKO_AGENT_TOKEN=<uuid> bin/toko tasks fail <id>
```

Harness source lives in `harness/lib/harness/`:
- `config.rb` — loads and validates the YAML config
- `server_client.rb` — HTTP client for the server API
- `agent_runner.rb` — claims a task, spawns an agent, reports result
- `gateway.rb` — poll loop, concurrency control

### Rails infrastructure

**Solid suite replaces external services**: Solid Queue (background jobs), Solid Cache (Rails.cache), and Solid Cable (Action Cable) all use SQLite — no Redis or external queue broker needed in development or production.

**UI components**: All UI is written with [Phlex](https://www.phlex.fun) (`phlex-rails`). No ERB views except layouts. Components live in `app/views/` as Ruby classes inheriting from `ApplicationView` (pages) or `ApplicationComponent` (partials). Render them from controllers with `render MyView.new(...)`.

**Asset pipeline**: Propshaft (not Sprockets) + importmap-rails for JavaScript (no bundler/transpilation). Stimulus for JS interactivity, Turbo for SPA-like navigation.

**Deployment**: Kamal 2 with Docker. `config/deploy.yml` targets a single server with a local Docker registry. Production uses a persistent Docker volume (`toko_storage`) for SQLite files and Active Storage. Solid Queue runs inside Puma (single-server mode via `SOLID_QUEUE_IN_PUMA=true`).

**CI** (`bin/ci` / `.github/workflows/ci.yml`): rubocop → bundler-audit → importmap audit → brakeman → `rails test` → seed replant. System tests run in a separate CI job.
