# Aya

A food and food-science platform built with Phoenix 1.8, LiveView 1.1, and Tailwind CSS v4.

## Architecture

Aya is organized into domain contexts under `lib/aya/`:

| Context | Purpose |
|---|---|
| `Aya.Accounts` | Users, roles, memberships, URM (User Role Mapping), auth |
| `Aya.News` | Food news aggregation, RSS feeds, articles |
| `Aya.Recipes` | Recipe management, ingredients, steps, nutrition |
| `Aya.Research` | Academic papers, studies, food science publications |
| `Aya.Ingredients` | Ingredient database, properties, substitutions |
| `Aya.Reports` | Market reports, trend analysis, data aggregation |
| `Aya.Trends` | Market trends, price tracking, seasonal data |
| `Aya.Content` | Shared content utilities: tagging, search, media |

The web layer lives under `lib/aya_web/`:

```
lib/aya_web/
├── components/          # Shared UI components
│   ├── core_components.ex
│   ├── layouts.ex
│   └── ui/              # Domain-agnostic reusable UI
│       ├── skeleton.ex
│       ├── badge.ex
│       ├── card.ex
│       ├── empty_state.ex
│       ├── inline_alert.ex
│       └── copy_button.ex
├── controllers/         # Traditional controllers
├── live/                # LiveView modules by context
└── hooks/               # Co-located and external JS hooks
```

Authorization is **rule-based** (not RBAC). The URM (User Role Mapping) pattern provides identity and audit — roles carry permissions as JSONB but actual auth decisions are rule-based.

## Dependencies

### Phoenix & Web

| Dep | Version | Purpose |
|---|---|---|
| `phoenix` | ~> 1.8.5 | Web framework |
| `phoenix_live_view` | ~> 1.1.0 | Real-time server-rendered UI |
| `phoenix_live_dashboard` | ~> 0.8.3 | Runtime monitoring dashboard (dev routes) |
| `phoenix_html` | ~> 4.1 | HTML helpers and form builders |
| `phoenix_ecto` | ~> 4.5 | Ecto integration for Phoenix |
| `bandit` | ~> 1.5 | HTTP server (replaces Cowboy) |
| `phoenix_live_reload` | ~> 1.2 | Dev-only hot reload |

### Database

| Dep | Version | Purpose |
|---|---|---|
| `ecto_sql` | ~> 3.13 | SQL adapter for Ecto |
| `postgrex` | >= 0.0.0 | PostgreSQL driver |

### Assets

| Dep | Version | Purpose |
|---|---|---|
| `esbuild` | ~> 0.10 | JavaScript bundling (dev only) |
| `tailwind` | ~> 0.3 | Tailwind CSS v4 CLI (dev only) |
| `heroicons` | v2.2.0 | SVG icon library (compile-time only) |

### Auth & Security

| Dep | Version | Purpose |
|---|---|---|
| `bcrypt_elixir` | ~> 3.0 | Password hashing with bcrypt |

### HTTP & Email

| Dep | Version | Purpose |
|---|---|---|
| `req` | ~> 0.5 | HTTP client for external API calls |
| `swoosh` | ~> 1.16 | Email delivery (Mailgun, SES, SMTP, etc.) |

### Data & i18n

| Dep | Version | Purpose |
|---|---|---|
| `jason` | ~> 1.2 | JSON encoding/decoding |
| `gettext` | ~> 1.0 | Internationalization |

### Observability

| Dep | Version | Purpose |
|---|---|---|
| `telemetry_metrics` | ~> 1.0 | Metrics definitions |
| `telemetry_poller` | ~> 1.0 | Periodic metric polling |

### Clustering

| Dep | Version | Purpose |
|---|---|---|
| `dns_cluster` | ~> 0.2.0 | DNS-based node discovery for clustering |

### Testing

| Dep | Version | Purpose |
|---|---|---|
| `lazy_html` | >= 0.1.0 | HTML parsing and assertions in tests |
| `mimic` | ~> 1.10 | Behaviour-based mocking (test only) |

### Shared Libraries (`events/libs/`)

Custom library ecosystem shared across projects. All are path dependencies.

| Lib | Purpose | When to use |
|---|---|---|
| `fn_types` | Standard result/error types (`FnTypes.Result`) | Return types for all public functions |
| `fn_decorator` | Function decorators for cross-cutting concerns | Logging, timing, caching at function level |
| `dag` | Directed acyclic graph operations | Dependency resolution, pipeline ordering |
| `effect` | Effect system for side-effect management | Isolating side effects for testability |
| `om_behaviours` | Shared behaviour definitions | Defining contracts between modules |
| `om_schema` | Schema macros and helpers | Defining Ecto schemas with standard fields (audit, timestamps, type/subtype) |
| `om_query` | Query builder macros | Building composable Ecto queries with filtering, sorting, pagination |
| `om_crud` | CRUD context generator | Auto-generating `create_*/1`, `update_*/1`, `list_*/0`, etc. in contexts |
| `om_migration` | Migration macros | Writing migrations with standard audit fields and indexes |
| `om_http` | HTTP behaviour and helpers | Defining HTTP client contracts |
| `om_api_client` | API client generator | Building typed HTTP clients for external APIs |
| `om_rss` | RSS feed parser | Parsing and consuming RSS/Atom feeds |
| `om_cache` | Caching layer (Nebulex) | In-memory and distributed caching |
| `om_scheduler` | Job scheduling | Recurring tasks, background jobs |
| `om_health` | Health check endpoints | Readiness/liveness probes |
| `om_middleware` | Middleware pipeline | Composing request/response processing |
| `om_credo` | Credo rules and config | Static analysis (dev/test only) |

## Design System

All visual tokens are CSS custom properties defined in `assets/css/app.css`. The color scheme is "warm-earth" — appetizing, natural, food-inspired.

### Rules

- Always use **semantic token classes**, never raw Tailwind utilities for colors/spacing
- Links use **color differentiation**, not underlines
- No `transition: all` — specify exact properties
- All animations use S-tier properties only: `transform`, `opacity`, `filter`
- Never animate D-tier properties: `width`, `height`, `margin`, `padding`, `top`/`left`
- Nested rounded elements use **concentric border radius**
- Images have subtle outlines with explicit `width`/`height`
- Buttons use `active:scale-[0.96]` for tactile feedback
- Icons are optically centered, shadows preferred over borders for depth

### Color Tokens

| Token | Purpose |
|---|---|
| `--color-surface` | Base background |
| `--color-surface-alt` | Alternate/elevated surface |
| `--color-text` | Primary text |
| `--color-text-secondary` | Secondary text |
| `--color-text-muted` | Muted/placeholder text |
| `--color-primary` | Brand primary (warm orange-red) |
| `--color-secondary` | Brand secondary (fresh green) |
| `--color-accent` | Brand accent (golden amber) |
| `--color-info`, `--color-success`, `--color-warning`, `--color-error` | Semantic colors |

### Theme

Light/Dark/System toggle via `[data-theme="dark"]` on `<html>`, persisted to `localStorage`.

### Motion

- Spring physics via the `/css-spring` skill for natural movement
- Individual transform properties (`translate`, `rotate`, `scale` — not shorthand)
- `--duration-fast` (150ms), `--duration-normal` (200ms), `--duration-slow` (300ms)
- `linear()` easing for custom curves

## Extended `<.link>` Component

Aya overrides Phoenix's built-in `<.link>` in `CoreComponents` with an extended version that adds resource hints, convenience attrs, and accessibility features. It's a **drop-in replacement** — all existing Phoenix link attrs work unchanged.

### Attrs

| Attr | Type | Default | Description |
|---|---|---|---|
| `navigate` | `string` | `nil` | LiveView full navigation (new mount) |
| `patch` | `string` | `nil` | LiveView patch (same LiveView, params change) |
| `href` | `any` | `nil` | Standard HTML link |
| `replace` | `boolean` | `false` | Replace browser history instead of push |
| `method` | `string` | `nil` | HTTP method (for non-GET links) |
| `prefetch` | `boolean` | `false` | Prefetch page HTML on hover/touch |
| `preload` | `boolean` | `false` | Prefetch immediately on render |
| `prerender` | `boolean` | `false` | Prerender via Speculation Rules API (Chrome 109+) |
| `external` | `boolean` | `false` | Auto-adds `target="_blank" rel="noopener noreferrer"` |
| `active` | `boolean` | `false` | Adds active class + `aria-current="page"` |
| `active_class` | `string` | `"text-text font-medium"` | Class applied when `active` is true |
| `disabled` | `boolean` | `false` | Prevents click, dims link, adds `aria-disabled` |
| `loading` | `boolean` | `false` | Shows inline spinner during navigation |

### When to use what

| Scenario | Attr | Example |
|---|---|---|
| Nav links, sidebar items | `prefetch` | `<.link navigate={~p"/recipes"} prefetch>` |
| Wizard next step, onboarding flow | `preload` | `<.link navigate={~p"/step-2"} preload>` |
| Search → top result (Chrome) | `prerender` | `<.link navigate={~p"/recipe/1"} prerender>` |
| GitHub, docs, external sites | `external` | `<.link href="https://..." external>` |
| Current page indicator in nav | `active` | `<.link active={@page == :recipes}>` |
| Feature behind permissions | `disabled` | `<.link disabled={!@can_access}>` |
| Slow pages, heavy data loads | `loading` | `<.link navigate={~p"/reports"} loading>` |

### Resource hints in LiveView context

| Hint | Fetches | LiveView benefit | Cost |
|---|---|---|---|
| `prefetch` | HTML document (on hover) | Faster initial paint while WebSocket connects | Near zero — only on hover intent |
| `preload` | HTML document (immediately) | Same, but doesn't wait for hover | One extra HTTP request per render |
| `prerender` | Full page + JS + WebSocket | Instant navigation (page already rendered) | Full page load in hidden tab |

**Recommendation**: Use `prefetch` on most navigation links. Use `preload` for high-confidence next pages. Avoid `prerender` in LiveView unless the target is a non-LiveView page.

### Examples

```elixir
<%-- Standard (unchanged from Phoenix) --%>
<.link navigate={~p"/recipes"}>Recipes</.link>
<.link href="/logout" method="delete">Log out</.link>

<%-- Prefetch on hover --%>
<.link navigate={~p"/recipes"} prefetch>Recipes</.link>

<%-- External link --%>
<.link href="https://github.com/aya" external>Source Code</.link>

<%-- Active nav link --%>
<.link navigate={~p"/recipes"} active={@live_action == :index} prefetch>
  Recipes
</.link>

<%-- Disabled until permission --%>
<.link navigate={~p"/admin"} disabled={!@current_user.admin?}>Admin</.link>

<%-- Loading spinner --%>
<.link navigate={~p"/reports"} loading>Generate Report</.link>

<%-- Compose multiple --%>
<.link navigate={~p"/dashboard"} prefetch active={@page == :dashboard} class="px-3 py-2">
  Dashboard
</.link>
```

## SEO & Meta Tags (`AyaWeb.SEO`)

Reusable component for Open Graph, Twitter Cards, article metadata, canonical URLs, and JSON-LD structured data.

### Setup

Add to root layout `<head>`:

```heex
<AyaWeb.SEO.meta_tags meta={assigns[:meta]} canonical_url={assigns[:canonical_url]} json_ld={assigns[:json_ld]} />
```

### Setting meta in LiveViews

```elixir
def handle_params(%{"slug" => slug}, _uri, socket) do
  recipe = Recipes.get!(slug)
  {:noreply, assign(socket,
    meta: %{
      title: recipe.title,
      description: String.slice(recipe.summary, 0, 160),
      image: recipe.image_url,
      image_width: 1200,
      image_height: 630,
      url: url(~p"/recipes/#{slug}"),
      type: "article",
      published_time: DateTime.to_iso8601(recipe.published_at),
      author: recipe.author_name,
      tags: ["baking", "sourdough"]
    },
    json_ld: AyaWeb.SEO.recipe_json_ld(%{
      name: recipe.title,
      description: recipe.summary,
      image: recipe.image_url,
      author: recipe.author_name,
      prep_time: "PT30M",
      cook_time: "PT45M",
      ingredients: recipe.ingredients,
      instructions: recipe.steps
    })
  )}
end
```

### Meta keys reference

| Key | Default | Platform | Description |
|---|---|---|---|
| `title` | "Aya — Food & Science" | All | Page title |
| `description` | App description | All | Max ~160 chars |
| `image` | "/images/og-default.jpg" | All | 1200x630 recommended |
| `image_width` | — | Facebook, LinkedIn | Helps render without downloading image |
| `image_height` | — | Facebook, LinkedIn | Same |
| `image_alt` | Falls back to title | Twitter, Facebook | Accessibility |
| `url` | — | All | Canonical page URL |
| `type` | "website" | Facebook | "website", "article", "profile" |
| `twitter_card` | "summary_large_image" | Twitter/X | "summary" or "summary_large_image" |
| `twitter_site` | — | Twitter/X | Site's @handle |
| `twitter_creator` | — | Twitter/X | Author's @handle |
| `published_time` | — | Facebook | ISO 8601 (article type) |
| `author` | — | Facebook | Author name (article type) |
| `section` | — | Facebook | Article category |
| `tags` | — | Facebook | List of tag strings |
| `noindex` | — | Google | Set truthy to prevent indexing |

### JSON-LD helpers

```elixir
# Recipe structured data (shows rich cards in Google)
AyaWeb.SEO.recipe_json_ld(%{name: "...", ingredients: [...], instructions: [...]})

# Article structured data
AyaWeb.SEO.article_json_ld(%{title: "...", author: "...", published_time: "..."})
```

## LiveView Conventions

- **Streams** for collections — never raw assigns with lists
- Always `to_form/2` → `@form` → `<.form for={@form}>`
- Preload associations before template access
- Avoid LiveComponents unless they need independent lifecycle
- Colocated hooks with `.` prefix for inline scripts
- Loading: topbar for page nav, `phx-submit-loading`/`phx-click-loading` variants, skeleton screens

### Required Hooks

| Hook | Purpose |
|---|---|
| `.CopyToClipboard` | Copy text to clipboard |
| `.UserTimezone` | Detect and send user timezone |
| `.InlineAlert` | Auto-dismiss inline alerts |
| `.SkeletonLoader` | Manage skeleton loading states |

### Dev Utilities (Browser)

| Shortcut | Tool |
|---|---|
| `Ctrl+Shift+K` | Clear all browser state |
| `Ctrl+Shift+G` | Grid/layout overlay |
| `Ctrl+Shift+S` | Spacing/box model debugger |
| `Ctrl+Shift+A` | Accessibility quick audit |
| `Ctrl+Shift+L` | LiveView debug panel |

## Environment Configuration (`.mise.toml`)

All environment variables are defined in `.mise.toml` at the project root. This is the single source of truth for configuration across dev, test, and production.

Install [mise](https://mise.jdx.dev/) and run `mise trust` in the project root to activate.

### Variables

| Variable | Default | Description |
|---|---|---|
| **Application** | | |
| `PORT` | `4000` | HTTP listen port |
| `PHX_HOST` | `localhost` | Hostname for URL generation |
| `PHX_SERVER` | `true` | Enable HTTP server |
| `SECRET_KEY_BASE` | — | Session signing key (`mix phx.gen.secret`) |
| **Database** | | |
| `DATABASE_URL` | — | Ecto connection string (prod only) |
| `POSTGRES_USER` | `postgres` | PostgreSQL user |
| `POSTGRES_PASSWORD` | `postgres` | PostgreSQL password |
| `POSTGRES_DB` | `aya_dev` | Database name |
| `POOL_SIZE` | `10` | DB connection pool size |
| `ECTO_SSL` | `false` | Enable SSL for DB connections (managed DBs) |
| **HTTP / SSL** | | |
| `PHX_HTTPS` | `false` | Enable HTTPS at the app level |
| `SSL_KEY_PATH` | — | Path to SSL private key |
| `SSL_CERT_PATH` | — | Path to SSL certificate |
| `PHX_HTTPS_PORT` | `443` | HTTPS listen port |
| `FORCE_SSL` | `true` | Compile-time: force HTTP→HTTPS redirect (HSTS) |
| **Migrations** | | |
| `AUTO_MIGRATE` | `false` | Run pending migrations on app boot |
| **Clustering** | | |
| `DNS_CLUSTER_QUERY` | — | DNS query for node discovery |
| **Docker** | | |
| `ELIXIR_VERSION` | `1.20.0-rc.3` | Elixir version for Docker image |
| `OTP_VERSION` | `28.4.1` | OTP version for Docker image |
| `DEBIAN_VERSION` | `trixie-20260316` | Debian version for Docker image |
| **Proxy** | | |
| `HTTP_PROXY` | — | HTTP proxy (corporate networks) |
| `HTTPS_PROXY` | — | HTTPS proxy (corporate networks) |
| `NO_PROXY` | — | Proxy bypass list |

For local overrides, create `.mise.local.toml` (gitignored).

## Local Development

### Prerequisites

- Elixir >= 1.19 / OTP >= 28 (managed by mise)
- PostgreSQL 17+

### Setup

```bash
mise trust          # activate .mise.toml
just setup          # deps.get + ecto.setup + assets
just dev            # start with iex
```

Visit [localhost:4000](http://localhost:4000).

### Common Commands

```bash
just dev            # iex -S mix phx.server
just server         # mix phx.server (no iex)
just console        # iex -S mix
just fmt            # mix format
just check          # compile --warnings-as-errors
just precommit      # compile + format + test
just test           # mix test
just test-file path # mix test <file>
```

### Database

```bash
just db-create      # mix ecto.create
just db-migrate     # mix ecto.migrate
just db-rollback    # rollback last migration
just db-rollback-n 3   # rollback last 3
just db-reset       # drop + create + migrate + seed
just db-status      # show migration status
just db-seed        # run seeds
```

## Docker Deployment

Aya ships as a multi-stage Docker image based on `hexpm/elixir` with full Debian Bookworm (not slim/alpine).

### Build

```bash
# Standard build
just docker-build

# Build with HTTP proxy (corporate/restricted networks)
just docker-build-proxy

# Build without cache
just docker-build-fresh
```

The build automatically vendors shared libs from `../../events/libs/` into `./libs/`.

### Run with Docker Compose

```bash
# Generate a secret key
just gen-secret

# Start (app + postgres)
just up

# Start and rebuild
just up-build

# View logs
just logs

# Stop
just down

# Stop and remove volumes
just down-clean
```

### Container Operations

```bash
just shell             # bash into the app container
just remote-console    # IEx remote console
```

### Migrations (Docker / Release)

Migrations can be run inside the container or via the release binary:

```bash
# Via Justfile
just docker-migrate            # run all pending
just docker-migrate-n 3        # run next 3
just docker-rollback           # rollback last
just docker-rollback-n 3       # rollback last 3
just docker-rollback-all       # rollback everything
just docker-migration-status   # show status
```

Or directly via the release binary / IEx:

```bash
# From release binary
bin/aya eval "Aya.Release.migrate()"
bin/aya eval "Aya.Release.migrate(3)"
bin/aya eval "Aya.Release.rollback_step()"
bin/aya eval "Aya.Release.rollback_step(3)"
bin/aya eval "Aya.Release.rollback_all()"
bin/aya eval "Aya.Release.rollback(Aya.Repo, 20260322043530)"
bin/aya eval "Aya.Release.migration_status()"
```

Or from IEx (locally or via remote console):

```elixir
Aya.Release.migrate()
Aya.Release.migrate(3)
Aya.Release.rollback_step()
Aya.Release.rollback_step(3)
Aya.Release.rollback_all()
Aya.Release.rollback(Aya.Repo, 20260322043530)
Aya.Release.migration_status()
```

Set `AUTO_MIGRATE=true` to run all pending migrations automatically on app boot (single-node deploys only).

## Elixir Conventions

- Pattern matching over conditionals — never `if..else`
- `@type` and `@spec` on all public functions
- Pipeline style preferred
- `FnTypes.Result` as standard return type (`{:ok, value}` / `{:error, reason}`)
- One module per file
- Always use UTC for timestamps

## Testing

```bash
just test               # run all tests
just test-cover         # with coverage
just test-file <path>   # single file
just test-only <tag>    # by tag
```

Tests live under `test/` mirroring `lib/` structure. Test support modules:

| Module | Purpose |
|---|---|
| `ConnCase` | Controller/plug tests with connection |
| `DataCase` | Context/schema tests with sandbox |
| `LiveCase` | LiveView integration tests |
| `Fixtures` | Test data generators |
| `HttpCase` | HTTP client testing with Mimic |
| `ProcessCase` | Process/GenServer testing |

Mocking uses `Mimic` (behaviour-based). HTML assertions use `lazy_html`.

## Reference

- **AGENTS.md** — Single source of truth for architecture, guidelines, and conventions (6000+ lines)
- [Phoenix docs](https://hexdocs.pm/phoenix)
- [LiveView docs](https://hexdocs.pm/phoenix_live_view)
- [Ecto docs](https://hexdocs.pm/ecto)
- [Tailwind CSS v4](https://tailwindcss.com/docs)
