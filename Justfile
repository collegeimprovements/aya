# ── Aya ─────────────────────────────────────────────────────────────
# Usage: just <recipe>
# Run `just --list` to see all available recipes.

# Load env vars from .mise.toml via mise
set dotenv-load := false

# ── Dev ─────────────────────────────────────────────────────────────

# Install dependencies and set up the project
setup:
    mix setup

# Start the Phoenix dev server
dev:
    iex -S mix phx.server

# Start the Phoenix dev server (no iex)
server:
    mix phx.server

# Run the formatter
fmt:
    mix format

# Compile with warnings as errors
check:
    mix compile --warnings-as-errors

# Run precommit checks (compile, format, test)
precommit:
    mix precommit

# Open an IEx session with the app loaded
console:
    iex -S mix

# ── Database ────────────────────────────────────────────────────────

# Create the database
db-create:
    mix ecto.create

# Run all pending migrations
db-migrate:
    mix ecto.migrate

# Rollback the last migration
db-rollback:
    mix ecto.rollback

# Rollback the last N migrations
db-rollback-n n:
    mix ecto.rollback -n {{n}}

# Reset the database (drop + create + migrate + seed)
db-reset:
    mix ecto.reset

# Show migration status
db-status:
    mix ecto.migrations

# Seed the database
db-seed:
    mix run priv/repo/seeds.exs

# ── Test ────────────────────────────────────────────────────────────

# Run all tests
test:
    mix test

# Run tests with coverage
test-cover:
    mix test --cover

# Run a specific test file
test-file file:
    mix test {{file}}

# Run tests matching a pattern
test-only pattern:
    mix test --only {{pattern}}

# ── Docker ──────────────────────────────────────────────────────────

# Vendor shared libs into ./libs for Docker build context
vendor-libs:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Vendoring shared libs from ../../events/libs/ → ./libs/"
    rm -rf libs
    cp -r ../../events/libs libs
    echo "Done. $(ls libs | wc -l | tr -d ' ') libs vendored."

# Build the Docker image
docker-build: vendor-libs
    docker build \
      --build-arg ELIXIR_VERSION=${ELIXIR_VERSION:-1.20.0-rc.3} \
      --build-arg OTP_VERSION=${OTP_VERSION:-28.4.1} \
      --build-arg DEBIAN_VERSION=${DEBIAN_VERSION:-trixie-20260316} \
      -t aya:latest .

# Build the Docker image with HTTP proxy
docker-build-proxy: vendor-libs
    docker build \
      --build-arg ELIXIR_VERSION=${ELIXIR_VERSION:-1.20.0-rc.3} \
      --build-arg OTP_VERSION=${OTP_VERSION:-28.4.1} \
      --build-arg DEBIAN_VERSION=${DEBIAN_VERSION:-trixie-20260316} \
      --build-arg HTTP_PROXY=${HTTP_PROXY} \
      --build-arg HTTPS_PROXY=${HTTPS_PROXY} \
      --build-arg NO_PROXY=${NO_PROXY:-localhost,127.0.0.1} \
      -t aya:latest .

# Build without cache
docker-build-fresh: vendor-libs
    docker build --no-cache \
      --build-arg ELIXIR_VERSION=${ELIXIR_VERSION:-1.20.0-rc.3} \
      --build-arg OTP_VERSION=${OTP_VERSION:-28.4.1} \
      --build-arg DEBIAN_VERSION=${DEBIAN_VERSION:-trixie-20260316} \
      -t aya:latest .

# Start all services (app + db)
up:
    docker compose up -d

# Start all services and rebuild
up-build: vendor-libs
    docker compose up -d --build

# Stop all services
down:
    docker compose down

# Stop all services and remove volumes
down-clean:
    docker compose down -v

# View app logs
logs:
    docker compose logs -f app

# View all service logs
logs-all:
    docker compose logs -f

# Open a shell in the running app container
shell:
    docker compose exec app /bin/bash

# Open an IEx remote console to the running app
remote-console:
    docker compose exec app /app/bin/aya remote

# ── Migrations (Docker / Release) ──────────────────────────────────

# Run all pending migrations in the Docker container
docker-migrate:
    docker compose exec app /app/bin/aya eval "Aya.Release.migrate()"

# Run N migrations in the Docker container
docker-migrate-n n:
    docker compose exec app /app/bin/aya eval "Aya.Release.migrate({{n}})"

# Rollback last migration in Docker
docker-rollback:
    docker compose exec app /app/bin/aya eval "Aya.Release.rollback_step()"

# Rollback last N migrations in Docker
docker-rollback-n n:
    docker compose exec app /app/bin/aya eval "Aya.Release.rollback_step({{n}})"

# Rollback all migrations in Docker
docker-rollback-all:
    docker compose exec app /app/bin/aya eval "Aya.Release.rollback_all()"

# Show migration status in Docker
docker-migration-status:
    docker compose exec app /app/bin/aya eval "Aya.Release.migration_status()"

# ── Cleanup ─────────────────────────────────────────────────────────

# Remove vendored libs (after Docker build)
clean-libs:
    rm -rf libs

# Full clean: remove build artifacts, deps, vendored libs
clean:
    rm -rf _build deps libs

# Generate a secret key base
gen-secret:
    mix phx.gen.secret
