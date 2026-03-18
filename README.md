# Toko

Toko is an agent orchestration platform. It has two main components:

1. **The Server** — a Rails app that is the central source of truth for agents, tasks, and configuration.
2. **The Harness Gateway** — a binary that reads a config file, keeps agents online via heartbeat pings, and dispatches tasks to agents.

```
[ Server (Rails) ] <--HTTP--> [ Harness Gateway ] --> [ Agent processes ]
   agents, tasks                  settings.yml           spawned per task
   organizations
   /api/v1
```

## Requirements

- Ruby 4.0.1
- SQLite 3.8+

## Getting started

```bash
bin/setup
bin/rails db:seed
bin/rails server
```

The server runs on port **3360**.

## Running the harness

Create a local settings file (gitignored) from the example:

```bash
cp harness/config.example.yml harness/settings.yml
# edit settings.yml and add your agent tokens
bin/harness harness/settings.yml
```

The harness sends a heartbeat ping to the server every 30 seconds for each configured agent token. Agents are shown as:

- **online** — pinged within the last 5 minutes
- **missing** — pinged 5–10 minutes ago
- **offline** — not pinged for over 10 minutes

## toko CLI

Agents can interact with the server via the `toko` CLI, configured with environment variables:

```bash
export TOKO_URL=http://localhost:3360
export TOKO_AGENT_TOKEN=<agent-uuid>

bin/toko tasks list
bin/toko tasks claim <id>
bin/toko tasks complete <id>
bin/toko tasks fail <id>
```

## Tests

```bash
bin/rails test
bin/rails test test/models/agent_test.rb      # single file
bin/rails test test/models/agent_test.rb:42   # single test
bin/ci                                         # full CI suite
```
