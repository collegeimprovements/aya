# Aya — Food & Food Science Platform

Aya is a comprehensive food and food science application: Latest Food News, Recipes, Research Papers, Ingredients, Reports, and Market Trends.

**Stack:** Elixir 1.18+ (targeting 1.20+ features), Phoenix 1.8, LiveView, PostgreSQL, Tailwind CSS v4, Bandit.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Folder Structure](#folder-structure)
3. [Design System](#design-system)
4. [Shared Libraries](#shared-libraries)
5. [Elixir Guidelines](#elixir-guidelines)
6. [Phoenix & LiveView Guidelines](#phoenix--liveview-guidelines)
7. [CSS & JS Guidelines](#css--js-guidelines)
8. [Modern CSS & JS Features](#modern-css--js-features)
9. [Component Library](#component-library)
10. [Testing Framework](#testing-framework)
11. [Spec-Driven Development](#spec-driven-development)

---

## Architecture Overview

### Domain Contexts

Aya is organized into bounded contexts under `lib/aya/`:

| Context | Responsibility |
|---|---|
| `Aya.News` | Food news aggregation, RSS feeds, articles |
| `Aya.Recipes` | Recipe management, ingredients, steps, nutrition |
| `Aya.Research` | Academic papers, studies, food science publications |
| `Aya.Ingredients` | Ingredient database, properties, substitutions |
| `Aya.Reports` | Market reports, trend analysis, data aggregation |
| `Aya.Trends` | Market trends, price tracking, seasonal data |
| `Aya.Accounts` | Users, roles, URM (user_role_mappings), accounts, memberships, auth |
| `Aya.Content` | Shared content utilities: tagging, search, media |

Each context is a self-contained module with its own schemas, queries, and business logic. Contexts communicate through well-defined public APIs — never reach into another context's internal modules.

### Web Layer

Under `lib/aya_web/`:

| Directory | Purpose |
|---|---|
| `components/` | Shared UI components (`core_components.ex`, `layouts.ex`) |
| `components/ui/` | Domain-agnostic reusable UI components (cards, badges, skeleton, etc.) |
| `live/` | LiveView modules organized by context |
| `live/news_live/` | News-related LiveViews |
| `live/recipes_live/` | Recipe-related LiveViews |
| `controllers/` | Traditional controllers (health check, static pages, API) |
| `hooks/` | Co-located and external JS hooks |

### Supervision Tree

```
Aya.Application
├── Aya.Repo (PostgreSQL via Ecto)
├── AyaWeb.Telemetry
├── Phoenix.PubSub (Aya.PubSub)
├── DNSCluster
├── AyaWeb.Endpoint
└── (future: Aya.Scheduler, Aya.Cache, etc.)
```

---

## Folder Structure

```
aya/
├── AGENTS.md                          # THIS FILE — single source of truth
├── mix.exs                            # Dependencies and project config
├── config/
│   ├── config.exs                     # Base config (design system tokens live here)
│   ├── dev.exs                        # Development config
│   ├── test.exs                       # Test config
│   ├── prod.exs                       # Production config
│   └── runtime.exs                    # Runtime config (env vars)
│
├── lib/
│   ├── aya/                           # Domain / Business Logic
│   │   ├── application.ex             # OTP application & supervision tree
│   │   ├── repo.ex                    # Ecto repository
│   │   ├── mailer.ex                  # Email via Swoosh
│   │   │
│   │   ├── news/                      # News context
│   │   │   ├── news.ex                # Public API (Aya.News)
│   │   │   ├── article.ex             # Schema
│   │   │   ├── feed.ex                # Schema
│   │   │   └── feed_fetcher.ex        # Background job
│   │   │
│   │   ├── recipes/                   # Recipes context
│   │   │   ├── recipes.ex             # Public API (Aya.Recipes)
│   │   │   ├── recipe.ex              # Schema
│   │   │   └── ingredient_line.ex     # Schema
│   │   │
│   │   ├── research/                  # Research context
│   │   ├── ingredients/               # Ingredients context
│   │   ├── reports/                   # Reports context
│   │   ├── trends/                    # Trends context
│   │   ├── accounts/                  # Accounts context
│   │   └── content/                   # Shared content utilities
│   │
│   └── aya_web/                       # Web Layer
│       ├── aya_web.ex                 # Web module macros
│       ├── endpoint.ex                # Phoenix endpoint
│       ├── router.ex                  # All routes
│       ├── telemetry.ex               # Metrics
│       ├── gettext.ex                 # i18n backend
│       │
│       ├── components/                # UI Components
│       │   ├── core_components.ex     # Foundation components (flash, input, button, table, etc.)
│       │   ├── layouts.ex             # App layout, flash_group, theme toggle
│       │   ├── layouts/
│       │   │   ├── root.html.heex     # HTML skeleton (head, body, theme script)
│       │   │   └── app.html.heex      # App chrome (nav, sidebar, footer) — if extracted
│       │   └── ui/                    # Reusable UI components
│       │       ├── skeleton.ex        # Skeleton loading screens
│       │       ├── badge.ex           # Status badges
│       │       ├── card.ex            # Content cards
│       │       ├── empty_state.ex     # Empty state illustrations
│       │       └── inline_alert.ex    # Inline success/error/info messages
│       │
│       ├── live/                      # LiveViews by context
│       │   ├── news_live/
│       │   │   ├── index.ex           # News listing
│       │   │   └── show.ex            # Article detail
│       │   ├── recipes_live/
│       │   │   ├── index.ex
│       │   │   └── show.ex
│       │   └── home_live.ex           # Landing page
│       │
│       ├── controllers/               # Traditional controllers
│       │   ├── page_controller.ex     # Static pages
│       │   ├── page_html.ex
│       │   ├── page_html/
│       │   ├── health_controller.ex   # Health check endpoint
│       │   ├── error_html.ex
│       │   └── error_json.ex
│       │
│       └── hooks/                     # JS hook modules (for non-colocated hooks)
│           └── README.md              # Document hook conventions
│
├── assets/
│   ├── css/
│   │   └── app.css                    # Tailwind v4 entry + design tokens
│   ├── js/
│   │   └── app.js                     # JS entry, LiveSocket, hooks
│   ├── vendor/
│   │   ├── heroicons.js               # Heroicon plugin
│   │   └── topbar.js                  # Progress bar
│   └── tsconfig.json
│
├── priv/
│   ├── repo/
│   │   ├── migrations/                # Ecto migrations
│   │   └── seeds.exs                  # Seed data
│   ├── static/                        # Static assets (favicon, robots, images)
│   └── gettext/                       # Translation files
│
└── test/
    ├── test_helper.exs                # ExUnit config + Mimic setup
    ├── support/
    │   ├── conn_case.ex               # Controller test case
    │   ├── data_case.ex               # Data layer test case
    │   ├── live_case.ex               # LiveView test case (with timezone, auth helpers)
    │   ├── fixtures.ex                # Shared test fixtures / factories
    │   ├── http_case.ex               # HTTP/API integration test case (Mimic + Req)
    │   └── process_case.ex            # Process/GenServer test case
    ├── aya/                           # Domain tests (mirrors lib/aya/)
    │   ├── news/
    │   ├── recipes/
    │   └── ...
    └── aya_web/                       # Web tests (mirrors lib/aya_web/)
        ├── live/
        ├── controllers/
        └── ...
```

---

## Accounts Context (URM-based Identity & Audit)

The accounts context (`Aya.Accounts`) implements multi-tenant identity management using the **URM (User Role Mapping) pattern**. The URM ID is the central audit reference — every table tracks `created_by_urm_id` and `updated_by_urm_id` to know who did what, in what role, in what account.

**Authorization is rule-based, not RBAC.** Roles and URMs provide the identity/audit backbone. Actual authorization decisions will be rule-based (not role-lookup-based).

### Schemas

| Schema | Table | Purpose |
|---|---|---|
| `Aya.Accounts.Account` | `accounts` | Tenants/organizations (multi-tenant) |
| `Aya.Accounts.User` | `users` | Users with email/password auth, lockout protection |
| `Aya.Accounts.Role` | `roles` | Global or account-scoped roles with permissions (JSONB) |
| `Aya.Accounts.UserRoleMapping` | `user_role_mappings` | **Central audit table** — assigns roles to users in accounts |
| `Aya.Accounts.Membership` | `memberships` | User-to-account join (GitHub org model) |
| `Aya.Accounts.UserToken` | `users_tokens` | Session/email tokens (phx.gen.auth pattern) |

### Bootstrap Data

Seeded in migration — always present:

| Entity | ID | Purpose |
|---|---|---|
| Default Account | `Aya.Constants.default_account_id()` | Single-tenant fallback |
| System User | `Aya.Constants.system_user_id()` | Automated operations (cannot login) |
| System Role | `Aya.Constants.system_role_id()` | `super_admin` with `{"*": true}` permissions |
| System URM | `Aya.Constants.system_urm_id()` | Default audit field value, links system user + role + account |

### Key API (`Aya.Accounts`)

**Auth:** `register_user/1`, `authenticate_user/3` (with lockout), `generate_user_session_token/1`, `get_user_by_session_token/1`

**Roles:** `assign_role/4`, `remove_role/3`, `has_role?/3`, `get_user_roles/2`, `list_urms_for_user/1`

**Memberships:** `add_user_to_account/3`, `remove_user_from_account/2`, `member?/2`

**Generated CRUD (via OmCrud):** All schemas get `create_*`, `get_*`, `list_*`, `update_*`, `delete_*` and bang variants. URM is aliased as `urm` — e.g., `create_urm/1`, `list_urms/0`.

### URM Audit Pattern

All future tables should include audit fields referencing URM:

```elixir
# In schema
audit_fields()  # adds created_by_urm_id, updated_by_urm_id

# In migration
add :created_by_urm_id, :uuid, default: fragment("'#{system_urm_id_const()}'::uuid")
add :updated_by_urm_id, :uuid, default: fragment("'#{system_urm_id_const()}'::uuid")
```

---

## Design System

### Philosophy

The design system is **config-driven**. All visual tokens (colors, spacing, typography, radii, shadows) are defined as CSS custom properties in `assets/css/app.css` and can be swapped by changing a single theme config. The goal:

- **One place to change colors** → entire app updates
- **Color scheme variants** → e.g., warm-earth (default), blue-clean, red-bold — switchable via config
- **Dark mode** → automatic via `[data-theme="dark"]` attribute on `<html>`
- **Responsive** → mobile-first grid system via Tailwind's built-in breakpoints
- **Accessible** → proper contrast ratios, focus states, reduced-motion support

### Color Token Structure

All colors use CSS custom properties with semantic names, NOT raw color values in templates:

```css
/* Surfaces */
--color-surface          /* Main background */
--color-surface-alt      /* Alternate/card background */
--color-surface-hover    /* Hover state */
--color-surface-invert   /* Inverted (for contrast elements) */

/* Text */
--color-text             /* Primary text */
--color-text-secondary   /* Secondary/supporting text */
--color-text-muted       /* Disabled/placeholder text */
--color-text-invert      /* Text on inverted surfaces */

/* Brand */
--color-primary          /* Primary action color */
--color-primary-hover    /* Primary hover */
--color-primary-soft     /* Primary background tint (for badges, alerts) */
--color-primary-text     /* Text on primary */

--color-secondary        /* Secondary action */
--color-accent           /* Accent/highlight */

/* Semantic */
--color-info / --color-info-soft
--color-success / --color-success-soft
--color-warning / --color-warning-soft
--color-error / --color-error-soft

/* Chrome */
--color-border           /* Default borders */
--color-border-strong    /* Emphasized borders */
--color-ring             /* Focus ring color */
--color-link             /* Link color (distinct from text, NO underline) */
--color-link-hover       /* Link hover */
```

### Using Colors in Templates

**Always** use the design token classes. **Never** use raw Tailwind color utilities (`text-red-500`, `bg-blue-200`):

```heex
<%!-- CORRECT: semantic tokens --%>
<div class="bg-surface text-text border border-border">
  <a class="text-link hover:text-link-hover">Click me</a>
  <p class="text-text-secondary">Supporting text</p>
</div>

<%!-- WRONG: raw colors --%>
<div class="bg-white text-gray-900 border border-gray-200">
  <a class="text-blue-600 underline">Click me</a>
</div>
```

### Links

Links use **color differentiation**, NOT underlines:
- Default: `text-link` (uses `--color-link`)
- Hover: `hover:text-link-hover` with subtle transition
- **Never** use `underline` on links unless inside prose/article content

#### Extended `<.link>` (CoreComponents override)

Aya overrides `Phoenix.Component.link/1` in `CoreComponents` via `import Phoenix.Component, except: [link: 1]`. The replacement is a **strict superset** — all Phoenix attrs work, plus:

**Resource hints** (browser-native prefetching):

| Attr | Trigger | Mechanism | Best for |
|---|---|---|---|
| `prefetch` | Hover/touch | JS injects `<link rel="prefetch">` on mouseenter | Nav links, sidebar, cards |
| `preload` | Render | Server renders `<link rel="prefetch">` | Wizard next step, onboarding |
| `prerender` | Render | `<script type="speculationrules">` | Chrome-only, high-confidence |

**Convenience attrs:**

| Attr | What it does | Renders |
|---|---|---|
| `external` | Opens in new tab safely | `target="_blank" rel="noopener noreferrer"` |
| `active` | Marks link as current page | `aria-current="page"` + `active_class` |
| `active_class` | Custom active styling | Default: `"text-text font-medium"` |
| `disabled` | Prevents navigation, dims | `aria-disabled="true"`, `pointer-events-none` |
| `loading` | Shows spinner during nav | Inline SVG spinner visible during `phx-click-loading` |

**Rules:**
- Use `prefetch` on all navigation links (zero cost until hover)
- Use `external` for any link leaving the app (never manually write `target="_blank"`)
- Use `active` for nav/sidebar links (never manually compare paths in class attrs)
- Use `disabled` for permission-gated links (never hide links — disable them)
- Avoid `prerender` for LiveView pages (too expensive — full mount + WebSocket)

**Pattern:**
```elixir
# Sidebar nav
<.link navigate={~p"/recipes"} prefetch active={@page == :recipes}>Recipes</.link>

# External
<.link href="https://github.com" external>GitHub</.link>

# Permission-gated
<.link navigate={~p"/admin"} disabled={!@is_admin} prefetch>Admin</.link>
```

### Spacing & Typography

Use Tailwind's default spacing scale. For consistent section spacing:
- Page padding: `px-4 sm:px-6 lg:px-8`
- Section gap: `space-y-8` or `gap-8`
- Card padding: `p-4 sm:p-6`
- Typography: system font stack, sizes via Tailwind (`text-sm`, `text-base`, `text-lg`, etc.)

### Responsive Breakpoints

Follow Tailwind's mobile-first breakpoints:
- Base: mobile (< 640px)
- `sm:` — 640px+
- `md:` — 768px+
- `lg:` — 1024px+
- `xl:` — 1280px+

### Skeleton Screens

For loading states, use skeleton components instead of spinners:

```heex
<.skeleton type="text" lines={3} />
<.skeleton type="card" />
<.skeleton type="table" rows={5} cols={4} />
```

### Inline Alerts

For inline success/error/info messages (not toast-style):

```heex
<.inline_alert type={:success}>Item saved successfully</.inline_alert>
<.inline_alert type={:error}>Failed to save</.inline_alert>
```

### Theme Toggle

Three modes: System (auto) / Light / Dark. Persisted to `localStorage`. Applied via `data-theme` attribute on `<html>` before paint to prevent flash.

### Design Engineering (via `emil-design-engineering` + `make-interfaces-feel-better` skills)

Both skills are installed and should be consulted for all UI work. The `emil-design-engineering` skill provides the broader design engineering framework (easing, forms, touch, accessibility, marketing pages), while `make-interfaces-feel-better` focuses on micro-interactions and visual polish details. Key principles to always apply:

#### Typography
- **Headings**: `text-wrap: balance` (Tailwind: `text-balance`)
- **Body text**: `text-wrap: pretty` (Tailwind: `text-pretty`)
- **Font smoothing**: already applied in `app.css` (`-webkit-font-smoothing: antialiased`)
- **Dynamic numbers**: always use `tabular-nums` (counters, prices, timers, table columns)
- **Vertical text centering** (`text-box`): trim leading/trailing whitespace from text for true optical centering — eliminates manual padding adjustments:
  ```css
  .button, .badge, .tag {
    text-box: trim-both cap alphabetic; /* trims above cap-height and below alphabetic baseline */
  }
  ```
  - `text-box-trim`: `trim-start` | `trim-end` | `trim-both` — which sides to trim
  - `text-box-edge`: `cap` (top metric), `alphabetic` (bottom metric) — which text metrics to trim to
  - Shorthand: `text-box: trim-both cap alphabetic`
  - Use on buttons, badges, headings, and any element where vertical centering looks "off" despite correct padding

#### Surfaces
- **Concentric border radius**: `outerRadius = innerRadius + padding` — mismatched radii on nested elements is the #1 thing that makes UIs feel off
- **Optical alignment over geometric**: buttons with icons need less padding on the icon side (`icon-side = text-side - 2px`)
- **Shadows over borders**: for cards, buttons, elevated elements — use layered `box-shadow` with transparency. Keep borders for dividers/separators
- **Image outlines**: subtle `outline: 1px solid rgba(0,0,0,0.1); outline-offset: -1px` on images for depth
- **Min hit area**: interactive elements need at least 40x40px — extend with pseudo-element if visible element is smaller

#### Animations
- **Interruptible**: always use CSS transitions for interactive states (hover, toggle, open/close) — they can be interrupted mid-animation. Reserve keyframes for one-shot sequences
- **Enter animations**: split content into semantic chunks, stagger ~100ms delay, combine `opacity` + `blur(4px)` + `translateY(12px)`
- **Exit animations**: subtle — small fixed `translateY(-12px)`, shorter duration than enter (150ms vs 300ms)
- **Icon animations**: animate with `opacity`, `scale(0.25→1)`, `blur(4px→0)` — never toggle visibility
- **Scale on press**: `active:scale-[0.96]` on buttons for tactile feedback (never below 0.95)

#### Easing & Duration (from `emil-design-engineering`)
- **Easing blueprint**: `ease-out` for enters/mounts, `ease-in-out` for position/size changes, `ease` for hover/color transitions. Never `linear` for UI motion
- **Duration scale**: 100–150ms for micro-interactions (hover, toggle), 150–250ms for UI transitions (panels, dropdowns), 300ms+ for modals/page transitions
- **Frequency principle**: reduce animation intensity when action repeats frequently — a button clicked 50x/day needs less fanfare than a first-run onboarding
- **Spring animations**: prefer for drag/gesture responses where overshooting feels natural; use CSS transitions everywhere else. Use the `/css-spring` skill to generate `linear()` easing curves that simulate spring physics in pure CSS. Use `/see-transition` to visualize any easing curve before committing to it
- **`linear()` easing function**: define custom easing curves as a series of points — replaces `cubic-bezier()` for complex curves that cubic-bezier can't express (multi-bounce, spring, elastic):
  ```css
  /* Bounce easing — impossible with cubic-bezier */
  transition: transform 600ms linear(
    0, 0.5 25%, 1 50%, 0.85 60%, 1 70%, 0.95 80%, 1
  );
  ```
  - Each value is a stop point (0–1), optional percentage sets the position
  - Use the `/css-spring` skill to generate `linear()` curves automatically
  - Use for: spring physics, bounce, elastic, custom organic motion

#### Forms & Controls (from `emil-design-engineering`)
- **Input font-size ≥ 16px**: prevents iOS Safari auto-zoom on focus
- **Label association**: every `<input>` must have an associated `<label>` (via `for=`/`id=` or wrapping)
- **Form Enter submission**: wrap related inputs in a `<form>` so Enter submits. Use `phx-submit` on the form, not `phx-click` on the button
- **Cmd+Enter for textareas**: textareas consume Enter for newlines — bind Cmd/Ctrl+Enter for submission
- **Button semantics**: use `<button>` for actions, `<.link>` for navigation — never a styled `<div>`
- **Disable after submit**: prevent double submission by disabling the submit button during `phx-submit` processing (Phoenix's `phx-disable-with` handles this)
- **Checkbox dead zones**: ensure the label is clickable, not just the tiny checkbox input
- **`inputmode`**: set the right mobile keyboard — `inputmode="numeric"` for quantities/amounts, `inputmode="decimal"` for prices, `inputmode="search"` for search fields, `inputmode="email"` for email, `inputmode="tel"` for phone. Avoids the wrong keyboard layout on mobile
- **`enterkeyhint`**: customize the Enter key label — `enterkeyhint="search"` shows a search icon, `enterkeyhint="send"` shows send, `enterkeyhint="next"` for multi-step forms. Communicates intent to the user

#### Touch & Accessibility (from `emil-design-engineering`)
- **Hover on touch**: wrap hover effects in `@media (hover: hover)` — touch devices don't have hover, so hover states get "stuck"
- **Touch-action**: use `touch-action: manipulation` on interactive elements to disable double-tap-to-zoom delay
- **Tap targets**: minimum 44x44px (WCAG) — extend with padding or pseudo-elements if the visible element is smaller
- **Tooltips**: show on hover with 200ms delay (avoid flicker on mouse movement), accessible via `aria-describedby`
- **`prefers-reduced-motion`**: wrap all animations in `@media (prefers-reduced-motion: no-preference)` or use Tailwind's `motion-safe:` prefix
- **Focus-visible**: style focus rings with `:focus-visible` (not `:focus`) so keyboard users see them, mouse users don't
- **ARIA labels**: icon-only buttons always need `aria-label`; decorative icons get `aria-hidden="true"`
- **`reading-flow`**: control keyboard tab and screen reader order for flex/grid children — ensures visual reordering doesn't break accessibility:
  ```css
  /* Tab order follows visual flex layout, not DOM order */
  .reordered-nav { display: flex; flex-direction: row-reverse; reading-flow: flex-visual; }
  /* Tab order follows grid area placement */
  .dashboard { display: grid; reading-flow: grid-rows; }
  ```
  - `reading-flow: flex-visual` — tab order matches visual flex order (respects `order`, `row-reverse`, etc.)
  - `reading-flow: grid-rows` / `grid-columns` — tab order follows grid placement
  - Replaces manual `tabindex` management when CSS reorders elements visually

#### Layout Shift Prevention (from `emil-design-engineering`)
- **Hardcode dimensions**: images, avatars, and media should have explicit `width`/`height` or aspect-ratio to prevent CLS
- **Skeleton screens**: match exact layout dimensions (already enforced via our `<.skeleton>` component)
- **Font loading**: use `font-display: swap` and preload critical fonts to prevent FOIT/FOUT

#### Marketing & Content Pages (from `emil-design-engineering`)
- **No scroll-jacking**: never override native scroll behavior with parallax or scroll-linked animations
- **No auto-advance carousels**: let users control navigation pace
- **Intro animations**: gate with `sessionStorage` so they only play once per session, not on every page load
- **Context-based CTAs**: tailor call-to-action copy to page content, not generic "Sign Up" everywhere
- **Code snippets**: include copy-to-clipboard button on all code blocks

#### Animation Performance (informed by `/motion-audit` skill)

Use the `/motion-audit` skill to audit animation code. Animations are classified into render-pipeline tiers:

| Tier | Pipeline | Properties | Goal |
|------|----------|------------|------|
| **S** | Compositor only | `transform`, `opacity`, `filter`, `clip-path` | Target for all interactive animations |
| **A** | Main thread → compositor | JS-driven S-tier properties | Acceptable for JS hooks with `motion` |
| **B** | DOM setup + S/A | FLIP technique, layout animations | Use sparingly for reorder/resize |
| **C** | Paint trigger | `background-color`, `box-shadow`, `outline` | Avoid in loops; OK for one-shot hover |
| **D** | Layout trigger | `width`, `height`, `margin`, `padding`, `top/left` | **Never animate** — use `transform` instead |
| **F** | Layout thrashing | Interleaved DOM reads/writes | **Bug** — always fix |

**Rules:**
- **Never** use `transition: all` or Tailwind's bare `transition` — always specify exact properties: `transition-[scale,opacity]`
- **`will-change`**: only for `transform`, `opacity`, `filter` — never `all`, and only when you notice first-frame stutter
- **Animate only S-tier properties** in CSS transitions. If you need to animate size/position, use the FLIP technique (`transform: scale()` / `translate()`) instead of animating `width`/`height`/`top`/`left`
- **No layout thrashing**: never interleave DOM reads (`getBoundingClientRect()`, `offsetHeight`) with writes (`style.transform = ...`) in a loop — batch reads then writes
- **Individual transform properties**: use `translate`, `rotate`, `scale` as separate properties instead of the `transform` shorthand — they compose independently and can be animated separately without overriding each other:
  ```css
  .card {
    scale: 1;
    translate: 0 0;
    rotate: 0deg;
    transition: scale 150ms ease-out, translate 300ms ease-out;
  }
  .card:hover {
    scale: 1.02;        /* doesn't reset translate or rotate */
  }
  .card:active {
    scale: 0.96;
  }
  .card.dragging {
    translate: var(--dx) var(--dy);  /* doesn't reset scale */
    rotate: 2deg;
  }
  ```
  - Each property animates on its own timeline — no need to re-specify the entire `transform` string
  - Avoids the classic bug where `transform: scale(1.02)` on hover resets `transform: translateX(10px)` from another state
  - All three are S-tier (compositor-only) properties

#### Motion JS Library (via `/motion` skill)

For complex animations in JS hooks (drag, gesture, scroll-linked, orchestrated sequences), use the [Motion](https://motion.dev) library (vanilla JS — `import { animate } from "motion"`). This is optional — prefer pure CSS transitions for simple interactions. When using Motion in hooks:

- Import from `"motion"` (vanilla JS), not `"motion/react"`
- Use `animate(element, { transform, opacity }, { duration, easing })` syntax
- Prefer `willChange` option over CSS `will-change` for automatic cleanup
- Avoid object allocation inside `requestAnimationFrame` callbacks

#### Review Checklist for UI Work
- [ ] Nested rounded elements use concentric border radius
- [ ] Icons are optically centered
- [ ] Shadows used instead of borders for depth (borders only for dividers)
- [ ] Enter animations are split and staggered with correct easing (`ease-out`)
- [ ] Exit animations are subtle
- [ ] Dynamic numbers use `tabular-nums`
- [ ] Headings use `text-balance`, body uses `text-pretty`
- [ ] Images have subtle outlines and explicit dimensions (no layout shift)
- [ ] Buttons use `active:scale-[0.96]` where appropriate
- [ ] No `transition: all` — only specific properties
- [ ] All animated properties are S-tier (transform, opacity, filter) — no width/height/top/left
- [ ] Interactive elements have at least 44x44px tap target
- [ ] Hover effects wrapped in `@media (hover: hover)` or Tailwind `hover:` (which handles this)
- [ ] Inputs have associated labels and font-size ≥ 16px
- [ ] Icon-only buttons have `aria-label`
- [ ] Animations respect `prefers-reduced-motion` (use `motion-safe:`)
- [ ] Focus rings use `focus-visible:` not `focus:`
- [ ] Stagger delays use `sibling-index()` instead of hardcoded `nth-child` values
- [ ] Buttons/badges use `text-box: trim-both cap alphabetic` for vertical centering
- [ ] Dialog/popover toggling uses `commandfor`/`command` attributes before reaching for JS
- [ ] Tooltips use `interestfor` + `popover="hint"` before reaching for JS hooks
- [ ] Dialogs have appropriate `closedby` attribute

---

## Shared Libraries

Aya leverages the shared library ecosystem at `../../events/libs/`. These are **path dependencies** in `mix.exs`.

### Core Libraries (always use)

| Library | Purpose | Usage |
|---|---|---|
| `fn_types` | Result, Maybe, Pipeline, Validation, Guards | Error handling, function composition |
| `fn_decorator` | Composable decorators (caching, telemetry) | Cross-cutting concerns |
| `om_schema` | Enhanced Ecto schema macros, validation pipelines | All schemas |
| `om_query` | Pipeline query builder, search, pagination | All queries |
| `om_crud` | CRUD helpers, batch ops, soft delete | Data operations |
| `om_migration` | Composable migration DSL | All migrations |
| `om_behaviours` | Adapter, Builder, Service, Worker behaviors | Architecture patterns |
| `om_middleware` | Middleware abstractions | Request/data pipelines |
| `om_credo` | Custom Credo checks | Code quality (dev/test only) |

### HTTP & External APIs

| Library | Purpose | Usage |
|---|---|---|
| `om_http` | Shared HTTP utilities, proxy config | Foundation for HTTP |
| `om_api_client` | Middleware-based HTTP client on Req | All external API calls |
| `om_rss` | RSS/Atom/JSON feed parser & fetcher | Food news aggregation |

### Infrastructure

| Library | Purpose | Usage |
|---|---|---|
| `om_cache` | Nebulex cache wrapper (Redis/Local) | Caching API responses, feeds |
| `om_scheduler` | Cron + interval job scheduling | Feed fetching, report generation |
| `om_health` | Health monitoring | `/health` endpoint |

### Supporting

| Library | Purpose |
|---|---|
| `dag` | Directed Acyclic Graph (dependency of effect, om_scheduler) |
| `effect` | Composable workflow orchestration, saga pattern, parallel execution |

### When to Extend Shared Libs

If a shared library doesn't do what you need or has a bug:
1. **Fix it directly** in `/Users/arpit/Documents/Projects/events/libs/{lib_name}/`
2. Add tests for the fix in the library's own test suite
3. The path dependency means Aya picks up changes immediately

---

## Elixir Guidelines

### Modern Elixir (1.18+ / targeting 1.20+)

- **Pattern matching over conditionals**: Prefer multi-clause functions, `case`, and `cond` over `if..else`. **Never** use `if..else` — always use pattern matching, `case`, or `cond`
- **Type safety**: Use `@type` and `@spec` annotations on all public functions. When Elixir 1.20 set-theoretic types are available, adopt them
- **Pipeline style**: Prefer `|>` pipelines for data transformation chains
- **`with` for happy paths**: Use `with` + pattern matching for multi-step operations that can fail
- Use `FnTypes.Result` (`{:ok, value}` / `{:error, reason}`) as the standard return type for fallible operations

### Pattern Matching Rules

```elixir
# PREFERRED: multi-clause functions
def process(%{type: :article} = item), do: handle_article(item)
def process(%{type: :recipe} = item), do: handle_recipe(item)
def process(%{type: _} = item), do: handle_generic(item)

# PREFERRED: case when matching on a single value
case Repo.insert(changeset) do
  {:ok, record} -> {:ok, record}
  {:error, changeset} -> {:error, changeset}
end

# NEVER: if..else
# if item.type == :article do ... else ... end
```

### Naming Conventions

- Modules: `Aya.News.Article` (singular for schemas, context module is plural namespace)
- Context APIs: `Aya.News.list_articles/1`, `Aya.News.get_article!/1`, `Aya.News.create_article/1`
- Predicates: end with `?` — `published?/1`, NOT `is_published/1` (reserve `is_` for guards)
- Private helpers: descriptive names, no `do_` prefix convention

### Immutability & Rebinding

Variables are immutable but can be rebound. Block expressions (`case`, `cond`, `with`) must bind their result:

```elixir
# CORRECT
socket =
  case action do
    :create -> assign(socket, :mode, :new)
    :edit -> assign(socket, :mode, :edit)
  end

# WRONG — rebinding inside block doesn't propagate
case action do
  :create -> socket = assign(socket, :mode, :new)
  :edit -> socket = assign(socket, :mode, :edit)
end
```

### Elixir Lists

Lists do NOT support index access via `[]`. Use `Enum.at/2`, pattern matching, or `hd/tl`:

```elixir
# WRONG
mylist[0]

# CORRECT
Enum.at(mylist, 0)
[first | _rest] = mylist
```

### OTP & Processes

- Use `start_supervised!/1` in tests
- Use `Process.monitor/1` + `assert_receive {:DOWN, ...}` instead of `Process.sleep`
- `DynamicSupervisor` and `Registry` need names in child specs
- Use `Task.async_stream/3` with `timeout: :infinity` for concurrent enumeration

### Date/Time

- Use `DateTime`, `Date`, `Time`, `Calendar` from stdlib
- **Always** store timestamps in UTC in the database (`utc_datetime` / `utc_datetime_usec`)
- Convert to user's timezone only at the presentation layer (LiveView)
- Get user timezone from browser via JS hook (see [JS Hooks](#co-located-js-hooks))
- Use the `tz` library only if timezone database is needed beyond what stdlib provides

### Module Organization

- **Never** nest multiple modules in the same file
- One module per file, file path mirrors module name
- Keep modules focused — if a module exceeds ~200 LOC, consider splitting

---

## Phoenix & LiveView Guidelines

### Phoenix 1.8 Specifics

- **Always** begin LiveView templates with `<Layouts.app flash={@flash}>` wrapper
- `AyaWeb.Layouts` is aliased in `aya_web.ex` — no need to re-alias
- `<.flash_group>` component lives in `Layouts` module — **forbidden** outside it
- `Phoenix.View` is gone — don't use it
- Use `<.icon name="hero-x-mark" />` for all icons (never Heroicons modules)
- Use `<.input field={@form[:name]} type="text" />` for all form inputs

### Router

- `scope` blocks provide alias prefix — don't add redundant aliases
- LiveViews use `Live` suffix: `AppWeb.NewsLive.Index`
- **Never** use deprecated `live_redirect` / `live_patch` — use `<.link navigate={...}>` / `<.link patch={...}>`

### LiveView Conventions

- **Streams for collections**: Always use `stream/3` for lists. Never assign raw lists that grow
- Stream parent needs `phx-update="stream"` and a DOM `id`
- Streams are NOT enumerable — refetch + `reset: true` to filter
- Track empty state with separate assign or CSS `hidden only:block` trick
- **Avoid LiveComponents** unless you have a strong reason (independent lifecycle needed)
- Name LiveViews: `AyaWeb.NewsLive.Index`, `AyaWeb.NewsLive.Show`

### Forms

- Always `to_form/2` in LiveView → `@form` assign → `<.form for={@form}>`
- **Never** pass changesets directly to templates
- **Never** use `<.form let={f}>` — always `<.form for={@form}>`
- Unique DOM IDs on all forms: `id="article-form"`

### Ecto

- Preload associations before accessing in templates
- `field :name, :string` even for `:text` columns
- Use `Ecto.Changeset.get_field/2` to read changeset fields
- Don't cast programmatically-set fields (`user_id`) in `cast/3`
- Generate migrations with `mix ecto.gen.migration name_with_underscores`
- **Never** use `changeset[:field]` — structs don't implement Access

---

## CSS & JS Guidelines

### Tailwind CSS v4

- Uses new import syntax in `app.css` — **no `tailwind.config.js` needed**
- **Never** use Tailwind's `@apply` to extract utility classes into CSS (this is the Tailwind directive, not native CSS `@mixin`/`@apply` — the native CSS feature is fine, see [CSS Mixins](#css-mixins-mixin--apply))
- **Always** use semantic design tokens (see [Design System](#design-system))
- **Never** use raw Tailwind color utilities (`text-red-500`) — use token classes (`text-error`)
- Class lists use `[...]` syntax for conditionals:

```heex
<div class={[
  "px-4 py-2 rounded-md",
  @active && "bg-primary text-primary-text",
  !@active && "bg-surface-alt text-text-secondary"
]}>
```

### JavaScript

- Only `app.js` and `app.css` bundles are supported
- **Never** write inline `<script>` tags in templates
- **Never** reference external vendor script `src` in layouts
- Import vendor deps into `app.js`

### Co-located JS Hooks

Use colocated hooks for inline scripts in HEEx. Hook names **MUST** start with `.`:

```heex
<div id="copy-target" phx-hook=".CopyToClipboard" data-content={@content}>
  <button>Copy</button>
</div>
<script :type={Phoenix.LiveView.ColocatedHook} name=".CopyToClipboard">
  export default {
    mounted() {
      this.el.querySelector("button").addEventListener("click", () => {
        navigator.clipboard.writeText(this.el.dataset.content)
      })
    }
  }
</script>
```

### Required JS Hooks

These hooks should be implemented as colocated hooks:

| Hook | Purpose | Trigger |
|---|---|---|
| `.CopyToClipboard` | Copy text to clipboard | Button click |
| `.UserTimezone` | Detect user's IANA timezone, push to server | Mount |
| `.InlineAlert` | Auto-dismiss inline alerts after timeout | Mount |
| `.SkeletonLoader` | Transition from skeleton → real content | Update |

#### Timezone Hook Pattern

```heex
<div id="tz-detector" phx-hook=".UserTimezone" class="hidden" />
<script :type={Phoenix.LiveView.ColocatedHook} name=".UserTimezone">
  export default {
    mounted() {
      const tz = Intl.DateTimeFormat().resolvedOptions().timeZone
      this.pushEvent("set_timezone", { timezone: tz })
    }
  }
</script>
```

Server-side handler stores timezone in socket assigns for display formatting.

### Loading Indicators

- **Page navigation**: topbar.js (already configured)
- **Form submission**: `phx-submit-loading` variant classes
- **Button clicks**: `phx-click-loading` variant with spinner icon
- **Content loading**: Skeleton screen components (not spinners)
- **Inline operations**: Inline alert that shows success/error after completion

### External JS Hook Pattern (assets/js/)

For complex hooks that need their own files:

```js
// assets/js/hooks/my_hook.js
export default {
  mounted() { ... },
  updated() { ... },
  destroyed() { ... }
}
```

Import in `app.js` and pass to LiveSocket constructor.

### Dev Utilities (localhost only)

#### Clear All Browser State (`Ctrl+Shift+K`)

One command to nuke all client-side state — localStorage, sessionStorage, cookies, caches, IndexedDB, service workers. Essential during development when stale state causes confusing bugs.

#### JS Utility — `assets/js/dev/clear_all.js`

```js
/**
 * Clear all browser state for this origin.
 * Call via console: __clearAll()
 * Or keyboard shortcut: Ctrl+Shift+K (dev only)
 */
export async function clearAll() {
  const results = []

  // 1. localStorage
  const lsCount = localStorage.length
  localStorage.clear()
  results.push(`localStorage: ${lsCount} items`)

  // 2. sessionStorage
  const ssCount = sessionStorage.length
  sessionStorage.clear()
  results.push(`sessionStorage: ${ssCount} items`)

  // 3. Cookies (all for this origin)
  const cookies = document.cookie.split(";")
  for (const cookie of cookies) {
    const name = cookie.split("=")[0].trim()
    if (name) {
      document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/`
      document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/;domain=${location.hostname}`
    }
  }
  results.push(`cookies: ${cookies.filter(c => c.trim()).length} cleared`)

  // 4. Cache API (service worker caches)
  if ("caches" in window) {
    const cacheNames = await caches.keys()
    await Promise.all(cacheNames.map(name => caches.delete(name)))
    results.push(`caches: ${cacheNames.length} stores`)
  }

  // 5. IndexedDB
  if ("indexedDB" in window) {
    const dbs = await indexedDB.databases()
    for (const db of dbs) {
      indexedDB.deleteDatabase(db.name)
    }
    results.push(`indexedDB: ${dbs.length} databases`)
  }

  // 6. Service Workers
  if ("serviceWorker" in navigator) {
    const registrations = await navigator.serviceWorker.getRegistrations()
    await Promise.all(registrations.map(r => r.unregister()))
    results.push(`serviceWorkers: ${registrations.length} unregistered`)
  }

  // 7. BroadcastChannel — notify other tabs
  try {
    const channel = new BroadcastChannel("clear-all")
    channel.postMessage({ action: "clear" })
    channel.close()
    results.push("broadcast: notified other tabs")
  } catch (_) {}

  console.log(
    "%c🧹 All browser state cleared",
    "color: #c2410c; font-weight: bold; font-size: 14px"
  )
  console.table(results.map(r => {
    const [area, detail] = r.split(": ")
    return { area, detail }
  }))

  return results
}
```

#### Wire into `app.js` (dev only)

```js
// app.js — at the bottom, dev-only block
if (window.location.hostname === "localhost") {
  import("./dev/clear_all.js").then(({ clearAll }) => {
    // Expose globally for console: __clearAll()
    window.__clearAll = async () => {
      await clearAll()
      window.location.reload()
    }

    // Keyboard shortcut: Ctrl+Shift+K
    document.addEventListener("keydown", async (e) => {
      if (e.ctrlKey && e.shiftKey && e.key === "K") {
        e.preventDefault()
        if (confirm("Clear all browser state and reload?")) {
          await clearAll()
          window.location.reload()
        }
      }
    })
  })
}
```

**Three ways to trigger:**
1. **Keyboard**: `Ctrl+Shift+K` — shows confirmation dialog, clears, reloads
2. **Console**: `__clearAll()` — clears and reloads
3. **Other tabs**: automatically cleared via `BroadcastChannel` when triggered from any tab

#### Server-side: Mix Task

```elixir
# lib/mix/tasks/dev.clear.ex
defmodule Mix.Tasks.Dev.Clear do
  @moduledoc "Clear all development state: sessions, caches, tmp files."
  @shortdoc "Clear all dev state"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    # Clear Phoenix session/cookie signing salt (forces all sessions to invalidate)
    Mix.shell().info("Clearing tmp files...")
    File.rm_rf!("tmp")
    File.mkdir_p!("tmp")

    # Clear any file-based caches
    File.rm_rf!("priv/static/cache")

    # Clear Ecto sandbox state
    Mix.shell().info("Resetting database connections...")
    Mix.Task.run("ecto.reset", [])

    Mix.shell().info("""

    ✓ Server state cleared. To also clear browser state:
      1. Open the app in Chrome
      2. Press Ctrl+Shift+K
      — or —
      Open DevTools console and run: __clearAll()
    """)
  end
end
```

#### Full Nuclear Option (one shell command)

```bash
# Clear everything — server + trigger browser clear on next load
mix dev.clear && echo "Now press Ctrl+Shift+K in the browser"
```

Or add a convenience alias in `mix.exs`:

```elixir
defp aliases do
  [
    # ... existing aliases ...
    "dev.nuke": ["dev.clear", "cmd echo '\nPress Ctrl+Shift+K in browser to clear client state'"]
  ]
end
```

#### What Gets Cleared

| Storage | Cleared by | Contains |
|---|---|---|
| `localStorage` | `Ctrl+Shift+K` | Theme preference, dismissed banners, intro animation flags |
| `sessionStorage` | `Ctrl+Shift+K` | Scroll positions, feed cursors, session-scoped UI state |
| Cookies | `Ctrl+Shift+K` | Session cookie, CSRF token, LiveView session |
| Cache API | `Ctrl+Shift+K` | Service worker caches (if any) |
| IndexedDB | `Ctrl+Shift+K` | Offline data stores (if any) |
| Service Workers | `Ctrl+Shift+K` | Background workers (if any) |
| DB / Ecto | `mix dev.clear` | Development database (full reset) |
| tmp files | `mix dev.clear` | Uploaded files, generated artifacts |

#### Screen Size & Breakpoint Indicator

A fixed badge in the corner showing the current viewport dimensions and active Tailwind breakpoint. Invaluable for responsive development.

**CSS-only approach** — zero JS, uses Tailwind's responsive prefixes:

```heex
<%!-- In app.html.heex or root.html.heex, wrapped in dev check --%>
<%= if Application.get_env(:aya, :dev_tools, false) do %>
  <div id="dev-breakpoint"
       class="fixed bottom-1 right-1 z-[99999] flex items-center gap-1.5
              rounded-full bg-surface-invert/90 px-2.5 py-1 font-mono text-xs
              text-text-invert shadow-lg backdrop-blur-sm
              pointer-events-none select-none"
  >
    <%!-- Viewport dimensions (JS-updated) --%>
    <span id="dev-viewport-size" class="tabular-nums opacity-70"></span>
    <span class="opacity-30">·</span>
    <%!-- Active breakpoint — only one shows at a time --%>
    <span class="sm:hidden">XS</span>
    <span class="hidden sm:inline md:hidden">SM</span>
    <span class="hidden md:inline lg:hidden">MD</span>
    <span class="hidden lg:inline xl:hidden">LG</span>
    <span class="hidden xl:inline 2xl:hidden">XL</span>
    <span class="hidden 2xl:inline">2XL</span>
  </div>
  <script>
    (() => {
      const el = document.getElementById("dev-viewport-size");
      if (!el) return;
      const update = () => { el.textContent = `${innerWidth}×${innerHeight}`; };
      update();
      addEventListener("resize", update, { passive: true });
    })();
  </script>
<% end %>
```

Enable in `config/dev.exs`:

```elixir
config :aya, dev_tools: true
```

The badge shows e.g. `1280×720 · LG` — updates live on resize, uses Tailwind's own breakpoints so it's always accurate, and is `pointer-events-none` so it never interferes with clicking.

#### Grid / Layout Overlay (`Ctrl+Shift+G`)

Toggle a column grid overlay to check alignment:

```js
// In assets/js/dev/grid_overlay.js
export function toggleGrid() {
  const id = "dev-grid-overlay"
  const existing = document.getElementById(id)

  if (existing) {
    existing.remove()
    return
  }

  const overlay = document.createElement("div")
  overlay.id = id
  Object.assign(overlay.style, {
    position: "fixed",
    inset: "0",
    zIndex: "99998",
    pointerEvents: "none",
    display: "grid",
    gridTemplateColumns: "repeat(12, 1fr)",
    gap: "0",
    padding: "0 1rem",
    mixBlendMode: "multiply",
  })

  // Match your page container max-width
  const container = document.createElement("div")
  Object.assign(container.style, {
    position: "fixed",
    inset: "0",
    margin: "0 auto",
    maxWidth: "80rem", // match your content max-width
    display: "grid",
    gridTemplateColumns: "repeat(12, 1fr)",
    gap: "1rem",
    padding: "0 1rem",
    pointerEvents: "none",
  })

  for (let i = 0; i < 12; i++) {
    const col = document.createElement("div")
    Object.assign(col.style, {
      background: "oklch(60% 0.15 260 / 0.08)",
      borderInline: "1px solid oklch(60% 0.15 260 / 0.15)",
    })
    container.appendChild(col)
  }

  overlay.appendChild(container)
  document.body.appendChild(overlay)
}
```

#### Spacing / Box Model Debugger (`Ctrl+Shift+S`)

Outline every element to visualize spacing, padding, and margins:

```js
// In assets/js/dev/spacing_debug.js
export function toggleSpacing() {
  const id = "dev-spacing-styles"
  const existing = document.getElementById(id)

  if (existing) {
    existing.remove()
    return
  }

  const style = document.createElement("style")
  style.id = id
  style.textContent = `
    * {
      outline: 1px solid oklch(60% 0.2 30 / 0.3) !important;
    }
    *:hover {
      outline: 2px solid oklch(60% 0.25 260 / 0.8) !important;
      outline-offset: -1px;
    }
  `
  document.head.appendChild(style)
}
```

#### Accessibility Quick Audit (`Ctrl+Shift+A`)

Highlight common a11y issues inline — missing alt text, missing labels, small tap targets, missing ARIA:

```js
// In assets/js/dev/a11y_audit.js
export function toggleA11yAudit() {
  const id = "dev-a11y-styles"
  const existing = document.getElementById(id)

  if (existing) {
    existing.remove()
    document.querySelectorAll("[data-a11y-issue]").forEach(el => {
      delete el.dataset.a11yIssue
    })
    return
  }

  // Flag issues with data attributes
  // Images without alt
  document.querySelectorAll("img:not([alt])").forEach(el => {
    el.dataset.a11yIssue = "missing alt"
  })

  // Inputs without labels
  document.querySelectorAll("input:not([aria-label]):not([aria-labelledby])").forEach(el => {
    if (!el.id || !document.querySelector(`label[for="${el.id}"]`)) {
      if (!el.closest("label")) {
        el.dataset.a11yIssue = "missing label"
      }
    }
  })

  // Buttons/links without accessible names
  document.querySelectorAll("button:not([aria-label]), a:not([aria-label])").forEach(el => {
    if (!el.textContent.trim() && !el.querySelector("img[alt]")) {
      el.dataset.a11yIssue = "missing accessible name"
    }
  })

  // Small tap targets
  document.querySelectorAll("button, a, input, select, textarea, [role='button']").forEach(el => {
    const rect = el.getBoundingClientRect()
    if (rect.width > 0 && rect.height > 0 && (rect.width < 44 || rect.height < 44)) {
      el.dataset.a11yIssue = (el.dataset.a11yIssue || "") + " small-target"
    }
  })

  const style = document.createElement("style")
  style.id = id
  style.textContent = `
    [data-a11y-issue] {
      outline: 3px solid oklch(55% 0.25 30) !important;
      outline-offset: 2px;
      position: relative;
    }
    [data-a11y-issue]::after {
      content: attr(data-a11y-issue);
      position: absolute;
      top: -1.5em;
      left: 0;
      font-size: 10px;
      font-family: system-ui;
      background: oklch(55% 0.25 30);
      color: white;
      padding: 1px 5px;
      border-radius: 3px;
      white-space: nowrap;
      z-index: 99999;
      pointer-events: none;
    }
  `
  document.head.appendChild(style)
}
```

#### LiveView Debug Panel (`Ctrl+Shift+L`)

Show LiveView connection state, event latency, and socket info:

```js
// In assets/js/dev/lv_debug.js
export function toggleLiveViewDebug(liveSocket) {
  const id = "dev-lv-panel"
  const existing = document.getElementById(id)

  if (existing) {
    existing.remove()
    liveSocket.disableDebug()
    return
  }

  liveSocket.enableDebug()

  const panel = document.createElement("div")
  panel.id = id
  Object.assign(panel.style, {
    position: "fixed",
    bottom: "40px",
    right: "8px",
    zIndex: "99999",
    background: "oklch(15% 0 0 / 0.92)",
    color: "oklch(90% 0 0)",
    fontFamily: "ui-monospace, monospace",
    fontSize: "11px",
    padding: "8px 12px",
    borderRadius: "8px",
    backdropFilter: "blur(8px)",
    minWidth: "200px",
    pointerEvents: "none",
    lineHeight: "1.6",
  })

  function update() {
    const socket = liveSocket.getSocket()
    const views = liveSocket.roots ? Object.keys(liveSocket.roots).length : "?"
    const state = socket?.isConnected() ? "connected" : "disconnected"
    const latency = liveSocket.currentLocation ? "" : ""

    panel.innerHTML = `
      <div style="font-weight:600; margin-bottom:4px; color:oklch(80% 0.15 150)">LiveView Debug</div>
      <div>Socket: <span style="color:${state === "connected" ? "oklch(80% 0.2 150)" : "oklch(70% 0.25 30)"}">${state}</span></div>
      <div>Transport: ${socket?.transport?.constructor?.name || "—"}</div>
      <div>Views: ${views}</div>
      <div>URL: ${window.location.pathname}</div>
      <div style="margin-top:4px; opacity:0.5">Ctrl+Shift+L to close</div>
    `
  }

  update()
  panel._interval = setInterval(update, 2000)
  document.body.appendChild(panel)
}
```

#### Quick Theme Cycle (`Ctrl+Shift+T`)

Cycle through light → dark → system with a keyboard shortcut instead of clicking the toggle:

```js
// In assets/js/dev/theme_cycle.js
export function cycleTheme() {
  const current = localStorage.getItem("phx:theme")
  const next = current === "light" ? "dark" : current === "dark" ? null : "light"

  if (next) {
    localStorage.setItem("phx:theme", next)
    document.documentElement.setAttribute("data-theme", next)
  } else {
    localStorage.removeItem("phx:theme")
    document.documentElement.removeAttribute("data-theme")
  }

  // Flash the breakpoint indicator briefly to show current theme
  console.log(`%cTheme: ${next || "system"}`, "color: #c2410c; font-weight: bold")
}
```

#### Wiring All Dev Utilities in `app.js`

```js
// app.js — bottom of file
if (window.location.hostname === "localhost") {
  import("./dev/clear_all.js").then(({ clearAll }) => {
    window.__clearAll = async () => { await clearAll(); location.reload() }
  })

  document.addEventListener("keydown", async (e) => {
    // Ctrl+Shift+<key> shortcuts
    if (!e.ctrlKey || !e.shiftKey) return

    switch (e.key) {
      case "K": // Clear all state
        e.preventDefault()
        if (confirm("Clear all browser state and reload?")) {
          const { clearAll } = await import("./dev/clear_all.js")
          await clearAll()
          location.reload()
        }
        break

      case "G": // Grid overlay
        e.preventDefault()
        const { toggleGrid } = await import("./dev/grid_overlay.js")
        toggleGrid()
        break

      case "S": // Spacing debugger
        e.preventDefault()
        const { toggleSpacing } = await import("./dev/spacing_debug.js")
        toggleSpacing()
        break

      case "A": // Accessibility audit
        e.preventDefault()
        const { toggleA11yAudit } = await import("./dev/a11y_audit.js")
        toggleA11yAudit()
        break

      case "L": // LiveView debug
        e.preventDefault()
        const { toggleLiveViewDebug } = await import("./dev/lv_debug.js")
        toggleLiveViewDebug(liveSocket)
        break

      case "T": // Theme cycle
        e.preventDefault()
        const { cycleTheme } = await import("./dev/theme_cycle.js")
        cycleTheme()
        break
    }
  })
}
```

All dev utilities are:
- **Lazy-loaded** via dynamic `import()` — zero cost in production, zero cost until first use in dev
- **Toggle-based** — press the shortcut again to turn off
- **`pointer-events: none`** — overlays never interfere with clicking

#### Dev Utilities Quick Reference

| Shortcut | Utility | What it does |
|---|---|---|
| `Ctrl+Shift+K` | Clear All | Nuke localStorage, sessionStorage, cookies, caches, IndexedDB, SW |
| `Ctrl+Shift+G` | Grid Overlay | 12-column grid overlay matching your layout max-width |
| `Ctrl+Shift+S` | Spacing Debug | Outline every element to visualize box model |
| `Ctrl+Shift+A` | A11y Audit | Highlight missing alt, labels, ARIA, small tap targets |
| `Ctrl+Shift+L` | LiveView Debug | Show socket state, transport, view count |
| `Ctrl+Shift+T` | Theme Cycle | Light → Dark → System |
| `__clearAll()` | Console | Same as Ctrl+Shift+K, callable from DevTools |

### ECharts (Data Visualization)

[Apache ECharts](https://echarts.apache.org/) is installed via npm in `assets/` for charts in Trends, Reports, and any data-heavy views. The hook uses **tree-shaken imports** — only the chart types and components registered in `assets/js/hooks/echarts_hook.js` are bundled.

**Registered hook:** `ECharts` (external hook, not colocated — name has no `.` prefix).

**Currently imported chart types:** Line, Bar, Pie. To add more (Scatter, Heatmap, Candlestick, etc.), add the import in `echarts_hook.js`.

**Usage pattern:**

```heex
<div id="price-trend" phx-hook="ECharts" phx-update="ignore" class="h-80 w-full" />
```

```elixir
# Push chart data from server
push_event(socket, "echarts:update", %{
  option: %{
    xAxis: %{type: "category", data: months},
    yAxis: %{type: "value"},
    series: [%{data: prices, type: "line", smooth: true}]
  }
})
```

**Events the hook listens for:**
- `echarts:update` — set or update chart options (pass `%{option: map}`)
- `echarts:resize` — manually trigger resize

**Attributes:**
- `data-no-merge="true"` — replace options entirely instead of merging
- `data-option={Jason.encode!(option)}` — provide initial option without push_event

The chart auto-resizes via `ResizeObserver` and detects dark theme from `<html class="dark">`.

---

## Modern CSS & JS Features

Use the latest CSS and JS features. Target latest Chrome — no polyfills, no legacy fallbacks. Prefer CSS-native solutions over JS.

### CSS Nesting

Native CSS nesting is the default for organizing styles. Use `&` for compound selectors:

```css
.card {
  background: var(--color-surface-alt);
  border-radius: var(--radius-lg);

  & .title {
    font-weight: 600;
  }

  &:hover {
    box-shadow: var(--shadow-md);
  }

  /* Nest media/container queries */
  @media (width >= 768px) {
    grid-template-columns: 1fr 2fr;
  }

  @container card (min-width: 400px) {
    flex-direction: row;
  }
}
```

**Rules:**
- Nest related styles instead of flat BEM-style selectors
- Max 3 levels deep — beyond that, extract to a new rule
- Nest `@media`, `@container`, and `@supports` queries inside the relevant selector

### `@scope` — Component-Scoped Styles

Scope styles to a DOM subtree without BEM or CSS modules. Pairs naturally with LiveView components:

```css
@scope (.recipe-card) to (.recipe-card-actions) {
  p { color: var(--color-text-secondary); }
  img { border-radius: var(--radius-md); }
  /* Styles only apply inside .recipe-card but NOT inside .recipe-card-actions */
}

/* Scope to a component without a lower boundary */
@scope (.ingredient-list) {
  li { padding-block: var(--spacing-2); }
  .amount { font-variant-numeric: tabular-nums; }
}
```

**Use for:** component styles that shouldn't leak outward or pierce into nested sub-components.

### View Transitions & Page Transitions

Use the View Transitions API for smooth LiveView navigations:

```css
/* Enable view transitions for LiveView navigate (full page transitions) */
@view-transition {
  navigation: auto;
}

/* Name elements that persist across navigations */
.hero-image {
  view-transition-name: hero;
}

/* Customize the transition animation */
::view-transition-old(hero) {
  animation: fade-out 200ms ease-in;
}
::view-transition-new(hero) {
  animation: fade-in 300ms ease-out;
}

/* Respect reduced motion */
@media (prefers-reduced-motion: reduce) {
  @view-transition { navigation: none; }
  ::view-transition-group(*) { animation-duration: 0s; }
}
```

**LiveView integration notes:**
- `@view-transition { navigation: auto; }` works for `navigate` (full page transitions) out of the box — no JS needed
- For `patch` transitions (same LiveView, different state), use a hook that calls `document.startViewTransition()` in the `updated()` callback — the DOM update is already complete at that point
- For stream items, give each item a unique `view-transition-name` derived from its DOM ID for item-level transitions

```js
// Colocated hook for patch-based view transitions
export default {
  updated() {
    if (document.startViewTransition) {
      // DOM is already updated by LiveView — snapshot the transition
      document.startViewTransition()
    }
  }
}
```

**Nested View Transition Groups:**

View transition groups can be nested for 3D transforms and clipping during transitions. Set `view-transition-group: contain` on parent elements so child transitions are grouped under the parent's transition pseudo-element tree:

```css
.card-grid {
  view-transition-group: contain; /* children nest inside this group */
}
.card {
  view-transition-name: card;
}
```

This preserves spatial relationships (3D perspective, overflow clipping) during the transition — without nesting, each element transitions independently as a flat overlay.

**`moveBefore()` — DOM State-Preserving Move:**

`moveBefore()` reparents an element without losing state — videos keep playing, iframes don't reload, CSS animations don't restart, inputs retain focus:

```js
// In a hook: reorder stream items without state loss
container.moveBefore(draggedElement, targetElement)
```

- Same API as `insertBefore()` but preserves element state during reparenting
- Critical for LiveView stream reordering where elements contain stateful content (video players, form inputs, running animations)
- Pair with `phx-hook` for drag-and-drop reordering

### `@starting-style` — Entry Animations Without JS

Animate elements from their initial state on mount — replaces JS-based enter animations for simple cases:

```css
.dialog[open] {
  opacity: 1;
  transform: translateY(0);
  transition: opacity 300ms ease-out, transform 300ms ease-out;
  transition-behavior: allow-discrete; /* enables display: none → block transition */

  @starting-style {
    opacity: 0;
    transform: translateY(12px);
  }
}
```

**LiveView notes:**
- Works for initial LiveView mount and elements added via streams — the element is new in the DOM, so `@starting-style` fires
- Does NOT fire on `updated()` patches where the element was already in the DOM — only on initial insertion
- For re-mount animations (e.g., after stream reset), the element must be removed and re-added
- Combine with `transition-behavior: allow-discrete` for `display: none → block` transitions driven by LiveView assigns

### `transition-behavior: allow-discrete` — Animate Display & Visibility

Animate properties that were traditionally not animatable (`display`, `visibility`, `overlay`):

```css
/* Fade in/out with display: none → block */
.tooltip {
  display: none;
  opacity: 0;
  transition: opacity 200ms ease-out, display 200ms allow-discrete;

  &.visible {
    display: block;
    opacity: 1;
  }

  @starting-style {
    &.visible {
      opacity: 0;
    }
  }
}

/* LiveView — toggle via assigns */
.panel {
  display: none;
  opacity: 0;
  scale: 0.95;
  transition: opacity 200ms ease-out, scale 200ms ease-out,
              display 200ms allow-discrete;

  &[data-state="open"] {
    display: block;
    opacity: 1;
    scale: 1;

    @starting-style {
      opacity: 0;
      scale: 0.95;
    }
  }
}
```

**Rules:**
- Always pair with `@starting-style` for the entry animation
- `display` transitions as a discrete step at the right moment — `none → block` happens at the start, `block → none` happens at the end
- Replaces JS `classList.add/remove` timing hacks for show/hide animations

### CSS Grid & Subgrid

**Grid is the default layout tool** — use flexbox only for 1D alignment (navbars, button groups).

```css
/* Responsive grid with auto-fill */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(300px, 100%), 1fr));
  gap: var(--spacing-4);
}

/* Subgrid — align child elements across sibling cards */
.card {
  display: grid;
  grid-template-rows: subgrid;
  grid-row: span 3; /* title + body + footer */
}
```

**Subgrid rules:**
- Use `subgrid` when children across siblings must align (card titles, table-like layouts, form labels)
- The parent must define explicit row/column tracks for the child to inherit
- Always set `grid-row: span N` or `grid-column: span N` on the subgrid container

**Named grid areas** — readable layout definitions without line numbers:

```css
.recipe-page {
  display: grid;
  grid-template-areas:
    "header  header"
    "sidebar content"
    "footer  footer";
  grid-template-columns: 250px 1fr;
  gap: var(--spacing-4);

  @media (width < 768px) {
    grid-template-areas:
      "header"
      "content"
      "sidebar"
      "footer";
    grid-template-columns: 1fr;
  }
}
.recipe-header  { grid-area: header; }
.recipe-sidebar { grid-area: sidebar; }
.recipe-content { grid-area: content; }
.recipe-footer  { grid-area: footer; }
```

- Use named areas for page-level layouts and components with distinct regions
- The ASCII art makes responsive reordering obvious — just rearrange the template string
- Prefer over line-number placement (`grid-column: 1 / 3`) for readability

**Masonry layout** — native Pinterest-style flowing grids:

```css
/* Recipe gallery with masonry — items fill vertical gaps naturally */
.recipe-gallery {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(280px, 100%), 1fr));
  grid-template-rows: masonry;
  gap: var(--spacing-4);
}
```

- `grid-template-rows: masonry` — items pack into the shortest column (vertical masonry)
- `grid-template-columns: masonry` — horizontal masonry (rare)
- Use for: image galleries, recipe card grids with varying heights, blog post layouts
- Replaces JS masonry libraries (Masonry.js, etc.) and the `columns` CSS hack

**Gap decorations** — style the gaps between grid/flex items:

```css
.recipe-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-4);
  column-rule: 1px solid var(--color-border);
  row-rule: 1px dashed var(--color-border);
}

.nav-links {
  display: flex;
  gap: var(--spacing-4);
  column-rule: 1px solid var(--color-border); /* dividers between nav items */
}
```

- `column-rule` and `row-rule` — same syntax as `border` (`width style color`)
- Draws lines/dashes in the gap space between grid/flex items
- Replaces the `border-right` + `:last-child` hack for item separators
- Use for: navigation separators, data grid lines, dashboard card dividers

### Selectors: `:has()`, `:is()`, `:where()`, `@container`

```css
/* :has() — parent selector */
.form-group:has(:invalid) {
  border-color: var(--color-error);
}
.card:has(> img) {
  padding-top: 0;
}

/* :is() — grouping with specificity of the most specific selector */
:is(h1, h2, h3):hover { color: var(--color-primary); }

/* :where() — same as :is() but zero specificity (great for resets/defaults) */
:where(.prose) p { line-height: 1.75; }

/* Container queries — respond to parent size, not viewport */
.sidebar {
  container-type: inline-size;
  container-name: sidebar;
}
@container sidebar (min-width: 400px) {
  .sidebar-nav { flex-direction: row; }
}
```

**When to use:**
- `:has()` — parent styling based on children, form validation states, conditional layouts
- `:is()` — reduce repetition in selectors (keeps highest specificity)
- `:where()` — base/reset styles that are easy to override (zero specificity)
- `@container` — components that adapt to their container, not the viewport. Use container query units (`cqw`, `cqh`, `cqi`, `cqb`) for sizing relative to the container

**Scroll-state queries** — style elements based on scroll state without JS:

```css
/* Style sticky headers when they're actually stuck */
.sticky-header {
  container-type: scroll-state;
}
.sticky-header > .content {
  @container scroll-state(stuck: top) {
    box-shadow: var(--shadow-md);
    border-bottom: 1px solid var(--color-border);
  }
}

/* Style snapped carousel items */
.carousel {
  container-type: scroll-state;
}
.carousel > .slide {
  @container not scroll-state(snapped: x) {
    opacity: 0.5;
    scale: 0.95;
  }
}

/* Show scroll indicators only when scrollable */
.scroll-container {
  container-type: scroll-state;
}
.scroll-container > .scroll-indicator {
  @container not scroll-state(scrollable: top) {
    display: none; /* hide "scroll up" when already at top */
  }
}
```

Three query types: `stuck` (sticky elements), `snapped` (scroll-snap), `scrollable` (overflow direction). Replaces `IntersectionObserver` + class toggling for scroll-dependent styling.

**Anchored container queries** — style elements based on their anchor position fallback:

```css
/* Tooltip with auto-flipping arrow */
.tooltip {
  container-type: anchored;
  position-try-fallbacks: flip-block;
}
.tooltip > .arrow {
  @container anchored(fallback: flip-block) {
    transform: rotate(180deg); /* flip arrow when tooltip flips */
  }
}
```

Query the active `position-try-fallbacks` value to conditionally style anchored elements — e.g., flip arrows, adjust padding based on which side the popover landed on.

### Form Validation: `:user-valid` / `:user-invalid`

Style form validation only after user interaction — no red borders on page load:

```css
/* Only show error styling after the user has interacted with the field */
input:user-invalid {
  border-color: var(--color-error);
  outline-color: var(--color-error);
}

input:user-valid {
  border-color: var(--color-success);
}

/* Style the parent form-group based on validation state */
.form-group:has(:user-invalid) {
  & .error-message { display: block; }
  & .label { color: var(--color-error); }
}
```

**Why `:user-invalid` over `:invalid`:**
- `:invalid` matches immediately on render — a required empty field is `:invalid` before the user has done anything
- `:user-invalid` only matches after the user has interacted (typed, blurred, or submitted)
- Pairs with Phoenix's `phx-feedback-for` concept but at the CSS level — no JS needed for basic visual feedback

### `if()` CSS Function

CSS `if()` enables inline conditional values — works like a ternary operator:

```css
.button {
  background: if(style(--variant: primary): var(--color-primary); else: var(--color-surface-alt));
  color: if(style(--variant: primary): var(--color-primary-text); else: var(--color-text));
}
```

**Multi-branch conditions and range syntax:**

```css
.indicator {
  /* Range comparisons in style queries */
  color: if(
    style(--level > 80): var(--color-error);
    style(--level > 50): var(--color-warning);
    else: var(--color-success)
  );
}

/* Combine with media() and supports() */
.layout {
  columns: if(media(width >= 768px): 2; else: 1);
}
```

- Supports `media()`, `supports()`, and `style()` query types inline
- Range syntax (`>`, `<`, `>=`, `<=`) works in `style()` queries and `@container style()` rules
- Combine with `data-*` attributes for state-driven styling without class toggling

### Custom `data-*` Attributes

**Prefer `data-*` attributes over CSS class toggling for state.** They're semantic, queryable, and pair naturally with attribute selectors and `if()`:

```heex
<div data-state={if @expanded, do: "open", else: "closed"}
     data-size={@size}
     data-variant={@variant}>
```

```css
[data-state="open"] {
  max-height: var(--content-height, auto);
  opacity: 1;
}
[data-state="closed"] {
  max-height: 0;
  opacity: 0;
}

/* Combine with :has() */
.accordion:has([data-state="open"]) {
  border-color: var(--color-primary);
}
```

**Rules:**
- Use `data-state` for open/closed/loading/error/active states
- Use `data-variant`, `data-size` for component variants — mirrors component props in CSS
- Prefer `data-*` + CSS selectors over conditional Tailwind class lists for complex state

**Advanced `attr()` — typed data-attribute values:**

`attr()` now works with any CSS property (not just `content`) and parses into typed values:

```css
/* Read colors, lengths, numbers directly from data attributes */
.chip {
  background: attr(data-color type(<color>), var(--color-primary-soft));
  padding-inline: attr(data-padding type(<length>), 12px);
}

.progress {
  width: calc(attr(data-value type(<number>), 0) * 1%);
}
```

```heex
<span class="chip" data-color={@category.color} data-padding="16px"><%= @category.name %></span>
<div class="progress" data-value={@percent}></div>
```

- Syntax: `attr(name type(<type>), fallback)` — types include `<color>`, `<length>`, `<number>`, `<custom-ident>`
- Pairs naturally with LiveView assigns → data attributes → CSS styling pipeline
- Use for dynamic per-element styling without inline styles or custom properties per instance

### Custom CSS Functions (`@function`)

Define reusable CSS functions — composable, maintainable logic directly in stylesheets:

```css
@function --spacing(--n) {
  result: calc(var(--n) * 0.25rem);
}

@function --fluid-size(--min, --max) {
  result: clamp(var(--min), var(--min) + (var(--max) - var(--min)) * ((100vw - 320px) / (1280 - 320)), var(--max));
}

.card {
  padding: --spacing(4);      /* 1rem */
  font-size: --fluid-size(1rem, 1.5rem);
}
```

- Arguments accept default values: `@function --fn(--arg: 1rem) { ... }`
- Functions compose: call other custom functions in the `result` expression
- Use for repeated calculations (spacing scales, fluid values, color transforms) instead of copy-pasting `calc()` expressions

### CSS Mixins (`@mixin` / `@apply`)

Reusable blocks of declarations — like `@function` but for property groups instead of single values:

```css
@mixin --center {
  display: flex;
  align-items: center;
  justify-content: center;
}

@mixin --card-base {
  background: var(--color-surface-alt);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  padding: var(--spacing-4);
}

.hero { @apply --center; min-height: 60dvh; }
.recipe-card { @apply --card-base; }
.ingredient-card { @apply --card-base; padding: var(--spacing-2); }
```

- `@mixin --name { declarations }` — defines a reusable set of properties
- `@apply --name` — applies those declarations inline
- **This is native CSS `@apply`, NOT Tailwind's `@apply`** — the Tailwind directive (which extracts utility classes) should still be avoided. Native `@mixin`/`@apply` defines and reuses custom declaration blocks
- Use for: shared component bases (card, button, layout patterns) that `@function` can't express (functions return values, mixins apply property blocks)
- Complements `@function` — use functions for computed values, mixins for property groups

### OKLCH Colors, `color-mix()`, and Relative Color Syntax

**Use OKLCH for all color definitions** — perceptually uniform, wider gamut, easier to reason about than HSL. Existing hex tokens should be migrated to OKLCH when touched.

```css
:root {
  /* oklch(lightness chroma hue) */
  --color-primary: oklch(55% 0.25 260);
  --color-primary-hover: oklch(48% 0.25 260);   /* darken = reduce lightness */
  --color-primary-soft: oklch(95% 0.04 260);     /* tint = high lightness, low chroma */
}
```

**`color-mix()` — derive shades without hardcoding each one:**

```css
:root {
  --color-primary: oklch(55% 0.25 260);
  --color-primary-hover: color-mix(in oklch, var(--color-primary) 85%, black);
  --color-primary-soft: color-mix(in oklch, var(--color-primary) 15%, white);
  --color-primary-muted: color-mix(in oklch, var(--color-primary) 50%, transparent);
}
```

**Relative color syntax — programmatic color manipulation:**

```css
:root {
  --color-primary: oklch(55% 0.25 260);
  /* Darken by reducing lightness */
  --color-primary-dark: oklch(from var(--color-primary) calc(l - 0.1) c h);
  /* Desaturate by reducing chroma */
  --color-primary-muted: oklch(from var(--color-primary) l calc(c * 0.5) h);
  /* Shift hue for complementary */
  --color-complement: oklch(from var(--color-primary) l c calc(h + 180));
}
```

**OKLCH conventions:**
- Lightness: 0%–100% (0 = black, 100 = white)
- Chroma: 0–0.4 (0 = gray; most screen colors cap ~0.25)
- Hue: 0–360 (same wheel as HSL)
- Generate palettes by holding hue + chroma constant, varying lightness in even steps

**Wide gamut colors** — `display-p3` and beyond:

OKLCH already supports wide gamut, but you can also use the `color()` function for explicit color spaces:

```css
:root {
  /* P3 gamut — ~50% more colors than sRGB, supported on modern displays */
  --color-accent-vivid: color(display-p3 1 0.2 0.1);

  /* Graceful fallback for sRGB displays */
  --color-accent-vivid: oklch(65% 0.29 25); /* OKLCH auto-gamut-maps */
}
```

- Prefer OKLCH over `color(display-p3 ...)` — OKLCH handles gamut mapping automatically
- `color(display-p3 ...)` is useful when you have exact P3 values from a design tool
- Use `@media (color-gamut: p3) { }` to detect wide-gamut display support for progressive enhancement

### `light-dark()` and `color-scheme`

Simplify dark mode token definitions with `light-dark()`:

```css
:root {
  color-scheme: light dark;

  --color-surface: light-dark(#fafaf8, #1c1917);
  --color-text: light-dark(oklch(15% 0 0), oklch(92% 0 0));
  --color-border: light-dark(oklch(85% 0.01 80), oklch(30% 0.01 80));
}
```

**Notes:**
- `light-dark()` uses the `color-scheme` property to pick the right value — no media query or `data-theme` selector needed for each token
- Toggle `color-scheme` via JS (`document.documentElement.style.colorScheme = "dark"`) to switch themes
- `color-scheme: light dark` also tells the browser to style form controls, scrollbars, and system UI appropriately for the active scheme

### `@property` — Typed Custom Properties

Register custom properties with types, enabling animation and inheritance control:

```css
@property --color-primary {
  syntax: "<color>";
  inherits: true;
  initial-value: oklch(55% 0.25 260);
}

@property --progress {
  syntax: "<number>";
  inherits: false;
  initial-value: 0;
}

/* Now you can animate between color token values (impossible with unregistered properties) */
.card {
  background: var(--color-primary);
  transition: --color-primary 300ms ease;
}
[data-theme="dark"] .card {
  --color-primary: oklch(72% 0.2 260); /* smoothly transitions! */
}

/* Animate a progress value */
.progress-ring {
  --progress: 0;
  transition: --progress 500ms ease-out;
  background: conic-gradient(var(--color-primary) calc(var(--progress) * 1%), transparent 0);
}
```

### `accent-color` — Style Native Form Controls

One-line theming for checkboxes, radio buttons, range inputs, and progress bars:

```css
:root {
  accent-color: var(--color-primary);
}
```

This colors all native form controls to match your brand. Combine with `color-scheme: light dark` so controls also adapt to dark mode.

### Semantic HTML & Native Elements

Use native HTML elements before reaching for ARIA or JS:

```html
<!-- Dialog — use native <dialog> with showModal() -->
<dialog> over <div role="dialog">

<!-- Details/Summary — native accordion, no JS -->
<details> / <summary> over JS accordion
<!-- Exclusive accordion groups — only one open at a time -->
<details name="faq"> — same name attribute creates a group

<!-- Autocomplete — native search suggestions, no JS -->
<input list="ingredients"> + <datalist id="ingredients"> over JS autocomplete

<!-- Popover — native popover API -->
<div popover> + <button popovertarget="id"> over JS dropdowns

<!-- Search -->
<search> over <div role="search">

<!-- Navigation grouping -->
<nav aria-label="Main"> over <div class="nav">

<!-- Output for live results -->
<output> for calculated/live values (inherently aria-live)

<!-- Meter and Progress -->
<meter> for gauges, <progress> for loading bars
```

**Rules:**
- `<button>` for actions, `<a>` for navigation — never a styled `<div>` or `<span>`
- Every `<img>` needs `alt` (empty `alt=""` for decorative images)
- Every form input needs a `<label>` (see Forms & Controls section)
- Use `<article>` for independently distributable content (news articles, recipe cards)
- Use `<section>` with `aria-labelledby` for page sections
- Use `<aside>` for tangentially related content (sidebars, related links)
- Use `<time datetime="...">` for all dates/times — machine-readable
- Use `inert` attribute to make background content non-interactive when modals/drawers are open:

```heex
<main inert={@show_modal}>
  <%!-- page content — fully inert when modal is open --%>
</main>
<.modal :if={@show_modal}>...</.modal>
```

`inert` replaces JS focus-trap libraries. Pairs directly with LiveView boolean assigns.

**Exclusive accordion groups** — `<details name="">` creates groups where only one can be open:

```heex
<%!-- Only one FAQ answer visible at a time — no JS --%>
<details name="faq">
  <summary>What's the shelf life?</summary>
  <p>3-5 days refrigerated.</p>
</details>
<details name="faq">
  <summary>Can I freeze it?</summary>
  <p>Yes, up to 3 months.</p>
</details>
```

Use for: FAQ sections, recipe step-by-step (show one step at a time), ingredient group details.

**`<datalist>` — native autocomplete suggestions:**

```heex
<input list="ingredients" type="text" placeholder="Search ingredients..."
       inputmode="search" enterkeyhint="search" />
<datalist id="ingredients">
  <option value="Chicken breast" />
  <option value="Chickpeas" />
  <option value="Chicken thigh" />
</datalist>
```

- Browser-native fuzzy matching and keyboard navigation
- Populate options from LiveView assigns — re-renders update the suggestion list
- Use for: ingredient search, tag input, recipe name lookup
- For complex autocomplete (custom rendering, async fetch), use a LiveView component with `phx-change` debounce instead

### Invoker Commands — Declarative Button Actions

Buttons can perform actions on other elements without JS. Replaces simple `phx-click` handlers for pure-DOM operations:

```heex
<%!-- Show a modal — no JS, no phx-click, no hook --%>
<button commandfor="confirm-dialog" command="show-modal">Delete</button>
<dialog id="confirm-dialog">
  <p>Are you sure?</p>
  <button commandfor="confirm-dialog" command="close">Cancel</button>
  <button phx-click="delete" commandfor="confirm-dialog" command="close">Confirm</button>
</dialog>

<%!-- Toggle a popover --%>
<button commandfor="settings-menu" command="toggle-popover">Settings</button>
<div id="settings-menu" popover="auto">...</div>
```

**Built-in commands:** `show-modal`, `close` (for dialogs), `toggle-popover`, `show-popover`, `hide-popover`. Custom commands use `--` prefix (e.g., `command="--custom-action"`) and fire a `CommandEvent` on the target.

**LiveView integration:**
- Use `commandfor`/`command` for DOM-only operations (show/close dialogs, toggle popovers) — no round-trip needed
- Combine with `phx-click` when you also need server-side work (e.g., close dialog AND process deletion)
- Replaces JS hooks for simple modal/popover toggling

### Dialog `closedby` — Native Close Behavior

Control how dialogs can be dismissed via a single attribute:

```heex
<%!-- Click outside or Escape to close --%>
<dialog closedby="any">...</dialog>

<%!-- Only Escape key closes (not click-outside) --%>
<dialog closedby="closerequest">...</dialog>

<%!-- Cannot be dismissed except programmatically --%>
<dialog closedby="none">...</dialog>
```

- `closedby="any"` — light dismiss (click outside, Escape, or close button). Use for non-critical dialogs, settings panels
- `closedby="closerequest"` — Escape key only. Use for forms, confirmation dialogs where accidental click-outside dismissal would lose data
- `closedby="none"` — only `close()` or invoker commands. Use for blocking flows (auth, required input)
- Default: `closedby="closerequest"` for `showModal()`, `closedby="none"` for `show()`

### Popover API

Full native popover support — replaces JS dropdown/tooltip/menu libraries:

```heex
<button popovertarget="menu">Open Menu</button>
<div id="menu" popover="auto" class="dropdown-menu">
  <%!-- content --%>
</div>
```

**`popover="auto"` vs `popover="manual"` vs `popover="hint"`:**
- `auto` — light dismiss (click outside or Escape closes it), only one auto-popover open at a time, nesting supported
- `manual` — must be explicitly closed, multiple can be open simultaneously
- `hint` — ephemeral UI (tooltips, hovercards). Opening a hint does NOT close other open auto/manual popovers, enabling layered UI. Only one hint open at a time

**LiveView integration:**
- Popover open/close state lives in the DOM, not in LiveView assigns — use `phx-update="ignore"` on the popover if the server should not control its visibility
- To sync state back to server, listen for the `toggle` event in a hook and `pushEvent`
- LiveView's DOM patching (morphdom) does NOT restore popover open state on re-render — `phx-update="ignore"` prevents this

**Combine with anchor positioning** for positioned dropdowns without JS:

```css
[popovertarget] { anchor-name: --trigger; }
[popover] {
  position-anchor: --trigger;
  top: anchor(bottom);
  left: anchor(start);
  position-try-fallbacks: flip-block;
}
```

**Interest invokers** — declarative hover/focus-triggered popovers without JS hooks:

```heex
<%!-- Tooltip on hover/focus — no JS, no hook, no mouseenter event --%>
<a interestfor="nutrition-tip" href="/nutrition">Protein</a>
<div id="nutrition-tip" popover="hint">
  <p>Recommended: 0.8g per kg body weight</p>
</div>
```

- `interestfor` on `<a>` or `<button>` triggers the target popover on hover/focus
- Pairs with `popover="hint"` for tooltips and hovercards
- `interest-delay` CSS property controls open/close timing (default `0.5s`):
  ```css
  [interestfor] { interest-delay: 200ms 300ms; } /* 200ms open, 300ms close */
  ```
- Replaces JS hooks with `mouseenter`/`mouseleave`/`focus`/`blur` for tooltip behavior

**`ToggleEvent.source`** — identify which element triggered a popover/dialog toggle:

```js
dialog.addEventListener("toggle", (e) => {
  if (e.source?.dataset.action === "delete") {
    // triggered by delete button — can distinguish intent
  }
})
```

Useful in hooks when multiple buttons open the same dialog with different intents.

### Native `<select>` Customization (CSS `appearance: base-select`)

Style `<select>` dropdowns natively — no JS dropdown libraries:

```css
select, ::picker(select) {
  appearance: base-select;
}

select::picker-icon {
  content: url("data:image/svg+xml,..."); /* custom chevron */
}

select::picker(select) {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-lg);
}

option {
  padding: 8px 12px;
  border-radius: var(--radius-sm);
}
option:checked {
  background: var(--color-primary-soft);
}
```

**`<selectedcontent>` — reflect the selected option's content in the button:**

```heex
<select>
  <button>
    <selectedcontent></selectedcontent> <%!-- mirrors the selected <option>'s innerHTML --%>
  </button>
  <option value="mild">🌶️ Mild</option>
  <option value="medium">🌶️🌶️ Medium</option>
  <option value="hot">🌶️🌶️🌶️ Hot</option>
</select>
```

`<selectedcontent>` auto-updates to show the selected option's full HTML content (including images, icons) in the select trigger — replaces the plain text-only display of native selects.

### Anchor Positioning

Position elements relative to any anchor — replaces Popper/Floating UI:

```css
.trigger {
  anchor-name: --menu-anchor;
}

.menu {
  position: fixed;
  position-anchor: --menu-anchor;
  top: anchor(bottom);
  left: anchor(left);
  position-try-fallbacks: flip-block, flip-inline; /* auto-flip if clipped */
}
```

**Use for:** tooltips, dropdowns, popovers, context menus, floating labels.

### CSS Scroll-Driven Animations

Animate based on scroll position without JS — pure CSS, runs on compositor thread:

```css
/* Progress bar that fills as user scrolls */
.reading-progress {
  animation: grow-width linear;
  animation-timeline: scroll();
  position: fixed;
  top: 0;
  height: 3px;
  background: var(--color-primary);
}
@keyframes grow-width {
  from { width: 0; }
  to { width: 100%; }
}

/* Fade in elements as they enter the viewport */
.reveal {
  animation: fade-in linear both;
  animation-timeline: view();
  animation-range: entry 0% entry 100%;
}
@keyframes fade-in {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
```

**Rules:**
- `animation-timeline: scroll()` — scroll-position-linked (progress bars, parallax)
- `animation-timeline: view()` — viewport-entry (reveal on scroll)
- Prefer these over JS `IntersectionObserver` + class toggling for pure visual animation. Still use `IntersectionObserver` when you need to trigger side effects (push events to LiveView for infinite scroll, lazy-load data, analytics)

### `interpolate-size` and `calc-size()` — Animate to `auto`

Solve the classic "animate height to auto" problem:

```css
/* Enable auto-size interpolation globally */
:root {
  interpolate-size: allow-keywords;
}

/* Now you can transition to/from auto */
.collapsible {
  height: 0;
  overflow: hidden;
  transition: height 300ms ease-out;

  &[data-state="open"] {
    height: auto; /* smoothly animates! */
  }
}

/* Or use calc-size() for computed values */
.expandable {
  max-height: 0;
  transition: max-height 300ms ease-out;

  &[data-state="open"] {
    max-height: calc-size(auto);
  }
}
```

No more `max-height: 9999px` hacks or JS height measurement.

### `field-sizing: content` — Auto-sizing Inputs

Textareas and inputs that grow to fit their content:

```css
textarea {
  field-sizing: content;
  min-height: 3lh;   /* minimum 3 lines */
  max-height: 20lh;  /* cap at 20 lines */
}

input[type="text"] {
  field-sizing: content;
  min-width: 10ch;   /* minimum 10 characters wide */
}
```

Replaces JS auto-resize libraries. The `lh` unit (line-height) is perfect for setting min/max in terms of visible lines.

### Responsive Values: `clamp()`, `min()`, `max()`

Fluid responsive values without breakpoints:

```css
/* Fluid typography — scales between viewport sizes */
h1 { font-size: clamp(1.75rem, 1rem + 2.5vw, 3rem); }
h2 { font-size: clamp(1.25rem, 0.8rem + 1.5vw, 2rem); }

/* Fluid spacing */
.section { padding-block: clamp(2rem, 5vw, 6rem); }

/* Responsive container — fluid with min/max */
.content { width: min(100% - 2rem, 72rem); margin-inline: auto; }

/* Grid column min-width */
.grid { grid-template-columns: repeat(auto-fill, minmax(min(300px, 100%), 1fr)); }
```

### Dynamic Viewport Units (`dvh`, `svh`, `lvh`)

Use dynamic viewport units to account for mobile browser chrome (address bar, toolbar):

```css
/* Full-height layout that accounts for mobile address bar */
.app-shell { min-height: 100dvh; }

/* Hero section — always fills visible area */
.hero { height: 100svh; } /* svh = smallest viewport = address bar visible */
```

- `dvh` — dynamic, updates as browser chrome appears/disappears (use for layouts that should fill available space)
- `svh` — smallest viewport height (address bar fully shown) — safe for "fill the screen" hero sections
- `lvh` — largest viewport height (address bar hidden) — rarely used directly

### Logical Properties

Use logical properties for future i18n/RTL readiness:

```css
/* Prefer logical over physical */
.card {
  margin-inline: auto;           /* instead of margin-left/right: auto */
  padding-block: var(--spacing-4); /* instead of padding-top/bottom */
  padding-inline: var(--spacing-6);
  border-start-start-radius: var(--radius-lg); /* instead of border-top-left-radius */
}

.sidebar {
  border-inline-end: 1px solid var(--color-border); /* instead of border-right */
  inset-inline-start: 0; /* instead of left: 0 */
}
```

**Rule:** prefer `*-inline-*` / `*-block-*` / `inset-*` over physical `left`/`right`/`top`/`bottom` for all new CSS. The layout automatically mirrors for RTL languages.

### `aspect-ratio`

Replaces the padding-bottom hack for responsive media:

```css
.video-embed { aspect-ratio: 16 / 9; }
.recipe-thumbnail { aspect-ratio: 4 / 3; }
.avatar { aspect-ratio: 1; } /* perfect square */
```

Always set `aspect-ratio` on images and video containers to prevent layout shift.

### Scroll Behavior: `scroll-snap`, `overscroll-behavior`, `scrollbar-*`

```css
/* Scroll snap — for carousels, step galleries, category lists */
.recipe-steps {
  display: flex;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  scroll-padding-inline: var(--spacing-4); /* account for container padding */
}
.recipe-steps > * {
  scroll-snap-align: start;
  flex-shrink: 0;
}

/* Overscroll behavior — prevent scroll chaining in modals/drawers */
.modal-body {
  overscroll-behavior: contain; /* scrolling inside doesn't scroll the page behind */
}

/* Standard scrollbar styling (prefer over ::-webkit-scrollbar) */
.scrollable {
  scrollbar-width: thin;
  scrollbar-color: var(--color-border) transparent;
  scrollbar-gutter: stable; /* reserve scrollbar space to prevent layout shift */
}
```

**`scrollbar-gutter: stable`** is important for content that may or may not overflow — it prevents layout shift when a scrollbar appears/disappears.

**`::scroll-marker` / `::scroll-button()` — native carousel navigation:**

Build carousels with pure CSS — no JS libraries, no hooks:

```css
/* Carousel with scroll buttons and dot indicators */
.carousel {
  overflow-x: auto;
  scroll-snap-type: x mandatory;

  &::scroll-button(left) {
    content: "←";
    /* auto-disabled when scrolled to start */
  }
  &::scroll-button(right) {
    content: "→";
    /* auto-disabled when scrolled to end */
  }
}

.carousel > * {
  scroll-snap-align: start;

  &::scroll-marker {
    content: "";
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: var(--color-border);

    &:target-current {
      background: var(--color-primary);
    }
  }
}

/* Position the marker group */
.carousel::scroll-marker-group {
  display: flex;
  gap: 8px;
  justify-content: center;
}
```

- `::scroll-button(left|right|up|down)` — native prev/next buttons, auto-disable at scroll boundaries
- `::scroll-marker` — per-item navigation dots/tabs, grouped in `::scroll-marker-group`
- `:target-current` — style the marker for the currently visible/snapped item
- Fully stylable, keyboard-accessible, and compositor-friendly
- Replaces JS carousel libraries (Swiper, Embla, etc.) for most use cases

**`scrollIntoView()` container option:**

```js
// Only scroll the nearest ancestor — don't cascade to parent scroll containers
element.scrollIntoView({ block: "nearest", container: "nearest" })
```

Prevents nested scroll containers from all scrolling simultaneously. Use in hooks for in-page navigation within scrollable panels.

**`scroll-target-group` — TOC / step navigation from anchor links:**

Transforms manually-created anchor links into scroll-aware navigation with active-state tracking — no JS, no `IntersectionObserver`:

```css
/* The scrollable content area */
.article-body {
  scroll-target-group: auto;
}

/* TOC sidebar — anchor links automatically become scroll-markers */
.toc a {
  &:target-current {
    color: var(--color-primary);
    font-weight: 600;
    border-inline-start: 2px solid var(--color-primary);
  }
}
```

```heex
<%!-- Recipe steps with TOC navigation --%>
<nav class="toc">
  <a href="#prep">Prep</a>
  <a href="#cook">Cook</a>
  <a href="#plate">Plate</a>
</nav>

<div class="article-body">
  <section id="prep"><h2>Prep</h2>...</section>
  <section id="cook"><h2>Cook</h2>...</section>
  <section id="plate"><h2>Plate</h2>...</section>
</div>
```

- `scroll-target-group: auto` on the scroll container converts same-page anchor links into scroll-markers
- `:target-current` pseudo-class styles the link whose target section is currently in view
- Use for: recipe step navigation, article TOCs, book chapter sidebars, multi-section forms
- Replaces JS scroll-spy libraries and `IntersectionObserver` + active-class toggling patterns
- Pairs with `scroll-snap` for step-by-step views where each section snaps into place

### `env()` — Safe Area Insets

Handle notched/rounded displays (iPhone, modern Android):

```css
.bottom-nav {
  padding-bottom: env(safe-area-inset-bottom, 0px);
}

.app-shell {
  padding-left: env(safe-area-inset-left, 0px);
  padding-right: env(safe-area-inset-right, 0px);
}
```

**Requires** `<meta name="viewport" content="..., viewport-fit=cover">` in the layout head. Without `viewport-fit=cover`, safe area insets are always 0. Essential for full-bleed designs on mobile.

### `isolation: isolate` — Stacking Context Control

Create stacking contexts explicitly instead of relying on `z-index` + `position: relative` hacks:

```css
/* Create a stacking context — all z-index values inside are scoped */
.modal-container {
  isolation: isolate;
}

/* Header stays above page content without fighting z-index across the app */
.app-header {
  isolation: isolate;
  z-index: 10;
}

/* Each card's internal z-index (for overlapping badges, etc.) is self-contained */
.card {
  isolation: isolate;
}
```

**Rule:** use `isolation: isolate` on any component that uses `z-index` internally. This prevents z-index values from leaking out and conflicting with other components. Pairs with the z-index scale from the design system.

### `::marker` & `@counter-style` — Custom List Styling

Style list markers natively — useful for recipe steps, ingredient lists:

```css
/* Style markers directly */
ol.recipe-steps::marker {
  color: var(--color-primary);
  font-weight: 700;
  font-size: 1.1em;
}

/* Custom counter style */
@counter-style step-counter {
  system: numeric;
  symbols: "0" "1" "2" "3" "4" "5" "6" "7" "8" "9";
  prefix: "Step ";
  suffix: ". ";
}

ol.recipe-steps {
  list-style-type: step-counter;
}

/* Emoji markers */
@counter-style ingredients {
  system: cyclic;
  symbols: "🥕" "🧅" "🧄" "🫑" "🍅";
}
ul.ingredient-list {
  list-style-type: ingredients;
}
```

### Tree Counting: `sibling-index()` & `sibling-count()`

Native CSS functions that return an element's position and total sibling count — eliminates hardcoded `nth-child` stagger delays:

```css
/* Automatic stagger animation — works for any number of children */
.card-grid > * {
  animation: fade-in 300ms ease-out both;
  animation-delay: calc(sibling-index() * 50ms);
}

/* Dynamic sizing based on count */
.tag-list > * {
  flex-basis: calc(100% / sibling-count());
}

/* Progress indicator using position */
.steps > .step::before {
  content: counter(none); /* position-aware */
  width: calc(sibling-index() / sibling-count() * 100%);
}
```

- `sibling-index()` — 1-based position among siblings (replaces `nth-child(1)`, `nth-child(2)`, ...)
- `sibling-count()` — total number of siblings (replaces JS `element.parentElement.children.length`)
- Directly replaces hardcoded stagger delay patterns: instead of `&:nth-child(1) { delay: 50ms } &:nth-child(2) { delay: 100ms } ...`, use `calc(sibling-index() * 50ms)`
- Pure CSS, no JS — works with LiveView streams where child count changes dynamically

### `clip-path` Animations

`clip-path` is compositor-friendly (S-tier) — animate shapes without layout or paint cost:

```css
/* Reveal animation */
.reveal {
  clip-path: inset(100% 0 0 0);
  transition: clip-path 400ms ease-out;

  &.visible {
    clip-path: inset(0);
  }
}

/* Circle wipe from center */
.hero {
  clip-path: circle(0% at 50% 50%);
  transition: clip-path 500ms ease-out;

  &.loaded {
    clip-path: circle(100% at 50% 50%);
  }
}

/* Diagonal slice */
.card-overlay {
  clip-path: polygon(0 0, 100% 0, 100% 0%, 0 0%);
  transition: clip-path 300ms ease-out;

  &:hover {
    clip-path: polygon(0 0, 100% 0, 100% 100%, 0 100%);
  }
}
```

**`shape()` function — complex responsive clipping shapes:**

`shape()` enables curved, non-polygonal clip paths that respond to CSS custom properties:

```css
/* Organic blob shape with animated curves */
.blob {
  clip-path: shape(from 0% 50%,
    curve to 50% 0% with 20% 0%,
    curve to 100% 50% with 100% 20%,
    curve to 50% 100% with 80% 100%,
    close
  );
}

/* Dynamic shape driven by custom properties */
.wave {
  --wave-height: 20px;
  clip-path: shape(from 0% 0%,
    hline to 100%,
    vline to calc(100% - var(--wave-height)),
    curve to 0% calc(100% - var(--wave-height)) with 50% 100%,
    close
  );
}
```

- Commands: `move to`, `line to`, `hline to`, `vline to`, `curve to ... with ...`, `close`
- Works with CSS custom properties for animatable, dynamic shapes
- S-tier performance (compositor-friendly) — same as `clip-path` with `polygon()`
- Use for organic shapes, wave dividers, custom borders that `polygon()` can't express

### `offset-path` — Motion Path Animations

Animate elements along a path — S-tier performance (compositor-only):

```css
/* Animate along a circular path */
.orbit-item {
  offset-path: circle(120px at center);
  animation: orbit 4s linear infinite;
}
@keyframes orbit {
  to { offset-distance: 100%; }
}

/* Animate along a custom SVG-like path */
.flying-ingredient {
  offset-path: path("M 0 200 Q 100 0 200 200 T 400 200");
  animation: fly 2s ease-in-out;
}
@keyframes fly {
  from { offset-distance: 0%; }
  to { offset-distance: 100%; }
}
```

- `offset-path` — the path to follow (circle, ellipse, `path()`, `ray()`, or any shape)
- `offset-distance` — position along the path (0%–100%), animatable
- `offset-rotate` — element rotation along the path (`auto` = follow path direction)
- Use for: onboarding animations, ingredient-toss effects, loading indicators, decorative motion
- S-tier: runs entirely on the compositor thread

### `::highlight()` — Custom Text Highlighting

Highlight text ranges without mutating the DOM — no `<mark>` wrapper elements needed:

```js
// In a hook: highlight search matches without DOM mutation
const range = new Range()
range.setStart(textNode, startOffset)
range.setEnd(textNode, endOffset)

const highlight = new Highlight(range)
CSS.highlights.set("search", highlight)
```

```css
::highlight(search) {
  background: var(--color-warning-soft);
  color: var(--color-warning-text);
}
```

- Highlight API creates named highlights from `Range` objects — no DOM insertion
- Works with LiveView: DOM structure stays intact, highlights are a separate layer
- Use for: search result highlighting in recipes/articles, text selection effects, syntax highlighting
- Multiple named highlights can coexist (`"search"`, `"active"`, `"spelling"`)

### `corner-shape` — Beyond Border Radius

Control corner styles beyond simple rounding:

```css
/* Squircle — continuous curvature like iOS icons */
.app-icon {
  corner-shape: squircle;
  border-radius: 20%;
}

/* Superellipse with custom curvature */
.card {
  corner-shape: superellipse(3); /* higher = more "square" rounding */
  border-radius: var(--radius-lg);
}

/* Other shapes */
.badge { corner-shape: bevel; border-radius: 8px; }   /* chamfered corners */
.cutout { corner-shape: notch; border-radius: 12px; }  /* notched/cut corners */
.scallop { corner-shape: scoop; border-radius: 16px; } /* inward-curved corners */
```

- Values: `round` (default), `bevel`, `notch`, `scoop`, `squircle`
- `superellipse(n)` function for custom continuous curves (n=2 is circle, n→∞ is square)
- Animatable — use for hover effects that morph corner shape
- `squircle` is the iOS/macOS icon shape — use for app icons, avatars, image masks

### `stretch` Sizing Keyword

A sizing keyword that fills the containing block's available space while preserving margins:

```css
/* Fill available width — cleaner than width: 100% */
.full-width-content {
  width: stretch;
  margin-inline: 1rem; /* margins are preserved, unlike width: 100% */
}

/* Fill available height in a flex/grid container */
.panel {
  height: stretch;
}
```

- Applied to the margin box, not the content/padding/border box — margins are subtracted, not ignored
- Replaces `width: 100%` + manual margin math or `calc(100% - 2rem)` patterns
- Works on both `width` and `height`

### `@media (prefers-contrast)` — High Contrast Accessibility

Respect user contrast preferences:

```css
@media (prefers-contrast: more) {
  :root {
    --color-border: oklch(30% 0 0);            /* stronger borders */
    --color-text-secondary: oklch(25% 0 0);    /* darker secondary text */
    --shadow-sm: none;                          /* remove subtle shadows */
  }

  /* Ensure focus rings are always visible */
  :focus-visible {
    outline: 3px solid var(--color-text);
    outline-offset: 2px;
  }
}

@media (prefers-contrast: less) {
  :root {
    --color-border: oklch(85% 0.01 80);        /* softer borders */
    --color-text-secondary: oklch(55% 0 0);    /* lighter secondary text */
  }
}
```

### Resource Hints, Preloading & Script Loading

#### Script Loading Strategies

```heex
<%!-- Our app.js — defer is correct. Downloads in parallel, executes after HTML is parsed --%>
<script defer phx-track-static type="text/javascript" src={~p"/assets/js/app.js"}></script>

<%!-- Inline render-blocking script — only for critical pre-paint work (theme init) --%>
<script>
  (() => { /* theme setup — must run before first paint to prevent FOUC */ })();
</script>
```

**`defer` vs `async` vs `type="module"` vs inline:**

| Strategy | Download | Execute | Use when |
|---|---|---|---|
| `defer` | Parallel with HTML parse | After HTML parsed, before `DOMContentLoaded`, in order | **Default for app.js** — needs the DOM, order matters |
| `async` | Parallel with HTML parse | Immediately when downloaded, any order | Independent scripts (analytics, third-party) that don't touch DOM |
| `type="module"` | Parallel (deferred by default) | After HTML parsed, in order, strict mode | ES module scripts — if migrating app.js to ESM. Implies `defer` |
| Inline (no src) | N/A | Immediately, blocks parsing | **Only** for critical pre-paint work (theme init, above-fold critical path) |
| Dynamic `import()` | On demand | When imported | Code splitting — lazy-load heavy features (charting, editors) |

**Rules:**
- **app.js always uses `defer`** — it needs the DOM parsed to mount LiveSocket
- **Never** use `async` on app.js — LiveSocket must initialize after DOM is ready
- **Inline scripts must be tiny** — only theme init, critical CSS custom property setup, or feature detection that must run before first paint
- **Dynamic `import()`** in hooks for heavy libraries:

```js
// In a colocated hook — lazy-load ECharts only when the chart container mounts
export default {
  async mounted() {
    const { init } = await import("echarts/core")
    const { BarChart } = await import("echarts/charts")
    // Initialize chart...
  }
}
```

#### `modulepreload` — Preload JS Modules

`modulepreload` fetches, parses, and compiles a JS module ahead of time — faster than `preload` for JS because it also enters the module map:

```heex
<%!-- In root layout <head> — preload the main bundle and critical chunks --%>
<link rel="modulepreload" href={~p"/assets/js/app.js"} />

<%!-- Preload dynamically-imported chunks you know will be needed --%>
<link rel="modulepreload" href={~p"/assets/js/chunks/echarts.js"} />
```

**When to use:**
- `modulepreload` for your own JS modules (app.js, code-split chunks) — gives the browser a head start on parse + compile
- `preload as="script"` for non-module scripts (legacy, third-party)
- Preload chunks that will be `import()`-ed on the current page (e.g., if the page has a chart, preload the chart chunk)

#### Speculation Rules API — Prerender & Prefetch Pages

Speculation Rules tell the browser to prefetch or prerender pages the user is likely to navigate to. Unlike `<link rel="prefetch">`, this can fully prerender the page in a hidden tab for instant navigation:

```heex
<%!-- In root layout <head> --%>
<script type="speculationrules">
  {
    "prerender": [
      {
        "where": {
          "and": [
            { "href_matches": "/*" },
            { "not": { "href_matches": "/logout" } },
            { "not": { "href_matches": "/admin/*" } }
          ]
        },
        "eagerness": "moderate"
      }
    ],
    "prefetch": [
      {
        "where": { "selector_matches": "a[data-prefetch]" },
        "eagerness": "eager"
      }
    ]
  }
</script>
```

**Eagerness levels:**
- `"immediate"` — speculate as soon as the rules are observed (use sparingly — expensive)
- `"eager"` — speculate as soon as possible (typically on hover or early intent)
- `"moderate"` — speculate on hover (200ms dwell) — **good default for prerender**
- `"conservative"` — speculate only on click/tap — safest, lowest waste

**LiveView integration:**
- Prerender works with LiveView `navigate` — the browser prerenders the full page including the server-rendered HTML. When the user actually navigates, LiveView connects the WebSocket to the already-rendered DOM
- Use `"moderate"` eagerness for prerender (avoids wasting server resources on pages the user never visits)
- Use `"eager"` for prefetch on links you're confident the user will click (e.g., primary CTAs, obvious next steps)
- Mark high-priority links with `data-prefetch` for targeted prefetching:

```heex
<.link navigate={~p"/recipes/#{@recipe.slug}"} data-prefetch>
  {@recipe.title}
</.link>
```

**Rules & caveats:**
- Prefetch downloads the HTML — lightweight, safe to be aggressive
- Prerender fully renders the page in a hidden tab — more expensive, be selective
- Exclude pages with side effects (logout, form submissions, payment pages)
- Exclude admin/authenticated pages that shouldn't be speculatively rendered
- The browser respects `Save-Data` header and won't speculate on metered connections
- Speculation rules are additive — multiple `<script type="speculationrules">` blocks are merged

**Dynamic speculation rules** — update rules based on context:

```js
// In a hook — add speculation rules after analyzing the page
const rules = {
  prerender: [
    {
      urls: getVisibleLinkUrls(), // prerender only links currently in viewport
      eagerness: "moderate"
    }
  ]
}
const script = document.createElement("script")
script.type = "speculationrules"
script.textContent = JSON.stringify(rules)
document.head.append(script)
```

#### Resource Hints

```heex
<%!-- Preload critical fonts --%>
<link rel="preload" href={~p"/fonts/inter-var.woff2"} as="font" type="font/woff2" crossorigin />

<%!-- Preconnect to known external origins --%>
<link rel="preconnect" href="https://api.example.com" />
<link rel="dns-prefetch" href="https://cdn.example.com" />

<%!-- Preload critical above-fold images --%>
<link rel="preload" href={~p"/images/hero.webp"} as="image" fetchpriority="high" />
```

**`fetchpriority` attribute** — control loading priority:

```heex
<img src={@hero_url} fetchpriority="high" />
<img src={@thumbnail_url} loading="lazy" fetchpriority="low" decoding="async" />
```

**Resource hint summary:**

| Hint | What it does | Use when |
|---|---|---|
| `preload` | Fetch now, high priority, current page | Fonts, hero images, above-fold CSS, critical JS chunks |
| `modulepreload` | Fetch + parse + compile JS module | app.js, known dynamic import chunks |
| `prefetch` | Fetch at low priority, cache for next navigation | Likely next-page resources |
| `prerender` (via Speculation Rules) | Fully render page in hidden tab | Likely next page (moderate eagerness) |
| `preconnect` | DNS + TCP + TLS handshake | External origins you'll fetch from |
| `dns-prefetch` | DNS lookup only | External origins (fallback for older browsers) |

**Rules:**
- `preload` for critical resources needed in the current page
- `modulepreload` for JS you know will execute on this page
- Speculation Rules for next-page prerendering (replaces `<link rel="prefetch">` for pages)
- `<link rel="prefetch">` still useful for sub-resources (images, data) of the next page
- All fonts must use `font-display: swap` (or `optional` for non-critical fonts)
- Below-fold images always get `loading="lazy"` and `decoding="async"`
- Use `fetchpriority="high"` on the LCP (Largest Contentful Paint) image — usually the hero

### Tab Title, Favicon & Dynamic Updates

#### Page Titles

LiveView's `<.live_title>` updates the tab title dynamically without a page reload:

```heex
<%!-- In root.html.heex — already configured --%>
<.live_title default="Aya" suffix=" · Food & Science">
  {assigns[:page_title]}
</.live_title>
```

Set `page_title` in LiveView `mount/3` and `handle_params/3`:

```elixir
# Static page title
def mount(_params, _session, socket) do
  {:ok, assign(socket, page_title: "News Feed")}
end

# Dynamic page title from data
def handle_params(%{"slug" => slug}, _uri, socket) do
  article = News.get_article_by_slug!(slug)
  {:noreply, assign(socket, page_title: article.title, article: article)}
end

# Update title on state change (e.g., unread count)
def handle_info({:new_items, count}, socket) do
  title = if count > 0, do: "(#{count}) News Feed", else: "News Feed"
  {:noreply, assign(socket, page_title: title)}
end
```

**Title patterns:**
- Feed pages: `"News Feed"` → `"(3) News Feed"` when new items arrive
- Detail pages: `"Article Title"` (the article/recipe/paper title itself)
- Search: `"Search: #{query}"` — shows the active search query
- Forms: `"New Recipe"` / `"Edit: Recipe Name"`
- Errors: `"Not Found"` / `"Server Error"`

#### Modern Favicon Setup

Replace the single `.ico` with a modern favicon stack. Place files in `priv/static/`:

```
priv/static/
├── favicon.ico          # 32x32 ICO — legacy fallback (keep for older browsers)
├── favicon.svg          # SVG favicon — scalable, supports dark mode
├── apple-touch-icon.png # 180x180 PNG — iOS home screen
├── icon-192.png         # 192x192 PNG — Android/PWA
├── icon-512.png         # 512x512 PNG — PWA splash screen
└── site.webmanifest     # Web app manifest
```

In `root.html.heex` `<head>`:

```heex
<%!-- Favicon stack — order matters: browser picks the first it supports --%>
<link rel="icon" href={~p"/favicon.svg"} type="image/svg+xml" />
<link rel="icon" href={~p"/favicon.ico"} sizes="32x32" />
<link rel="apple-touch-icon" href={~p"/apple-touch-icon.png"} />
<link rel="manifest" href={~p"/site.webmanifest"} />

<%!-- Theme color — matches your design system, updates address bar on mobile --%>
<meta name="theme-color" content="#fafaf8" media="(prefers-color-scheme: light)" />
<meta name="theme-color" content="#1c1917" media="(prefers-color-scheme: dark)" />
```

#### SVG Favicon with Dark Mode Support

An SVG favicon can adapt to light/dark mode using CSS media queries inside the SVG:

```xml
<!-- priv/static/favicon.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">
  <style>
    .bg { fill: #c2410c; }    /* --color-primary in light mode */
    .fg { fill: #ffffff; }
    @media (prefers-color-scheme: dark) {
      .bg { fill: #fb923c; }  /* lighter primary for dark backgrounds */
      .fg { fill: #1c1917; }
    }
  </style>
  <rect class="bg" width="128" height="128" rx="24" />
  <text class="fg" x="64" y="92" font-size="80" font-family="system-ui"
        text-anchor="middle" font-weight="700">A</text>
</svg>
```

The SVG favicon automatically switches appearance when the OS theme changes — no JS needed.

#### Dynamic Favicon Updates

Update the favicon at runtime to show status — unread counts, loading state, error indicators:

```js
// Colocated hook — dynamic favicon manager
export default {
  mounted() {
    this.defaultHref = document.querySelector("link[rel='icon'][type='image/svg+xml']")?.href
    this.canvas = document.createElement("canvas")
    this.canvas.width = 64
    this.canvas.height = 64

    this.handleEvent("update-favicon", ({ badge }) => {
      if (badge && badge > 0) {
        this.setBadge(badge)
      } else {
        this.resetFavicon()
      }
    })
  },

  setBadge(count) {
    const ctx = this.canvas.getContext("2d")
    const img = new Image()
    img.onload = () => {
      // Draw the base favicon
      ctx.clearRect(0, 0, 64, 64)
      ctx.drawImage(img, 0, 0, 64, 64)

      // Draw the badge circle
      const text = count > 99 ? "99+" : String(count)
      const badgeSize = text.length > 2 ? 32 : 24
      ctx.fillStyle = "#dc2626"  // red badge
      ctx.beginPath()
      ctx.arc(64 - badgeSize / 2, badgeSize / 2, badgeSize / 2, 0, Math.PI * 2)
      ctx.fill()

      // Draw the count
      ctx.fillStyle = "#ffffff"
      ctx.font = `bold ${badgeSize * 0.6}px system-ui`
      ctx.textAlign = "center"
      ctx.textBaseline = "middle"
      ctx.fillText(text, 64 - badgeSize / 2, badgeSize / 2 + 1)

      // Update the favicon
      this.setFaviconHref(this.canvas.toDataURL("image/png"))
    }
    img.src = this.defaultHref
  },

  resetFavicon() {
    this.setFaviconHref(this.defaultHref)
  },

  setFaviconHref(href) {
    // Replace the link element (some browsers don't react to href changes)
    const link = document.querySelector("link[rel='icon']")
    const newLink = link.cloneNode()
    newLink.href = href
    link.parentNode.replaceChild(newLink, link)
  }
}
```

Server-side — push favicon updates from LiveView:

```elixir
# When new items arrive
def handle_info({:new_items, count}, socket) do
  title = if count > 0, do: "(#{count}) News Feed", else: "News Feed"
  socket = assign(socket, page_title: title)

  # Update favicon badge to match
  {:noreply, push_event(socket, "update-favicon", %{badge: count})}
end

# Clear badge when user scrolls to top / views items
def handle_event("items-viewed", _params, socket) do
  {:noreply, push_event(socket, "update-favicon", %{badge: 0})}
end
```

#### Minimal Favicon Change (No Canvas)

For simpler cases — swap between predefined static favicons:

```js
// Swap between pre-built favicon variants
function setFaviconVariant(variant) {
  const link = document.querySelector("link[rel='icon'][type='image/svg+xml']")
  if (link) {
    link.href = `/favicons/favicon-${variant}.svg` // "default", "unread", "error"
  }
}
```

Pre-build favicon variants as static SVGs:
- `favicon-default.svg` — normal state
- `favicon-unread.svg` — with a red dot badge
- `favicon-error.svg` — with an error indicator
- `favicon-loading.svg` — with a subtle animation (CSS animation inside SVG)

#### Web App Manifest

```json
{
  "name": "Aya — Food & Science",
  "short_name": "Aya",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#fafaf8",
  "theme_color": "#c2410c",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" },
    { "src": "/favicon.svg", "sizes": "any", "type": "image/svg+xml" }
  ]
}
```

#### `theme-color` Dynamic Updates

Update the mobile browser address bar color to match context:

```js
// Change theme-color meta dynamically (e.g., on route change or theme toggle)
function setThemeColor(color) {
  document.querySelector('meta[name="theme-color"]')?.setAttribute("content", color)
}

// Match your data-theme attribute
const observer = new MutationObserver(() => {
  const isDark = document.documentElement.dataset.theme === "dark"
  setThemeColor(isDark ? "#1c1917" : "#fafaf8")
})
observer.observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme"] })
```

#### Tab Title & Favicon Checklist

- [ ] `page_title` set in every LiveView `mount/3` and `handle_params/3`
- [ ] Dynamic titles show context (unread count, search query, item name)
- [ ] SVG favicon with dark mode support via `@media (prefers-color-scheme: dark)` inside the SVG
- [ ] Favicon stack: SVG (primary) → ICO (fallback) → apple-touch-icon → manifest
- [ ] `<meta name="theme-color">` with light/dark variants
- [ ] Dynamic favicon badge for unread counts (canvas or pre-built variant swap)
- [ ] `site.webmanifest` with proper icons, name, theme color
- [ ] Title and favicon badge update together (consistent unread state)
- [ ] Badge cleared when user views items (`push_event` from server)
- [ ] Favicon `setFaviconHref` replaces the `<link>` element (not just `.href`) for browser compatibility

### Meta Tags, OG Tags & Link Previews

When users share Aya links on WhatsApp, Telegram, Slack, Twitter/X, LinkedIn, iMessage, or Discord — a rich preview card should appear with the correct title, description, and image. These platforms scrape specific meta tags from the HTML `<head>`. Since they don't execute JavaScript, all meta tags **must be in the server-rendered HTML** (root layout or controller-rendered pages), not injected by LiveView client-side.

#### Architecture: SEO Component

Create a reusable component for meta tags in `lib/aya_web/components/seo.ex`:

```elixir
defmodule AyaWeb.SEO do
  @moduledoc """
  SEO and social sharing meta tag component.

  Assigns `:meta` in the LiveView or controller, then render in root layout.
  """
  use Phoenix.Component

  @default_meta %{
    title: "Aya — Food & Science",
    description: "Latest food news, recipes, research papers, ingredients, reports, and market trends.",
    image: "/images/og-default.jpg",
    url: nil,
    type: "website",
    twitter_card: "summary_large_image",
    site_name: "Aya"
  }

  attr :meta, :map, default: %{}
  attr :canonical_url, :string, default: nil

  def meta_tags(assigns) do
    meta = Map.merge(@default_meta, assigns.meta || %{})
    assigns = assign(assigns, :meta, meta)

    ~H"""
    <%!-- Primary meta --%>
    <meta name="description" content={@meta.description} />

    <%!-- Canonical URL --%>
    <link :if={@canonical_url} rel="canonical" href={@canonical_url} />

    <%!-- Open Graph (Facebook, WhatsApp, Telegram, LinkedIn, Discord, iMessage) --%>
    <meta property="og:type" content={@meta.type} />
    <meta property="og:title" content={@meta.title} />
    <meta property="og:description" content={@meta.description} />
    <meta property="og:image" content={@meta.image} />
    <meta :if={@meta[:url]} property="og:url" content={@meta.url} />
    <meta property="og:site_name" content={@meta.site_name} />
    <meta property="og:locale" content="en_US" />

    <%!-- OG Image dimensions (helps platforms render faster without downloading the image first) --%>
    <meta :if={@meta[:image_width]} property="og:image:width" content={to_string(@meta.image_width)} />
    <meta :if={@meta[:image_height]} property="og:image:height" content={to_string(@meta.image_height)} />
    <meta :if={@meta[:image]} property="og:image:alt" content={@meta[:image_alt] || @meta.title} />

    <%!-- Twitter/X Card --%>
    <meta name="twitter:card" content={@meta.twitter_card} />
    <meta name="twitter:title" content={@meta.title} />
    <meta name="twitter:description" content={@meta.description} />
    <meta name="twitter:image" content={@meta.image} />

    <%!-- Article metadata (for og:type "article") --%>
    <meta :if={@meta[:published_time]} property="article:published_time" content={@meta.published_time} />
    <meta :if={@meta[:author]} property="article:author" content={@meta.author} />
    <meta :if={@meta[:section]} property="article:section" content={@meta.section} />
    """
  end
end
```

#### Root Layout Integration

Add the meta component to `root.html.heex`:

```heex
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="csrf-token" content={get_csrf_token()} />
  <.live_title default="Aya" suffix=" · Food & Science">
    {assigns[:page_title]}
  </.live_title>

  <%!-- SEO & Social sharing meta tags --%>
  <AyaWeb.SEO.meta_tags meta={assigns[:meta]} canonical_url={assigns[:canonical_url]} />

  <%!-- Favicon stack --%>
  <link rel="icon" href={~p"/favicon.svg"} type="image/svg+xml" />
  <link rel="icon" href={~p"/favicon.ico"} sizes="32x32" />
  <link rel="apple-touch-icon" href={~p"/apple-touch-icon.png"} />
  <link rel="manifest" href={~p"/site.webmanifest"} />
  <meta name="theme-color" content="#fafaf8" media="(prefers-color-scheme: light)" />
  <meta name="theme-color" content="#1c1917" media="(prefers-color-scheme: dark)" />

  <link phx-track-static rel="stylesheet" href={~p"/assets/css/app.css"} />
  <script defer phx-track-static type="text/javascript" src={~p"/assets/js/app.js"}></script>
  <%!-- ... theme init script ... --%>
</head>
```

#### Setting Meta in LiveViews

```elixir
# News article detail
def handle_params(%{"slug" => slug}, _uri, socket) do
  article = News.get_article!(slug)

  meta = %{
    title: article.title,
    description: truncate(article.summary, 160),
    image: article.thumbnail_url || "/images/og-default.jpg",
    image_width: 1200,
    image_height: 630,
    url: url(~p"/news/#{article.slug}"),
    type: "article",
    published_time: DateTime.to_iso8601(article.published_at),
    author: article.source_name,
    section: "Food News"
  }

  {:noreply,
   socket
   |> assign(page_title: article.title, article: article)
   |> assign(meta: meta, canonical_url: url(~p"/news/#{article.slug}"))}
end

# Recipe detail
def handle_params(%{"slug" => slug}, _uri, socket) do
  recipe = Recipes.get_recipe!(slug)

  meta = %{
    title: "#{recipe.title} — Recipe",
    description: truncate(recipe.description, 160),
    image: recipe.cover_image_url || "/images/og-default.jpg",
    image_width: 1200,
    image_height: 630,
    url: url(~p"/recipes/#{recipe.slug}"),
    type: "article",
    section: "Recipes"
  }

  {:noreply,
   socket
   |> assign(page_title: recipe.title, recipe: recipe)
   |> assign(meta: meta, canonical_url: url(~p"/recipes/#{recipe.slug}"))}
end

# Index/feed pages — use defaults, just set title and description
def mount(_params, _session, socket) do
  meta = %{
    title: "Food News — Aya",
    description: "Latest food industry news, trends, and analysis."
  }

  {:ok, assign(socket, page_title: "News Feed", meta: meta)}
end
```

#### OG Image Best Practices

The OG image is what makes or breaks the link preview. Get this right:

**Image specifications:**
- **Size**: 1200×630px — the universal standard. Platforms will crop/resize but this ratio works everywhere
- **Format**: JPEG for photos, PNG for graphics/text overlays. Avoid SVG (not supported by crawlers)
- **File size**: under 300KB — large images timeout on WhatsApp/Telegram crawlers
- **Absolute URLs**: always use full `https://` URLs, never relative paths. Crawlers don't resolve relative URLs
- **HTTPS required**: WhatsApp, Telegram, and Twitter will not load images over HTTP
- **No text in the outer 10%**: platforms crop differently — keep important content centered

**Default OG image** — `priv/static/images/og-default.jpg`:
- Used when no page-specific image is set
- Should show the Aya brand/logo clearly
- Works as a recognizable fallback for index pages, search results, etc.

**Dynamic OG images** (optional, for article/recipe detail pages):
- Use the article's hero image or recipe photo directly
- Ensure images are at least 1200×630 — smaller images get downscaled and look blurry
- If user-uploaded images vary in size, generate a standardized OG image server-side (overlay on a branded template)

#### Platform-Specific Behavior

| Platform | Tags used | Image size | Notes |
|---|---|---|---|
| **WhatsApp** | `og:title`, `og:description`, `og:image` | 1200×630, crops to ~1.9:1 | Caches aggressively — use `?v=` query param to bust. Requires HTTPS |
| **Telegram** | `og:title`, `og:description`, `og:image` | 1200×630 | Shows larger previews. Supports `og:image:width/height` for faster rendering |
| **Twitter/X** | `twitter:card`, `twitter:title`, `twitter:description`, `twitter:image` | 1200×628 for `summary_large_image` | Falls back to `og:*` if `twitter:*` missing. `summary` card shows small square image |
| **Slack** | `og:title`, `og:description`, `og:image` | 1200×630 | Unfurls automatically. Respects `og:site_name` |
| **Discord** | `og:title`, `og:description`, `og:image`, `theme-color` | 1200×630 | Shows `<meta name="theme-color">` as embed sidebar color |
| **LinkedIn** | `og:title`, `og:description`, `og:image` | 1200×627 | Strict — image must be > 200px in each dimension |
| **iMessage** | `og:title`, `og:description`, `og:image` | 1200×630 | Shows rich preview bubble with image |
| **Facebook** | `og:title`, `og:description`, `og:image`, `og:type` | 1200×630 | Use their [Sharing Debugger](https://developers.facebook.com/tools/debug/) to test |

#### Description Best Practices

```elixir
# Helper for truncating descriptions to OG-safe lengths
defp truncate(nil, _max), do: nil
defp truncate(text, max) when byte_size(text) <= max, do: text
defp truncate(text, max) do
  text
  |> String.slice(0, max - 1)
  |> String.replace(~r/\s+\S*$/, "")  # don't cut mid-word
  |> Kernel.<>("…")
end
```

**Rules:**
- **Title**: 50–60 characters. Don't include the site name — `og:site_name` handles that
- **Description**: 120–160 characters. First sentence of the content, or a hand-written summary. Front-load the most important information
- **No HTML** in title or description — crawlers render it as plain text
- **No emoji** in OG title — some platforms strip or garble them
- **Unique per page** — never use the same description for all pages (search engines penalize this)

#### Canonical URLs

Prevent duplicate content issues and tell search engines which URL is authoritative:

```elixir
# Always set canonical_url for pages that can be reached via multiple URLs
# e.g., /news/my-article and /news/my-article?ref=email should both canonicalize to /news/my-article
assign(socket, canonical_url: url(~p"/news/#{article.slug}"))
```

**Rules:**
- Every page with content should have a canonical URL
- Strip query params (tracking, filters, pagination) from the canonical
- Use absolute URLs with `https://`
- Self-referencing canonicals are fine (page points to itself)

#### Structured Data (JSON-LD)

Add structured data for rich search results (recipe cards, article carousels, FAQ snippets):

```heex
<%!-- In the LiveView template, not the layout --%>
<script type="application/ld+json">
  {Jason.encode!(%{
    "@context" => "https://schema.org",
    "@type" => "Recipe",
    "name" => @recipe.title,
    "description" => @recipe.description,
    "image" => @recipe.cover_image_url,
    "author" => %{"@type" => "Person", "name" => @recipe.author_name},
    "datePublished" => DateTime.to_iso8601(@recipe.inserted_at),
    "prepTime" => "PT#{@recipe.prep_minutes}M",
    "cookTime" => "PT#{@recipe.cook_minutes}M",
    "totalTime" => "PT#{@recipe.prep_minutes + @recipe.cook_minutes}M",
    "recipeYield" => "#{@recipe.servings} servings",
    "recipeCategory" => @recipe.category,
    "recipeIngredient" => Enum.map(@recipe.ingredients, & &1.text),
    "recipeInstructions" => Enum.map(@recipe.steps, fn step ->
      %{"@type" => "HowToStep", "text" => step.instruction}
    end)
  })}
</script>
```

**Relevant schema types for Aya:**

| Type | Use for | Rich result |
|---|---|---|
| `Recipe` | Recipe detail pages | Recipe card with image, time, rating in search |
| `Article` / `NewsArticle` | News articles | Article carousel in search |
| `FAQPage` | FAQ sections | Expandable Q&A in search results |
| `BreadcrumbList` | All pages | Breadcrumb trail in search results |
| `WebSite` + `SearchAction` | Home page | Sitelinks search box in Google |

#### Testing & Debugging Link Previews

Platforms cache link previews aggressively. Use these tools to validate and force re-crawl:

- **WhatsApp**: no official tool — share the link in a private chat to yourself. To bust cache, append `?v=2` to the URL
- **Telegram**: send the link to [@webpagebot](https://t.me/webpagebot) to refresh the preview
- **Twitter/X**: [Card Validator](https://cards-dev.twitter.com/validator)
- **Facebook**: [Sharing Debugger](https://developers.facebook.com/tools/debug/) — also forces re-scrape
- **LinkedIn**: [Post Inspector](https://www.linkedin.com/post-inspector/)
- **Discord**: paste link, delete message, paste again to refresh
- **Google**: [Rich Results Test](https://search.google.com/test/rich-results) for structured data

**Cache-busting pattern** for development:

```elixir
# In dev, append a version to OG image URLs to prevent caching
defp og_image_url(path) do
  if Mix.env() == :dev do
    "#{path}?v=#{System.system_time(:second)}"
  else
    path
  end
end
```

#### Meta Tags & Link Preview Checklist

- [ ] `AyaWeb.SEO.meta_tags/1` component exists and is rendered in `root.html.heex`
- [ ] Every page assigns `:meta` with at least `title` and `description`
- [ ] Detail pages (articles, recipes, research) set `og:type` to `"article"` with `published_time`
- [ ] `og:image` is always an absolute `https://` URL, 1200×630px, under 300KB
- [ ] `og:image:width` and `og:image:height` set (faster rendering on Telegram/WhatsApp)
- [ ] Default OG image exists at `/images/og-default.jpg` for pages without specific images
- [ ] `og:description` is 120–160 chars, no HTML, no emoji, front-loaded with key info
- [ ] `og:title` is 50–60 chars, does NOT include site name (use `og:site_name` for that)
- [ ] `twitter:card` set to `summary_large_image` for content pages
- [ ] Canonical URL set on every content page, stripping query params
- [ ] JSON-LD structured data on recipe and article detail pages
- [ ] Link previews tested on WhatsApp, Telegram, and Twitter before launch
- [ ] `<meta name="theme-color">` set (Discord uses this for embed sidebar color)

### Typography & Font Features

```css
/* Variable fonts */
@font-face {
  font-family: "Inter";
  src: url("/fonts/inter-var.woff2") format("woff2");
  font-weight: 100 900;
  font-display: swap;
}

/* OpenType features */
.tabular   { font-variant-numeric: tabular-nums; }        /* tables, counters, prices */
.oldstyle  { font-variant-numeric: oldstyle-nums; }        /* body text prose */
.fractions { font-variant-numeric: diagonal-fractions; }    /* 1/2 → ½ */
.ordinals  { font-variant-numeric: ordinal; }               /* 1st → 1ˢᵗ */

/* Ligatures — enable in prose, disable in code */
.prose    { font-variant-ligatures: common-ligatures; }
code, pre { font-variant-ligatures: none; }

/* Optical sizing */
h1 { font-optical-sizing: auto; }

/* text-box-trim — remove leading/trailing whitespace from text boxes */
h1, h2, h3 {
  text-box-trim: both;
  text-box-edge: cap alphabetic; /* trim to cap height and alphabetic baseline */
}
```

**`text-box-trim`** removes the extra space above and below text caused by line-height and font metrics. Essential for precise optical alignment of text next to icons, in buttons, and in card headers.

**Text wrapping (reiterated):**
- `text-wrap: balance` on headings (≤ 6 lines)
- `text-wrap: pretty` on body paragraphs (avoids orphans)

**`line-clamp` — multiline text truncation:**

```css
.card-description {
  line-clamp: 3; /* truncate after 3 lines with ellipsis */
}
.feed-preview {
  line-clamp: 2;
}
```

- Replaces the old `-webkit-line-clamp` + `-webkit-box-orient` + `display: -webkit-box` hack
- Use for: card descriptions, feed item previews, recipe summaries — any clamped multi-line text

**`initial-letter` — drop caps:**

```css
.article-body > p:first-of-type::first-letter {
  initial-letter: 3; /* spans 3 lines */
  margin-inline-end: 0.5em;
  color: var(--color-primary);
  font-weight: 700;
}
```

- `initial-letter: N` — the first letter spans N lines of text
- `initial-letter: N drop` — same but sunk below the baseline
- Use for: recipe introductions, article leads, editorial content — adds typographic polish without layout hacks

### Modern JavaScript Features

Use modern JS in hooks and `app.js` — esbuild passes through to Chrome:

```js
// Structured clone — deep copy without JSON.parse(JSON.stringify())
const copy = structuredClone(data)

// AbortController — cancel fetch, addEventListener, anything
const controller = new AbortController()
el.addEventListener("click", handler, { signal: controller.signal })
controller.abort() // removes all listeners attached with this signal

// Logical assignment
opts.value ??= "default"     // assign if null/undefined
opts.items ||= []            // assign if falsy

// Array methods
const last = items.at(-1)                              // negative indexing
const grouped = Object.groupBy(items, i => i.category) // native groupBy
const unique = [...new Set(items)]                     // dedup

// Promise.withResolvers — expose resolve/reject
const { promise, resolve, reject } = Promise.withResolvers()

// using — deterministic resource cleanup
{
  using handle = getResource()
  // handle[Symbol.dispose]() called automatically at block exit
}

// Intl.DateTimeFormat — locale-aware formatting (server-side Elixir for logic)
const fmt = new Intl.DateTimeFormat("en", { dateStyle: "medium", timeStyle: "short" })
fmt.format(new Date()) // "Mar 23, 2026, 2:30 PM"

// Navigator.clipboard
await navigator.clipboard.writeText(text)

// IntersectionObserver — lazy loading, infinite scroll, analytics
const observer = new IntersectionObserver(entries => {
  for (const e of entries) {
    if (e.isIntersecting) {
      e.target.classList.add("visible")
      observer.unobserve(e.target)
    }
  }
}, { threshold: 0.1 })

// scheduler.yield() — yield to main thread in long tasks
async function processItems(items) {
  for (const item of items) {
    doWork(item)
    await scheduler.yield() // let browser handle events/paint between items
  }
}

// Navigation API — intercept navigations for unsaved-changes confirmation
navigation.addEventListener("navigate", (e) => {
  if (hasUnsavedChanges && !confirm("Discard changes?")) {
    e.preventDefault()
  }
})

// crypto.randomUUID() — native UUID generation
const id = crypto.randomUUID() // "a1b2c3d4-e5f6-..."

// Iterator helpers — lazy operations on iterators (no array conversion)
const topExpensive = items.values()
  .filter(i => i.price > 10)
  .map(i => i.name)
  .take(5)
  .toArray()

// Set methods — native set operations
const setA = new Set([1, 2, 3])
const setB = new Set([2, 3, 4])
setA.union(setB)              // Set {1, 2, 3, 4}
setA.intersection(setB)       // Set {2, 3}
setA.difference(setB)         // Set {1}
setA.symmetricDifference(setB) // Set {1, 4}
setA.isSubsetOf(setB)         // false

// BroadcastChannel — cross-tab communication
const channel = new BroadcastChannel("theme-sync")
channel.postMessage({ theme: "dark" })  // send to all tabs
channel.onmessage = (e) => {
  document.documentElement.style.colorScheme = e.data.theme
}

// Import attributes — type-safe imports
import config from "./config.json" with { type: "json" }
import styles from "./component.css" with { type: "css" }
```

### Chrome Built-in AI APIs

On-device AI powered by Gemini Nano — no API keys, no network calls for inference, fully offline after initial model download. All APIs share the same platform requirements:

- **Chrome 138+** (Desktop only — Windows, macOS, Linux, ChromeOS)
- **Storage:** 22 GB free minimum for the Gemini Nano model
- **GPU:** >4 GB VRAM, or CPU with 16 GB RAM + 4 cores
- **HTTPS required** (secure context)
- **Transient user activation** required for `create()` calls (user must have recently interacted)
- All APIs follow the same pattern: `availability()` → `create()` → use → `destroy()`
- TypeScript types: `npm install @types/dom-chromium-ai`

| API | Status | Use Case |
|-----|--------|----------|
| **Translator** | Stable (138+) | CJK translations, multilingual content |
| **Language Detector** | Stable (138+) | Auto-detect source language before translation |
| **Summarizer** | Stable (138+) | TLDRs, key points, headlines for articles/recipes |
| **Prompt API** | Stable for Extensions (138+), Origin Trial for Web | Open-ended Gemini Nano — custom AI features |
| **Writer** | Developer Trial | Generate content (descriptions, emails) |
| **Rewriter** | Developer Trial | Refine text (tone, length, formality) |
| **Proofreader** | Origin Trial | Grammar and spelling corrections |

#### Translator API

On-device translation for recipe content, ingredient lists, and articles into CJK languages (Chinese, Japanese, Korean) and others.

**Feature detection and availability:**

```js
if (!("Translator" in self)) {
  // Fall back to server-side translation
  return
}

const availability = await Translator.availability({
  sourceLanguage: "en",
  targetLanguage: "ja",
})
// "available" | "downloadable" | "downloading" | "unavailable"
```

**Creating and using a translator:**

```js
const translator = await Translator.create({
  sourceLanguage: "en",
  targetLanguage: "zh",
  monitor(m) {
    m.addEventListener("downloadprogress", (e) => {
      console.log(`Downloaded ${Math.floor(e.loaded * 100)}%`)
    })
  },
})

// Single translation
const translated = await translator.translate("Dice the onions finely")

// Streaming for long content (recipes, articles)
const stream = translator.translateStreaming(articleBody)
let result = ""
for await (const chunk of stream) {
  result += chunk
}

// Quota check before translating
const usage = await translator.measureInputUsage(longText)
if (usage <= translator.inputQuota) {
  await translator.translate(longText)
}

// Always destroy when done
translator.destroy()
```

**With language detection (auto-detect source language):**

```js
const detector = await LanguageDetector.create()
const [{ detectedLanguage, confidence }] = await detector.detect(userInput)
detector.destroy()

if (confidence > 0.8) {
  const translator = await Translator.create({
    sourceLanguage: detectedLanguage,
    targetLanguage: "en",
  })
  const translated = await translator.translate(userInput)
  translator.destroy()
}
```

**Key constraints:**
- Desktop Chrome 138+ only (not mobile)
- Requires transient user activation (user must have interacted — e.g., button click)
- HTTPS required; same-origin iframes or cross-origin with `allow="translator"`
- 22 GB free storage for model; language packs downloaded on demand
- BCP 47 language codes: `en`, `ja`, `ko`, `zh`, `zh-TW`, `zh-Hans`, `fr`, `de`, `es`, `pt-BR`, `ar`, `hi`, `th`, `vi`, and ~40+ others
- Each translator instance is one direction (en→ja ≠ ja→en) — create separate instances per direction

**LiveView integration pattern:**

```js
// Hook: translate recipe content client-side on button click
export default {
  mounted() {
    this.el.addEventListener("click", async () => {
      if (!("Translator" in self)) {
        this.pushEvent("translate-server", {}) // fallback to server
        return
      }
      const targetLang = this.el.dataset.targetLang
      const sourceText = document.getElementById(this.el.dataset.sourceId).textContent

      const translator = await Translator.create({
        sourceLanguage: "en",
        targetLanguage: targetLang,
      })
      const translated = await translator.translate(sourceText)
      translator.destroy()

      this.pushEvent("translation-complete", { text: translated, lang: targetLang })
    })
  }
}
```

#### Summarizer API

On-device text summarization — generate TLDRs, key points, teasers, or headlines from recipe descriptions, articles, and research papers without server round-trips.

**Feature detection and availability:**

```js
if (!("Summarizer" in self)) {
  // Fall back to server-side summarization
  return
}

const availability = await Summarizer.availability({
  type: "key-points",
  format: "markdown",
  length: "short",
})
```

**Creating and using a summarizer:**

```js
const summarizer = await Summarizer.create({
  sharedContext: "Summarize food and recipe content for quick scanning",
  type: "key-points",  // "key-points" | "tldr" | "teaser" | "headline"
  format: "markdown",  // "markdown" | "plain-text"
  length: "short",     // "short" | "medium" | "long"
  monitor(m) {
    m.addEventListener("downloadprogress", (e) => {
      console.log(`Downloaded ${Math.floor(e.loaded * 100)}%`)
    })
  },
})

// Summarize with optional per-call context
const summary = await summarizer.summarize(articleText, {
  context: "This is a research paper about fermentation techniques",
})

// Streaming for progressive UI updates
const stream = summarizer.summarizeStreaming(longArticle)
let summary = ""
for await (const chunk of stream) {
  summary = chunk // each chunk is the full summary so far
  updateUI(summary)
}

summarizer.destroy()
```

**Summary types and output sizes:**

| Type | Short | Medium | Long |
|------|-------|--------|------|
| `key-points` | ~3 bullets | ~5 bullets | ~7 bullets |
| `tldr` | ~1 sentence | ~3 sentences | ~5 sentences |
| `teaser` | ~1 sentence | ~3 sentences | ~5 sentences |
| `headline` | ~12 words | ~17 words | ~22 words |

**Key constraints:**
- Same hardware/platform requirements as Translator API (Desktop Chrome 138+, 22 GB storage, HTTPS)
- Requires transient user activation for `create()`
- `sharedContext` (set at create time) applies to all calls; `context` (per-call) adds specific guidance
- Input quota: check with `measureInputUsage()` before summarizing very long text

**LiveView integration pattern:**

```js
// Hook: summarize article content on demand
export default {
  async mounted() {
    this.handleEvent("summarize", async ({ text, type }) => {
      if (!("Summarizer" in self)) {
        this.pushEvent("summarize-server", { text, type })
        return
      }
      const summarizer = await Summarizer.create({
        type: type || "tldr",
        format: "markdown",
        length: "short",
      })
      const summary = await summarizer.summarize(text)
      summarizer.destroy()
      this.pushEvent("summary-ready", { summary })
    })
  }
}
```

#### Language Detector API

Auto-detect the language of user input before translation or routing. Stable in Chrome 138+.

```js
if (!("LanguageDetector" in self)) return

const detector = await LanguageDetector.create()

const results = await detector.detect("这道菜很好吃")
// Returns array sorted by confidence:
// [{ detectedLanguage: "zh", confidence: 0.97 }, { detectedLanguage: "ja", confidence: 0.02 }, ...]

const topResult = results[0]
console.log(topResult.detectedLanguage) // "zh"
console.log(topResult.confidence)       // 0.97

detector.destroy()
```

- Returns an array of `{ detectedLanguage, confidence }` objects sorted by confidence (0–1)
- Use to auto-detect source language before creating a Translator instance
- Use to route content to language-specific processing pipelines
- Use to set `lang` attribute on user-generated content for screen readers

**LiveView pattern — detect and translate in one flow:**

```js
export default {
  async handleTranslate(text, targetLang) {
    const detector = await LanguageDetector.create()
    const [{ detectedLanguage }] = await detector.detect(text)
    detector.destroy()

    const translator = await Translator.create({
      sourceLanguage: detectedLanguage,
      targetLanguage: targetLang,
    })
    const translated = await translator.translate(text)
    translator.destroy()

    this.pushEvent("translated", { text: translated, from: detectedLanguage, to: targetLang })
  }
}
```

#### Prompt API (Gemini Nano)

Open-ended access to Gemini Nano on-device. **Stable for Chrome Extensions (138+), Origin Trial for web pages.** Use for custom AI features that don't fit the specialized APIs.

```js
if (!("LanguageModel" in self)) return

// Check availability
const availability = await LanguageModel.availability()
// "available" | "downloadable" | "downloading" | "unavailable"

// Create a session with system prompt
const session = await LanguageModel.create({
  systemPrompt: "You are a helpful food science assistant. Answer concisely.",
  temperature: 0.7,    // 0–2, lower = more deterministic
  topK: 40,            // top-k sampling
})

// Single prompt
const response = await session.prompt("What makes bread rise?")

// Streaming response
const stream = session.promptStreaming("Explain the Maillard reaction")
for await (const chunk of stream) {
  updateUI(chunk) // each chunk is the full response so far
}

// Quota management
const usage = await session.measureInputUsage("Is this too long to process?")
if (usage <= session.inputQuota) {
  await session.prompt("Is this too long to process?")
}

// Clone session (preserves conversation context, cheaper than creating new)
const forkedSession = await session.clone()

session.destroy()
```

**Use cases for Aya:**
- Ingredient substitution suggestions ("What can I use instead of tamarind paste?")
- Recipe scaling assistance ("Convert this recipe from 4 to 6 servings")
- Food science Q&A embedded in recipe pages
- Smart categorization of user-submitted content
- Content classification without server round-trip

**Key differences from Translator/Summarizer:**
- General-purpose — no specialized task, you define behavior via system prompt
- Conversational — session maintains context across multiple `prompt()` calls
- `clone()` forks the session with full context (cheaper than recreating)
- Higher variability — tune with `temperature` and `topK`
- Web support is Origin Trial only (not stable yet) — use feature detection and server fallback

#### Writer & Rewriter APIs (Developer Trial)

Not yet stable — available behind flags for experimentation. Document here for awareness.

**Writer** — generate new content from a task description:

```js
const writer = await Writer.create({
  sharedContext: "Writing recipe descriptions for a food app",
  tone: "casual",      // "formal" | "casual" | "neutral"
  length: "medium",    // "short" | "medium" | "long"
  format: "markdown",  // "markdown" | "plain-text"
})

const description = await writer.write(
  "Write a brief description for a spicy Thai basil chicken stir-fry recipe",
  { context: "Target audience is home cooks, not professional chefs" }
)
writer.destroy()
```

**Rewriter** — refine existing text:

```js
const rewriter = await Rewriter.create({
  sharedContext: "Simplifying recipe instructions for beginner cooks",
  tone: "casual",
  length: "as-is",     // "shorter" | "longer" | "as-is"
  format: "plain-text",
})

const simplified = await rewriter.rewrite(
  "Deglaze the fond with a splash of dry white wine, reducing au sec before incorporating the demi-glace",
  { context: "Reader is a beginner home cook" }
)
rewriter.destroy()
```

- Both support streaming variants: `writeStreaming()` / `rewriteStreaming()`
- Same pattern: `availability()` → `create()` → use → `destroy()`
- Monitor with `sharedContext` (create-time) and `context` (per-call)
- **Not stable yet** — use feature detection (`"Writer" in self`) and always have a server fallback

### Geolocation

Browser-native location access for local food discovery, nearby restaurant search, and region-specific content.

#### `<geolocation>` HTML Element (Chrome 144+) — Preferred

The `<geolocation>` element is a **data mediator** — it handles both permission request AND data retrieval in one step. The browser renders a trusted, styled button; the site just listens for the `location` event. No JS API calls, no permission management.

```heex
<%!-- Progressive enhancement: <geolocation> with JS API fallback --%>
<geolocation onlocation="handleLocation(event)" accuracymode="approximate">
  <%!-- Fallback content renders in browsers without <geolocation> support --%>
  <button phx-click="request-location">Use my location</button>
</geolocation>

<script>
function handleLocation(event) {
  if (event.target.position) {
    const { latitude, longitude } = event.target.position.coords
    // Push to LiveView via a hook or inline pushEvent
  } else if (event.target.error) {
    console.error("Location error:", event.target.error.message)
  }
}
</script>
```

**Attributes:**

| Attribute | Values | Description |
|---|---|---|
| `accuracymode` | `"precise"` / `"approximate"` | GPS vs network location (default: approximate) |
| `autolocate` | boolean | Auto-retrieve on load if permission already granted (no unexpected prompts) |
| `watch` | boolean | Continuous updates as user moves (`watchPosition` behavior) |

**Properties (read-only):** `position` (GeolocationPosition), `error` (GeolocationPositionError)

**Events:** `location` — fires when data is retrieved or an error occurs

**CSS pseudo-class:** `:granted` — style the element when permission is active:

```css
geolocation:granted {
  /* visually indicate location is active */
}
```

**Why prefer over the JS API:**
- Ties permission request to explicit user action (the browser-rendered button) — no reflexive blocking
- Built-in recovery for previously blocked permissions (Chrome blocks after 3 dismissals — element provides a path to re-grant)
- Progressive enhancement: fallback content renders in unsupported browsers
- No JS permission management code needed

**Feature detection:**

```js
if ("HTMLGeolocationElement" in window) {
  // Native <geolocation> supported
} else {
  // Fall back to navigator.geolocation JS API
}
```

#### `navigator.geolocation` JS API — Fallback

Use the JS API as fallback when `<geolocation>` is not supported, or when you need programmatic control (e.g., triggering from a LiveView server event).

```js
navigator.geolocation.getCurrentPosition(
  (pos) => {
    const { latitude, longitude, accuracy } = pos.coords
    this.pushEvent("location-update", { lat: latitude, lng: longitude, accuracy })
  },
  (err) => {
    // err.code: 1 = PERMISSION_DENIED, 2 = POSITION_UNAVAILABLE, 3 = TIMEOUT
    this.pushEvent("location-error", { code: err.code, message: err.message })
  },
  {
    enableHighAccuracy: false, // true = GPS (slower, more battery), false = network (faster)
    timeout: 10000,            // max wait time in ms
    maximumAge: 300000,        // accept cached position up to 5 minutes old
  }
)
```

**LiveView hook pattern (JS API fallback):**

```js
export default {
  mounted() {
    this.handleEvent("request-location", () => {
      if ("HTMLGeolocationElement" in window) return // let <geolocation> handle it

      if (!("geolocation" in navigator)) {
        this.pushEvent("location-error", { code: 0, message: "Geolocation not supported" })
        return
      }
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          this.pushEvent("location-update", {
            lat: pos.coords.latitude,
            lng: pos.coords.longitude,
            accuracy: pos.coords.accuracy,
          })
        },
        (err) => {
          this.pushEvent("location-error", { code: err.code, message: err.message })
        },
        { enableHighAccuracy: false, timeout: 10000, maximumAge: 300000 }
      )
    })
  }
}
```

**Rules (apply to both approaches):**
- Always handle permission denial gracefully — show a fallback (manual location input, city selector)
- Use approximate/low accuracy by default — network location is faster, less battery, and sufficient for "nearby" queries. Only use precise/high accuracy for map pin-drop
- Cache positions (`maximumAge`) — no need to re-query for a "nearby restaurants" feature that updates every few minutes
- HTTPS required — geolocation is a secure-context-only API
- Never request location on page load — always on user action (button click or `autolocate` with existing permission)
- Round coordinates before sending to server (3–4 decimal places ≈ 11m accuracy is plenty for city-level features)

### Web Animations API (WAAPI)

For JS hooks that need more than CSS transitions — programmatic control, timeline binding, orchestration:

```js
// Basic element animation
const anim = el.animate(
  [
    { opacity: 0, transform: "translateY(12px)" },
    { opacity: 1, transform: "translateY(0)" }
  ],
  { duration: 300, easing: "ease-out", fill: "forwards" }
)

// Wait for completion
await anim.finished

// Scroll-linked animation via JS (when CSS scroll-timeline isn't enough)
el.animate(
  { transform: ["scale(0.8)", "scale(1)"] },
  { timeline: new ViewTimeline({ subject: el }), rangeStart: "entry", rangeEnd: "cover 50%" }
)

// Orchestrate a sequence in a hook
async function staggerReveal(container) {
  const children = container.children
  for (const [i, child] of Array.from(children).entries()) {
    child.animate(
      [
        { opacity: 0, filter: "blur(4px)", transform: "translateY(12px)" },
        { opacity: 1, filter: "blur(0px)", transform: "translateY(0)" }
      ],
      { duration: 300, delay: i * 80, easing: "ease-out", fill: "forwards" }
    )
  }
}
```

**When to use WAAPI vs CSS transitions:**
- CSS transitions — simple hover, toggle, open/close (interruptible, declarative)
- WAAPI — sequenced animations, scroll-timeline binding, dynamic values, `await anim.finished` for chaining
- Always animate S-tier properties (transform, opacity, filter, clip-path)

### CSS `@layer` — Cascade Control

Manage specificity and override order. Coordinate with Tailwind v4's own layers:

```css
/* In app.css — Tailwind v4 defines its own base/components/utilities layers
   via @import "tailwindcss". Use Tailwind's layer names for custom styles. */
@import "tailwindcss" source(none);

@layer base {
  /* Resets and element defaults — Tailwind's base layer */
  *, *::before, *::after { box-sizing: border-box; }
}

@layer components {
  /* Component styles — Tailwind's components layer */
  .card { background: var(--color-surface-alt); }
}

/* Tailwind utilities layer always wins — no need to declare it */
```

**Rules:**
- Use Tailwind v4's layer names (`base`, `components`, `utilities`) — don't invent parallel layers
- Custom `@layer` declarations must come after `@import "tailwindcss"` to avoid overriding Tailwind's internal layer order
- Never fight specificity with `!important` — reorder layers instead

### `@supports` — Feature Detection

Consistent pattern for progressive enhancement of newer features:

```css
/* Anchor positioning */
@supports (anchor-name: --x) {
  .tooltip { position-anchor: --trigger; top: anchor(bottom); }
}

/* View transitions */
@supports (view-transition-name: x) {
  .hero { view-transition-name: hero; }
}

/* Container queries */
@supports (container-type: inline-size) {
  .card-wrapper { container-type: inline-size; }
}
```

Use `@supports` for features where the fallback needs different CSS (not just "no effect"). For properties that are simply ignored when unsupported (like `text-wrap: pretty`), no `@supports` guard is needed.

### Performance Patterns

```css
/* content-visibility — skip rendering off-screen sections */
.feed-item {
  content-visibility: auto;
  contain-intrinsic-size: auto 300px; /* "auto" remembers computed size after first render */
}

/* contain — isolate layout/paint calculations */
.card {
  contain: layout style; /* changes inside don't trigger sibling recalc */
}

/* CSS containment for LiveView streams */
[id^="items-"] {
  contain: layout style paint;
  content-visibility: auto;
  contain-intrinsic-size: auto 80px;
}
```

**Rules:**
- Use `content-visibility: auto` on long lists, feeds, and below-fold sections
- Always pair with `contain-intrinsic-size: auto <estimate>` — the `auto` keyword lets the browser cache the real size after first render, reducing scroll jumps
- Use `contain: layout style` on visually independent components (cards, list items)
- **LiveView streams caveat**: `content-visibility: auto` with `contain-intrinsic-size` estimates can cause scroll position jumps when items are prepended via `phx-viewport-top` (the estimated heights replace real heights for off-screen items). Use `auto` in the `contain-intrinsic-size` to mitigate, and test with infinite scroll

### LiveView Scroll Patterns

```heex
<%!-- Reset scroll position on patch --%>
<div phx-scroll-reset id="results-container">
  <%!-- search results that should scroll to top on filter change --%>
</div>
```

**Basics:**
- LiveView `navigate` restores scroll position for back/forward navigations automatically
- LiveView `patch` maintains current scroll position — use `phx-scroll-reset` on containers that should reset to top on state change
- Use `scroll-margin-top` on anchored elements to account for sticky headers when scrolling into view

### Scroll Preservation Across Transitions & Back Navigation

When a user scrolls deep into a feed, clicks an article, reads it, and hits back — they should land exactly where they left off. This requires coordinating LiveView navigation, View Transitions, and scroll state persistence.

#### How LiveView Scroll Restoration Works

LiveView's `navigate` uses `pushState` and automatically saves/restores scroll position for back/forward navigations via the browser's native `history.scrollRestoration`. However, this breaks in two scenarios:

1. **View Transitions reset scroll** — by default, a view transition scrolls to top on the new page. The browser's scroll restoration fires *before* the transition completes, so the position is lost
2. **Infinite list DOM is gone** — when navigating away from a stream-based feed, the DOM is destroyed. On back navigation, LiveView re-mounts the LiveView and re-streams items from the server — but only the first page. The scroll position the browser tries to restore points to content that doesn't exist yet

#### Solution 1: View Transitions + Scroll Preservation

Prevent view transitions from resetting scroll on back/forward navigation:

```css
/* Allow the browser's native scroll restoration to work with view transitions */
@view-transition {
  navigation: auto;
}

/* Disable scroll reset during same-origin navigations that are traversals (back/forward) */
::view-transition-new(root) {
  /* The browser handles scroll restoration after the transition */
  overflow: clip;
}
```

```js
// In app.js or a global hook — intercept navigation to control scroll behavior
if ("navigation" in window) {
  navigation.addEventListener("navigate", (e) => {
    // For back/forward traversals, let the browser restore scroll
    if (e.navigationType === "traverse") {
      e.intercept({
        scroll: "after-transition",  // restore scroll AFTER view transition completes
        async handler() {
          // LiveView handles the actual navigation
          // This just ensures scroll timing is correct
        }
      })
    }
  })
}
```

The key is `scroll: "after-transition"` — it tells the browser to wait until the view transition finishes before restoring scroll position. Without this, the browser restores scroll to a position that doesn't exist yet (the old page is still visible during the transition).

#### Solution 2: Manual Scroll State for Infinite Lists

For infinite lists where the DOM is destroyed on navigation, save both scroll position AND the data cursor so the feed can be rebuilt:

```js
// Colocated hook on the feed container
export default {
  mounted() {
    this.feedKey = `scroll:${window.location.pathname}`

    // Restore saved state on mount
    const saved = sessionStorage.getItem(this.feedKey)
    if (saved) {
      const { scrollTop, cursor, itemCount } = JSON.parse(saved)
      // Tell the server to load items up to the saved cursor
      this.pushEvent("restore-feed", { cursor, item_count: itemCount })
      // Scroll will be restored after items are streamed (see updated())
      this.pendingScrollRestore = scrollTop
    }

    // Save scroll position on every scroll (debounced)
    let scrollTimer
    this.el.addEventListener("scroll", () => {
      clearTimeout(scrollTimer)
      scrollTimer = setTimeout(() => {
        this.saveScrollState()
      }, 100)
    }, { passive: true })

    // Also save right before navigating away
    document.addEventListener("phx:page-loading-start", () => {
      this.saveScrollState()
    }, { once: false })
  },

  updated() {
    // Restore scroll position after items are streamed back in
    if (this.pendingScrollRestore != null) {
      requestAnimationFrame(() => {
        this.el.scrollTop = this.pendingScrollRestore
        this.pendingScrollRestore = null
      })
    }
  },

  saveScrollState() {
    const lastItem = this.el.querySelector(".feed-item:last-child")
    const state = {
      scrollTop: this.el.scrollTop,
      cursor: lastItem?.dataset.cursor || null,
      itemCount: this.el.querySelectorAll(".feed-item").length
    }
    sessionStorage.setItem(this.feedKey, JSON.stringify(state))
  },

  destroyed() {
    // Keep the saved state — it's needed for back navigation
  }
}
```

Server-side handler:

```elixir
def handle_event("restore-feed", %{"cursor" => cursor, "item_count" => count}, socket) do
  # Load enough items to fill the viewport up to where the user was
  items = Feed.list_items(limit: count, before_cursor: cursor)
  {:noreply, stream(socket, :feed, items, reset: true)}
end
```

#### Solution 3: Page-Level Scroll Preservation (Non-Stream Pages)

For regular pages (not infinite lists) where the DOM is fully re-rendered by LiveView, the browser's native scroll restoration works if you don't interfere. Just ensure:

```js
// In app.js — do NOT set this to "manual" unless you have a specific reason
// LiveView and the browser handle scroll restoration automatically
// history.scrollRestoration = "manual"  // ← DON'T do this
```

For pages with scrollable sub-containers (not `window` scroll), save/restore per-container:

```js
// Colocated hook for scrollable sub-containers
export default {
  mounted() {
    const key = `scroll:${this.el.id}:${window.location.pathname}`
    const saved = sessionStorage.getItem(key)
    if (saved) {
      this.el.scrollTop = parseInt(saved, 10)
    }

    this.el.addEventListener("scroll", () => {
      sessionStorage.setItem(key, this.el.scrollTop)
    }, { passive: true })
  }
}
```

#### CSS: Scroll Position Anchoring

CSS scroll anchoring prevents the browser from jumping scroll position when content above the viewport changes (images loading, dynamic content inserted):

```css
/* Enable scroll anchoring (on by default, but ensure it's not disabled) */
.feed-container {
  overflow-anchor: auto;
}

/* Opt specific elements OUT of being scroll anchors (e.g., ads, banners that resize) */
.dynamic-banner {
  overflow-anchor: none;
}
```

This is particularly important for feeds where lazy-loaded images above the viewport expand and would otherwise push the current reading position down.

#### Scroll Preservation Checklist

- [ ] View transitions use `scroll: "after-transition"` via Navigation API for back/forward
- [ ] `history.scrollRestoration` is NOT set to `"manual"` (let the browser handle it)
- [ ] Infinite list hooks save scroll position + cursor to `sessionStorage` on scroll (debounced)
- [ ] Infinite list hooks save state on `phx:page-loading-start` (before navigation away)
- [ ] Server-side `restore-feed` event reloads items up to saved cursor on back navigation
- [ ] Scroll restored via `requestAnimationFrame` after items are streamed (`updated()` callback)
- [ ] Non-stream scrollable sub-containers save/restore via per-container hooks
- [ ] `overflow-anchor: auto` on feed containers (prevent jump from lazy-loaded images)
- [ ] `scroll-margin-top` accounts for sticky headers on all anchorable elements
- [ ] `sessionStorage` used (not `localStorage`) — scroll state is session-scoped

### Infinite Lists (Twitter/Feedly-style Feeds)

For feeds with thousands of items (news articles, recipes, research papers), combine LiveView streams with modern CSS/JS for buttery performance.

#### Template Structure

```heex
<div
  id="feed"
  phx-update="stream"
  phx-viewport-top={@page > 1 && "load-older"}
  phx-viewport-bottom="load-newer"
  class="feed-container"
>
  <%!-- Sticky date headers --%>
  <div :for={{id, item} <- @streams.feed} id={id} class="feed-item">
    <.feed_card item={item} />
  </div>
</div>

<%!-- "Back to top" floating button --%>
<button
  :if={@show_back_to_top}
  phx-click="scroll-to-top"
  class="back-to-top"
  aria-label="Back to top"
>
  <.icon name="hero-arrow-up" />
</button>
```

#### CSS — Rendering Performance

```css
/* Each feed item — skip rendering when off-screen */
.feed-item {
  content-visibility: auto;
  contain-intrinsic-size: auto 280px;  /* "auto" caches the real height after first paint */
  contain: layout style paint;          /* fully isolate each item */
}

/* The feed container */
.feed-container {
  scrollbar-gutter: stable;            /* prevent layout shift when scrollbar appears */
  overscroll-behavior-y: contain;      /* prevent pull-to-refresh / scroll chaining */
}

/* Sticky date/section headers within the feed */
.feed-date-header {
  position: sticky;
  top: var(--header-height, 64px);     /* below app header */
  z-index: 1;
  isolation: isolate;
  background: var(--color-surface);
  backdrop-filter: blur(8px);
  background: oklch(from var(--color-surface) l c h / 85%);
}
```

#### CSS — Entry Animations for New Items

```css
/* New items fade in when streamed into the DOM */
.feed-item {
  animation: feed-item-enter 300ms ease-out both;

  @starting-style {
    opacity: 0;
    transform: translateY(12px);
    filter: blur(4px);
  }
}

/* Stagger when multiple items load at once */
.feed-item {
  opacity: 1;
  transform: translateY(0);
  filter: blur(0);
  transition: opacity 300ms ease-out, transform 300ms ease-out, filter 300ms ease-out;

  @starting-style {
    opacity: 0;
    transform: translateY(12px);
    filter: blur(4px);
  }
}

/* Disable entry animation on scroll-triggered loads (reduce motion fatigue) */
.feed-container[data-loading="prepend"] .feed-item {
  animation: none;
  @starting-style { opacity: 1; transform: none; filter: none; }
}
```

#### JS Hook — Scroll Position Maintenance

The hardest part of infinite lists: maintaining scroll position when items are prepended above the viewport.

```heex
<div id="feed" phx-update="stream" phx-hook=".InfiniteScroll" ...>
```

```js
// Colocated hook
export default {
  mounted() {
    this.topSentinel = null
    this.isLoadingTop = false

    // Track "back to top" visibility
    this.scrollObserver = new IntersectionObserver(
      ([entry]) => {
        this.pushEvent("toggle-back-to-top", { show: !entry.isIntersecting })
      },
      { rootMargin: "-300px 0px 0px 0px" }
    )

    // Observe the first child as the top sentinel
    this.observeTopSentinel()

    // Scroll position maintenance for prepends
    this.pendingPrepend = false
    this.el.addEventListener("scroll", () => {
      this.el.dataset.loading = ""
    }, { passive: true })
  },

  updated() {
    // After LiveView prepends items, restore scroll position
    if (this.pendingPrepend) {
      // The browser auto-scrolls with content-visibility — anchor to the
      // item that was previously at the top
      this.anchorEl?.scrollIntoView({ block: "start" })
      this.pendingPrepend = false
      this.el.dataset.loading = ""
    }
    this.observeTopSentinel()
  },

  handleEvent("prepending", () => {
    // Snapshot the first visible item before prepend
    this.anchorEl = this.el.querySelector(".feed-item:first-child")
    this.pendingPrepend = true
    this.el.dataset.loading = "prepend"
  }),

  observeTopSentinel() {
    const first = this.el.querySelector(".feed-item:first-child")
    if (first && first !== this.topSentinel) {
      if (this.topSentinel) this.scrollObserver.unobserve(this.topSentinel)
      this.scrollObserver.observe(first)
      this.topSentinel = first
    }
  },

  destroyed() {
    this.scrollObserver.disconnect()
  }
}
```

#### JS Hook — Reading Progress & Scroll-Linked Effects

```css
/* Reading progress bar — pure CSS, no JS */
.reading-progress {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: var(--color-primary);
  transform-origin: left;
  animation: progress-fill linear;
  animation-timeline: scroll(nearest block);
  z-index: 50;
}
@keyframes progress-fill {
  from { transform: scaleX(0); }
  to { transform: scaleX(1); }
}

/* "New items available" pill — anchored to the feed top */
.new-items-pill {
  anchor-name: --feed-top;
  position: fixed;
  position-anchor: --feed-top;
  top: calc(anchor(bottom) + 8px);
  left: 50%;
  translate: -50% 0;
  z-index: 10;
}
```

#### Performance — Deferred & Batched Work

```js
// Defer non-critical work (analytics, prefetch) to idle time
requestIdleCallback(() => {
  trackImpression(visibleItems)
  prefetchNextPage(cursor)
})

// For heavy processing (parsing, transforming), yield between items
async function processStreamBatch(items) {
  for (const item of items) {
    processItem(item)
    await scheduler.yield()  // let browser paint between items
  }
}
```

#### Image Lazy Loading in Feed Items

```heex
<img
  src={@item.thumbnail_url}
  alt={@item.title}
  loading="lazy"
  decoding="async"
  fetchpriority={if @index < 3, do: "high", else: "low"}
  width="400"
  height="225"
  class="feed-image"
/>
```

```css
.feed-image {
  aspect-ratio: 16 / 9;
  object-fit: cover;
  background: var(--color-surface-alt);  /* placeholder color while loading */
  outline: 1px solid oklch(0% 0 0 / 0.05);
  outline-offset: -1px;

  /* Fade in when loaded */
  opacity: 1;
  transition: opacity 200ms ease-out;

  @starting-style {
    opacity: 0;
  }
}
```

#### View Transitions for Item Navigation

When clicking a feed item to navigate to its detail page, use view transitions for continuity:

```css
/* Each feed card's image can morph into the detail page hero */
.feed-item[id] img {
  view-transition-name: var(--vt-name); /* set dynamically via style attribute */
}

/* On the detail page */
.article-hero {
  view-transition-name: article-hero;
}
```

```heex
<%!-- In the feed item --%>
<.link
  navigate={~p"/news/#{@item.slug}"}
  style={"view-transition-name: article-#{@item.id}"}
>
  <img src={@item.thumbnail_url} ... />
</.link>
```

#### Infinite List Checklist

- [ ] Stream items use `content-visibility: auto` + `contain-intrinsic-size: auto <height>`
- [ ] Each item has `contain: layout style paint` for full isolation
- [ ] Container has `overscroll-behavior-y: contain` (no scroll chaining)
- [ ] Container has `scrollbar-gutter: stable` (no layout shift)
- [ ] Scroll position maintained on prepend (anchor element pattern)
- [ ] Entry animations disabled for scroll-triggered batch loads (frequency principle)
- [ ] Images use `loading="lazy"` + `decoding="async"` + explicit dimensions
- [ ] Images have `aspect-ratio` to prevent CLS
- [ ] First 3 items' images use `fetchpriority="high"`, rest use `"low"`
- [ ] Sticky section headers use `backdrop-filter` + semi-transparent background
- [ ] "Back to top" button appears after scrolling past threshold
- [ ] Non-critical work (analytics, prefetch) deferred via `requestIdleCallback`
- [ ] Heavy processing yields via `scheduler.yield()` between items
- [ ] View transition names set on navigable media for detail-page morphing
- [ ] Reading progress bar uses CSS `animation-timeline: scroll()` (no JS)

---

## Component Library

### Core Components (`core_components.ex`)

Foundation components that every page uses. **No DaisyUI** — pure Tailwind with design tokens.

| Component | Purpose | Key Props |
|---|---|---|
| `flash/1` | Toast notification | `kind` (:info / :error), `flash`, `title` |
| `button/1` | Button / link button | `variant` (primary/secondary/ghost), `size`, `loading` |
| `input/1` | Form input with label + errors | `field`, `type`, `label`, `class` |
| `header/1` | Page header with title + actions | `inner_block`, `subtitle`, `actions` slots |
| `table/1` | Data table with streaming | `id`, `rows`, `col` slot, `action` slot |
| `list/1` | Data list | `item` slot |
| `icon/1` | Heroicon wrapper | `name`, `class` |
| `show/2`, `hide/2` | JS transitions | `selector` |

### UI Components (`components/ui/`)

Extended components. Each in its own file for organization:

| Component | File | Purpose |
|---|---|---|
| `skeleton/1` | `skeleton.ex` | Skeleton loading placeholders |
| `badge/1` | `badge.ex` | Status/category badges |
| `card/1` | `card.ex` | Content cards with image, title, meta |
| `empty_state/1` | `empty_state.ex` | Empty state with icon + message + action |
| `inline_alert/1` | `inline_alert.ex` | Inline success/error/warning/info messages |
| `copy_button/1` | `copy_button.ex` | Copy-to-clipboard button with feedback |
| `avatar/1` | `avatar.ex` | User avatar with fallback |
| `stat/1` | `stat.ex` | Stat card (number + label + trend) |
| `nav_link/1` | `nav_link.ex` | Navigation link with active state |

### Modals, Sheets & Drawers

A comprehensive overlay system inspired by Silk's component model — built entirely with native `<dialog>`, CSS, and minimal JS hooks. No React, no libraries. All animations are GPU-accelerated (S-tier: transform + opacity + filter), interruptible via CSS transitions, and respect `prefers-reduced-motion`.

#### Overlay Types

| Type | Direction | Use case | Dismiss |
|---|---|---|---|
| **Modal** | Center, scale up | Confirmations, forms, detail views | `closedby="any"` or `closedby="closerequest"` |
| **Bottom Sheet** | Slides up from bottom | Mobile actions, filters, pickers | Swipe down or backdrop tap |
| **Top Sheet** | Slides down from top | Notifications, banners, alerts | Swipe up or backdrop tap |
| **Side Drawer** | Slides from left/right | Navigation, settings, filters | Swipe toward edge or backdrop tap |
| **Detached Sheet** | Floats above bottom | Toasts, mini-players, contextual panels | Swipe down or explicit close |
| **Lightbox** | Fade + scale | Image/media viewer | Backdrop tap, Escape, pinch-to-dismiss |
| **Page Sheet** | Full slide from bottom | Full-screen detail, sub-flows | Back button, swipe down from top |
| **Stacking Sheets** | Stack with depth | Multi-step flows, nested detail | Each sheet dismisses independently |

#### Base Dialog Component

All overlay types build on a single base `<dialog>` wrapper:

```elixir
# lib/aya_web/components/ui/overlay.ex
defmodule AyaWeb.UI.Overlay do
  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  @doc """
  Base overlay component. All modals, sheets, and drawers use this.

  ## Attributes
    * `id` - Required. Unique dialog ID.
    * `variant` - :modal | :bottom_sheet | :top_sheet | :drawer_left | :drawer_right
                 | :detached | :lightbox | :page_sheet. Default :modal.
    * `size` - :sm | :md | :lg | :xl | :full. Default :md.
    * `closedby` - "any" | "closerequest" | "none". Default "any".
    * `on_close` - Optional JS command or server event on close.
    * `class` - Additional CSS classes.

  ## Slots
    * `inner_block` - Main content.
    * `header` - Optional header with title + close button.
    * `footer` - Optional footer with actions.
  """

  attr :id, :string, required: true
  attr :variant, :atom, default: :modal
  attr :size, :atom, default: :md
  attr :closedby, :string, default: "any"
  attr :on_close, :any, default: nil
  attr :class, :string, default: nil

  slot :header
  slot :inner_block, required: true
  slot :footer

  def overlay(assigns) do
    ~H"""
    <dialog
      id={@id}
      closedby={@closedby}
      class={[
        "overlay",
        "overlay--#{@variant}",
        "overlay--#{@size}",
        @class
      ]}
      phx-hook={if @on_close, do: ".OverlayHook"}
      data-on-close={@on_close}
    >
      <div class="overlay__backdrop" />
      <div class="overlay__surface">
        <header :for={header <- @header} class="overlay__header">
          {render_slot(header)}
          <button commandfor={@id} command="close" class="overlay__close" aria-label="Close">
            <.icon name="hero-x-mark" class="size-5" />
          </button>
        </header>
        <div class="overlay__body">
          {render_slot(@inner_block)}
        </div>
        <footer :for={footer <- @footer} class="overlay__footer">
          {render_slot(footer)}
        </footer>
      </div>
    </dialog>
    """
  end
end
```

#### Usage in LiveView Templates

```heex
<%!-- Trigger — declarative, no JS --%>
<button commandfor="delete-confirm" command="show-modal">Delete Recipe</button>

<%!-- Modal --%>
<.overlay id="delete-confirm" variant={:modal} size={:sm} closedby="closerequest">
  <:header>Confirm Deletion</:header>
  Are you sure you want to delete this recipe? This cannot be undone.
  <:footer>
    <button commandfor="delete-confirm" command="close" class="btn-secondary">Cancel</button>
    <button phx-click="delete" commandfor="delete-confirm" command="close" class="btn-primary">
      Delete
    </button>
  </:footer>
</.overlay>

<%!-- Bottom Sheet --%>
<button commandfor="filters-sheet" command="show-modal">Filters</button>

<.overlay id="filters-sheet" variant={:bottom_sheet} size={:lg}>
  <:header>Filter Results</:header>
  <.filter_form fields={@filter_fields} />
</.overlay>

<%!-- Side Drawer --%>
<button commandfor="nav-drawer" command="show-modal">Menu</button>

<.overlay id="nav-drawer" variant={:drawer_left} size={:sm}>
  <:header>Navigation</:header>
  <.side_nav links={@nav_links} />
</.overlay>

<%!-- Page Sheet (full screen sub-flow) --%>
<button commandfor="recipe-detail" command="show-modal">View Recipe</button>

<.overlay id="recipe-detail" variant={:page_sheet} size={:full}>
  <:header>{@recipe.title}</:header>
  <.recipe_full recipe={@recipe} />
</.overlay>
```

#### CSS — Animation System

All overlays share a unified animation system. Each variant overrides only `transform` origin/direction:

```css
/* ============================================
   Base overlay — shared by all variants
   ============================================ */

.overlay {
  /* Reset native dialog styles */
  border: none;
  padding: 0;
  margin: 0;
  max-width: unset;
  max-height: unset;
  background: transparent;
  overflow: visible;

  /* Full viewport overlay */
  position: fixed;
  inset: 0;
  width: 100%;
  height: 100%;
  display: grid;
  place-items: center;
  z-index: var(--z-modal, 200);
  isolation: isolate;

  /* Entry — the dialog itself transitions from closed to open */
  opacity: 1;
  transition:
    opacity 250ms ease-out,
    overlay 250ms allow-discrete,
    display 250ms allow-discrete;

  @starting-style {
    opacity: 0;
  }
}

/* Closed state — must use [open] since <dialog> is hidden by default */
.overlay:not([open]) {
  opacity: 0;
  pointer-events: none;
}

/* ============================================
   Backdrop — separate from ::backdrop for
   more animation control
   ============================================ */

.overlay__backdrop {
  position: fixed;
  inset: 0;
  background: oklch(0% 0 0 / 0.4);
  backdrop-filter: blur(4px);
  z-index: -1;

  opacity: 1;
  transition: opacity 250ms ease-out;

  @starting-style {
    opacity: 0;
  }
}

/* Darken backdrop more on mobile for readability */
@media (max-width: 640px) {
  .overlay__backdrop {
    background: oklch(0% 0 0 / 0.6);
  }
}

/* Hide the native ::backdrop (we use our own for better animation) */
.overlay::backdrop {
  display: none;
}

/* ============================================
   Surface — the visible panel
   ============================================ */

.overlay__surface {
  position: relative;
  display: flex;
  flex-direction: column;
  background: var(--color-surface);
  border-radius: var(--radius-xl, 16px);
  box-shadow:
    0 25px 50px -12px oklch(0% 0 0 / 0.25),
    0 0 0 1px oklch(0% 0 0 / 0.05);
  max-height: calc(100dvh - 2rem);
  overflow: hidden;

  /* Interruptible transitions — can be interrupted mid-animation */
  transition:
    transform 300ms cubic-bezier(0.32, 0.72, 0, 1),
    opacity 250ms ease-out,
    filter 250ms ease-out;

  @starting-style {
    opacity: 0;
    filter: blur(4px);
  }
}

.overlay:not([open]) .overlay__surface {
  opacity: 0;
  filter: blur(4px);
}

.overlay__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--spacing-4) var(--spacing-6);
  border-bottom: 1px solid var(--color-border);
  flex-shrink: 0;

  & > :first-child {
    font-weight: 600;
    font-size: 1.125rem;
    text-wrap: balance;
  }
}

.overlay__close {
  display: grid;
  place-items: center;
  width: 36px;
  height: 36px;
  border-radius: var(--radius-md);
  color: var(--color-text-secondary);
  cursor: pointer;
  transition: background 150ms ease, color 150ms ease;
  flex-shrink: 0;

  &:hover {
    background: var(--color-surface-hover);
    color: var(--color-text);
  }
  &:active {
    scale: 0.96;
  }
}

.overlay__body {
  flex: 1;
  overflow-y: auto;
  overscroll-behavior: contain;  /* prevent scroll chaining */
  padding: var(--spacing-6);
}

.overlay__footer {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: var(--spacing-3);
  padding: var(--spacing-4) var(--spacing-6);
  border-top: 1px solid var(--color-border);
  flex-shrink: 0;
}

/* ============================================
   Size variants
   ============================================ */

.overlay--sm .overlay__surface { width: min(400px, calc(100vw - 2rem)); }
.overlay--md .overlay__surface { width: min(560px, calc(100vw - 2rem)); }
.overlay--lg .overlay__surface { width: min(720px, calc(100vw - 2rem)); }
.overlay--xl .overlay__surface { width: min(960px, calc(100vw - 2rem)); }
.overlay--full .overlay__surface {
  width: calc(100vw - 2rem);
  height: calc(100dvh - 2rem);
}

/* ============================================
   Variant: Modal (center, scale up)
   ============================================ */

.overlay--modal {
  place-items: center;
}
.overlay--modal .overlay__surface {
  @starting-style {
    transform: scale(0.95) translateY(8px);
  }
}
.overlay--modal:not([open]) .overlay__surface {
  transform: scale(0.97) translateY(-4px);
}

/* ============================================
   Variant: Bottom Sheet
   ============================================ */

.overlay--bottom_sheet {
  place-items: end center;
}
.overlay--bottom_sheet .overlay__surface {
  width: 100%;
  max-width: min(560px, 100vw);
  border-radius: var(--radius-xl) var(--radius-xl) 0 0;
  max-height: 85dvh;

  @starting-style {
    transform: translateY(100%);
  }
}
.overlay--bottom_sheet:not([open]) .overlay__surface {
  transform: translateY(100%);
}

/* Drag handle */
.overlay--bottom_sheet .overlay__header::before {
  content: "";
  position: absolute;
  top: 8px;
  left: 50%;
  translate: -50% 0;
  width: 36px;
  height: 4px;
  border-radius: 2px;
  background: var(--color-border-strong);
}

/* ============================================
   Variant: Top Sheet
   ============================================ */

.overlay--top_sheet {
  place-items: start center;
}
.overlay--top_sheet .overlay__surface {
  width: 100%;
  max-width: min(560px, 100vw);
  border-radius: 0 0 var(--radius-xl) var(--radius-xl);
  max-height: 85dvh;

  @starting-style {
    transform: translateY(-100%);
  }
}
.overlay--top_sheet:not([open]) .overlay__surface {
  transform: translateY(-100%);
}

/* ============================================
   Variant: Drawer Left / Right
   ============================================ */

.overlay--drawer_left {
  place-items: stretch start;
}
.overlay--drawer_left .overlay__surface {
  height: 100dvh;
  max-height: 100dvh;
  border-radius: 0 var(--radius-xl) var(--radius-xl) 0;

  @starting-style {
    transform: translateX(-100%);
  }
}
.overlay--drawer_left:not([open]) .overlay__surface {
  transform: translateX(-100%);
}

.overlay--drawer_right {
  place-items: stretch end;
}
.overlay--drawer_right .overlay__surface {
  height: 100dvh;
  max-height: 100dvh;
  border-radius: var(--radius-xl) 0 0 var(--radius-xl);

  @starting-style {
    transform: translateX(100%);
  }
}
.overlay--drawer_right:not([open]) .overlay__surface {
  transform: translateX(100%);
}

/* ============================================
   Variant: Page Sheet (full slide from bottom)
   ============================================ */

.overlay--page_sheet {
  place-items: end center;
}
.overlay--page_sheet .overlay__surface {
  width: 100vw;
  height: calc(100dvh - 12px);
  max-height: calc(100dvh - 12px);
  border-radius: var(--radius-xl) var(--radius-xl) 0 0;

  @starting-style {
    transform: translateY(100%);
  }
}
.overlay--page_sheet:not([open]) .overlay__surface {
  transform: translateY(100%);
}

/* ============================================
   Variant: Detached (floating, for toasts/mini-players)
   ============================================ */

.overlay--detached {
  place-items: end center;
  padding-bottom: env(safe-area-inset-bottom, 16px);
  pointer-events: none; /* allow interaction with page behind */
}
.overlay--detached .overlay__backdrop {
  display: none; /* no backdrop */
}
.overlay--detached .overlay__surface {
  pointer-events: auto;
  margin-bottom: 1rem;
  max-height: 50dvh;

  @starting-style {
    transform: translateY(16px);
  }
}
.overlay--detached:not([open]) .overlay__surface {
  transform: translateY(16px);
}

/* ============================================
   Variant: Lightbox (media viewer)
   ============================================ */

.overlay--lightbox {
  place-items: center;
}
.overlay--lightbox .overlay__backdrop {
  background: oklch(0% 0 0 / 0.85);
}
.overlay--lightbox .overlay__surface {
  background: transparent;
  box-shadow: none;
  max-width: 95vw;
  max-height: 95dvh;

  @starting-style {
    transform: scale(0.9);
  }
}
.overlay--lightbox:not([open]) .overlay__surface {
  transform: scale(0.9);
}

/* ============================================
   Stacking — when sheets open on top of sheets
   ============================================ */

/* Push back the previous dialog when a new one opens */
dialog.overlay[open]:has(~ dialog.overlay[open]) .overlay__surface {
  transform: scale(0.94) translateY(-8px);
  filter: brightness(0.92);
  border-radius: var(--radius-xl);
  transition:
    transform 300ms cubic-bezier(0.32, 0.72, 0, 1),
    filter 300ms ease;
}

/* Third level of stacking — even smaller */
dialog.overlay[open]:has(~ dialog.overlay[open] ~ dialog.overlay[open]) .overlay__surface {
  transform: scale(0.88) translateY(-16px);
  filter: brightness(0.85);
}

/* ============================================
   Reduced motion
   ============================================ */

@media (prefers-reduced-motion: reduce) {
  .overlay,
  .overlay__backdrop,
  .overlay__surface {
    transition-duration: 0ms !important;
  }
  .overlay__surface {
    @starting-style {
      transform: none !important;
      filter: none !important;
    }
  }
}
```

#### JS Hook — Swipe-to-Dismiss & Snap Points

For sheets and drawers, add swipe/drag gesture support via a hook. The animation uses WAAPI for smooth, interruptible gesture tracking:

```js
// assets/js/dev/../hooks/overlay_gestures.js
// Also usable as a colocated hook

export default {
  mounted() {
    const surface = this.el.querySelector(".overlay__surface")
    if (!surface) return

    const variant = this.el.classList.contains("overlay--bottom_sheet") ? "bottom"
      : this.el.classList.contains("overlay--top_sheet") ? "top"
      : this.el.classList.contains("overlay--drawer_left") ? "left"
      : this.el.classList.contains("overlay--drawer_right") ? "right"
      : null

    if (!variant) return // Only gesture-dismiss for sheets/drawers

    // Snap points (detents) — percentage of max travel
    this.detents = JSON.parse(this.el.dataset.detents || "null") // e.g., [0.3, 0.6, 1.0]
    this.dismissThreshold = 0.35  // dismiss if dragged past 35%
    this.velocity = 0
    this.lastY = 0
    this.lastTime = 0
    this.isDragging = false

    const axis = (variant === "left" || variant === "right") ? "x" : "y"
    const dismissDir = { bottom: 1, top: -1, left: -1, right: 1 }[variant]

    // Determine max travel distance
    const getMax = () => axis === "y" ? surface.offsetHeight : surface.offsetWidth

    const onPointerDown = (e) => {
      // Only start drag from the header/handle area for sheets
      if (variant === "bottom" || variant === "top") {
        const header = surface.querySelector(".overlay__header")
        if (header && !header.contains(e.target)) return
      }

      this.isDragging = true
      this.startPos = axis === "y" ? e.clientY : e.clientX
      this.currentOffset = 0
      this.lastY = this.startPos
      this.lastTime = Date.now()
      this.velocity = 0

      surface.style.transition = "none"  // disable CSS transition during drag
      surface.setPointerCapture(e.pointerId)
    }

    const onPointerMove = (e) => {
      if (!this.isDragging) return
      const current = axis === "y" ? e.clientY : e.clientX
      const delta = (current - this.startPos) * dismissDir

      // Only allow dragging in the dismiss direction (positive = toward dismiss)
      const clamped = Math.max(0, delta)
      this.currentOffset = clamped

      // Track velocity for fling detection
      const now = Date.now()
      const dt = now - this.lastTime
      if (dt > 0) {
        const dPos = current - this.lastY
        this.velocity = dPos / dt  // px/ms
      }
      this.lastY = current
      this.lastTime = now

      // Apply transform — GPU composited, S-tier
      const progress = clamped / getMax()
      const translate = axis === "y"
        ? `translateY(${clamped * dismissDir}px)`
        : `translateX(${clamped * dismissDir}px)`

      surface.style.transform = translate

      // Fade backdrop proportionally
      const backdrop = this.el.querySelector(".overlay__backdrop")
      if (backdrop) {
        backdrop.style.opacity = String(1 - progress * 0.8)
      }
    }

    const onPointerUp = (e) => {
      if (!this.isDragging) return
      this.isDragging = false

      const max = getMax()
      const progress = this.currentOffset / max
      const flung = Math.abs(this.velocity) > 0.5  // fling threshold: 0.5 px/ms

      // Decide: dismiss or snap back
      const shouldDismiss = progress > this.dismissThreshold || (flung && this.velocity * dismissDir > 0)

      // Restore CSS transitions
      surface.style.transition = ""

      if (shouldDismiss) {
        // Animate to dismissed position, then close
        const translate = axis === "y"
          ? `translateY(${max * dismissDir}px)`
          : `translateX(${max * dismissDir}px)`

        const anim = surface.animate(
          [{ transform: surface.style.transform }, { transform: translate }],
          { duration: 200, easing: "cubic-bezier(0.32, 0.72, 0, 1)", fill: "forwards" }
        )
        anim.finished.then(() => {
          surface.style.transform = ""
          surface.getAnimations().forEach(a => a.cancel())
          this.el.close()
        })
      } else if (this.detents) {
        // Snap to nearest detent
        const nearest = this.detents.reduce((a, b) =>
          Math.abs(b - progress) < Math.abs(a - progress) ? b : a
        )
        const snapPos = nearest * max * dismissDir
        const translate = axis === "y"
          ? `translateY(${snapPos}px)`
          : `translateX(${snapPos}px)`

        surface.animate(
          [{ transform: surface.style.transform }, { transform: translate }],
          { duration: 300, easing: "cubic-bezier(0.32, 0.72, 0, 1)", fill: "forwards" }
        )
      } else {
        // Snap back to open position
        const backdrop = this.el.querySelector(".overlay__backdrop")
        surface.animate(
          [{ transform: surface.style.transform }, { transform: "translateY(0)" }],
          { duration: 300, easing: "cubic-bezier(0.32, 0.72, 0, 1)", fill: "forwards" }
        ).finished.then(() => {
          surface.style.transform = ""
        })
        if (backdrop) {
          backdrop.animate(
            [{ opacity: backdrop.style.opacity }, { opacity: "1" }],
            { duration: 200, fill: "forwards" }
          ).finished.then(() => { backdrop.style.opacity = "" })
        }
      }

      // Clean up inline styles
      const backdrop = this.el.querySelector(".overlay__backdrop")
      if (backdrop) backdrop.style.opacity = ""
    }

    surface.addEventListener("pointerdown", onPointerDown)
    surface.addEventListener("pointermove", onPointerMove)
    surface.addEventListener("pointerup", onPointerUp)
    surface.addEventListener("pointercancel", onPointerUp)

    // Cleanup
    this._cleanup = () => {
      surface.removeEventListener("pointerdown", onPointerDown)
      surface.removeEventListener("pointermove", onPointerMove)
      surface.removeEventListener("pointerup", onPointerUp)
      surface.removeEventListener("pointercancel", onPointerUp)
    }
  },

  destroyed() {
    this._cleanup?.()
  }
}
```

Usage with snap points (detents):

```heex
<.overlay id="player-sheet" variant={:bottom_sheet} size={:lg}>
  <div phx-hook=".OverlayGestures" id="player-sheet-gestures" data-detents="[0.3, 1.0]">
    <%!-- Sheet snaps to 30% or 100% height --%>
  </div>
</.overlay>
```

#### Scroll Locking

When a modal/sheet opens, the page behind must not scroll. Use the `inert` + CSS approach:

```heex
<%!-- In app.html.heex — inert the main content when any overlay is open --%>
<main inert={@overlay_open} class={[@overlay_open && "scroll-locked"]}>
  {@inner_content}
</main>
```

```css
/* Prevent body scroll when overlay is open — no layout shift */
.scroll-locked {
  overflow: hidden;
  /* Preserve scroll position — prevents jump-to-top */
  position: fixed;
  inset: 0;
  /* The JS hook will save/restore scrollY */
}
```

Better approach — let `<dialog showModal()>` handle it natively. The browser already prevents scroll on the page when a `showModal()` dialog is open (via the `:modal` pseudo-class and the top layer). The `inert` attribute handles focus trapping. Minimal JS needed:

```css
/* The browser adds this automatically for showModal() dialogs —
   ensures body doesn't scroll. No manual scroll locking needed. */
html:has(dialog.overlay[open]) {
  overflow: hidden;
}
```

#### Focus Management

Native `<dialog>` with `showModal()` handles focus trapping automatically:
- Focus moves to the first focusable element inside the dialog on open
- Tab is trapped within the dialog
- Focus returns to the trigger element on close (via `commandfor`)
- The `inert` attribute on `<main>` reinforces this

For custom focus behavior:

```js
// In the overlay hook
this.el.addEventListener("toggle", (e) => {
  if (e.newState === "open") {
    // Focus a specific element (e.g., the first input in a form sheet)
    const autofocus = this.el.querySelector("[autofocus]")
    if (autofocus) {
      requestAnimationFrame(() => autofocus.focus())
    }
  }
})
```

#### Stacking Sheets

When one sheet opens on top of another, the previous sheet scales down for depth:

```heex
<%!-- First sheet --%>
<button commandfor="settings" command="show-modal">Settings</button>
<.overlay id="settings" variant={:bottom_sheet}>
  <:header>Settings</:header>
  <%!-- Inside, another trigger --%>
  <button commandfor="account-detail" command="show-modal">Account Details</button>
</.overlay>

<%!-- Second sheet — opens on top, pushing first one back --%>
<.overlay id="account-detail" variant={:bottom_sheet}>
  <:header>Account</:header>
  <%!-- content --%>
</.overlay>
```

The CSS `:has()` selector (in the stacking section above) automatically scales back the previous sheet — no JS coordination needed. The browser's top layer handles z-ordering for `showModal()` dialogs.

#### Mobile Adaptations

Sheets should adapt between mobile and desktop:

```css
/* Bottom sheet on mobile → centered modal on desktop */
@media (min-width: 640px) {
  .overlay--bottom_sheet {
    place-items: center;
  }
  .overlay--bottom_sheet .overlay__surface {
    border-radius: var(--radius-xl);
    max-height: 80dvh;
    width: min(560px, calc(100vw - 4rem));

    @starting-style {
      transform: scale(0.95) translateY(8px);
    }
  }
  .overlay--bottom_sheet:not([open]) .overlay__surface {
    transform: scale(0.97) translateY(-4px);
  }

  /* Hide drag handle on desktop */
  .overlay--bottom_sheet .overlay__header::before {
    display: none;
  }
}

/* Drawer on mobile → side panel on desktop (non-modal) */
@media (min-width: 1024px) {
  .overlay--drawer_left.overlay--persistent {
    position: relative;
    display: block;

    & .overlay__backdrop { display: none; }
    & .overlay__surface {
      height: auto;
      border-radius: 0;
      box-shadow: none;
      border-right: 1px solid var(--color-border);
    }
  }
}
```

#### Animation Guidelines (from skills)

All overlay animations must follow these rules:

- **Easing**: `cubic-bezier(0.32, 0.72, 0, 1)` for sheets/drawers (smooth deceleration). `ease-out` for modals. Never `linear`
- **Duration**: 250–300ms for open, 200ms for close (exits are faster than enters)
- **Enter**: Combine `opacity` + `transform` + `filter: blur(4px)`. Split content into semantic chunks (header, body, footer) and stagger ~60ms if content is complex
- **Exit**: Subtle — smaller transform than enter, shorter duration
- **Interruptible**: All animations use CSS transitions (not `@keyframes`) so they can be reversed mid-flight if the user re-triggers
- **Frequency principle**: If a sheet is opened 50 times a day, keep animations minimal. Reserve elaborate enter animations for first-time flows
- **S-tier only**: Only animate `transform`, `opacity`, `filter`, `clip-path`. Never animate `width`, `height`, `top`, `left`
- **Backdrop**: Fade opacity independently from the surface — backdrop fades in 250ms, surface can take 300ms
- **Spring physics**: Use `/css-spring` skill for gesture-release animations where overshoot feels natural
- **Reduced motion**: Always wrap in `@media (prefers-reduced-motion: no-preference)` or disable entirely

#### Overlay Checklist

- [ ] Uses native `<dialog>` with `showModal()` (via `command="show-modal"`)
- [ ] `closedby` attribute set appropriately (any/closerequest/none)
- [ ] Background content uses `inert` when overlay is open
- [ ] Scroll locked on body via `html:has(dialog.overlay[open])` or native `showModal()`
- [ ] Surface animates with S-tier properties only (transform, opacity, filter)
- [ ] Transitions are interruptible (CSS transitions, not keyframes)
- [ ] Enter: 250–300ms, exit: 200ms, easing: `cubic-bezier(0.32, 0.72, 0, 1)`
- [ ] Backdrop fades with `backdrop-filter: blur(4px)` and semi-transparent background
- [ ] Surface uses `overscroll-behavior: contain` on scrollable body
- [ ] Bottom sheets have drag handle and swipe-to-dismiss via pointer events + WAAPI
- [ ] Stacking sheets scale back via `:has()` selector (no JS)
- [ ] Close button is ≥ 44px tap target, uses `commandfor` + `command="close"`
- [ ] Focus trapped by native `showModal()`, returns to trigger on close
- [ ] `prefers-reduced-motion` disables all animation
- [ ] Bottom sheet → modal on desktop via `@media (min-width: 640px)`
- [ ] Concentric border radius on nested rounded elements
- [ ] Shadows (not borders) on surface for depth
- [ ] Safe area insets respected via `env(safe-area-inset-bottom)`

### Component Design Rules

1. **No DaisyUI classes** — build everything with Tailwind utilities + design tokens
2. All interactive elements must have **focus-visible** states
3. All components must work in **both light and dark mode**
4. Use CSS transitions for micro-interactions (150-200ms for hovers, 300ms for entrances)
5. Loading states on buttons: replace text with spinner, disable button
6. Links: `text-link hover:text-link-hover transition-colors` — NO underlines

---

## Testing Framework

### Stack

- **ExUnit** — test runner
- **Mimic** — mocking (replaces Mox — better API, more flexible)
- **LazyHTML** — HTML assertion library for LiveView tests
- **Ecto.Adapters.SQL.Sandbox** — database isolation

### Test Organization

```
test/
├── test_helper.exs          # ExUnit.start(), Mimic.copy() calls
├── support/
│   ├── conn_case.ex          # Controller tests
│   ├── data_case.ex          # Data/schema tests
│   ├── live_case.ex          # LiveView tests (extends ConnCase + timezone + auth helpers)
│   ├── http_case.ex          # External HTTP integration tests (Mimic on Req)
│   ├── process_case.ex       # GenServer/process tests
│   └── fixtures.ex           # Shared factory functions
├── aya/                      # Domain tests
└── aya_web/                  # Web tests
```

### Mimic Setup

In `test_helper.exs`:

```elixir
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Aya.Repo, :manual)

# Copy modules that will be mocked
Mimic.copy(Req)
Mimic.copy(DateTime)
```

In test files:

```elixir
use Mimic

setup :verify_on_exit!

test "fetches article" do
  Req.
  |> expect(:get, fn _url, _opts ->
    {:ok, %Req.Response{status: 200, body: %{"title" => "Food News"}}}
  end)

  assert {:ok, article} = News.fetch_article("https://example.com/article")
  assert article.title == "Food News"
end
```

### Testing 3rd Party HTTP APIs

**Always** use Mimic to mock `Req` (or the specific API client module) for HTTP tests:

```elixir
defmodule Aya.News.FeedFetcherTest do
  use Aya.DataCase, async: true
  use Mimic

  setup :verify_on_exit!

  describe "fetch/1" do
    test "parses RSS feed successfully" do
      Req
      |> expect(:get, fn url, _opts ->
        assert url =~ "example.com/feed"
        {:ok, %Req.Response{status: 200, body: rss_xml_fixture()}}
      end)

      assert {:ok, articles} = FeedFetcher.fetch("https://example.com/feed")
      assert length(articles) > 0
    end

    test "handles network errors" do
      Req
      |> expect(:get, fn _url, _opts ->
        {:error, %Req.TransportError{reason: :timeout}}
      end)

      assert {:error, _reason} = FeedFetcher.fetch("https://example.com/feed")
    end
  end
end
```

### Testing Timezone & DateTime

```elixir
defmodule Aya.TimeDisplayTest do
  use Aya.DataCase, async: true
  use Mimic

  setup :verify_on_exit!

  test "converts UTC to user timezone" do
    utc_time = ~U[2026-03-22 14:30:00Z]

    # Test display in different timezones
    assert "2:30 PM" = TimeDisplay.format(utc_time, "UTC")
    assert "10:00 PM" = TimeDisplay.format(utc_time, "Asia/Kolkata")
    assert "7:30 AM" = TimeDisplay.format(utc_time, "America/Los_Angeles")
  end
end
```

### Testing Elixir Processes

```elixir
defmodule Aya.News.FeedPollerTest do
  use Aya.DataCase, async: true

  test "polls feed on interval" do
    {:ok, pid} = start_supervised!({FeedPoller, interval: 100, feed_url: "https://example.com"})

    ref = Process.monitor(pid)

    # Synchronize with process
    _ = :sys.get_state(pid)

    # Assert process is running
    assert Process.alive?(pid)

    # Stop and verify clean shutdown
    stop_supervised!(FeedPoller)
    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
  end
end
```

### Integration Tests

For tests that need the full stack (LiveView + database + mocked HTTP):

```elixir
defmodule AyaWeb.NewsLive.IndexTest do
  use AyaWeb.ConnCase, async: true
  use Mimic

  import Phoenix.LiveViewTest

  setup :verify_on_exit!

  test "displays news articles", %{conn: conn} do
    # Insert test data
    article = insert_article(%{title: "New Food Discovery", published_at: ~U[2026-03-22 10:00:00Z]})

    {:ok, view, html} = live(conn, ~p"/news")

    assert has_element?(view, "#article-#{article.id}")
    assert has_element?(view, "#article-#{article.id} [data-role='title']", "New Food Discovery")
  end
end
```

### Test Best Practices

1. **Always** `async: true` unless test needs shared database state
2. **Always** `setup :verify_on_exit!` with Mimic
3. **Never** use `Process.sleep` — use monitors, `:sys.get_state`, or `assert_receive`
4. Test **outcomes**, not implementation details
5. Use `has_element?/2` and `element/2` — **never** test raw HTML
6. Give DOM elements `data-role` attributes for test selectors
7. Fixtures go in `test/support/fixtures.ex` as simple functions
8. For shared test data setup, use `setup` blocks, not `setup_all`

---

## Spec-Driven Development

### Workflow

1. **Spec** → Write the specification (in AGENTS.md or a `specs/` directory)
2. **Schema** → Define Ecto schemas + migrations
3. **Context** → Implement context module with public API
4. **Tests** → Write tests for context (unit + integration)
5. **LiveView** → Build the UI
6. **Component tests** → Test the LiveView
7. **Refine** → Update spec based on learnings

### Spec Format

Each feature should have a brief spec before implementation:

```markdown
### Feature: News Feed Aggregation

**Goal:** Fetch and display food news from RSS/Atom feeds.

**Schemas:**
- `Feed` — url, name, last_fetched_at, fetch_interval, active?
- `Article` — feed_id, title, url, summary, content, published_at, image_url

**Context API (Aya.News):**
- `list_articles(opts)` — paginated, filterable by feed, date range
- `get_article!(id)` — with feed preloaded
- `create_feed(attrs)` — validate URL, attempt initial fetch
- `fetch_feed(feed)` — fetch + parse + upsert articles

**LiveViews:**
- `NewsLive.Index` — paginated article list with feed filter
- `NewsLive.Show` — article detail with related articles

**Background:**
- `FeedFetcher` — scheduled job via om_scheduler, fetches all active feeds
```

### Adding New Features

When adding a new feature:
1. Add the spec to this file (or `specs/feature_name.md`)
2. Create the context directory under `lib/aya/`
3. Create schemas with `om_schema` macros
4. Create migrations with `om_migration` helpers
5. Implement context module
6. Write tests
7. Build LiveView UI
8. Update this file with any architectural decisions

---

## Quick Reference

### Project Commands

| Command | Purpose |
|---|---|
| `mix setup` | Install deps, create DB, build assets |
| `mix phx.server` | Start dev server (localhost:4000) |
| `iex -S mix phx.server` | Start dev server with IEx |
| `mix test` | Run all tests |
| `mix test test/path.exs` | Run specific test file |
| `mix test --failed` | Re-run failed tests |
| `mix precommit` | Compile (warnings=errors) + format + test |
| `mix ecto.gen.migration name` | Generate migration |
| `mix ecto.migrate` | Run migrations |
| `mix ecto.reset` | Drop + create + migrate + seed |

### HTTP Client

**Always** use `Req` (via `om_api_client` for structured API calls). **Never** use `:httpoison`, `:tesla`, or `:httpc`.

### Key Patterns

| Pattern | Use |
|---|---|
| `FnTypes.Result` | `{:ok, val}` / `{:error, reason}` returns |
| `FnTypes.Pipeline` | Multi-step data transformations |
| `om_api_client` pipeline | External HTTP API calls |
| `om_query` pipeline | Database query building |
| `om_schema` validators | Schema validation pipelines |
| `effect` workflows | Multi-step operations with rollback, parallel fan-out |

### Things to NEVER Do

- **Never** use `if..else` — use pattern matching, `case`, or `cond`
- **Never** use DaisyUI classes
- **Never** use raw Tailwind colors — use design tokens
- **Never** use underline on links — use color
- **Never** use `Process.sleep` in tests
- **Never** nest modules in same file
- **Never** use Tailwind's `@apply` in CSS (native CSS `@mixin`/`@apply` is fine)
- **Never** write inline `<script>` tags
- **Never** use `changeset[:field]` — use `Ecto.Changeset.get_field/2`
- **Never** use `String.to_atom/1` on user input
- **Never** use `Enum.each` in templates — use `for` comprehensions

<!-- usage-rules-start -->

<!-- phoenix:elixir-start -->
## Elixir guidelines

- Elixir lists **do not support index based access via the access syntax**

  **Never do this (invalid)**:

      i = 0
      mylist = ["blue", "green"]
      mylist[i]

  Instead, **always** use `Enum.at`, pattern matching, or `List` for index based list access, ie:

      i = 0
      mylist = ["blue", "green"]
      Enum.at(mylist, i)

- Elixir variables are immutable, but can be rebound, so for block expressions like `if`, `case`, `cond`, etc
  you *must* bind the result of the expression to a variable if you want to use it and you CANNOT rebind the result inside the expression, ie:

      # INVALID: we are rebinding inside the `if` and the result never gets assigned
      if connected?(socket) do
        socket = assign(socket, :val, val)
      end

      # VALID: we rebind the result of the `if` to a new variable
      socket =
        if connected?(socket) do
          assign(socket, :val, val)
        end

- **Never** nest multiple modules in the same file as it can cause cyclic dependencies and compilation errors
- **Never** use map access syntax (`changeset[:field]`) on structs as they do not implement the Access behaviour by default. For regular structs, you **must** access the fields directly, such as `my_struct.field` or use higher level APIs that are available on the struct if they exist, `Ecto.Changeset.get_field/2` for changesets
- Elixir's standard library has everything necessary for date and time manipulation. Familiarize yourself with the common `Time`, `Date`, `DateTime`, and `Calendar` interfaces by accessing their documentation as necessary. **Never** install additional dependencies unless asked or for date/time parsing (which you can use the `date_time_parser` package)
- Don't use `String.to_atom/1` on user input (memory leak risk)
- Predicate function names should not start with `is_` and should end in a question mark. Names like `is_thing` should be reserved for guards
- Elixir's builtin OTP primitives like `DynamicSupervisor` and `Registry`, require names in the child spec, such as `{DynamicSupervisor, name: MyApp.MyDynamicSup}`, then you can use `DynamicSupervisor.start_child(MyApp.MyDynamicSup, child_spec)`
- Use `Task.async_stream(collection, callback, options)` for concurrent enumeration with back-pressure. The majority of times you will want to pass `timeout: :infinity` as option

## Mix guidelines

- Read the docs and options before using tasks (by using `mix help task_name`)
- To debug test failures, run tests in a specific file with `mix test test/my_test.exs` or run all previously failed tests with `mix test --failed`
- `mix deps.clean --all` is **almost never needed**. **Avoid** using it unless you have good reason

## Test guidelines

- **Always use `start_supervised!/1`** to start processes in tests as it guarantees cleanup between tests
- **Avoid** `Process.sleep/1` and `Process.alive?/1` in tests
  - Instead of sleeping to wait for a process to finish, **always** use `Process.monitor/1` and assert on the DOWN message:

      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, :process, ^pid, :normal}

   - Instead of sleeping to synchronize before the next call, **always** use `_ = :sys.get_state/1` to ensure the process has handled prior messages
<!-- phoenix:elixir-end -->

<!-- phoenix:phoenix-start -->
## Phoenix guidelines

- Remember Phoenix router `scope` blocks include an optional alias which is prefixed for all routes within the scope. **Always** be mindful of this when creating routes within a scope to avoid duplicate module prefixes.

- You **never** need to create your own `alias` for route definitions! The `scope` provides the alias, ie:

      scope "/admin", AppWeb.Admin do
        pipe_through :browser

        live "/users", UserLive, :index
      end

  the UserLive route would point to the `AppWeb.Admin.UserLive` module

- `Phoenix.View` no longer is needed or included with Phoenix, don't use it
<!-- phoenix:phoenix-end -->

<!-- phoenix:ecto-start -->
## Ecto Guidelines

- **Always** preload Ecto associations in queries when they'll be accessed in templates, ie a message that needs to reference the `message.user.email`
- Remember `import Ecto.Query` and other supporting modules when you write `seeds.exs`
- `Ecto.Schema` fields always use the `:string` type, even for `:text`, columns, ie: `field :name, :string`
- `Ecto.Changeset.validate_number/2` **DOES NOT SUPPORT the `:allow_nil` option**. By default, Ecto validations only run if a change for the given field exists and the change value is not nil, so such as option is never needed
- You **must** use `Ecto.Changeset.get_field(changeset, :field)` to access changeset fields
- Fields which are set programmatically, such as `user_id`, must not be listed in `cast` calls or similar for security purposes. Instead they must be explicitly set when creating the struct
- **Always** invoke `mix ecto.gen.migration migration_name_using_underscores` when generating migration files, so the correct timestamp and conventions are applied
<!-- phoenix:ecto-end -->

<!-- phoenix:html-start -->
## Phoenix HTML guidelines

- Phoenix templates **always** use `~H` or .html.heex files (known as HEEx), **never** use `~E`
- **Always** use the imported `Phoenix.Component.form/1` and `Phoenix.Component.inputs_for/1` function to build forms. **Never** use `Phoenix.HTML.form_for` or `Phoenix.HTML.inputs_for` as they are outdated
- When building forms **always** use the already imported `Phoenix.Component.to_form/2` (`assign(socket, form: to_form(...))` and `<.form for={@form} id="msg-form">`), then access those forms in the template via `@form[:field]`
- **Always** add unique DOM IDs to key elements (like forms, buttons, etc) when writing templates, these IDs can later be used in tests (`<.form for={@form} id="product-form">`)
- For "app wide" template imports, you can import/alias into the `aya_web.ex`'s `html_helpers` block, so they will be available to all LiveViews, LiveComponent's, and all modules that do `use AyaWeb, :html`

- Elixir supports `if/else` but **does NOT support `if/else if` or `if/elsif`**. **Never use `else if` or `elseif` in Elixir**, **always** use `cond` or `case` for multiple conditionals.

  **Never do this (invalid)**:

      <%= if condition do %>
        ...
      <% else if other_condition %>
        ...
      <% end %>

  Instead **always** do this:

      <%= cond do %>
        <% condition -> %>
          ...
        <% condition2 -> %>
          ...
        <% true -> %>
          ...
      <% end %>

- HEEx require special tag annotation if you want to insert literal curly's like `{` or `}`. If you want to show a textual code snippet on the page in a `<pre>` or `<code>` block you *must* annotate the parent tag with `phx-no-curly-interpolation`:

      <code phx-no-curly-interpolation>
        let obj = {key: "val"}
      </code>

  Within `phx-no-curly-interpolation` annotated tags, you can use `{` and `}` without escaping them, and dynamic Elixir expressions can still be used with `<%= ... %>` syntax

- HEEx class attrs support lists, but you must **always** use list `[...]` syntax. You can use the class list syntax to conditionally add classes, **always do this for multiple class values**:

      <a class={[
        "px-2 text-white",
        @some_flag && "py-5",
        if(@other_condition, do: "border-red-500", else: "border-blue-100"),
        ...
      ]}>Text</a>

  and **always** wrap `if`'s inside `{...}` expressions with parens, like done above (`if(@other_condition, do: "...", else: "...")`)

  and **never** do this, since it's invalid (note the missing `[` and `]`):

      <a class={
        "px-2 text-white",
        @some_flag && "py-5"
      }> ...
      => Raises compile syntax error on invalid HEEx attr syntax

- **Never** use `<% Enum.each %>` or non-for comprehensions for generating template content, instead **always** use `<%= for item <- @collection do %>`
- HEEx HTML comments use `<%!-- comment --%>`. **Always** use the HEEx HTML comment syntax for template comments (`<%!-- comment --%>`)
- HEEx allows interpolation via `{...}` and `<%= ... %>`, but the `<%= %>` **only** works within tag bodies. **Always** use the `{...}` syntax for interpolation within tag attributes, and for interpolation of values within tag bodies. **Always** interpolate block constructs (if, cond, case, for) within tag bodies using `<%= ... %>`.

  **Always** do this:

      <div id={@id}>
        {@my_assign}
        <%= if @some_block_condition do %>
          {@another_assign}
        <% end %>
      </div>

  and **Never** do this – the program will terminate with a syntax error:

      <%!-- THIS IS INVALID NEVER EVER DO THIS --%>
      <div id="<%= @invalid_interpolation %>">
        {if @invalid_block_construct do}
        {end}
      </div>
<!-- phoenix:html-end -->

<!-- phoenix:liveview-start -->
## Phoenix LiveView guidelines

- **Never** use the deprecated `live_redirect` and `live_patch` functions, instead **always** use the `<.link navigate={href}>` and  `<.link patch={href}>` in templates, and `push_navigate` and `push_patch` functions LiveViews
- **Avoid LiveComponent's** unless you have a strong, specific need for them
- LiveViews should be named like `AppWeb.WeatherLive`, with a `Live` suffix. When you go to add LiveView routes to the router, the default `:browser` scope is **already aliased** with the `AppWeb` module, so you can just do `live "/weather", WeatherLive`

### LiveView streams

- **Always** use LiveView streams for collections for assigning regular lists to avoid memory ballooning and runtime termination with the following operations:
  - basic append of N items - `stream(socket, :messages, [new_msg])`
  - resetting stream with new items - `stream(socket, :messages, [new_msg], reset: true)` (e.g. for filtering items)
  - prepend to stream - `stream(socket, :messages, [new_msg], at: -1)`
  - deleting items - `stream_delete(socket, :messages, msg)`

- When using the `stream/3` interfaces in the LiveView, the LiveView template must 1) always set `phx-update="stream"` on the parent element, with a DOM id on the parent element like `id="messages"` and 2) consume the `@streams.stream_name` collection and use the id as the DOM id for each child. For a call like `stream(socket, :messages, [new_msg])` in the LiveView, the template would be:

      <div id="messages" phx-update="stream">
        <div :for={{id, msg} <- @streams.messages} id={id}>
          {msg.text}
        </div>
      </div>

- LiveView streams are *not* enumerable, so you cannot use `Enum.filter/2` or `Enum.reject/2` on them. Instead, if you want to filter, prune, or refresh a list of items on the UI, you **must refetch the data and re-stream the entire stream collection, passing reset: true**:

      def handle_event("filter", %{"filter" => filter}, socket) do
        # re-fetch the messages based on the filter
        messages = list_messages(filter)

        {:noreply,
         socket
         |> assign(:messages_empty?, messages == [])
         # reset the stream with the new messages
         |> stream(:messages, messages, reset: true)}
      end

- LiveView streams *do not support counting or empty states*. If you need to display a count, you must track it using a separate assign. For empty states, you can use Tailwind classes:

      <div id="tasks" phx-update="stream">
        <div class="hidden only:block">No tasks yet</div>
        <div :for={{id, task} <- @streams.tasks} id={id}>
          {task.name}
        </div>
      </div>

  The above only works if the empty state is the only HTML block alongside the stream for-comprehension.

- When updating an assign that should change content inside any streamed item(s), you MUST re-stream the items
  along with the updated assign:

      def handle_event("edit_message", %{"message_id" => message_id}, socket) do
        message = Chat.get_message!(message_id)
        edit_form = to_form(Chat.change_message(message, %{content: message.content}))

        # re-insert message so @editing_message_id toggle logic takes effect for that stream item
        {:noreply,
         socket
         |> stream_insert(:messages, message)
         |> assign(:editing_message_id, String.to_integer(message_id))
         |> assign(:edit_form, edit_form)}
      end

  And in the template:

      <div id="messages" phx-update="stream">
        <div :for={{id, message} <- @streams.messages} id={id} class="flex group">
          {message.username}
          <%= if @editing_message_id == message.id do %>
            <%!-- Edit mode --%>
            <.form for={@edit_form} id="edit-form-#{message.id}" phx-submit="save_edit">
              ...
            </.form>
          <% end %>
        </div>
      </div>

- **Never** use the deprecated `phx-update="append"` or `phx-update="prepend"` for collections

### LiveView JavaScript interop

- Remember anytime you use `phx-hook="MyHook"` and that JS hook manages its own DOM, you **must** also set the `phx-update="ignore"` attribute
- **Always** provide an unique DOM id alongside `phx-hook` otherwise a compiler error will be raised

LiveView hooks come in two flavors, 1) colocated js hooks for "inline" scripts defined inside HEEx,
and 2) external `phx-hook` annotations where JavaScript object literals are defined and passed to the `LiveSocket` constructor.

#### Inline colocated js hooks

**Never** write raw embedded `<script>` tags in heex as they are incompatible with LiveView.
Instead, **always use a colocated js hook script tag (`:type={Phoenix.LiveView.ColocatedHook}`)
when writing scripts inside the template**:

    <input type="text" name="user[phone_number]" id="user-phone-number" phx-hook=".PhoneNumber" />
    <script :type={Phoenix.LiveView.ColocatedHook} name=".PhoneNumber">
      export default {
        mounted() {
          this.el.addEventListener("input", e => {
            let match = this.el.value.replace(/\D/g, "").match(/^(\d{3})(\d{3})(\d{4})$/)
            if(match) {
              this.el.value = `${match[1]}-${match[2]}-${match[3]}`
            }
          })
        }
      }
    </script>

- colocated hooks are automatically integrated into the app.js bundle
- colocated hooks names **MUST ALWAYS** start with a `.` prefix, i.e. `.PhoneNumber`

#### External phx-hook

External JS hooks (`<div id="myhook" phx-hook="MyHook">`) must be placed in `assets/js/` and passed to the
LiveSocket constructor:

    const MyHook = {
      mounted() { ... }
    }
    let liveSocket = new LiveSocket("/live", Socket, {
      hooks: { MyHook }
    });

#### Pushing events between client and server

Use LiveView's `push_event/3` when you need to push events/data to the client for a phx-hook to handle.
**Always** return or rebind the socket on `push_event/3` when pushing events:

    # re-bind socket so we maintain event state to be pushed
    socket = push_event(socket, "my_event", %{...})

    # or return the modified socket directly:
    def handle_event("some_event", _, socket) do
      {:noreply, push_event(socket, "my_event", %{...})}
    end

Pushed events can then be picked up in a JS hook with `this.handleEvent`:

    mounted() {
      this.handleEvent("my_event", data => console.log("from server:", data));
    }

Clients can also push an event to the server and receive a reply with `this.pushEvent`:

    mounted() {
      this.el.addEventListener("click", e => {
        this.pushEvent("my_event", { one: 1 }, reply => console.log("got reply from server:", reply));
      })
    }

Where the server handled it via:

    def handle_event("my_event", %{"one" => 1}, socket) do
      {:reply, %{two: 2}, socket}
    end

### LiveView tests

- `Phoenix.LiveViewTest` module and `LazyHTML` (included) for making your assertions
- Form tests are driven by `Phoenix.LiveViewTest`'s `render_submit/2` and `render_change/2` functions
- Come up with a step-by-step test plan that splits major test cases into small, isolated files. You may start with simpler tests that verify content exists, gradually add interaction tests
- **Always reference the key element IDs you added in the LiveView templates in your tests** for `Phoenix.LiveViewTest` functions like `element/2`, `has_element/2`, selectors, etc
- **Never** tests again raw HTML, **always** use `element/2`, `has_element/2`, and similar: `assert has_element?(view, "#my-form")`
- Instead of relying on testing text content, which can change, favor testing for the presence of key elements
- Focus on testing outcomes rather than implementation details
- Be aware that `Phoenix.Component` functions like `<.form>` might produce different HTML than expected. Test against the output HTML structure, not your mental model of what you expect it to be
- When facing test failures with element selectors, add debug statements to print the actual HTML, but use `LazyHTML` selectors to limit the output, ie:

      html = render(view)
      document = LazyHTML.from_fragment(html)
      matches = LazyHTML.filter(document, "your-complex-selector")
      IO.inspect(matches, label: "Matches")

### Form handling

#### Creating a form from params

If you want to create a form based on `handle_event` params:

    def handle_event("submitted", params, socket) do
      {:noreply, assign(socket, form: to_form(params))}
    end

When you pass a map to `to_form/1`, it assumes said map contains the form params, which are expected to have string keys.

You can also specify a name to nest the params:

    def handle_event("submitted", %{"user" => user_params}, socket) do
      {:noreply, assign(socket, form: to_form(user_params, as: :user))}
    end

#### Creating a form from changesets

When using changesets, the underlying data, form params, and errors are retrieved from it. The `:as` option is automatically computed too. E.g. if you have a user schema:

    defmodule Aya.Accounts.User do
      use Ecto.Schema
      ...
    end

And then you create a changeset that you pass to `to_form`:

    %Aya.Accounts.User{}
    |> Ecto.Changeset.change()
    |> to_form()

Once the form is submitted, the params will be available under `%{"user" => user_params}`.

In the template, the form form assign can be passed to the `<.form>` function component:

    <.form for={@form} id="todo-form" phx-change="validate" phx-submit="save">
      <.input field={@form[:field]} type="text" />
    </.form>

Always give the form an explicit, unique DOM ID, like `id="todo-form"`.

#### Avoiding form errors

**Always** use a form assigned via `to_form/2` in the LiveView, and the `<.input>` component in the template. In the template **always access forms this**:

    <%!-- ALWAYS do this (valid) --%>
    <.form for={@form} id="my-form">
      <.input field={@form[:field]} type="text" />
    </.form>

And **never** do this:

    <%!-- NEVER do this (invalid) --%>
    <.form for={@changeset} id="my-form">
      <.input field={@changeset[:field]} type="text" />
    </.form>

- You are FORBIDDEN from accessing the changeset in the template as it will cause errors
- **Never** use `<.form let={f} ...>` in the template, instead **always use `<.form for={@form} ...>`**, then drive all form references from the form assign as in `@form[:field]`. The UI should **always** be driven by a `to_form/2` assigned in the LiveView module that is derived from a changeset
<!-- phoenix:liveview-end -->

<!-- usage-rules-end -->
