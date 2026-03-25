defmodule AyaWeb.ShowcaseLive do
  use AyaWeb, :live_view

  @sample_markdown """
  # Sourdough Starter

  A **wild yeast** culture used to leaven bread.

  ## Feeding Schedule

  - Morning: 1:1:1 ratio (starter:flour:water)
  - Evening: discard half, feed again

  ## Tips

  > Keep at room temperature (70-75°F) for an active starter.
  > Refrigerate if not baking daily.

  ### Signs of readiness

  1. Doubles in size within 4-6 hours
  2. Smells pleasantly sour
  3. Passes the `float test`

  ---

  For more details, see [The Bread Baker's Guide](https://example.com).
  """

  @impl true
  def mount(_params, _session, socket) do
    form =
      to_form(
        %{
          "name" => "",
          "bio" => "",
          "role" => "",
          "notifications" => "true",
          "dark_mode" => "false",
          "rich_colors" => "false",
          "ingredient_id" => "",
          "tags" => [],
          "ingredients" => [],
          "terms" => "false",
          "newsletter" => "true",
          "vegan" => "false",
          "gluten_free" => "false",
          "dairy_free" => "true",
          "difficulty" => "intermediate",
          "meal_type" => "dinner"
        },
        as: :demo
      )

    socket =
      socket
      |> assign(
        page_title: "Component Showcase",
        form: form,
        active_section: "toast",
        progress_value: 62,
        current_page: 3,
        search_options: sample_options(),
        grouped_options: sample_grouped_options(),
        tag_options: sample_tag_options(),
        rich_colors: false,
        sample_markdown: @sample_markdown,
        tab_mode: :url,
        dt_sort_by: nil,
        dt_sort_dir: "asc",
        dt_selected: []
      )
      |> assign(:uploaded_files, [])
      |> allow_upload(:files,
        accept: ~w(.jpg .jpeg .png .gif .webp .pdf .doc .docx .txt .csv),
        max_entries: 10,
        max_file_size: 10_000_000,
        auto_upload: true,
        progress: &handle_upload_progress/3
      )
      |> allow_upload(:image,
        accept: ~w(.jpg .jpeg .png .gif .webp),
        max_entries: 1,
        max_file_size: 10_000_000
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="lg:flex lg:gap-10">
      <.showcase_sidebar />

      <div class="flex-1 min-w-0">
        <.header>
          Component Showcase
          <:subtitle>The Aya design system component library</:subtitle>
        </.header>

        <.toast_container flash={@flash} rich_colors={@rich_colors} />
        <.toast_trigger />

        <%!-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
             GENERAL
             ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --%>
        <div class="mt-10 space-y-12">
          <.category_header id="cat-general" label="General" />

          <%!-- ━━━ Button ━━━ --%>
          <section id="button-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Button</h3>
            <.divider />
            <div class="space-y-5">
              <%!-- Variants --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Variants</p>
                <div class="flex flex-wrap items-center gap-3">
                  <.button variant="primary">Primary</.button>
                  <.button variant="secondary">Secondary</.button>
                  <.button variant="ghost">Ghost</.button>
                  <.button variant="soft">Soft</.button>
                </div>
              </div>
              <%!-- Sizes --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Sizes</p>
                <div class="flex flex-wrap items-center gap-3">
                  <.button variant="primary" size="sm">Small</.button>
                  <.button variant="primary" size="md">Medium</.button>
                  <.button variant="primary" size="lg">Large</.button>
                </div>
              </div>
              <%!-- With icons --%>
              <div>
                <p class="text-xs text-text-muted mb-2">With icons</p>
                <div class="flex flex-wrap items-center gap-3">
                  <.button variant="primary" size="sm">
                    <.icon name="hero-plus-mini" class="size-4" /> Add Recipe
                  </.button>
                  <.button variant="soft" size="sm">
                    <.icon name="hero-arrow-down-tray" class="size-4" /> Export
                  </.button>
                  <.button variant="ghost" size="sm">
                    <.icon name="hero-share" class="size-4" /> Share
                  </.button>
                  <.button variant="secondary" size="sm">
                    <.icon name="hero-check" class="size-4" /> Save
                  </.button>
                </div>
              </div>
              <%!-- Icon-only --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Icon-only</p>
                <div class="flex flex-wrap items-center gap-3">
                  <.button variant="soft" size="sm" class="!px-2" aria-label="Favorite">
                    <.icon name="hero-heart" class="size-4" />
                  </.button>
                  <.button variant="ghost" size="sm" class="!px-2" aria-label="Edit">
                    <.icon name="hero-pencil-square" class="size-4" />
                  </.button>
                  <.button variant="ghost" size="sm" class="!px-2" aria-label="Delete">
                    <.icon name="hero-trash" class="size-4 text-error" />
                  </.button>
                  <.button variant="primary" size="sm" class="!px-2" aria-label="Add">
                    <.icon name="hero-plus" class="size-4" />
                  </.button>
                  <button
                    class="size-8 rounded-full bg-surface-alt flex items-center justify-center text-text-muted hover:text-text hover:bg-surface-hover transition-colors cursor-pointer"
                    aria-label="More options"
                  >
                    <.icon name="hero-ellipsis-horizontal" class="size-4" />
                  </button>
                  <button
                    class="size-10 rounded-full bg-primary flex items-center justify-center text-primary-text hover:bg-primary-hover transition-colors cursor-pointer active:scale-95"
                    aria-label="Add item"
                  >
                    <.icon name="hero-plus" class="size-5" />
                  </button>
                </div>
              </div>
              <%!-- Pill / rounded --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Pill / rounded</p>
                <div class="flex flex-wrap items-center gap-3">
                  <button class="rounded-full bg-primary px-5 py-2 text-sm font-semibold text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]">
                    Subscribe
                  </button>
                  <button class="rounded-full border border-border px-5 py-2 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors">
                    Cancel
                  </button>
                  <button class="rounded-full bg-text text-surface px-5 py-2 text-sm font-semibold cursor-pointer hover:opacity-90 transition-opacity active:scale-[0.97]">
                    Got it
                  </button>
                  <button class="rounded-full bg-surface-alt px-5 py-2 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors">
                    Later
                  </button>
                </div>
              </div>
              <%!-- Destructive / warning --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Destructive & states</p>
                <div class="flex flex-wrap items-center gap-3">
                  <button class="rounded-md bg-error px-4 py-2 text-sm font-medium text-white cursor-pointer hover:opacity-90 transition-opacity active:scale-[0.96]">
                    Delete
                  </button>
                  <button class="rounded-md border border-error/30 bg-error-soft px-4 py-2 text-sm font-medium text-error-text cursor-pointer hover:bg-error/10 transition-colors">
                    Remove
                  </button>
                  <.button variant="primary" disabled>Disabled</.button>
                  <.button variant="primary" size="sm">
                    <.spinner size="xs" color="current" /> Loading...
                  </.button>
                </div>
              </div>
              <%!-- Full-width CTA --%>
              <div class="max-w-xs">
                <p class="text-xs text-text-muted mb-2">Full-width CTA</p>
                <button class="w-full rounded-xl bg-primary px-4 py-3 text-sm font-semibold text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.97]">
                  Continue
                </button>
                <button class="w-full mt-2 rounded-xl bg-surface-alt px-4 py-3 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors">
                  Skip for now
                </button>
              </div>
            </div>
          </section>

          <%!-- ━━━ Badge ━━━ --%>
          <section id="badge-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Badge</h3>
            <.divider />
            <div class="flex flex-wrap items-center gap-2">
              <.badge>Default</.badge>
              <.badge variant="primary">Primary</.badge>
              <.badge variant="secondary">Secondary</.badge>
              <.badge variant="accent">Accent</.badge>
              <.badge variant="info">Info</.badge>
              <.badge variant="success">Success</.badge>
              <.badge variant="warning">Warning</.badge>
              <.badge variant="error">Error</.badge>
            </div>
            <div class="flex flex-wrap items-center gap-2">
              <.badge size="sm" variant="primary">Small</.badge>
              <.badge size="md" variant="primary">Medium</.badge>
              <.badge size="lg" variant="primary">Large</.badge>
            </div>
          </section>

          <%!-- ━━━ Avatar ━━━ --%>
          <section id="avatar-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Avatar</h3>
            <.divider />
            <div class="flex items-center gap-3">
              <.avatar name="Alice Baker" size="xs" />
              <.avatar name="Bob Chen" size="sm" />
              <.avatar name="Clara Davis" size="md" />
              <.avatar name="Derek Evans" size="lg" />
              <.avatar name="Ella Fox" size="xl" />
            </div>
            <div class="flex items-center gap-3">
              <.avatar src="https://i.pravatar.cc/80?img=1" alt="User 1" size="md" />
              <.avatar src="https://i.pravatar.cc/80?img=2" alt="User 2" size="md" />
              <.avatar src="https://i.pravatar.cc/80?img=3" alt="User 3" size="md" />
            </div>
          </section>

          <%!-- ━━━ Link ━━━ --%>
          <section id="link-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Link</h3>
            <.divider />
            <div class="space-y-5">
              <%!-- Variants --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Variants</p>
                <div class="flex flex-wrap items-center gap-6">
                  <.link href="#" variant="default">Default</.link>
                  <.link href="#" variant="muted">Muted</.link>
                  <.link href="#" variant="subtle">Subtle</.link>
                  <.link href="#" variant="underline">Underline</.link>
                  <.link href="#" variant="underline-hover">Underline hover</.link>
                  <.link href="#" variant="plain">Plain</.link>
                </div>
              </div>
              <%!-- In prose context --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Inline with text</p>
                <p class="text-sm text-text-secondary max-w-md">
                  This recipe was inspired by
                  <.link href="#" variant="underline">traditional techniques</.link>
                  and modern <.link href="#" variant="underline">molecular gastronomy</.link>
                  approaches documented in the <.link href="#" variant="underline">archives</.link>.
                </p>
              </div>
              <%!-- External link --%>
              <div>
                <p class="text-xs text-text-muted mb-2">External (opens in new tab)</p>
                <div class="flex flex-wrap items-center gap-6">
                  <.link href="https://example.com" external variant="default">
                    example.com
                    <.icon name="hero-arrow-top-right-on-square-mini" class="size-3.5 inline ml-0.5" />
                  </.link>
                  <.link href="https://example.com" external variant="muted">
                    External muted
                    <.icon name="hero-arrow-top-right-on-square-mini" class="size-3.5 inline ml-0.5" />
                  </.link>
                </div>
              </div>
              <%!-- Speculation Rules: prefetch / preload / prerender --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Speculation Rules</p>
                <div class="flex flex-wrap items-center gap-6">
                  <.link navigate={~p"/"} prefetch variant="default" id="demo-prefetch">
                    Prefetch on hover
                  </.link>
                  <.link navigate={~p"/"} preload variant="default" id="demo-preload">
                    Preload immediately
                  </.link>
                  <.link navigate={~p"/"} prerender variant="default" id="demo-prerender">
                    Prerender (Chrome)
                  </.link>
                </div>
                <p class="text-xs text-text-muted mt-1.5">
                  Open DevTools → Network → filter Doc to see requests.
                  Uses Speculation Rules API with &lt;link rel="prefetch"&gt; fallback.
                </p>
              </div>
              <%!-- Active & disabled --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Active & disabled</p>
                <div class="flex flex-wrap items-center gap-6">
                  <.link href="#" variant="default" active>Active link</.link>
                  <.link
                    href="#"
                    variant="default"
                    active
                    active_class="text-text font-semibold border-b border-link"
                  >
                    Custom active
                  </.link>
                  <.link href="#" variant="default" disabled>Disabled</.link>
                  <.link href="#" variant="muted" disabled>Disabled muted</.link>
                </div>
              </div>
              <%!-- Loading --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Loading (click to see spinner)</p>
                <div class="flex flex-wrap items-center gap-6">
                  <.link navigate={~p"/"} loading variant="default" id="demo-loading">
                    Save & continue
                  </.link>
                </div>
              </div>
              <%!-- With icons --%>
              <div>
                <p class="text-xs text-text-muted mb-2">With icons</p>
                <div class="flex flex-wrap items-center gap-6">
                  <.link href="#" variant="default">
                    <.icon name="hero-arrow-left-mini" class="size-4 inline" /> Back to recipes
                  </.link>
                  <.link href="#" variant="subtle">
                    View all <.icon name="hero-arrow-right-mini" class="size-4 inline" />
                  </.link>
                  <.link href="#" variant="muted">
                    <.icon name="hero-document-text-mini" class="size-4 inline" /> Documentation
                  </.link>
                </div>
              </div>
            </div>
          </section>

          <%!-- ━━━ Kbd ━━━ --%>
          <section id="kbd-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Kbd</h3>
            <.divider />
            <div class="flex items-center gap-2 text-sm text-text-secondary">
              Press
              <.kbd>⌘</.kbd>
              +
              <.kbd>K</.kbd>
              to open command palette
            </div>
            <div class="flex items-center gap-2 text-sm text-text-secondary">
              <.kbd>Ctrl</.kbd>
              +
              <.kbd>Shift</.kbd>
              +
              <.kbd>K</.kbd>
              to clear browser state
            </div>
          </section>

          <%!-- ━━━ Divider ━━━ --%>
          <section id="divider-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Divider</h3>
            <.divider />
            <div class="space-y-4 max-w-md">
              <.divider />
              <.divider label="or" />
              <div class="flex items-center h-8 gap-4">
                <span class="text-sm text-text-secondary">Left</span>
                <.divider orientation="vertical" />
                <span class="text-sm text-text-secondary">Right</span>
              </div>
            </div>
          </section>

          <%!-- ━━━ Copy Button ━━━ --%>
          <section id="copy-button-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Copy Button</h3>
            <.divider />
            <div class="flex items-center gap-3 p-3 rounded-lg bg-surface-alt">
              <code class="text-sm text-text font-mono flex-1">mix phx.gen.secret</code>
              <.copy_button id="copy-demo" content="mix phx.gen.secret" />
            </div>
          </section>

          <%!-- ━━━ Spinner ━━━ --%>
          <section id="spinner-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Spinner</h3>
            <.divider />
            <div class="flex items-center gap-4">
              <.spinner size="xs" />
              <.spinner size="sm" />
              <.spinner size="md" />
              <.spinner size="lg" />
              <.spinner size="xl" color="secondary" />
            </div>
            <.button variant="primary" size="sm">
              <.spinner size="xs" color="current" /> Loading...
            </.button>
          </section>

          <%!-- ━━━ Loading ━━━ --%>
          <section id="loading-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Loading</h3>
            <.divider />
            <div class="space-y-6">
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 max-w-xl">
                <div class="space-y-4">
                  <p class="text-xs text-text-muted">Shimmer — full sweep</p>
                  <div class="flex flex-col gap-3">
                    <.loading type="shimmer" text="Thinking..." size="sm" />
                    <.loading type="shimmer" text="Generating your recipe..." />
                    <.loading type="shimmer" text="Analyzing ingredients" size="lg" />
                  </div>
                </div>
                <div class="space-y-4">
                  <p class="text-xs text-text-muted">Shimmer — light beam left to right</p>
                  <div class="flex flex-col gap-3">
                    <.loading type="shimmer-slide" text="Searching recipes..." size="sm" />
                    <.loading type="shimmer-slide" text="Processing your request..." />
                    <.loading type="shimmer-slide" text="Almost there..." size="lg" />
                  </div>
                </div>
              </div>
              <.divider label="Speed control" />
              <div class="flex flex-col gap-3 max-w-sm">
                <.loading type="shimmer" text="Fast (0.6s)" speed="0.6s" />
                <.loading type="shimmer" text="Normal (1.5s — default)" />
                <.loading type="shimmer" text="Slow (3s)" speed="3s" />
                <.loading type="shimmer-slide" text="Fast slide (0.8s)" speed="0.8s" />
                <.loading type="shimmer-slide" text="Slow slide (4s)" speed="4s" />
              </div>
              <div>
                <p class="text-xs text-text-muted mb-3">Dots</p>
                <div class="flex items-center gap-6">
                  <.loading type="dots" size="sm" />
                  <.loading type="dots" />
                  <.loading type="dots" size="lg" />
                </div>
              </div>
              <div>
                <p class="text-xs text-text-muted mb-3">Pulse text</p>
                <div class="space-y-2">
                  <.loading type="pulse" text="Loading recipes..." />
                  <.loading type="pulse" text="Please wait..." size="sm" />
                </div>
              </div>
              <div>
                <p class="text-xs text-text-muted mb-3">Indeterminate bar</p>
                <div class="space-y-3 max-w-sm">
                  <.loading type="bar" size="sm" />
                  <.loading type="bar" />
                  <.loading type="bar" size="lg" />
                </div>
              </div>
              <div>
                <p class="text-xs text-text-muted mb-3">Typing indicator</p>
                <.loading type="typing" />
              </div>
            </div>
          </section>
        </div>

        <%!-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
             DATA DISPLAY
             ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --%>
        <div class="mt-16 space-y-12">
          <.category_header id="cat-data" label="Data Display" />

          <%!-- ━━━ Card ━━━ --%>
          <section id="card-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Card</h3>
            <.divider />
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              <.card>
                <:title>Sourdough Bread</:title>
                <:meta>Published 2 hours ago</:meta>
                <:body>
                  A classic artisan bread with a crispy crust and chewy interior. Perfect for sandwiches or as a side.
                </:body>
                <:footer>
                  <div class="flex items-center gap-2">
                    <.badge variant="secondary" size="sm">Baking</.badge>
                    <.badge variant="accent" size="sm">Fermentation</.badge>
                  </div>
                </:footer>
              </.card>
              <.card>
                <:title>Miso Ramen</:title>
                <:meta>Published yesterday</:meta>
                <:body>
                  Rich, umami-packed broth with handmade noodles. A bowl of comfort on cold days.
                </:body>
              </.card>
              <.card>
                <:title>Kimchi Fried Rice</:title>
                <:meta>3 days ago</:meta>
                <:body>
                  Quick weeknight dinner using leftover rice and aged kimchi. Ready in 15 minutes.
                </:body>
              </.card>
            </div>
          </section>

          <%!-- ━━━ Expandable Cards ━━━ --%>
          <section id="expandable-cards-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Expandable Cards</h3>
            <.divider />
            <.expandable_cards id="demo-ec">
              <:header>
                <h2 class="text-2xl font-bold tracking-tight">Today</h2>
                <div class="size-10 rounded-full bg-surface-alt border border-border" />
              </:header>
              <:card
                id="a"
                image="https://picsum.photos/seed/sourdough/800/600"
                category="Baking"
                title="5 Essential Sourdough Techniques"
              >
                <p>
                  Master the art of sourdough with these five fundamental techniques that every baker should know. From building your starter to scoring the perfect loaf.
                </p>
                <p>
                  Learn autolyse timing, bulk fermentation cues, shaping tension, and steam injection methods that transform your home oven into a bread bakery.
                </p>
              </:card>
              <:card
                id="b"
                image="https://picsum.photos/seed/ferment/800/600"
                category="Fermentation"
                title="The Art of Fermented Foods"
                theme="dark"
              >
                <p>
                  Explore the science behind fermentation — from kimchi and sauerkraut to miso and kombucha. Understand how beneficial bacteria transform simple ingredients.
                </p>
                <p>
                  Discover temperature control, salt ratios, and timing techniques that ensure consistent results every batch.
                </p>
              </:card>
              <:card
                id="c"
                image="https://picsum.photos/seed/molecular/800/600"
                category="Molecular"
                title="Kitchen Chemistry Experiments"
                theme="dark"
              >
                <p>
                  Bring the lab to your kitchen. Learn spherification, gelification, and emulsification techniques used by the world's top chefs.
                </p>
                <p>
                  Start with simple experiments using agar-agar and sodium alginate, then progress to advanced techniques like cryo-concentration and enzymatic reactions.
                </p>
              </:card>
              <:card
                id="d"
                image="https://picsum.photos/seed/quickmeal/800/600"
                category="Quick Meals"
                title="15-Minute Dinners That Impress"
              >
                <p>
                  Weeknight cooking doesn't mean boring. These recipes prove you can create restaurant-quality meals in under 15 minutes with pantry staples.
                </p>
                <p>
                  From garlic butter shrimp pasta to crispy tofu stir-fry — speed and flavor aren't mutually exclusive. Each recipe includes prep shortcuts and make-ahead tips.
                </p>
              </:card>
            </.expandable_cards>
          </section>

          <%!-- ━━━ Stat Card ━━━ --%>
          <section id="stat-card-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Stat Card</h3>
            <.divider />
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <.stat_card
                label="Total Recipes"
                value="1,234"
                trend="+12%"
                trend_direction={:up}
                icon="hero-book-open"
              />
              <.stat_card
                label="Active Users"
                value="89"
                trend="+3%"
                trend_direction={:up}
                icon="hero-users"
              />
              <.stat_card
                label="Ingredients"
                value="2,456"
                trend_direction={:neutral}
                icon="hero-beaker"
              />
              <.stat_card
                label="Reports"
                value="18"
                trend="-5%"
                trend_direction={:down}
                icon="hero-document-chart-bar"
              />
            </div>
          </section>

          <%!-- ━━━ Table ━━━ --%>
          <section id="table-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Table</h3>
            <.divider />
            <.table id="demo-table" rows={sample_table_rows()}>
              <:col :let={row} label="Name">{row.name}</:col>
              <:col :let={row} label="Category">{row.category}</:col>
              <:col :let={row} label="Calories">{row.calories}</:col>
            </.table>
          </section>

          <%!-- ━━━ Data Table ━━━ --%>
          <section id="data-table-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Data Table</h3>
            <.divider />
            <div class="space-y-8">
              <%!-- 1. Basic with sorting --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Sortable columns</p>
                <.data_table
                  id="dt-sortable"
                  rows={sample_table_rows()}
                  sortable
                  sort_by={@dt_sort_by}
                  sort_dir={@dt_sort_dir}
                >
                  <:col :let={row} label="Name" field="name">{row.name}</:col>
                  <:col :let={row} label="Category" field="category">{row.category}</:col>
                  <:col :let={row} label="Calories" field="calories" align="right">
                    {row.calories}
                  </:col>
                </.data_table>
              </div>

              <%!-- 2. With row selection --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Row selection</p>
                <.data_table
                  id="dt-selectable"
                  rows={sample_table_rows()}
                  selectable
                  selected={@dt_selected}
                >
                  <:col :let={row} label="Name">{row.name}</:col>
                  <:col :let={row} label="Category">{row.category}</:col>
                  <:col :let={row} label="Calories" align="right">{row.calories}</:col>
                  <:action :let={_row}>
                    <span class="text-xs text-accent cursor-pointer hover:underline">Edit</span>
                  </:action>
                </.data_table>
                <p :if={@dt_selected != []} class="text-xs text-text-muted mt-2">
                  Selected: {Enum.join(@dt_selected, ", ")}
                </p>
              </div>

              <%!-- 3. Compact + striped --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Compact + striped</p>
                <.data_table id="dt-compact" rows={sample_table_rows()} compact striped>
                  <:col :let={row} label="Name">{row.name}</:col>
                  <:col :let={row} label="Category">{row.category}</:col>
                  <:col :let={row} label="Calories" align="right">{row.calories}</:col>
                </.data_table>
              </div>

              <%!-- 4. Empty state --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Empty state</p>
                <.data_table id="dt-empty" rows={[]}>
                  <:col label="Name"></:col>
                  <:col label="Category"></:col>
                  <:col label="Calories"></:col>
                </.data_table>
              </div>
            </div>
          </section>

          <%!-- ━━━ List ━━━ --%>
          <section id="list-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">List</h3>
            <.divider />
            <div class="max-w-md">
              <.list>
                <:item title="Name">Sourdough Bread</:item>
                <:item title="Category">Baking</:item>
                <:item title="Prep Time">30 minutes</:item>
                <:item title="Difficulty">Intermediate</:item>
              </.list>
            </div>
          </section>

          <%!-- ━━━ Progress ━━━ --%>
          <section id="progress-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Progress</h3>
            <.divider />
            <div class="space-y-4 max-w-md">
              <.progress value={@progress_value} label="Upload Progress" show_value />
              <.progress value={85} color="success" size="lg" />
              <.progress value={30} color="warning" size="sm" />
              <.progress value={10} color="error" />
              <.button phx-click="increment_progress" variant="soft" size="sm">
                Increment Progress
              </.button>
            </div>
          </section>

          <%!-- ━━━ Skeleton ━━━ --%>
          <section id="skeleton-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Skeleton</h3>
            <.divider />
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-6">
              <%!-- Row 1: Basic types --%>
              <div class="rounded-lg border border-border p-4">
                <p class="text-xs text-text-muted mb-3">Text</p>
                <.skeleton type="text" lines={4} />
              </div>
              <div class="rounded-lg border border-border p-4">
                <p class="text-xs text-text-muted mb-3">Avatar + Text</p>
                <div class="flex items-center gap-3">
                  <.skeleton type="avatar" />
                  <.skeleton type="text" lines={2} />
                </div>
              </div>
              <div class="rounded-lg border border-border p-4">
                <p class="text-xs text-text-muted mb-3">Image</p>
                <.skeleton type="image" />
              </div>
              <%!-- Row 2: Composite types --%>
              <div class="rounded-lg border border-border p-4">
                <p class="text-xs text-text-muted mb-3">Profile</p>
                <.skeleton type="profile" />
              </div>
              <div class="rounded-lg border border-border p-4">
                <p class="text-xs text-text-muted mb-3">Comments</p>
                <.skeleton type="comment" rows={3} />
              </div>
              <div>
                <p class="text-xs text-text-muted mb-3">Card</p>
                <.skeleton type="card" />
              </div>
              <%!-- Row 3: Layout types --%>
              <div>
                <p class="text-xs text-text-muted mb-3">Feed Post</p>
                <.skeleton type="feed" />
              </div>
              <div class="rounded-lg border border-border p-4">
                <p class="text-xs text-text-muted mb-3">Form</p>
                <.skeleton type="form" rows={3} />
              </div>
              <div class="rounded-lg border border-border p-4">
                <p class="text-xs text-text-muted mb-3">List</p>
                <.skeleton type="list" rows={4} />
              </div>
            </div>
            <%!-- Full-width types --%>
            <div class="space-y-4 mt-4">
              <p class="text-xs text-text-muted">Stats</p>
              <.skeleton type="stats" />
              <p class="text-xs text-text-muted mt-4">Table</p>
              <.skeleton type="table" rows={4} cols={5} />
            </div>
          </section>

          <%!-- ━━━ Empty State ━━━ --%>
          <%!-- ━━━ Engagement Stats ━━━ --%>
          <section id="engagement-stats-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Engagement Stats</h3>
            <.divider />
            <p class="text-sm text-text-secondary">
              Social-style stats with animated counters. Click like/bookmark/repost to toggle. Numbers auto-increment every 5s.
            </p>
            <div class="rounded-lg border border-border p-6 max-w-md">
              <.engagement_stats
                id="demo-engagement"
                views={1200}
                reposts={15}
                likes={97}
                bookmarks={10}
              />
            </div>
          </section>

          <%!-- ━━━ Empty State ━━━ --%>
          <%!-- ━━━ Image ━━━ --%>
          <section id="image-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Image</h3>
            <.divider />
            <p class="text-sm text-text-secondary">
              Performant image component with lazy loading, responsive srcset, placeholders, and blur-to-clear reveal.
            </p>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-6 max-w-3xl">
              <div>
                <p class="text-xs text-text-muted mb-2">Blur reveal (default)</p>
                <.image
                  src="https://picsum.photos/seed/img1/400/300"
                  alt="Food photo"
                  width={400}
                  height={300}
                  rounded="rounded-lg"
                  aspect="4/3"
                />
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">Color placeholder</p>
                <.image
                  src="https://picsum.photos/seed/img2/400/300"
                  alt="Bread"
                  width={400}
                  height={300}
                  placeholder="color"
                  color="#d4a574"
                  rounded="rounded-lg"
                  aspect="4/3"
                />
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">Shimmer placeholder</p>
                <.image
                  src="https://picsum.photos/seed/img3/400/300"
                  alt="Ramen"
                  width={400}
                  height={300}
                  placeholder="shimmer"
                  rounded="rounded-lg"
                  aspect="4/3"
                />
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">Gradient placeholder</p>
                <.image
                  src="https://picsum.photos/seed/img4/400/300"
                  alt="Kimchi"
                  width={400}
                  height={300}
                  placeholder="gradient"
                  gradient="linear-gradient(135deg, #d4a574 0%, #8b6f47 100%)"
                  rounded="rounded-lg"
                  aspect="4/3"
                />
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">Priority (eager, no blur)</p>
                <.image
                  src="https://picsum.photos/seed/img5/400/300"
                  alt="Hero"
                  width={400}
                  height={300}
                  priority
                  reveal={false}
                  rounded="rounded-lg"
                  aspect="4/3"
                />
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">1:1 aspect ratio</p>
                <.image
                  src="https://picsum.photos/seed/img6/400/400"
                  alt="Square"
                  width={400}
                  height={400}
                  placeholder="shimmer"
                  rounded="rounded-full"
                  aspect="1/1"
                  class="max-w-[200px]"
                />
              </div>
            </div>
          </section>

          <%!-- ━━━ Empty State ━━━ --%>
          <section id="empty-state-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Empty State</h3>
            <.divider />
            <div class="rounded-lg border border-border">
              <.empty_state icon="hero-beaker" title="No experiments yet">
                <:description>
                  Get started by creating your first food science experiment.
                </:description>
                <:action>
                  <.button variant="primary" size="sm">Create Experiment</.button>
                </:action>
              </.empty_state>
            </div>
          </section>

          <%!-- ━━━ Description List ━━━ --%>
          <section id="description-list-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Description List</h3>
            <.divider />
            <div class="space-y-8">
              <%!-- Stacked --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Stacked (default)</p>
                <div class="max-w-md">
                  <.description_list>
                    <:item label="Name">Sourdough Bread</:item>
                    <:item label="Category">Baking</:item>
                    <:item label="Prep time">30 minutes</:item>
                    <:item label="Cook time">45 minutes</:item>
                    <:item label="Difficulty">
                      <.badge variant="accent" size="sm">Intermediate</.badge>
                    </:item>
                  </.description_list>
                </div>
              </div>
              <%!-- Inline --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Inline</p>
                <div class="max-w-md">
                  <.description_list variant="inline">
                    <:item label="Calories">285 kcal</:item>
                    <:item label="Protein">9g</:item>
                    <:item label="Carbs">56g</:item>
                    <:item label="Fat">2g</:item>
                  </.description_list>
                </div>
              </div>
              <%!-- Grid --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Grid (2 columns)</p>
                <.description_list variant="grid" columns={2}>
                  <:item label="Cuisine">French</:item>
                  <:item label="Course">Main</:item>
                  <:item label="Servings">4 portions</:item>
                  <:item label="Yield">1 loaf</:item>
                </.description_list>
              </div>
              <%!-- Striped --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Striped</p>
                <div class="max-w-md">
                  <.description_list variant="striped">
                    <:item label="pH Level">4.2</:item>
                    <:item label="Hydration">75%</:item>
                    <:item label="Bulk Ferment">4 hours</:item>
                    <:item label="Final Proof">12 hours</:item>
                  </.description_list>
                </div>
              </div>
            </div>
          </section>

          <%!-- ━━━ Timeline ━━━ --%>
          <section id="timeline-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Timeline</h3>
            <.divider />
            <div class="space-y-8">
              <%!-- Default --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Default</p>
                <div class="max-w-lg">
                  <.timeline>
                    <:item
                      title="Recipe published"
                      timestamp="2 hours ago"
                      icon_color="success"
                      status="complete"
                    >
                    </:item>
                    <:item
                      title="Review approved"
                      description="Passed quality review by the editorial team."
                      timestamp="5 hours ago"
                      icon_color="primary"
                      status="complete"
                    >
                    </:item>
                    <:item title="Submitted for review" timestamp="Yesterday" status="complete">
                    </:item>
                    <:item
                      title="Draft created"
                      description="Initial recipe draft with ingredients and steps."
                      timestamp="3 days ago"
                      status="complete"
                    >
                    </:item>
                  </.timeline>
                </div>
              </div>
              <%!-- With icons --%>
              <div>
                <p class="text-xs text-text-muted mb-2">With icons</p>
                <div class="max-w-lg">
                  <.timeline>
                    <:item
                      title="Delivered"
                      icon="hero-check"
                      icon_color="success"
                      timestamp="Today"
                      status="complete"
                    />
                    <:item
                      title="Out for delivery"
                      icon="hero-truck"
                      icon_color="primary"
                      timestamp="Today"
                      status="complete"
                    />
                    <:item
                      title="Processing"
                      icon="hero-cog-6-tooth"
                      icon_color="info"
                      timestamp="Yesterday"
                      status="current"
                    />
                    <:item
                      title="Order placed"
                      icon="hero-shopping-cart"
                      timestamp="2 days ago"
                      status="upcoming"
                    />
                  </.timeline>
                </div>
              </div>
              <%!-- Horizontal --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Horizontal</p>
                <.timeline direction="horizontal">
                  <:item
                    title="Order placed"
                    timestamp="Mar 20"
                    icon="hero-shopping-cart"
                    icon_color="success"
                    status="complete"
                  />
                  <:item
                    title="Processing"
                    timestamp="Mar 21"
                    icon="hero-cog-6-tooth"
                    icon_color="success"
                    status="complete"
                  />
                  <:item
                    title="Shipped"
                    timestamp="Mar 22"
                    icon="hero-truck"
                    icon_color="primary"
                    status="current"
                  />
                  <:item
                    title="Out for delivery"
                    timestamp="Mar 24"
                    icon="hero-map-pin"
                    status="upcoming"
                  />
                  <:item
                    title="Delivered"
                    timestamp="Mar 25"
                    icon="hero-check-circle"
                    status="upcoming"
                  />
                </.timeline>
              </div>
              <%!-- Horizontal compact --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Horizontal compact</p>
                <.timeline direction="horizontal" variant="compact">
                  <:item title="Mix" icon_color="success" status="complete" />
                  <:item title="Bulk ferment" icon_color="success" status="complete" />
                  <:item title="Shape" icon_color="primary" status="current" />
                  <:item title="Proof" status="upcoming" />
                  <:item title="Bake" status="upcoming" />
                  <:item title="Cool" status="upcoming" />
                </.timeline>
              </div>
              <%!-- Compact --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Compact</p>
                <div class="max-w-lg">
                  <.timeline variant="compact">
                    <:item title="Salt added" timestamp="10:42" icon_color="primary" />
                    <:item title="Temperature check" description="72°C internal" timestamp="10:30" />
                    <:item title="Oven preheated" timestamp="10:15" icon_color="warning" />
                    <:item title="Dough shaped" timestamp="10:00" />
                  </.timeline>
                </div>
              </div>
            </div>
          </section>
        </div>

        <%!-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
             FORMS & INPUT
             ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --%>
        <div class="mt-16 space-y-12">
          <.category_header id="cat-forms" label="Forms & Input" />

          <%!-- ━━━ Input ━━━ --%>
          <section id="input-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Input</h3>
            <.divider />
            <.form
              for={@form}
              phx-change="validate"
              phx-submit="submit"
              id="demo-form"
              class="space-y-4 max-w-md"
            >
              <.input field={@form[:name]} type="text" label="Name" placeholder="Enter your name" />
              <.input
                field={@form[:bio]}
                type="textarea"
                label="Bio"
                placeholder="Tell us about yourself"
              />
              <.input
                field={@form[:role]}
                type="select"
                label="Role"
                prompt="Select a role"
                options={["Chef", "Food Scientist", "Writer", "Student"]}
              />
              <.button type="submit" variant="primary">Submit</.button>
            </.form>
          </section>

          <%!-- ━━━ Toggle ━━━ --%>
          <section id="toggle-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Toggle</h3>
            <.divider />
            <div class="space-y-4 max-w-sm">
              <.toggle
                field={@form[:notifications]}
                label="Push notifications"
                description="Receive alerts when recipes are trending"
              />
              <.toggle field={@form[:dark_mode]} label="Dark mode" size="sm" />
              <.toggle label="Disabled toggle" disabled size="lg" />
            </div>
          </section>

          <%!-- ━━━ Checkbox ━━━ --%>
          <section id="checkbox-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Checkbox</h3>
            <.divider />
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-8 max-w-xl">
              <div class="space-y-6">
                <div class="space-y-3">
                  <p class="text-sm text-text-secondary mb-1">Individual</p>
                  <.checkbox field={@form[:terms]} label="Accept terms and conditions" />
                  <.checkbox
                    field={@form[:newsletter]}
                    label="Email newsletter"
                    description="Receive weekly updates about new recipes"
                  />
                  <.checkbox label="Disabled unchecked" disabled />
                  <.checkbox label="Disabled checked" disabled checked />
                </div>
                <.divider label="Group" />
                <.checkbox_group label="Dietary Preferences">
                  <:option field={@form[:vegan]} label="Vegan" description="No animal products" />
                  <:option
                    field={@form[:gluten_free]}
                    label="Gluten-free"
                    description="No wheat, rye, or barley"
                  />
                  <:option field={@form[:dairy_free]} label="Dairy-free" />
                </.checkbox_group>
              </div>
              <div>
                <p class="text-sm text-text-secondary mb-3">Card group</p>
                <.checkbox_group label="Features" variant="card">
                  <:option
                    field={@form[:vegan]}
                    label="Organic Ingredients"
                    description="Certified organic sourcing"
                  />
                  <:option
                    field={@form[:gluten_free]}
                    label="Allergen-free"
                    description="No common allergens"
                  />
                  <:option
                    field={@form[:dairy_free]}
                    label="Farm to Table"
                    description="Locally sourced produce"
                  />
                </.checkbox_group>
              </div>
            </div>
          </section>

          <%!-- ━━━ Radio ━━━ --%>
          <section id="radio-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Radio</h3>
            <.divider />
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-8 max-w-xl">
              <div class="space-y-6">
                <.radio_group field={@form[:difficulty]} label="Difficulty">
                  <:option value="beginner" label="Beginner" description="Simple techniques" />
                  <:option value="intermediate" label="Intermediate" />
                  <:option value="advanced" label="Advanced" description="Professional-level" />
                  <:option value="expert" label="Expert" disabled />
                </.radio_group>
                <.radio_group field={@form[:meal_type]} label="Meal Type">
                  <:option value="breakfast" label="Breakfast" />
                  <:option value="lunch" label="Lunch" />
                  <:option value="dinner" label="Dinner" />
                  <:option value="snack" label="Snack" />
                </.radio_group>
              </div>
              <div>
                <p class="text-sm text-text-secondary mb-3">Card group</p>
                <.radio_group field={@form[:difficulty]} label="Skill Level" variant="card">
                  <:option
                    value="beginner"
                    label="Beginner"
                    description="Simple recipes, basic techniques"
                  />
                  <:option
                    value="intermediate"
                    label="Intermediate"
                    description="Multi-step with some skill required"
                  />
                  <:option
                    value="advanced"
                    label="Advanced"
                    description="Complex techniques, precise timing"
                  />
                </.radio_group>
              </div>
            </div>
          </section>

          <%!-- ━━━ Search Select ━━━ --%>
          <section id="search-select-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Search Select</h3>
            <.divider />
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 max-w-2xl">
              <div class="space-y-4">
                <p class="text-xs text-text-muted">Basic with clear button</p>
                <.live_component
                  module={AyaWeb.UI.SearchSelect}
                  id="ingredient-select"
                  field={@form[:ingredient_id]}
                  label="Ingredient"
                  options={@search_options}
                  placeholder="Search ingredients..."
                />
                <p class="text-xs text-text-muted mt-4">Grouped options</p>
                <.live_component
                  module={AyaWeb.UI.SearchSelect}
                  id="grouped-select"
                  field={@form[:ingredient_id]}
                  label="Ingredient (grouped)"
                  options={@grouped_options}
                  placeholder="Search by group..."
                />
              </div>
              <div class="space-y-4">
                <p class="text-xs text-text-muted">Multi-select with chips</p>
                <.live_component
                  module={AyaWeb.UI.SearchSelect}
                  id="tags-select"
                  field={@form[:tags]}
                  label="Tags"
                  options={@tag_options}
                  multiple
                  placeholder="Add tags..."
                />
                <p class="text-xs text-text-muted mt-4">Creatable</p>
                <.live_component
                  module={AyaWeb.UI.SearchSelect}
                  id="creatable-select"
                  field={@form[:tags]}
                  label="Custom Tags"
                  options={@tag_options}
                  multiple
                  creatable
                  placeholder="Search or create..."
                />
              </div>
            </div>
          </section>

          <%!-- ━━━ Date Picker ━━━ --%>
          <section id="date-picker-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Date Picker</h3>
            <.divider />
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 max-w-2xl">
              <.date_picker id="dp-basic" name="event_date" label="Event Date" />
              <.date_picker id="dp-prefilled" name="start_date" label="Start Date" value="2026-03-23" />
              <.date_picker
                id="dp-constrained"
                name="booking"
                label="Booking (Mar 2026)"
                min="2026-03-01"
                max="2026-03-31"
              />
            </div>
            <.divider label="Date Range" class="mt-4" />
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 max-w-2xl">
              <.date_range_picker
                id="dr-basic"
                start_name="check_in"
                end_name="check_out"
                label="Trip Dates"
              />
              <.date_range_picker
                id="dr-prefilled"
                start_name="report_from"
                end_name="report_to"
                label="Report Period"
                start_value="2026-03-01"
                end_value="2026-03-15"
              />
            </div>
          </section>

          <%!-- ━━━ File Picker ━━━ --%>
          <section id="file-picker-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">File Picker</h3>
            <.divider />
            <p class="text-sm text-text-secondary">
              Drag & drop or click to upload. Supports image previews, file type restrictions, and size limits.
            </p>
            <div class="max-w-lg">
              <.file_picker
                upload={@uploads.files}
                uploaded_files={@uploaded_files}
                max_file_size_mb={10}
                max_total_size_mb={50}
              />
            </div>
          </section>

          <%!-- ━━━ Image Field ━━━ --%>
          <section id="image-field-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Image Field</h3>
            <.divider />
            <p class="text-sm text-text-secondary">
              Drop-in image upload + processing + preview component. Shows upload progress,
              processing state, and final image with responsive srcset.
            </p>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <%!-- Idle state --%>
              <div class="space-y-2">
                <p class="text-xs text-text-muted">Idle (default)</p>
                <.image_field
                  upload={@uploads.image}
                  status="idle"
                  alt="Recipe photo"
                  aspect="16/9"
                  rounded="rounded-xl"
                />
              </div>

              <%!-- Processing state --%>
              <div class="space-y-2">
                <p class="text-xs text-text-muted">Processing</p>
                <.image_field
                  status="processing"
                  alt="Recipe photo"
                  aspect="16/9"
                  rounded="rounded-xl"
                />
              </div>

              <%!-- Error state --%>
              <div class="space-y-2">
                <p class="text-xs text-text-muted">Error</p>
                <.image_field
                  status="error"
                  error_message="Image format not supported"
                  alt="Recipe photo"
                  aspect="16/9"
                  rounded="rounded-xl"
                />
              </div>

              <%!-- Ready state (static demo) --%>
              <div class="space-y-2">
                <p class="text-xs text-text-muted">Ready</p>
                <div class="image-field relative rounded-xl">
                  <div class="image-field__ready relative group">
                    <.image
                      src="https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&q=80"
                      alt="Artisan bread"
                      width={800}
                      height={533}
                      placeholder="color"
                      color="#d4a574"
                      rounded="rounded-xl"
                      aspect="16/9"
                    />
                    <button
                      type="button"
                      class={[
                        "absolute top-2 right-2 p-1.5 rounded-full",
                        "bg-black/60 text-white opacity-0 group-hover:opacity-100",
                        "transition-opacity duration-150 hover:bg-black/80"
                      ]}
                      aria-label="Remove image"
                    >
                      <.icon name="hero-x-mark" class="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <%!-- ━━━ Slider ━━━ --%>
          <section id="slider-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Slider</h3>
            <.divider />
            <div class="space-y-8">
              <div class="max-w-sm">
                <p class="text-xs text-text-muted mb-2">Basic with value</p>
                <.slider id="demo-slider" name="volume" value={62} label="Volume" show_value />
              </div>
              <div class="max-w-sm">
                <p class="text-xs text-text-muted mb-2">With prefix & step</p>
                <.slider
                  id="demo-price"
                  name="price"
                  min={0}
                  max={200}
                  step={5}
                  value={75}
                  label="Budget"
                  show_value
                  prefix="$"
                />
              </div>
              <div class="max-w-sm">
                <p class="text-xs text-text-muted mb-2">Range (dual-thumb)</p>
                <.slider
                  id="demo-range"
                  name="range"
                  min={0}
                  max={500}
                  step={10}
                  value={[100, 350]}
                  range
                  label="Price range"
                  show_value
                  prefix="$"
                />
              </div>
              <div class="max-w-sm">
                <p class="text-xs text-text-muted mb-2">With marks</p>
                <.slider
                  id="demo-marks"
                  name="temp"
                  min={0}
                  max={500}
                  step={25}
                  value={350}
                  label="Oven temperature"
                  show_value
                  suffix="°F"
                  marks={[
                    %{value: 0, label: "0°F"},
                    %{value: 212, label: "Boil"},
                    %{value: 350, label: "Bake"},
                    %{value: 500, label: "Broil"}
                  ]}
                />
              </div>
              <div class="max-w-sm">
                <p class="text-xs text-text-muted mb-2">Sizes</p>
                <div class="space-y-4">
                  <.slider id="demo-sm" name="sm" value={40} size="sm" label="Small" />
                  <.slider id="demo-md" name="md" value={60} size="md" label="Medium" />
                  <.slider id="demo-lg" name="lg" value={80} size="lg" label="Large" />
                </div>
              </div>
            </div>
          </section>

          <%!-- ━━━ Color Picker ━━━ --%>
          <section id="color-picker-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Color Picker</h3>
            <.divider />
            <div class="space-y-6">
              <div>
                <p class="text-xs text-text-muted mb-2">Default (with custom input)</p>
                <.color_picker id="demo-color" name="color" label="Accent color" />
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">Custom swatches</p>
                <.color_picker
                  id="demo-food-colors"
                  name="food_color"
                  label="Food color"
                  swatches={~w(#dc2626 #ea580c #d97706 #65a30d #16a34a #0891b2 #7c3aed #db2777)}
                />
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">Swatches only (no custom)</p>
                <.color_picker
                  id="demo-simple-color"
                  name="simple_color"
                  label="Theme"
                  allow_custom={false}
                  swatches={~w(#c2410c #166534 #0369a1 #7c3aed #1c1917)}
                />
              </div>
            </div>
          </section>

          <%!-- ━━━ Tag Input ━━━ --%>
          <section id="tag-input-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Tag Input</h3>
            <.divider />
            <div class="space-y-6">
              <div class="max-w-md">
                <p class="text-xs text-text-muted mb-2">Basic</p>
                <.live_component
                  module={AyaWeb.UI.TagInput}
                  id="demo-tags"
                  field={@form[:tags]}
                  label="Tags"
                  placeholder="Type and press Enter..."
                />
              </div>
              <div class="max-w-md">
                <p class="text-xs text-text-muted mb-2">With suggestions</p>
                <.live_component
                  module={AyaWeb.UI.TagInput}
                  id="demo-ingredient-tags"
                  field={@form[:ingredients]}
                  label="Ingredients"
                  placeholder="Add ingredients..."
                  suggestions={[
                    "Salt",
                    "Pepper",
                    "Garlic",
                    "Onion",
                    "Olive Oil",
                    "Butter",
                    "Flour",
                    "Sugar",
                    "Cumin",
                    "Paprika"
                  ]}
                  max_tags={6}
                />
              </div>
            </div>
          </section>
        </div>

        <%!-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
             FEEDBACK
             ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --%>
        <div class="mt-16 space-y-12">
          <.category_header id="cat-feedback" label="Feedback" />

          <%!-- ━━━ Toast ━━━ --%>
          <section id="toast-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Toast (Sonner-style)</h3>
            <.divider />
            <div class="space-y-5">
              <%!-- Types --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Types</p>
                <div class="flex flex-wrap items-center gap-3">
                  <.button phx-click="toast_info" variant="soft" size="sm">Info</.button>
                  <.button phx-click="toast_success" variant="soft" size="sm">Success</.button>
                  <.button phx-click="toast_warning" variant="soft" size="sm">Warning</.button>
                  <.button phx-click="toast_error" variant="soft" size="sm">Error</.button>
                  <.button phx-click="toast_rich" variant="primary" size="sm">Rich Toast</.button>
                  <.divider orientation="vertical" class="h-6" />
                  <.toggle
                    field={@form[:rich_colors]}
                    label="Rich colors"
                    phx-click="toggle_rich_colors"
                    size="sm"
                  />
                </div>
              </div>
              <%!-- Positions --%>
              <div>
                <p class="text-xs text-text-muted mb-2">Positions</p>
                <div class="flex flex-wrap items-center gap-3">
                  <.button
                    phx-click="toast_position"
                    phx-value-position="top-center"
                    variant="ghost"
                    size="sm"
                  >
                    Top center
                  </.button>
                  <.button
                    phx-click="toast_position"
                    phx-value-position="top-right"
                    variant="ghost"
                    size="sm"
                  >
                    Top right
                  </.button>
                  <.button
                    phx-click="toast_position"
                    phx-value-position="bottom-center"
                    variant="ghost"
                    size="sm"
                  >
                    Bottom center
                  </.button>
                  <.button
                    phx-click="toast_position"
                    phx-value-position="bottom-right"
                    variant="ghost"
                    size="sm"
                  >
                    Bottom right
                  </.button>
                </div>
              </div>
            </div>
          </section>

          <%!-- ━━━ Inline Alert ━━━ --%>
          <section id="inline-alert-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Inline Alert</h3>
            <.divider />
            <div class="space-y-3 max-w-xl">
              <.inline_alert type={:info}>This is an informational message.</.inline_alert>
              <.inline_alert type={:success}>Operation completed successfully.</.inline_alert>
              <.inline_alert type={:warning} dismissible>Disk space is running low.</.inline_alert>
              <.inline_alert type={:error}>Failed to save changes. Please try again.</.inline_alert>
            </div>
          </section>

          <%!-- ━━━ Banner ━━━ --%>
          <section id="banner-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Banner</h3>
            <.divider />
            <div class="space-y-3">
              <.banner variant={:info}>New recipes are published every Monday.</.banner>
              <.banner variant={:warning}>Scheduled maintenance on Sunday 2am-4am UTC.</.banner>
              <.banner variant={:success}>Your account has been verified.</.banner>
              <.banner variant={:error} dismissible={false}>Service degradation detected.</.banner>
            </div>
          </section>
        </div>

        <%!-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
             NAVIGATION
             ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --%>
        <div class="mt-16 space-y-12">
          <.category_header id="cat-nav" label="Navigation" />

          <%!-- ━━━ Tabs ━━━ --%>
          <section id="tabs-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Tabs</h3>
            <.divider />
            <div class="space-y-8">
              <div>
                <p class="text-sm text-text-secondary mb-3">Underline — static (no navigation)</p>
                <.tabs id="demo-tabs-static">
                  <:tab label="Overview" icon="hero-home" active />
                  <:tab label="Nutrition" icon="hero-beaker" />
                  <:tab label="Reviews" badge="12" />
                </.tabs>
              </div>

              <div>
                <p class="text-sm text-text-secondary mb-3">Underline — with icons and badges</p>
                <.tabs id="demo-tabs-badges">
                  <:tab label="All Recipes" icon="hero-book-open" active badge="128" />
                  <:tab label="Favorites" icon="hero-heart" badge="7" />
                  <:tab label="Drafts" icon="hero-pencil-square" badge="3" />
                  <:tab label="Archived" icon="hero-archive-box" />
                </.tabs>
              </div>

              <div>
                <p class="text-sm text-text-secondary mb-3">Pill — panel switching</p>
                <.tabs id="demo-tabs" variant="pill">
                  <:tab label="Ingredients" panel="panel-ingredients" active />
                  <:tab label="Instructions" panel="panel-instructions" />
                  <:tab label="Notes" panel="panel-notes" />
                </.tabs>
                <div class="mt-4 rounded-lg border border-border p-4">
                  <div id="panel-ingredients">
                    <p class="text-sm font-medium text-text mb-2">Sourdough Bread</p>
                    <ul class="space-y-1 text-sm text-text-secondary list-disc list-inside">
                      <li>500g bread flour</li>
                      <li>350ml water</li>
                      <li>100g active starter</li>
                      <li>10g salt</li>
                    </ul>
                  </div>
                  <div id="panel-instructions" hidden>
                    <p class="text-sm font-medium text-text mb-2">Method</p>
                    <ol class="space-y-1 text-sm text-text-secondary list-decimal list-inside">
                      <li>Mix flour and water, autolyse 30 min</li>
                      <li>Add starter and salt, fold to combine</li>
                      <li>Stretch and fold every 30 min for 2 hours</li>
                      <li>Bulk ferment 4-6 hours at room temp</li>
                      <li>Shape, cold retard overnight</li>
                      <li>Bake at 250C with steam, 45 min</li>
                    </ol>
                  </div>
                  <div id="panel-notes" hidden>
                    <p class="text-sm text-text-secondary">
                      Use bread flour for best results. The starter should pass the float test. Adjust hydration based on flour absorption. Cold retard in the fridge for 12-18 hours develops complex flavor.
                    </p>
                  </div>
                </div>
              </div>

              <div>
                <p class="text-sm text-text-secondary mb-3">Pill — icon-only compact</p>
                <.tabs id="demo-tabs-icons" variant="pill">
                  <:tab label="Grid" icon="hero-squares-2x2" panel="panel-grid" active />
                  <:tab label="List" icon="hero-list-bullet" panel="panel-list" />
                  <:tab label="Board" icon="hero-view-columns" panel="panel-board" />
                </.tabs>
                <div class="mt-4 rounded-lg border border-border p-4">
                  <div id="panel-grid">
                    <div class="grid grid-cols-3 gap-2">
                      <div :for={_ <- 1..6} class="h-16 rounded-md bg-surface-alt" />
                    </div>
                  </div>
                  <div id="panel-list" hidden>
                    <div class="space-y-2">
                      <div :for={_ <- 1..4} class="h-10 rounded-md bg-surface-alt" />
                    </div>
                  </div>
                  <div id="panel-board" hidden>
                    <div class="flex gap-2">
                      <div :for={_ <- 1..3} class="flex-1 space-y-2">
                        <div class="h-6 rounded bg-surface-alt" />
                        <div :for={_ <- 1..2} class="h-16 rounded-md bg-surface-alt" />
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div>
                <p class="text-sm text-text-secondary mb-3">
                  Smooth — pill (animated indicator + content transitions)
                </p>
                <.smooth_tabs id="demo-smooth-pill" class="max-w-md">
                  <:tab label="Ingredients" icon="hero-beaker" active>
                    <p class="text-sm font-medium text-text mb-2">Sourdough Bread</p>
                    <ul class="space-y-1 text-sm text-text-secondary list-disc list-inside">
                      <li>500g bread flour</li>
                      <li>350ml water</li>
                      <li>100g active starter</li>
                      <li>10g salt</li>
                    </ul>
                  </:tab>
                  <:tab label="Method" icon="hero-list-bullet">
                    <ol class="space-y-1 text-sm text-text-secondary list-decimal list-inside">
                      <li>Mix flour and water, autolyse 30 min</li>
                      <li>Add starter and salt, fold to combine</li>
                      <li>Stretch and fold every 30 min for 2 hours</li>
                      <li>Bulk ferment 4-6 hours at room temp</li>
                      <li>Shape, cold retard overnight</li>
                      <li>Bake at 250°C with steam, 45 min</li>
                    </ol>
                  </:tab>
                  <:tab label="Notes" badge="3">
                    <p class="text-sm text-text-secondary">
                      Use bread flour for best results. The starter should pass the float test. Adjust hydration based on flour absorption. Cold retard in the fridge for 12-18 hours develops complex flavor.
                    </p>
                  </:tab>
                </.smooth_tabs>
              </div>

              <div>
                <p class="text-sm text-text-secondary mb-3">Smooth — underline (sliding indicator)</p>
                <.smooth_tabs id="demo-smooth-underline" variant="underline" class="max-w-md">
                  <:tab label="Overview" active>
                    <div class="flex gap-6 py-1">
                      <div class="text-center">
                        <p class="text-2xl font-semibold text-text">128</p>
                        <p class="text-xs text-text-muted">Recipes</p>
                      </div>
                      <div class="text-center">
                        <p class="text-2xl font-semibold text-text">94%</p>
                        <p class="text-xs text-text-muted">Success rate</p>
                      </div>
                      <div class="text-center">
                        <p class="text-2xl font-semibold text-text">47</p>
                        <p class="text-xs text-text-muted">This week</p>
                      </div>
                    </div>
                  </:tab>
                  <:tab label="Activity">
                    <div class="space-y-2 py-1">
                      <div
                        :for={
                          item <- [
                            "Edited Sourdough Bread",
                            "Added Kimchi Fried Rice",
                            "Reviewed Miso Ramen"
                          ]
                        }
                        class="flex items-center gap-2 text-sm text-text-secondary"
                      >
                        <div class="size-1.5 rounded-full bg-primary" />
                        <span>{item}</span>
                      </div>
                    </div>
                  </:tab>
                  <:tab label="Settings">
                    <p class="text-sm text-text-secondary py-1">
                      Configure notifications, access controls, and integration preferences.
                    </p>
                  </:tab>
                </.smooth_tabs>
              </div>
            </div>
          </section>

          <%!-- ━━━ Accordion ━━━ --%>
          <section id="accordion-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Accordion</h3>
            <.divider />
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 max-w-3xl">
              <div class="space-y-6">
                <div>
                  <p class="text-xs text-text-muted mb-2">Default (dividers)</p>
                  <.accordion>
                    <:item title="Ingredients" icon="hero-beaker" open>
                      500g bread flour, 350ml water, 100g active sourdough starter, 10g fine sea salt.
                    </:item>
                    <:item title="Instructions" icon="hero-list-bullet">
                      Mix flour and water, autolyse 30 min. Add starter and salt, stretch and fold. Bulk ferment 4–6 hours. Shape, cold retard overnight.
                    </:item>
                    <:item title="Nutrition" icon="hero-chart-bar" badge="120 cal">
                      Per slice: 120 cal, 4g protein, 24g carbs, 0.5g fat.
                    </:item>
                  </.accordion>
                </div>
                <div>
                  <p class="text-xs text-text-muted mb-2">Card (bordered)</p>
                  <.accordion variant="card" id="card-acc" exclusive>
                    <:item title="What is Aya?" subtitle="About the platform" open>
                      Aya is a food and food-science platform for exploring recipes, ingredients, nutrition research, and market trends.
                    </:item>
                    <:item title="How do I add a recipe?" subtitle="Getting started">
                      Navigate to Recipes, click "New Recipe", fill in the details, and publish. You can save drafts and come back later.
                    </:item>
                    <:item title="Is Aya open source?" subtitle="Technical details">
                      Built with Elixir, Phoenix, and LiveView. Domain-driven design with bounded contexts.
                    </:item>
                  </.accordion>
                </div>
              </div>
              <div class="space-y-6">
                <div>
                  <p class="text-xs text-text-muted mb-2">Block (filled background)</p>
                  <.accordion variant="block" id="block-acc" exclusive>
                    <:item title="Step 1: Autolyse" subtitle="30 minutes" icon="hero-clock">
                      Mix flour and water, cover, and rest for 30 minutes. This hydrates the flour and begins gluten development.
                    </:item>
                    <:item title="Step 2: Mix" subtitle="5 minutes" icon="hero-hand-raised">
                      Add starter and salt. Pinch and fold until fully incorporated. The dough should feel shaggy but cohesive.
                    </:item>
                    <:item title="Step 3: Bulk Ferment" subtitle="4–6 hours" icon="hero-fire">
                      Stretch and fold every 30 min for the first 2 hours. Then leave covered at room temp until 50% volume increase.
                    </:item>
                  </.accordion>
                </div>
                <div>
                  <p class="text-xs text-text-muted mb-2">Separated (cards with gap)</p>
                  <.accordion variant="separated" id="sep-acc" exclusive>
                    <:item title="Personal Plan" icon="hero-user" badge="Free" open>
                      <p>
                        Up to 50 recipes, basic nutrition info, and community access. Perfect for home cooks.
                      </p>
                    </:item>
                    <:item title="Pro Plan" icon="hero-sparkles" badge="$9/mo">
                      <p>
                        Unlimited recipes, AI suggestions, meal planning, and export to PDF. For serious food enthusiasts.
                      </p>
                    </:item>
                    <:item title="Team Plan" icon="hero-user-group" badge="$29/mo">
                      <p>
                        Everything in Pro plus collaboration, shared recipe books, and admin controls for teams and restaurants.
                      </p>
                    </:item>
                  </.accordion>
                </div>
              </div>
            </div>
            <div>
              <p class="text-xs text-text-muted mb-2">Horizontal (tab-like)</p>
              <.accordion variant="horizontal" id="horiz-acc" chevron={false}>
                <:item title="Ingredients" icon="hero-beaker" open>
                  <p>
                    500g bread flour, 350ml water, 100g active sourdough starter, 10g fine sea salt.
                  </p>
                </:item>
                <:item title="Method" icon="hero-list-bullet">
                  <p>
                    Autolyse 30 min. Add starter + salt. Stretch & fold every 30 min for 2 hours. Bulk ferment 4–6h. Shape, cold retard overnight. Bake 250°C with steam.
                  </p>
                </:item>
                <:item title="Notes" icon="hero-chat-bubble-bottom-center-text">
                  <p>
                    Use bread flour for best results. The starter should pass the float test. Cold retard 12–18h for complex flavor.
                  </p>
                </:item>
              </.accordion>
            </div>
          </section>

          <%!-- ━━━ Breadcrumb ━━━ --%>
          <section id="breadcrumb-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Breadcrumb</h3>
            <.divider />
            <div class="space-y-4">
              <div>
                <p class="text-xs text-text-muted mb-2">Simple</p>
                <.breadcrumb>
                  <:crumb navigate={~p"/"} icon="hero-home">Home</:crumb>
                  <:crumb navigate={~p"/showcase"}>Recipes</:crumb>
                  <:crumb>Sourdough Bread</:crumb>
                </.breadcrumb>
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">Deep nesting</p>
                <.breadcrumb>
                  <:crumb navigate={~p"/"} icon="hero-home">Home</:crumb>
                  <:crumb navigate={~p"/showcase"}>Research</:crumb>
                  <:crumb navigate={~p"/showcase"}>Food Science</:crumb>
                  <:crumb navigate={~p"/showcase"}>Fermentation</:crumb>
                  <:crumb>Lacto-fermentation of Vegetables</:crumb>
                </.breadcrumb>
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">With icons</p>
                <.breadcrumb>
                  <:crumb navigate={~p"/"} icon="hero-home">Home</:crumb>
                  <:crumb navigate={~p"/showcase"} icon="hero-users">Accounts</:crumb>
                  <:crumb navigate={~p"/showcase"} icon="hero-cog-6-tooth">Settings</:crumb>
                  <:crumb>Notifications</:crumb>
                </.breadcrumb>
              </div>
            </div>
          </section>

          <%!-- ━━━ Pagination ━━━ --%>
          <section id="pagination-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Pagination</h3>
            <.divider />
            <.pagination page={@current_page} total_pages={20} on_page="paginate" />
          </section>

          <%!-- ━━━ Steps ━━━ --%>
          <section id="steps-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Steps</h3>
            <.divider />
            <div class="space-y-8">
              <div>
                <p class="text-sm text-text-secondary mb-4">Horizontal</p>
                <.steps>
                  <:step label="Account" status={:complete} />
                  <:step label="Profile" description="Add your details" status={:current} />
                  <:step label="Preferences" status={:upcoming} />
                  <:step label="Review" status={:upcoming} />
                </.steps>
              </div>
              <div>
                <p class="text-sm text-text-secondary mb-4">Vertical</p>
                <.steps orientation="vertical">
                  <:step label="Order Placed" description="March 22, 2026" status={:complete} />
                  <:step label="Processing" description="Preparing your order" status={:current} />
                  <:step label="Shipped" status={:upcoming} />
                  <:step label="Delivered" status={:upcoming} />
                </.steps>
              </div>
            </div>
          </section>

          <%!-- ━━━ Multi Step ━━━ --%>
          <section id="multi-step-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Multi Step</h3>
            <.divider />
            <.multi_step id="demo-multi-step" class="max-w-lg">
              <:step>
                <h2 class="text-base font-semibold mb-2">This is step one</h2>
                <p class="text-sm text-text-secondary">
                  Usually in this step we would explain why this thing exists and
                  what it does. Also, we would show a button to go to the next step.
                </p>
                <div class="mt-5 space-y-2">
                  <div class="skeleton-pulse rounded h-4 w-64" />
                  <div class="skeleton-pulse rounded h-4 w-48" />
                  <div class="skeleton-pulse rounded h-4" />
                  <div class="skeleton-pulse rounded h-4 w-96" />
                </div>
              </:step>
              <:step>
                <h2 class="text-base font-semibold mb-2">This is step two</h2>
                <p class="text-sm text-text-secondary">
                  Usually in this step we would explain why this thing exists and
                  what it does. Also, we would show a button to go to the next step.
                </p>
                <div class="mt-5 space-y-2">
                  <div class="skeleton-pulse rounded h-4 w-64" />
                  <div class="skeleton-pulse rounded h-4 w-48" />
                  <div class="skeleton-pulse rounded h-4 w-96" />
                </div>
              </:step>
              <:step>
                <h2 class="text-base font-semibold mb-2">This is step three</h2>
                <p class="text-sm text-text-secondary">
                  Usually in this step we would explain why this thing exists and
                  what it does. Also, we would show a button to go to the next step.
                </p>
                <div class="mt-5 space-y-2">
                  <div class="skeleton-pulse rounded h-4 w-64" />
                  <div class="skeleton-pulse rounded h-4 w-48" />
                  <div class="skeleton-pulse rounded h-4 w-32" />
                  <div class="skeleton-pulse rounded h-4 w-56" />
                  <div class="skeleton-pulse rounded h-4 w-96" />
                </div>
              </:step>
            </.multi_step>
          </section>

          <%!-- ━━━ Split Pane ━━━ --%>
          <section id="split-pane-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Split Pane</h3>
            <.divider />
            <p class="text-sm text-text-secondary">
              Master-detail layout — select from the sidebar to show content on the right.
            </p>

            <p class="text-xs text-text-muted mb-2">Recipe browser (slides from right)</p>
            <.split_pane id="sp-recipes" transition="right">
              <:item
                id="sp-bread"
                title="Sourdough Bread"
                subtitle="Baking · 4 hours"
                image="https://picsum.photos/seed/sourdough2/80/80"
                active
              >
                <div class="space-y-4">
                  <div class="flex items-center gap-4">
                    <img
                      src="https://picsum.photos/seed/sourdough2/400/200"
                      class="w-full h-40 rounded-lg object-cover outline-none"
                      alt=""
                    />
                  </div>
                  <h3 class="text-lg font-bold text-text">Sourdough Bread</h3>
                  <div class="flex gap-4 text-sm text-text-muted">
                    <span>Baking</span>
                    <span>4 hours</span>
                    <span>Intermediate</span>
                  </div>
                  <p class="text-sm text-text-secondary">
                    A classic artisan bread with a crispy crust and chewy interior. Requires an active sourdough starter and patience for bulk fermentation. Cold retard overnight for complex flavor.
                  </p>
                  <div class="flex gap-2">
                    <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-secondary-soft text-secondary">
                      Fermentation
                    </span>
                    <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-accent-soft text-accent">
                      Artisan
                    </span>
                  </div>
                </div>
              </:item>
              <:item
                id="sp-ramen"
                title="Miso Ramen"
                subtitle="Soup · 45 min"
                image="https://picsum.photos/seed/ramen2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/ramen2/400/200"
                    class="w-full h-40 rounded-lg object-cover outline-none"
                    alt=""
                  />
                  <h3 class="text-lg font-bold text-text">Miso Ramen</h3>
                  <div class="flex gap-4 text-sm text-text-muted">
                    <span>Soup</span>
                    <span>45 min</span>
                    <span>Easy</span>
                  </div>
                  <p class="text-sm text-text-secondary">
                    Rich, umami-packed broth with handmade noodles. Use white miso for milder flavor or red miso for depth. Top with soft-boiled egg, nori, and scallions.
                  </p>
                </div>
              </:item>
              <:item
                id="sp-kimchi"
                title="Kimchi Fried Rice"
                subtitle="Quick · 15 min"
                image="https://picsum.photos/seed/kimchi2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/kimchi2/400/200"
                    class="w-full h-40 rounded-lg object-cover outline-none"
                    alt=""
                  />
                  <h3 class="text-lg font-bold text-text">Kimchi Fried Rice</h3>
                  <div class="flex gap-4 text-sm text-text-muted">
                    <span>Quick</span>
                    <span>15 min</span>
                    <span>Beginner</span>
                  </div>
                  <p class="text-sm text-text-secondary">
                    Quick weeknight dinner using leftover rice and aged kimchi. The key is high heat and not stirring too much — you want crispy bits at the bottom.
                  </p>
                </div>
              </:item>
              <:item
                id="sp-mousse"
                title="Chocolate Mousse"
                subtitle="Dessert · 30 min"
                image="https://picsum.photos/seed/mousse2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/mousse2/400/200"
                    class="w-full h-40 rounded-lg object-cover outline-none"
                    alt=""
                  />
                  <h3 class="text-lg font-bold text-text">Chocolate Mousse</h3>
                  <div class="flex gap-4 text-sm text-text-muted">
                    <span>Dessert</span>
                    <span>30 min</span>
                    <span>Intermediate</span>
                  </div>
                  <p class="text-sm text-text-secondary">
                    Silky, rich chocolate mousse made with just dark chocolate, eggs, and a pinch of salt. No cream needed. Chill for at least 2 hours.
                  </p>
                </div>
              </:item>
            </.split_pane>

            <p class="text-xs text-text-muted mb-2 mt-6">Server list (slides from top)</p>
            <.split_pane
              id="sp-servers"
              sidebar_width="w-64"
              searchable
              search_placeholder="Filter servers..."
              transition="top"
            >
              <:item
                id="srv-web"
                title="web-prod-01"
                subtitle="us-east-1 · Healthy"
                icon="hero-server-stack"
                badge="2 vCPU"
                active
              >
                <div class="space-y-4">
                  <div class="flex items-center justify-between">
                    <h3 class="text-lg font-bold text-text">web-prod-01</h3>
                    <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-success-soft text-success">
                      Healthy
                    </span>
                  </div>
                  <div class="grid grid-cols-3 gap-4">
                    <div class="rounded-lg bg-surface-alt p-3 text-center">
                      <p class="text-lg font-semibold text-text">24%</p>
                      <p class="text-xs text-text-muted">CPU</p>
                    </div>
                    <div class="rounded-lg bg-surface-alt p-3 text-center">
                      <p class="text-lg font-semibold text-text">1.2 GB</p>
                      <p class="text-xs text-text-muted">Memory</p>
                    </div>
                    <div class="rounded-lg bg-surface-alt p-3 text-center">
                      <p class="text-lg font-semibold text-text">99.9%</p>
                      <p class="text-xs text-text-muted">Uptime</p>
                    </div>
                  </div>
                  <p class="text-sm text-text-secondary">
                    Running Phoenix 1.8 + Elixir 1.18. Last deployed 2h ago. Region: us-east-1.
                  </p>
                  <.divider label="Deploy" />
                  <div class="max-w-xs">
                    <.live_component
                      module={AyaWeb.UI.SearchSelect}
                      id="server-region-select"
                      field={@form[:ingredient_id]}
                      label="Deploy Region"
                      options={[
                        %{value: "us-east-1", label: "US East (Virginia)", group: "Americas"},
                        %{value: "us-west-2", label: "US West (Oregon)", group: "Americas"},
                        %{value: "eu-west-1", label: "EU West (Ireland)", group: "Europe"},
                        %{value: "eu-central-1", label: "EU Central (Frankfurt)", group: "Europe"},
                        %{
                          value: "ap-southeast-1",
                          label: "Asia Pacific (Singapore)",
                          group: "Asia Pacific"
                        },
                        %{
                          value: "ap-northeast-1",
                          label: "Asia Pacific (Tokyo)",
                          group: "Asia Pacific"
                        }
                      ]}
                      placeholder="Select region..."
                    />
                  </div>
                </div>
              </:item>
              <:item
                id="srv-api"
                title="api-prod-01"
                subtitle="us-east-1 · Healthy"
                icon="hero-globe-alt"
                badge="4 vCPU"
              >
                <div class="space-y-3">
                  <div class="flex items-center justify-between">
                    <h3 class="text-lg font-bold text-text">api-prod-01</h3>
                    <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-success-soft text-success">
                      Healthy
                    </span>
                  </div>
                  <p class="text-sm text-text-secondary">
                    API gateway handling 12K req/min. Last deployed 6h ago.
                  </p>
                </div>
              </:item>
              <:item
                id="srv-db"
                title="db-primary"
                subtitle="us-east-1 · Warning"
                icon="hero-circle-stack"
                badge="8 vCPU"
              >
                <div class="space-y-3">
                  <div class="flex items-center justify-between">
                    <h3 class="text-lg font-bold text-text">db-primary</h3>
                    <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-warning-soft text-warning">
                      Warning
                    </span>
                  </div>
                  <p class="text-sm text-text-secondary">
                    PostgreSQL 16.2. Disk usage at 82%. Consider scaling storage.
                  </p>
                </div>
              </:item>
              <:item
                id="srv-worker"
                title="worker-01"
                subtitle="eu-west-1 · Healthy"
                icon="hero-cog-6-tooth"
              >
                <div class="space-y-3">
                  <div class="flex items-center justify-between">
                    <h3 class="text-lg font-bold text-text">worker-01</h3>
                    <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-success-soft text-success">
                      Healthy
                    </span>
                  </div>
                  <p class="text-sm text-text-secondary">
                    Background job processor. Oban queues: 3 active, 0 stalled.
                  </p>
                </div>
              </:item>
            </.split_pane>
          </section>

          <%!-- ━━━ List Detail ━━━ --%>
          <section id="list-detail-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">List Detail</h3>
            <.divider />
            <p class="text-sm text-text-secondary">
              Click an item to reveal a detail panel. Supports sliding in from the right or left.
            </p>
            <p class="text-xs text-text-muted mb-2">Detail slides from right</p>
            <.list_detail id="ld-recipes" detail_width="w-96" class="max-w-2xl">
              <:item
                id="ld-bread"
                title="Sourdough Bread"
                subtitle="Baking · 4 hours"
                image="https://picsum.photos/seed/sourdough2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/sourdough2/400/200"
                    class="w-full h-36 rounded-lg object-cover outline-none"
                  />
                  <h3 class="text-lg font-bold text-text">Sourdough Bread</h3>
                  <div class="flex gap-3 text-xs text-text-muted">
                    <span>Baking</span><span>4 hours</span><span>Intermediate</span>
                  </div>
                  <p class="text-sm text-text-secondary">
                    A classic artisan bread with a crispy crust and chewy interior. Requires an active sourdough starter and patience for bulk fermentation.
                  </p>
                </div>
              </:item>
              <:item
                id="ld-ramen"
                title="Miso Ramen"
                subtitle="Soup · 45 min"
                image="https://picsum.photos/seed/ramen2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/ramen2/400/200"
                    class="w-full h-36 rounded-lg object-cover outline-none"
                  />
                  <h3 class="text-lg font-bold text-text">Miso Ramen</h3>
                  <p class="text-sm text-text-secondary">
                    Rich, umami-packed broth with handmade noodles. Use white miso for milder flavor or red miso for depth.
                  </p>
                </div>
              </:item>
              <:item
                id="ld-kimchi"
                title="Kimchi Fried Rice"
                subtitle="Quick · 15 min"
                image="https://picsum.photos/seed/kimchi2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/kimchi2/400/200"
                    class="w-full h-36 rounded-lg object-cover outline-none"
                  />
                  <h3 class="text-lg font-bold text-text">Kimchi Fried Rice</h3>
                  <p class="text-sm text-text-secondary">
                    Quick weeknight dinner using leftover rice and aged kimchi. High heat, don't stir too much.
                  </p>
                </div>
              </:item>
              <:item
                id="ld-mousse"
                title="Chocolate Mousse"
                subtitle="Dessert · 30 min"
                image="https://picsum.photos/seed/mousse2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/mousse2/400/200"
                    class="w-full h-36 rounded-lg object-cover outline-none"
                  />
                  <h3 class="text-lg font-bold text-text">Chocolate Mousse</h3>
                  <p class="text-sm text-text-secondary">
                    Silky, rich chocolate mousse made with just dark chocolate, eggs, and a pinch of salt. Chill 2 hours.
                  </p>
                </div>
              </:item>
            </.list_detail>

            <p class="text-xs text-text-muted mb-2 mt-6">Content slides left → right</p>
            <.list_detail id="ld-recipes-left" detail_width="w-96" direction="left" class="max-w-2xl">
              <:item
                id="ldl-bread"
                title="Sourdough Bread"
                subtitle="Baking · 4 hours"
                image="https://picsum.photos/seed/sourdough2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/sourdough2/400/200"
                    class="w-full h-36 rounded-lg object-cover outline-none"
                  />
                  <h3 class="text-lg font-bold text-text">Sourdough Bread</h3>
                  <p class="text-sm text-text-secondary">
                    A classic artisan bread with crispy crust and chewy interior.
                  </p>
                </div>
              </:item>
              <:item
                id="ldl-ramen"
                title="Miso Ramen"
                subtitle="Soup · 45 min"
                image="https://picsum.photos/seed/ramen2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/ramen2/400/200"
                    class="w-full h-36 rounded-lg object-cover outline-none"
                  />
                  <h3 class="text-lg font-bold text-text">Miso Ramen</h3>
                  <p class="text-sm text-text-secondary">
                    Rich broth with handmade noodles. White miso for milder, red for depth.
                  </p>
                </div>
              </:item>
              <:item
                id="ldl-kimchi"
                title="Kimchi Fried Rice"
                subtitle="Quick · 15 min"
                image="https://picsum.photos/seed/kimchi2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/kimchi2/400/200"
                    class="w-full h-36 rounded-lg object-cover outline-none"
                  />
                  <h3 class="text-lg font-bold text-text">Kimchi Fried Rice</h3>
                  <p class="text-sm text-text-secondary">
                    Quick weeknight dinner. High heat, don't stir too much.
                  </p>
                </div>
              </:item>
              <:item
                id="ldl-mousse"
                title="Chocolate Mousse"
                subtitle="Dessert · 30 min"
                image="https://picsum.photos/seed/mousse2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/mousse2/400/200"
                    class="w-full h-36 rounded-lg object-cover outline-none"
                  />
                  <h3 class="text-lg font-bold text-text">Chocolate Mousse</h3>
                  <p class="text-sm text-text-secondary">
                    Silky mousse with dark chocolate, eggs, and salt. Chill 2 hours.
                  </p>
                </div>
              </:item>
            </.list_detail>

            <p class="text-xs text-text-muted mb-2 mt-6">
              Fixed list + detail appears as extra space on right
            </p>
            <.list_detail
              id="ld-recipes-push"
              detail_width="w-96"
              list_width="w-80"
              direction="left"
              class="w-fit"
            >
              <:item
                id="ldp-bread"
                title="Sourdough Bread"
                subtitle="Baking · 4 hours"
                image="https://picsum.photos/seed/sourdough2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/sourdough2/400/200"
                    class="w-full h-36 rounded-lg object-cover outline-none"
                  />
                  <h3 class="text-lg font-bold text-text">Sourdough Bread</h3>
                  <div class="flex gap-3 text-xs text-text-muted">
                    <span>Baking</span><span>4 hours</span><span>Intermediate</span>
                  </div>
                  <p class="text-sm text-text-secondary">
                    A classic artisan bread with a crispy crust and chewy interior. Requires an active sourdough starter and patience for bulk fermentation.
                  </p>
                  <p class="text-sm text-text-secondary">
                    Tip: cold retard in the fridge overnight for complex flavor development.
                  </p>
                </div>
              </:item>
              <:item
                id="ldp-ramen"
                title="Miso Ramen"
                subtitle="Soup · 45 min"
                image="https://picsum.photos/seed/ramen2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/ramen2/400/200"
                    class="w-full h-36 rounded-lg object-cover outline-none"
                  />
                  <h3 class="text-lg font-bold text-text">Miso Ramen</h3>
                  <p class="text-sm text-text-secondary">
                    Rich, umami-packed broth with handmade noodles. A bowl of comfort on cold days.
                  </p>
                </div>
              </:item>
              <:item
                id="ldp-kimchi"
                title="Kimchi Fried Rice"
                subtitle="Quick · 15 min"
                image="https://picsum.photos/seed/kimchi2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/kimchi2/400/200"
                    class="w-full h-36 rounded-lg object-cover outline-none"
                  />
                  <h3 class="text-lg font-bold text-text">Kimchi Fried Rice</h3>
                  <p class="text-sm text-text-secondary">
                    Quick weeknight dinner using leftover rice and aged kimchi.
                  </p>
                </div>
              </:item>
              <:item
                id="ldp-mousse"
                title="Chocolate Mousse"
                subtitle="Dessert · 30 min"
                image="https://picsum.photos/seed/mousse2/80/80"
              >
                <div class="space-y-4">
                  <img
                    src="https://picsum.photos/seed/mousse2/400/200"
                    class="w-full h-36 rounded-lg object-cover outline-none"
                  />
                  <h3 class="text-lg font-bold text-text">Chocolate Mousse</h3>
                  <p class="text-sm text-text-secondary">
                    Silky, rich mousse. Dark chocolate, eggs, salt. Chill 2 hours.
                  </p>
                </div>
              </:item>
            </.list_detail>
          </section>
        </div>

        <%!-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
             EDITORS
             ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --%>
        <div class="mt-16 space-y-12">
          <.category_header id="cat-editors" label="Editors" />

          <%!-- ━━━ Rich Text Editor ━━━ --%>
          <section id="rich-editor-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Rich Text Editor</h3>
            <.divider />
            <div class="space-y-8">
              <div>
                <p class="text-xs text-text-muted mb-2">Full editor with toolbar</p>
                <.rich_editor
                  id="demo-editor"
                  name="content"
                  label="Recipe instructions"
                  placeholder="Write your recipe steps, tips, and notes..."
                  value="<h2>Sourdough Bread</h2><p>A classic artisan bread with a <strong>crispy crust</strong> and <em>chewy interior</em>.</p><h3>Ingredients</h3><ul><li>500g bread flour</li><li>350g water</li><li>100g active starter</li><li>10g salt</li></ul><h3>Steps</h3><ol><li>Mix flour and water, autolyse for 30 minutes</li><li>Add starter and salt, fold until combined</li><li>Bulk ferment 4-6 hours with stretch and folds every 30 min</li><li>Shape and cold proof overnight</li><li>Bake at 450°F in a Dutch oven</li></ol><blockquote><p>Pro tip: The dough should feel <u>tacky but not sticky</u> after mixing.</p></blockquote>"
                />
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">With AI selection menu</p>
                <.rich_editor
                  id="demo-ai-editor"
                  name="ai_content"
                  label="Article draft"
                  placeholder="Write something, then select text to see AI options..."
                  ai_enabled
                />
              </div>
            </div>
          </section>

          <%!-- ━━━ Markdown Editor ━━━ --%>
          <section id="markdown-editor-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Markdown Editor</h3>
            <.divider />
            <div class="space-y-8">
              <div>
                <p class="text-xs text-text-muted mb-2">With syntax highlighting & preview toggle</p>
                <.markdown_editor
                  id="demo-md-editor"
                  name="markdown"
                  label="Recipe notes"
                  placeholder="Write markdown..."
                  value={@sample_markdown}
                />
              </div>
            </div>
          </section>
        </div>

        <%!-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
             OVERLAYS & POPOVERS
             ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --%>
        <div class="mt-16 space-y-12">
          <.category_header id="cat-overlays" label="Overlays & Popovers" />

          <%!-- ━━━ Share Sheet ━━━ --%>
          <section id="share-sheet-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Share Sheet</h3>
            <.divider />
            <p class="text-sm text-text-secondary">
              iOS-style sheet with drag-to-dismiss. Supports 10 anchor positions relative to the trigger.
            </p>
            <div class="space-y-4">
              <div>
                <p class="text-xs text-text-muted mb-2">Viewport positions</p>
                <div class="flex flex-wrap gap-3">
                  <.share_sheet
                    :for={{id, pos} <- [{"ss-bottom", "bottom"}, {"ss-center", "center"}]}
                    id={id}
                    position={pos}
                    trigger_label={pos}
                  >
                    <:contact name="Alice" initial="A" color="#c2410c" />
                    <:contact name="Ben" initial="B" color="#166534" />
                    <:action label="Copy Link" icon="hero-link" />
                    <:action label="Send Message" icon="hero-chat-bubble-left" />
                  </.share_sheet>
                </div>
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">Anchored to trigger</p>
                <div class="flex flex-wrap gap-3">
                  <.share_sheet
                    :for={
                      {id, pos} <- [
                        {"ss-ts", "top-start"},
                        {"ss-t", "top"},
                        {"ss-te", "top-end"},
                        {"ss-bs", "bottom-start"},
                        {"ss-bc", "bottom-center"},
                        {"ss-be", "bottom-end"},
                        {"ss-l", "left"},
                        {"ss-r", "right"}
                      ]
                    }
                    id={id}
                    position={pos}
                    trigger_label={pos}
                  >
                    <:action label="Copy Link" icon="hero-link" />
                    <:action label="Send Message" icon="hero-chat-bubble-left" />
                    <:action label="Save to Files" icon="hero-arrow-down-tray" />
                  </.share_sheet>
                </div>
              </div>
            </div>
          </section>

          <%!-- ━━━ Morph Dialog ━━━ --%>
          <section id="morph-dialog-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Morph Dialog</h3>
            <.divider />
            <p class="text-sm text-text-secondary">
              Trigger button morphs into the dialog via FLIP animation. Four position variants.
            </p>
            <div class="flex flex-wrap gap-3">
              <.morph_dialog id="demo-morph-bottom" confirm_label="Receive">
                <:trigger>Bottom</:trigger>
                <:title>
                  <.icon name="hero-question-mark-circle" class="size-6 text-secondary" /> Confirm
                </:title>
                <:body>
                  <p>Dialog anchored to the bottom of the screen. Great for mobile-first flows.</p>
                </:body>
              </.morph_dialog>

              <.morph_dialog id="demo-morph-center" position="center" confirm_label="Got it">
                <:trigger>Center</:trigger>
                <:title>
                  <.icon name="hero-information-circle" class="size-6 text-info" /> Notice
                </:title>
                <:body>
                  <p>Dialog in the center of the viewport. Classic desktop modal feel.</p>
                </:body>
              </.morph_dialog>

              <.morph_dialog id="demo-morph-top" position="top" confirm_label="Dismiss">
                <:trigger>Top</:trigger>
                <:title>
                  <.icon name="hero-bell-alert" class="size-6 text-warning" /> Alert
                </:title>
                <:body>
                  <p>
                    Dialog at the top of the screen. Good for alerts and banners that need attention.
                  </p>
                </:body>
              </.morph_dialog>

              <.morph_dialog
                id="demo-morph-origin"
                position="origin"
                confirm_label="Yes, delete"
                cancel_label="Keep"
              >
                <:trigger>Origin</:trigger>
                <:title>
                  <.icon name="hero-exclamation-triangle" class="size-6 text-error" /> Delete item?
                </:title>
                <:body>
                  <p>Dialog expands right where the trigger is. Keeps the user's focus in context.</p>
                </:body>
              </.morph_dialog>
            </div>
            <.divider label="In-place CTA → Dialog" class="mt-6" />
            <p class="text-sm text-text-secondary">
              The trigger button morphs in-place into a confirmation dialog. Supports up/down direction and edge-aligned width.
            </p>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-6 max-w-2xl">
              <div>
                <p class="text-xs text-text-muted mb-2">Opens down (auto)</p>
                <.morph_dialog
                  id="demo-morph-receive"
                  position="origin"
                  origin_match_width
                  confirm_label="Receive"
                  cancel_label="Cancel"
                  trigger_class="!w-full !max-w-none !py-3 !text-base"
                >
                  <:trigger>Receive</:trigger>
                  <:title>
                    <.icon name="hero-question-mark-circle" class="size-6 text-secondary" /> Confirm
                  </:title>
                  <:body>
                    <p>Are you sure you want to receive a load of money?</p>
                  </:body>
                </.morph_dialog>
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">Opens up</p>
                <.morph_dialog
                  id="demo-morph-receive-up"
                  position="origin"
                  origin_direction="up"
                  origin_match_width
                  confirm_label="Send"
                  cancel_label="Cancel"
                  trigger_class="!w-full !max-w-none !py-3 !text-base"
                >
                  <:trigger>Send Payment</:trigger>
                  <:title>
                    <.icon name="hero-paper-airplane" class="size-6 text-primary" /> Confirm Transfer
                  </:title>
                  <:body>
                    <p>This will send $420 to Alex. This action cannot be undone.</p>
                  </:body>
                </.morph_dialog>
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">Narrow trigger</p>
                <.morph_dialog
                  id="demo-morph-delete-sm"
                  position="origin"
                  confirm_label="Yes, delete"
                  cancel_label="Keep"
                >
                  <:trigger>Delete</:trigger>
                  <:title>
                    <.icon name="hero-trash" class="size-6 text-error" /> Delete item?
                  </:title>
                  <:body>
                    <p>This will permanently remove the recipe and all its history.</p>
                  </:body>
                </.morph_dialog>
              </div>
            </div>
          </section>

          <%!-- ━━━ Overlay / Modal ━━━ --%>
          <section id="overlay-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Overlay (Modal / Sheet / Drawer)</h3>
            <.divider />
            <%!-- Organized by variant with labels --%>
            <div class="space-y-4">
              <div>
                <p class="text-xs font-medium text-text-muted uppercase tracking-wide mb-2">
                  Modal & Sheets
                </p>
                <div class="flex flex-wrap gap-2">
                  <button
                    :for={
                      {id, label} <- [
                        {"demo-modal", "Modal"},
                        {"demo-bottom-sheet", "Bottom Sheet"},
                        {"demo-top-sheet", "Top Sheet"},
                        {"demo-page-sheet", "Page Sheet"}
                      ]
                    }
                    data-commandfor={id}
                    data-command="show-modal"
                    class="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
                  >
                    {label}
                  </button>
                </div>
              </div>
              <div>
                <p class="text-xs font-medium text-text-muted uppercase tracking-wide mb-2">
                  Drawers
                </p>
                <div class="flex flex-wrap gap-2">
                  <button
                    :for={{id, label} <- [{"demo-drawer", "Right"}, {"demo-drawer-left", "Left"}]}
                    data-commandfor={id}
                    data-command="show-modal"
                    class="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
                  >
                    {label}
                  </button>
                </div>
              </div>
              <div>
                <p class="text-xs font-medium text-text-muted uppercase tracking-wide mb-2">
                  Detached Sheet — position & size
                </p>
                <div class="flex flex-wrap gap-2">
                  <button
                    :for={
                      {id, label} <- [
                        {"demo-detached-bottom", "Bottom (sm)"},
                        {"demo-detached-center", "Center (sm)"},
                        {"demo-detached-top", "Top (md)"},
                        {"demo-detached-full", "Full Width"}
                      ]
                    }
                    data-commandfor={id}
                    data-command="show-modal"
                    class="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
                  >
                    {label}
                  </button>
                </div>
              </div>
              <div>
                <p class="text-xs font-medium text-text-muted uppercase tracking-wide mb-2">
                  Special
                </p>
                <div class="flex flex-wrap gap-2">
                  <button
                    :for={
                      {id, label} <- [
                        {"demo-silk-sheet", "Confirmation"},
                        {"demo-silk-top-sheet", "Promo Top"},
                        {"demo-depth-sheet", "Depth Effect"}
                      ]
                    }
                    data-commandfor={id}
                    data-command="show-modal"
                    class="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
                  >
                    {label}
                  </button>
                </div>
              </div>
            </div>

            <.overlay id="demo-modal" variant={:modal} size={:md}>
              <:header>Recipe Details</:header>
              <div class="space-y-3">
                <p class="text-sm text-text-secondary">
                  This is a modal overlay. Click the backdrop, press Escape, or use the close button to dismiss.
                </p>
                <.inline_alert type={:info}>
                  Modals are great for confirmations and focused tasks.
                </.inline_alert>
              </div>
              <:footer>
                <button
                  data-commandfor="demo-modal"
                  data-command="close"
                  class="rounded-md border border-border px-4 py-2 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors"
                >
                  Cancel
                </button>
                <button
                  data-commandfor="demo-modal"
                  data-command="close"
                  class="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
                >
                  Confirm
                </button>
              </:footer>
            </.overlay>

            <.overlay id="demo-bottom-sheet" variant={:bottom_sheet} size={:lg}>
              <:header>Filter Recipes</:header>
              <div class="space-y-4">
                <p class="text-sm text-text-secondary">Swipe down to dismiss on touch devices.</p>
                <.input
                  name="filter_search"
                  type="text"
                  label="Search"
                  value=""
                  placeholder="Filter by name..."
                />
                <div class="flex flex-wrap gap-2">
                  <.badge variant="primary">Baking</.badge>
                  <.badge variant="secondary">Fermentation</.badge>
                  <.badge variant="accent">Molecular</.badge>
                  <.badge>Quick Meals</.badge>
                </div>
              </div>
              <:footer>
                <button
                  data-commandfor="demo-bottom-sheet"
                  data-command="close"
                  class="rounded-md border border-border px-4 py-2 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors"
                >
                  Reset
                </button>
                <button
                  data-commandfor="demo-bottom-sheet"
                  data-command="close"
                  class="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
                >
                  Apply Filters
                </button>
              </:footer>
            </.overlay>

            <%!-- Silk-style confirmation bottom sheet --%>
            <.overlay id="demo-silk-sheet" variant={:bottom_sheet} size={:sm}>
              <div class="flex flex-col items-center text-center px-4 pb-6 pt-2">
                <%!-- Illustration --%>
                <div class="w-36 h-36 rounded-2xl bg-gradient-to-br from-primary/20 via-accent/20 to-secondary/20 flex items-center justify-center mb-6">
                  <div class="relative">
                    <.icon name="hero-calendar-days" class="size-16 text-primary" />
                    <div class="absolute -bottom-1 -right-1 size-7 rounded-full bg-success flex items-center justify-center ring-4 ring-surface">
                      <.icon name="hero-check-mini" class="size-4 text-white" />
                    </div>
                  </div>
                </div>
                <%!-- Title --%>
                <h3 class="text-xl font-bold text-text mb-2">Recipe Added<br />to Your Meal Plan</h3>
                <%!-- Description --%>
                <p class="text-sm text-text-muted leading-relaxed max-w-[280px] mb-8">
                  Your recipe has been scheduled for Wednesday. We'll send you a reminder with the shopping list.
                </p>
                <%!-- CTA button --%>
                <button
                  data-commandfor="demo-silk-sheet"
                  data-command="close"
                  class="w-full max-w-[280px] rounded-full bg-text text-surface px-6 py-3.5 text-sm font-semibold cursor-pointer hover:opacity-90 transition-opacity active:scale-[0.97]"
                >
                  Got it
                </button>
              </div>
            </.overlay>

            <.overlay id="demo-drawer" variant={:drawer_right} size={:sm}>
              <:header>Settings</:header>
              <div class="space-y-4">
                <.toggle label="Email notifications" description="Get notified about new recipes" />
                <.toggle label="Weekly digest" />
                <.divider />
                <.toggle label="Public profile" description="Allow others to see your activity" />
              </div>
            </.overlay>

            <.overlay id="demo-drawer-left" variant={:drawer_left} size={:sm}>
              <:header>Navigation</:header>
              <nav class="space-y-1">
                <a
                  href="/"
                  class="flex items-center gap-3 px-3 py-2.5 text-sm font-medium rounded-md bg-surface-hover text-text"
                >
                  <.icon name="hero-home" class="size-4" /> Home
                </a>
                <a
                  href="/recipes"
                  class="flex items-center gap-3 px-3 py-2.5 text-sm font-medium rounded-md text-text-secondary hover:bg-surface-hover hover:text-text transition-colors"
                >
                  <.icon name="hero-book-open" class="size-4" /> Recipes
                </a>
                <a
                  href="/news"
                  class="flex items-center gap-3 px-3 py-2.5 text-sm font-medium rounded-md text-text-secondary hover:bg-surface-hover hover:text-text transition-colors"
                >
                  <.icon name="hero-newspaper" class="size-4" /> News
                </a>
                <a
                  href="/research"
                  class="flex items-center gap-3 px-3 py-2.5 text-sm font-medium rounded-md text-text-secondary hover:bg-surface-hover hover:text-text transition-colors"
                >
                  <.icon name="hero-beaker" class="size-4" /> Research
                </a>
              </nav>
            </.overlay>

            <.overlay id="demo-top-sheet" variant={:top_sheet} size={:lg}>
              <:header>Announcements</:header>
              <div class="space-y-3">
                <.inline_alert type={:info}>
                  New recipe collections are published every Monday.
                </.inline_alert>
                <.inline_alert type={:warning}>
                  Scheduled maintenance this Sunday, 2am-4am UTC.
                </.inline_alert>
              </div>
            </.overlay>

            <%!-- Silk-style promotional top sheet --%>
            <.overlay id="demo-silk-top-sheet" variant={:top_sheet} size={:md}>
              <div class="flex flex-col items-center text-center px-6 pb-8 pt-4 relative">
                <%!-- Close button --%>
                <button
                  data-commandfor="demo-silk-top-sheet"
                  data-command="close"
                  class="absolute top-2 right-2 size-8 rounded-full bg-surface-alt flex items-center justify-center text-text-muted hover:text-text hover:bg-surface-hover transition-colors cursor-pointer"
                  aria-label="Close"
                >
                  <.icon name="hero-x-mark-mini" class="size-4" />
                </button>
                <%!-- Title --%>
                <h3 class="text-2xl font-bold text-text leading-tight mb-5 mt-2">
                  New Collection<br />is Available
                </h3>
                <%!-- Illustration --%>
                <div class="w-48 h-36 rounded-2xl bg-gradient-to-br from-amber-100 via-orange-100 to-rose-100 dark:from-amber-900/30 dark:via-orange-900/30 dark:to-rose-900/30 flex items-center justify-center mb-5 overflow-hidden">
                  <div class="flex items-end gap-1">
                    <div class="w-10 h-20 rounded-t-xl bg-amber-400/80 dark:bg-amber-600/60" />
                    <div class="w-10 h-28 rounded-t-xl bg-orange-400/80 dark:bg-orange-600/60" />
                    <div class="w-10 h-16 rounded-t-xl bg-rose-400/80 dark:bg-rose-600/60" />
                    <div class="w-10 h-24 rounded-t-xl bg-amber-500/80 dark:bg-amber-700/60" />
                  </div>
                </div>
                <%!-- Description --%>
                <p class="text-sm text-text-muted leading-relaxed max-w-[300px] mb-6">
                  Your weekly fermentation recipes are ready. A curated blend of sourdough, kimchi, and kombucha — don't miss it!
                </p>
                <%!-- CTA --%>
                <button
                  data-commandfor="demo-silk-top-sheet"
                  data-command="close"
                  class="rounded-full bg-text text-surface px-8 py-3.5 text-sm font-semibold cursor-pointer hover:opacity-90 transition-opacity active:scale-[0.97]"
                >
                  Browse Now
                </button>
              </div>
            </.overlay>

            <.overlay id="demo-page-sheet" variant={:page_sheet} size={:full}>
              <:header>Recipe Editor</:header>
              <div class="space-y-6">
                <p class="text-sm text-text-secondary">
                  This is a full page sheet — ideal for complex sub-flows that need maximum space.
                </p>
                <.input
                  name="recipe_title"
                  type="text"
                  label="Recipe Title"
                  value=""
                  placeholder="Enter recipe name..."
                />
                <.input
                  name="recipe_desc"
                  type="textarea"
                  label="Description"
                  value=""
                  placeholder="Describe your recipe..."
                />
                <div class="grid grid-cols-2 gap-4">
                  <.input
                    name="prep_time"
                    type="text"
                    label="Prep Time"
                    value=""
                    placeholder="e.g. 30 min"
                  />
                  <.input
                    name="cook_time"
                    type="text"
                    label="Cook Time"
                    value=""
                    placeholder="e.g. 1 hour"
                  />
                </div>
                <.progress value={35} label="Completion" show_value />
                <.steps>
                  <:step label="Basics" status={:complete} />
                  <:step label="Ingredients" status={:current} />
                  <:step label="Instructions" status={:upcoming} />
                  <:step label="Review" status={:upcoming} />
                </.steps>
              </div>
              <:footer>
                <button
                  data-commandfor="demo-page-sheet"
                  data-command="close"
                  class="rounded-md border border-border px-4 py-2 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors"
                >
                  Discard
                </button>
                <button
                  data-commandfor="demo-page-sheet"
                  data-command="close"
                  class="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
                >
                  Save Draft
                </button>
              </:footer>
            </.overlay>

            <%!-- ── Detached Bottom (sm) ─────────────────── --%>
            <.overlay id="demo-detached-bottom" variant={:detached_sheet} size={:sm}>
              <div class="flex flex-col items-center text-center px-4 pb-6 pt-2">
                <div class="w-28 h-28 rounded-2xl bg-gradient-to-br from-primary/15 via-accent/15 to-secondary/15 flex items-center justify-center mb-5">
                  <.icon name="hero-share" class="size-12 text-primary" />
                </div>
                <h3 class="text-lg font-bold text-text mb-2">Share Recipe</h3>
                <p class="text-sm text-text-muted leading-relaxed max-w-[260px] mb-6">
                  Send this recipe to friends or save it to your collection.
                </p>
                <div class="flex gap-3 w-full max-w-[280px]">
                  <button
                    data-commandfor="demo-detached-bottom"
                    data-command="close"
                    class="flex-1 rounded-xl bg-surface-alt px-4 py-3 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    data-commandfor="demo-detached-bottom"
                    data-command="close"
                    class="flex-1 rounded-xl bg-primary px-4 py-3 text-sm font-semibold text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.97]"
                  >
                    Share
                  </button>
                </div>
              </div>
            </.overlay>

            <%!-- ── Detached Center (sm) ──────────── --%>
            <.overlay id="demo-detached-center" variant={:detached_sheet} size={:sm} position="center">
              <div class="flex flex-col items-center text-center px-6 pb-8 pt-4">
                <img
                  src="https://picsum.photos/seed/meal/400/300"
                  alt="Meal"
                  class="w-48 h-36 rounded-2xl object-cover mb-6"
                  loading="lazy"
                />
                <h3 class="text-xl font-bold text-text mb-2">Your Meal is Coming</h3>
                <p class="text-sm text-text-muted leading-relaxed max-w-[280px] mb-8">
                  Your food is on its way and will arrive soon! Sit back and get ready to enjoy your meal.
                </p>
                <button
                  data-commandfor="demo-detached-center"
                  data-command="close"
                  class="rounded-full bg-text text-surface px-8 py-3.5 text-sm font-semibold cursor-pointer hover:opacity-90 transition-opacity active:scale-[0.97]"
                >
                  Got it
                </button>
              </div>
            </.overlay>

            <%!-- ── Detached Top (md) ──────────── --%>
            <.overlay id="demo-detached-top" variant={:detached_sheet} size={:md} position="top">
              <:header>System Update</:header>
              <div class="space-y-3">
                <.inline_alert type={:info}>
                  A new version of Aya is available. Update now for the latest recipes and features.
                </.inline_alert>
                <p class="text-sm text-text-secondary">
                  Version 2.4.0 includes faster search, improved meal planning, and 50+ new recipes.
                </p>
              </div>
              <:footer>
                <button
                  data-commandfor="demo-detached-top"
                  data-command="close"
                  class="rounded-md border border-border px-4 py-2 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors"
                >
                  Later
                </button>
                <button
                  data-commandfor="demo-detached-top"
                  data-command="close"
                  class="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
                >
                  Update Now
                </button>
              </:footer>
            </.overlay>

            <%!-- ── Detached Full-width Bottom ──────────── --%>
            <.overlay id="demo-detached-full" variant={:detached_sheet} size={:full}>
              <:header>Quick Actions</:header>
              <div class="grid grid-cols-4 gap-4 py-2">
                <button
                  :for={
                    action <- [
                      {"hero-camera", "Camera"},
                      {"hero-photo", "Gallery"},
                      {"hero-document-text", "Document"},
                      {"hero-map-pin", "Location"}
                    ]
                  }
                  data-commandfor="demo-detached-full"
                  data-command="close"
                  class="flex flex-col items-center gap-2 py-3 rounded-xl hover:bg-surface-hover transition-colors cursor-pointer"
                >
                  <div class="size-12 rounded-full bg-primary/10 flex items-center justify-center">
                    <.icon name={elem(action, 0)} class="size-6 text-primary" />
                  </div>
                  <span class="text-xs font-medium text-text">{elem(action, 1)}</span>
                </button>
              </div>
            </.overlay>

            <%!-- ── Sheet with depth (scaled background) ─────────── --%>
            <.overlay id="demo-depth-sheet" variant={:bottom_sheet} size={:md} depth>
              <div class="flex flex-col items-center text-center px-4 pb-6 pt-2">
                <%!-- Illustration --%>
                <div class="w-40 h-40 rounded-3xl bg-gradient-to-br from-emerald-100 via-teal-100 to-cyan-100 dark:from-emerald-900/30 dark:via-teal-900/30 dark:to-cyan-900/30 flex items-center justify-center mb-5">
                  <div class="relative">
                    <.icon
                      name="hero-check-badge"
                      class="size-20 text-emerald-500 dark:text-emerald-400"
                    />
                  </div>
                </div>
                <%!-- Title --%>
                <h3 class="text-xl font-bold text-text mb-2">Order Confirmed</h3>
                <%!-- Description --%>
                <p class="text-sm text-text-muted leading-relaxed max-w-[300px] mb-6">
                  Your ingredient box is on its way. Fresh sourdough flour, heritage grains, and artisan salt — arriving tomorrow by noon.
                </p>
                <%!-- Stats row --%>
                <div class="flex gap-6 mb-6">
                  <div class="text-center">
                    <p class="text-lg font-semibold text-text">4</p>
                    <p class="text-xs text-text-muted">Items</p>
                  </div>
                  <div class="text-center">
                    <p class="text-lg font-semibold text-text">2.4 kg</p>
                    <p class="text-xs text-text-muted">Total weight</p>
                  </div>
                  <div class="text-center">
                    <p class="text-lg font-semibold text-text">12h</p>
                    <p class="text-xs text-text-muted">Delivery</p>
                  </div>
                </div>
                <%!-- CTA --%>
                <button
                  data-commandfor="demo-depth-sheet"
                  data-command="close"
                  class="w-full max-w-[280px] rounded-full bg-text text-surface px-6 py-3.5 text-sm font-semibold cursor-pointer hover:opacity-90 transition-opacity active:scale-[0.97]"
                >
                  Track Order
                </button>
                <button
                  data-commandfor="demo-depth-sheet"
                  data-command="close"
                  class="mt-2 text-sm text-text-muted hover:text-text transition-colors cursor-pointer"
                >
                  Dismiss
                </button>
              </div>
            </.overlay>

            <%!-- ── Nested drawers demo ────────────────────────────── --%>
            <.divider label="Nested Drawers" class="mt-6" />
            <p class="text-sm text-text-secondary">
              Drawers can open other drawers. Each layer stacks independently.
            </p>
            <div class="flex flex-wrap gap-3">
              <button
                data-commandfor="nested-drawer-1"
                data-command="show-modal"
                class="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
              >
                Nested Drawers (Right)
              </button>
              <button
                data-commandfor="nested-sheet-1"
                data-command="show-modal"
                class="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
              >
                Nested Sheets (Bottom)
              </button>
              <button
                data-commandfor="nested-mixed-1"
                data-command="show-modal"
                class="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
              >
                Mixed (Sheet → Modal → Drawer)
              </button>
            </div>

            <%!-- Nested right drawers: 3 levels deep --%>
            <.overlay id="nested-drawer-1" variant={:drawer_right} size={:md}>
              <:header>Account Settings</:header>
              <div class="space-y-4">
                <p class="text-sm text-text-secondary">
                  Level 1 — Main settings panel. Open a sub-drawer for details.
                </p>
                <.list>
                  <:item title="Email">arpit@example.com</:item>
                  <:item title="Plan">Pro</:item>
                  <:item title="Member since">March 2024</:item>
                </.list>
                <.divider />
                <button
                  data-commandfor="nested-drawer-2"
                  data-command="show-modal"
                  class="rounded-md bg-surface-alt border border-border px-4 py-2 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors flex items-center gap-2 w-full justify-between"
                >
                  Notification Preferences
                  <.icon name="hero-chevron-right-mini" class="size-4 text-text-muted" />
                </button>
                <button
                  data-commandfor="nested-drawer-2b"
                  data-command="show-modal"
                  class="rounded-md bg-surface-alt border border-border px-4 py-2 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors flex items-center gap-2 w-full justify-between"
                >
                  Privacy & Security
                  <.icon name="hero-chevron-right-mini" class="size-4 text-text-muted" />
                </button>
              </div>
            </.overlay>

            <.overlay id="nested-drawer-2" variant={:drawer_right} size={:sm}>
              <:header>Notification Preferences</:header>
              <div class="space-y-4">
                <p class="text-sm text-text-secondary">Level 2 — Nested inside Account Settings.</p>
                <.toggle label="Email notifications" description="Weekly digest and updates" />
                <.toggle label="Push notifications" description="Real-time alerts on your device" />
                <.toggle label="Recipe comments" description="When someone comments on your recipe" />
                <.divider />
                <button
                  data-commandfor="nested-drawer-3"
                  data-command="show-modal"
                  class="rounded-md bg-surface-alt border border-border px-4 py-2 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors flex items-center gap-2 w-full justify-between"
                >
                  Advanced Filters
                  <.icon name="hero-chevron-right-mini" class="size-4 text-text-muted" />
                </button>
              </div>
            </.overlay>

            <.overlay id="nested-drawer-2b" variant={:drawer_right} size={:sm}>
              <:header>Privacy & Security</:header>
              <div class="space-y-4">
                <p class="text-sm text-text-secondary">
                  Level 2 — Alternative path from Account Settings.
                </p>
                <.toggle label="Public profile" description="Allow others to see your activity" />
                <.toggle label="Two-factor auth" description="Add an extra layer of security" />
                <.toggle label="Data export" description="Download a copy of your data" />
              </div>
            </.overlay>

            <.overlay id="nested-drawer-3" variant={:drawer_right} size={:sm}>
              <:header>Advanced Filters</:header>
              <div class="space-y-4">
                <p class="text-sm text-text-secondary">Level 3 — Three drawers deep!</p>
                <.input
                  name="filter_keyword"
                  type="text"
                  label="Keyword filter"
                  value=""
                  placeholder="e.g. sourdough"
                />
                <.input
                  name="filter_category"
                  type="select"
                  label="Category"
                  value=""
                  prompt="All categories"
                  options={["Baking", "Fermentation", "Molecular", "Quick Meals"]}
                />
                <.inline_alert type={:info}>
                  These filters apply to all notification channels.
                </.inline_alert>
              </div>
              <:footer>
                <button
                  data-commandfor="nested-drawer-3"
                  data-command="close"
                  class="rounded-md border border-border px-4 py-2 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors"
                >
                  Cancel
                </button>
                <button
                  data-commandfor="nested-drawer-3"
                  data-command="close"
                  class="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
                >
                  Apply
                </button>
              </:footer>
            </.overlay>

            <%!-- Nested bottom sheets: 2 levels --%>
            <.overlay id="nested-sheet-1" variant={:bottom_sheet} size={:lg}>
              <:header>Select Category</:header>
              <div class="space-y-2">
                <p class="text-sm text-text-secondary">Level 1 — Pick a category, then refine.</p>
                <div class="grid grid-cols-2 gap-2">
                  <button
                    :for={
                      cat <- ["Baking", "Soups", "Salads", "Desserts", "Fermentation", "Molecular"]
                    }
                    data-commandfor="nested-sheet-2"
                    data-command="show-modal"
                    class="rounded-lg border border-border p-4 text-left text-sm font-medium text-text hover:bg-surface-hover transition-colors cursor-pointer"
                  >
                    {cat}
                    <span class="block text-xs text-text-muted mt-0.5">12 recipes</span>
                  </button>
                </div>
              </div>
            </.overlay>

            <.overlay id="nested-sheet-2" variant={:bottom_sheet} size={:lg}>
              <:header>Refine Selection</:header>
              <div class="space-y-4">
                <p class="text-sm text-text-secondary">
                  Level 2 — Nested sheet on top of the category picker.
                </p>
                <div class="flex flex-wrap gap-2">
                  <.badge variant="primary">Beginner</.badge>
                  <.badge variant="secondary">Under 30 min</.badge>
                  <.badge variant="accent">Vegetarian</.badge>
                  <.badge>Gluten-free</.badge>
                </div>
                <.input
                  name="nested_search"
                  type="text"
                  label="Search within category"
                  value=""
                  placeholder="Filter recipes..."
                />
              </div>
              <:footer>
                <button
                  data-commandfor="nested-sheet-2"
                  data-command="close"
                  class="rounded-md border border-border px-4 py-2 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors"
                >
                  Back
                </button>
                <button
                  data-commandfor="nested-sheet-2"
                  data-command="close"
                  class="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
                >
                  Show Results
                </button>
              </:footer>
            </.overlay>

            <%!-- Mixed nesting: bottom sheet → modal → drawer --%>
            <.overlay id="nested-mixed-1" variant={:bottom_sheet} size={:lg}>
              <:header>Share Recipe</:header>
              <div class="space-y-3">
                <p class="text-sm text-text-secondary">
                  Level 1 (Bottom Sheet) — Choose how to share.
                </p>
                <div class="grid grid-cols-3 gap-3">
                  <button class="flex flex-col items-center gap-2 rounded-lg border border-border p-4 text-sm text-text hover:bg-surface-hover transition-colors cursor-pointer">
                    <.icon name="hero-link" class="size-5 text-text-muted" /> Copy Link
                  </button>
                  <button class="flex flex-col items-center gap-2 rounded-lg border border-border p-4 text-sm text-text hover:bg-surface-hover transition-colors cursor-pointer">
                    <.icon name="hero-envelope" class="size-5 text-text-muted" /> Email
                  </button>
                  <button
                    data-commandfor="nested-mixed-2"
                    data-command="show-modal"
                    class="flex flex-col items-center gap-2 rounded-lg border border-border p-4 text-sm text-text hover:bg-surface-hover transition-colors cursor-pointer"
                  >
                    <.icon name="hero-cog-6-tooth" class="size-5 text-text-muted" /> Advanced
                  </button>
                </div>
              </div>
            </.overlay>

            <.overlay id="nested-mixed-2" variant={:modal} size={:sm}>
              <:header>Share Settings</:header>
              <div class="space-y-4">
                <p class="text-sm text-text-secondary">
                  Level 2 (Modal) — Configure sharing options.
                </p>
                <.toggle label="Allow comments" />
                <.toggle label="Allow remixing" description="Others can create variations" />
                <.divider />
                <button
                  data-commandfor="nested-mixed-3"
                  data-command="show-modal"
                  class="text-sm text-link hover:text-link-hover transition-colors cursor-pointer flex items-center gap-1"
                >
                  Manage permissions <.icon name="hero-arrow-right-mini" class="size-4" />
                </button>
              </div>
              <:footer>
                <button
                  data-commandfor="nested-mixed-2"
                  data-command="close"
                  class="rounded-md border border-border px-4 py-2 text-sm font-medium text-text cursor-pointer hover:bg-surface-hover transition-colors"
                >
                  Cancel
                </button>
                <button
                  data-commandfor="nested-mixed-2"
                  data-command="close"
                  class="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
                >
                  Share
                </button>
              </:footer>
            </.overlay>

            <.overlay id="nested-mixed-3" variant={:drawer_right} size={:sm}>
              <:header>Permissions</:header>
              <div class="space-y-4">
                <p class="text-sm text-text-secondary">Level 3 (Drawer) — Sheet → Modal → Drawer.</p>
                <.list>
                  <:item title="Owner">You (full access)</:item>
                  <:item title="Editors">2 people</:item>
                  <:item title="Viewers">Public</:item>
                </.list>
                <.inline_alert type={:success}>
                  Three levels of different overlay types stacked together.
                </.inline_alert>
              </div>
            </.overlay>
          </section>

          <%!-- ━━━ Family Dialog ━━━ --%>
          <section id="family-dialog-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Family Dialog</h3>
            <.divider />
            <p class="text-sm text-text-secondary">
              Click a list item to expand it into a dialog card with View Transitions.
            </p>
            <.family_dialog id="demo-family-dialog">
              <:item
                id="sourdough"
                title="Sourdough Bread"
                subtitle="Baking · 4 hours"
                image="https://picsum.photos/seed/sourdough2/80/80"
              >
                <p>
                  A classic artisan bread with a crispy crust and chewy interior. Requires an active sourdough starter and patience for bulk fermentation.
                </p>
                <p>Tip: cold retard in the fridge overnight for complex flavor development.</p>
              </:item>
              <:item
                id="ramen"
                title="Miso Ramen"
                subtitle="Soup · 45 min"
                image="https://picsum.photos/seed/ramen2/80/80"
              >
                <p>Rich, umami-packed broth with handmade noodles. A bowl of comfort on cold days.</p>
                <p>
                  Use white miso for a milder flavor or red miso for depth. Top with soft-boiled egg, nori, and scallions.
                </p>
              </:item>
              <:item
                id="kimchi"
                title="Kimchi Fried Rice"
                subtitle="Quick · 15 min"
                image="https://picsum.photos/seed/kimchi2/80/80"
              >
                <p>
                  Quick weeknight dinner using leftover rice and aged kimchi. The key is high heat and not stirring too much — you want crispy bits.
                </p>
              </:item>
              <:item
                id="mousse"
                title="Chocolate Mousse"
                subtitle="Dessert · 30 min"
                image="https://picsum.photos/seed/mousse2/80/80"
              >
                <p>
                  Silky, rich chocolate mousse made with just dark chocolate, eggs, and a pinch of salt. No cream needed.
                </p>
                <p>Chill for at least 2 hours. Serve with whipped cream and shaved chocolate.</p>
              </:item>
            </.family_dialog>

            <.divider label="As Accordion" class="mt-6" />
            <p class="text-sm text-text-secondary">
              Same data as inline accordions — with and without images.
            </p>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 max-w-2xl">
              <div>
                <p class="text-xs text-text-muted mb-2">With images (family dialog style)</p>
                <.accordion variant="card" id="family-img-acc" exclusive>
                  <:item
                    title="Sourdough Bread"
                    subtitle="Baking · 4 hours"
                    image="https://picsum.photos/seed/sourdough2/80/80"
                    open
                  >
                    <p>
                      A classic artisan bread with a crispy crust and chewy interior. Requires an active sourdough starter and patience for bulk fermentation.
                    </p>
                  </:item>
                  <:item
                    title="Miso Ramen"
                    subtitle="Soup · 45 min"
                    image="https://picsum.photos/seed/ramen2/80/80"
                  >
                    <p>
                      Rich, umami-packed broth with handmade noodles. A bowl of comfort on cold days.
                    </p>
                  </:item>
                  <:item
                    title="Kimchi Fried Rice"
                    subtitle="Quick · 15 min"
                    image="https://picsum.photos/seed/kimchi2/80/80"
                  >
                    <p>
                      Quick weeknight dinner using leftover rice and aged kimchi. High heat, don't stir too much.
                    </p>
                  </:item>
                  <:item
                    title="Chocolate Mousse"
                    subtitle="Dessert · 30 min"
                    image="https://picsum.photos/seed/mousse2/80/80"
                  >
                    <p>
                      Silky, rich chocolate mousse made with just dark chocolate, eggs, and a pinch of salt.
                    </p>
                  </:item>
                </.accordion>
              </div>
              <div>
                <p class="text-xs text-text-muted mb-2">Separated cards with images</p>
                <.accordion variant="separated" id="family-sep-acc" exclusive>
                  <:item
                    title="Sourdough Bread"
                    subtitle="Baking · 4 hours"
                    image="https://picsum.photos/seed/sourdough2/80/80"
                    open
                  >
                    <p>
                      A classic artisan bread with a crispy crust and chewy interior. Requires an active sourdough starter.
                    </p>
                    <p>Tip: cold retard in the fridge overnight for complex flavor development.</p>
                  </:item>
                  <:item
                    title="Miso Ramen"
                    subtitle="Soup · 45 min"
                    image="https://picsum.photos/seed/ramen2/80/80"
                  >
                    <p>
                      Rich, umami-packed broth with handmade noodles. Use white miso for milder flavor or red miso for depth.
                    </p>
                  </:item>
                  <:item
                    title="Kimchi Fried Rice"
                    subtitle="Quick · 15 min"
                    image="https://picsum.photos/seed/kimchi2/80/80"
                  >
                    <p>Quick weeknight dinner using leftover rice and aged kimchi.</p>
                  </:item>
                  <:item
                    title="Chocolate Mousse"
                    subtitle="Dessert · 30 min"
                    image="https://picsum.photos/seed/mousse2/80/80"
                  >
                    <p>Silky, rich chocolate mousse. Chill 2 hours, serve with whipped cream.</p>
                  </:item>
                </.accordion>
              </div>
            </div>

            <.divider label="CTA → Dialog → CTA" class="mt-6" />
            <p class="text-sm text-text-secondary">
              Full-width action buttons that morph into confirmation dialogs and back.
            </p>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 max-w-lg">
              <.morph_dialog
                id="fd-send"
                morph_cta
                position="origin"
                origin_direction="down"
                origin_match_width
                confirm_label="Send Money"
                cancel_label="Cancel"
                trigger_class="!w-full !max-w-none !py-3.5 !text-base !rounded-xl"
              >
                <:trigger>Send Money</:trigger>
                <:title>
                  <.icon name="hero-paper-airplane" class="size-6 text-primary" /> Confirm Transfer
                </:title>
                <:body>
                  <p>Send $420 to Alex. This cannot be undone.</p>
                </:body>
              </.morph_dialog>

              <.morph_dialog
                id="fd-receive"
                morph_cta
                position="origin"
                origin_direction="down"
                origin_match_width
                confirm_label="Receive Payment"
                cancel_label="Decline"
                trigger_class="!w-full !max-w-none !py-3.5 !text-base !rounded-xl !bg-secondary !text-secondary-text hover:!bg-secondary-hover"
                confirm_class="!bg-secondary !text-secondary-text"
              >
                <:trigger>Receive Payment</:trigger>
                <:title>
                  <.icon name="hero-arrow-down-tray" class="size-6 text-secondary" />
                  Incoming Transfer
                </:title>
                <:body>
                  <p>Alex is sending you $420. Accept this payment?</p>
                </:body>
              </.morph_dialog>

              <.morph_dialog
                id="fd-subscribe"
                morph_cta
                position="origin"
                origin_direction="up"
                origin_match_width
                width={340}
                confirm_label="Subscribe"
                cancel_label="Not now"
                trigger_class="!w-full !max-w-none !py-3.5 !text-base !rounded-xl !bg-text !text-surface hover:!opacity-90"
                confirm_class="!bg-text !text-surface"
              >
                <:trigger>Upgrade to Pro</:trigger>
                <:title>
                  <.icon name="hero-sparkles" class="size-6 text-accent" /> Go Pro
                </:title>
                <:body>
                  <p>Unlimited recipes, meal planning, and AI suggestions. $9/mo, cancel anytime.</p>
                </:body>
              </.morph_dialog>

              <.morph_dialog
                id="fd-delete"
                morph_cta
                position="origin"
                origin_direction="up"
                origin_match_width
                width={340}
                confirm_label="Delete"
                cancel_label="Keep"
                trigger_class="!w-full !max-w-none !py-3.5 !text-base !rounded-xl !bg-error !text-white hover:!opacity-90"
                confirm_class="!bg-error !text-white"
              >
                <:trigger>Delete Account</:trigger>
                <:title>
                  <.icon name="hero-exclamation-triangle" class="size-6 text-error" /> Are you sure?
                </:title>
                <:body>
                  <p>This permanently deletes your account and all data.</p>
                </:body>
              </.morph_dialog>
            </div>
          </section>

          <%!-- ━━━ Hover Card ━━━ --%>
          <section id="hover-card-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Hover Card</h3>
            <.divider />
            <p class="text-sm text-text-secondary">
              Rich content that appears on hover/focus. Card and sheet variants with 4 placements.
            </p>
            <div class="space-y-6">
              <div>
                <p class="text-xs text-text-muted mb-3">Card — placements</p>
                <div class="flex flex-wrap items-center gap-6">
                  <.hover_card
                    :for={
                      {p, label} <- [
                        {"bottom", "Bottom"},
                        {"top", "Top"},
                        {"left", "Left"},
                        {"right", "Right"}
                      ]
                    }
                    placement={p}
                  >
                    <:trigger>
                      <span class="text-sm font-medium text-primary underline decoration-dotted underline-offset-4">
                        {label}
                      </span>
                    </:trigger>
                    <:content>
                      <div class="flex gap-3">
                        <div class="size-10 rounded-full bg-primary-soft flex items-center justify-center shrink-0">
                          <span class="text-sm font-bold text-primary">AB</span>
                        </div>
                        <div>
                          <p class="text-sm font-semibold text-text">Alice Baker</p>
                          <p class="text-xs text-text-muted">Chef · 128 recipes</p>
                        </div>
                      </div>
                    </:content>
                  </.hover_card>
                </div>
              </div>
              <div>
                <p class="text-xs text-text-muted mb-3">Sheet — rich preview</p>
                <div class="flex flex-wrap items-center gap-6">
                  <.hover_card variant="sheet" width="w-80">
                    <:trigger>
                      <span class="text-sm font-medium text-primary underline decoration-dotted underline-offset-4">
                        Sourdough Bread
                      </span>
                    </:trigger>
                    <:content>
                      <div class="space-y-3">
                        <img
                          src="https://picsum.photos/seed/sourdough2/400/150"
                          class="w-full h-28 rounded-lg object-cover outline-none"
                          alt=""
                        />
                        <h4 class="text-sm font-bold text-text">Sourdough Bread</h4>
                        <p class="text-xs text-text-secondary">
                          A classic artisan bread with crispy crust and chewy interior. Requires an active sourdough starter.
                        </p>
                        <div class="flex gap-1.5">
                          <span class="px-2 py-0.5 text-[0.625rem] font-medium rounded-full bg-secondary-soft text-secondary">
                            Baking
                          </span>
                          <span class="px-2 py-0.5 text-[0.625rem] font-medium rounded-full bg-accent-soft text-accent">
                            4 hours
                          </span>
                        </div>
                      </div>
                    </:content>
                  </.hover_card>
                  <.hover_card variant="sheet" placement="right" width="w-72">
                    <:trigger>
                      <span class="text-sm font-medium text-primary underline decoration-dotted underline-offset-4">
                        web-prod-01
                      </span>
                    </:trigger>
                    <:content>
                      <div class="space-y-2">
                        <div class="flex items-center justify-between">
                          <span class="text-sm font-bold text-text">web-prod-01</span>
                          <span class="px-1.5 py-0.5 text-[0.625rem] font-medium rounded-full bg-success-soft text-success">
                            Healthy
                          </span>
                        </div>
                        <div class="grid grid-cols-3 gap-2 text-center">
                          <div class="rounded bg-surface-alt p-1.5">
                            <p class="text-sm font-semibold text-text">24%</p>
                            <p class="text-[0.625rem] text-text-muted">CPU</p>
                          </div>
                          <div class="rounded bg-surface-alt p-1.5">
                            <p class="text-sm font-semibold text-text">1.2G</p>
                            <p class="text-[0.625rem] text-text-muted">RAM</p>
                          </div>
                          <div class="rounded bg-surface-alt p-1.5">
                            <p class="text-sm font-semibold text-text">99.9%</p>
                            <p class="text-[0.625rem] text-text-muted">Up</p>
                          </div>
                        </div>
                        <p class="text-xs text-text-muted">us-east-1 · Phoenix 1.8</p>
                      </div>
                    </:content>
                  </.hover_card>
                </div>
              </div>
            </div>
          </section>

          <%!-- ━━━ Drawer ━━━ --%>
          <section id="drawer-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Drawer</h3>
            <.divider />
            <div class="flex flex-wrap items-center gap-3">
              <button
                :for={
                  {id, label} <- [
                    {"sc-drawer-right", "Right"},
                    {"sc-drawer-left", "Left"},
                    {"sc-drawer-bottom", "Bottom"}
                  ]
                }
                data-commandfor={id}
                data-command="show-modal"
                class="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-text cursor-pointer hover:bg-primary-hover transition-colors active:scale-[0.96]"
              >
                {label}
              </button>
            </div>

            <%!-- Right drawer --%>
            <.overlay id="sc-drawer-right" variant={:drawer_right} class="w-96">
              <:header>
                <div class="flex flex-col gap-0.5">
                  <span class="text-base font-semibold">Filters</span>
                  <span class="text-sm text-text-muted">Refine your recipe search.</span>
                </div>
              </:header>
              <div class="space-y-4">
                <.input
                  name="cuisine"
                  label="Cuisine"
                  type="select"
                  options={["Any", "French", "Italian", "Japanese", "Mexican"]}
                  value="Any"
                />
                <.input
                  name="difficulty"
                  label="Difficulty"
                  type="select"
                  options={["Any", "Easy", "Intermediate", "Advanced"]}
                  value="Any"
                />
              </div>
              <:footer>
                <div class="flex gap-3">
                  <.button variant="primary" size="sm">Apply filters</.button>
                  <.button variant="ghost" size="sm">Reset</.button>
                </div>
              </:footer>
            </.overlay>

            <%!-- Left drawer --%>
            <.overlay id="sc-drawer-left" variant={:drawer_left} class="w-72">
              <:header>
                <span class="text-base font-semibold">Navigation</span>
              </:header>
              <nav class="space-y-1">
                <a
                  :for={item <- ["Home", "Recipes", "Ingredients", "Research", "Settings"]}
                  href="#"
                  class="block px-3 py-2 text-sm text-text-secondary hover:text-text hover:bg-surface-hover rounded-md transition-colors"
                >
                  {item}
                </a>
              </nav>
            </.overlay>

            <%!-- Bottom sheet --%>
            <.overlay id="sc-drawer-bottom" variant={:bottom_sheet}>
              <:header>
                <span class="text-base font-semibold">Quick actions</span>
              </:header>
              <div class="grid grid-cols-3 gap-3 text-center">
                <div
                  :for={
                    {icon, label} <- [
                      {"hero-camera", "Photo"},
                      {"hero-book-open", "Recipe"},
                      {"hero-beaker", "Experiment"},
                      {"hero-clipboard-document-list", "List"},
                      {"hero-share", "Share"},
                      {"hero-bookmark", "Save"}
                    ]
                  }
                  class="flex flex-col items-center gap-2 p-3 rounded-lg hover:bg-surface-hover cursor-pointer transition-colors"
                >
                  <.icon name={icon} class="size-6 text-text-secondary" />
                  <span class="text-xs text-text-secondary">{label}</span>
                </div>
              </div>
            </.overlay>
          </section>

          <%!-- ━━━ Dropdown ━━━ --%>
          <section id="dropdown-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Dropdown</h3>
            <.divider />
            <div class="flex gap-4">
              <.dropdown id="demo-dropdown">
                <:trigger>
                  <.button variant="soft" size="sm">
                    Actions <.icon name="hero-chevron-down-mini" class="size-4 ml-1" />
                  </.button>
                </:trigger>
                <:item icon="hero-pencil">Edit</:item>
                <:item icon="hero-document-duplicate">Duplicate</:item>
                <:item icon="hero-arrow-down-tray">Export</:item>
                <:item icon="hero-trash" variant="danger">Delete</:item>
              </.dropdown>
            </div>
          </section>

          <%!-- ━━━ Tooltip ━━━ --%>
          <section id="tooltip-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Tooltip</h3>
            <.divider />
            <div class="flex items-center gap-6">
              <.tooltip id="tip-top" text="Tooltip on top" placement="top">
                <.button variant="soft" size="sm">Top</.button>
              </.tooltip>
              <.tooltip id="tip-bottom" text="Tooltip on bottom" placement="bottom">
                <.button variant="soft" size="sm">Bottom</.button>
              </.tooltip>
              <.tooltip id="tip-left" text="Tooltip on left" placement="left">
                <.button variant="soft" size="sm">Left</.button>
              </.tooltip>
              <.tooltip id="tip-right" text="Tooltip on right" placement="right">
                <.button variant="soft" size="sm">Right</.button>
              </.tooltip>
            </div>
          </section>

          <%!-- ━━━ Command Palette ━━━ --%>
          <section id="command-palette-section" class="space-y-4 scroll-mt-8">
            <h3 class="text-lg font-semibold text-text">Command Palette</h3>
            <.divider />
            <p class="text-sm text-text-secondary">
              Press
              <.kbd>⌘</.kbd>
              <.kbd>K</.kbd>
              or click the button below.
            </p>
            <button
              data-commandfor="cmd-palette"
              data-command="show-modal"
              class="rounded-md bg-surface-alt border border-border px-4 py-2 text-sm text-text-secondary cursor-pointer hover:bg-surface-hover transition-colors flex items-center gap-2"
            >
              <.icon name="hero-magnifying-glass" class="size-4" /> Search commands...
              <.kbd>⌘K</.kbd>
            </button>

            <.command_palette id="cmd-palette">
              <:group label="Navigation"></:group>
              <:item icon="hero-home" label="Home" navigate={~p"/"} />
              <:item icon="hero-book-open" label="Recipes" shortcut="⌘R" />
              <:item icon="hero-newspaper" label="News" />
              <:item icon="hero-beaker" label="Research" />
              <:group label="Actions"></:group>
              <:item icon="hero-plus" label="New Recipe" shortcut="⌘N" />
              <:item icon="hero-cog-6-tooth" label="Settings" />
              <:item icon="hero-arrow-right-start-on-rectangle" label="Sign Out" />
            </.command_palette>
          </section>
        </div>
      </div>
    </div>
    """
  end

  # ── Layout Components ────────────────────────────────────────────

  defp showcase_sidebar(assigns) do
    ~H"""
    <nav
      id="showcase-sidebar"
      phx-hook=".ScrollSpy"
      class="hidden lg:block sticky top-6 self-start w-48 shrink-0 max-h-[calc(100dvh-3rem)] overflow-y-auto"
    >
      <div class="space-y-5 pb-8">
        <div :for={{label, items} <- sidebar_categories()}>
          <h4 class="text-[0.6875rem] font-semibold uppercase tracking-wider text-text-muted mb-1.5 px-2.5">
            {label}
          </h4>
          <ul>
            <li :for={{name, anchor} <- items}>
              <a
                href={"##{anchor}"}
                data-section={anchor}
                class={[
                  "sidebar-link block px-2.5 py-1 text-[0.8125rem] rounded-md transition-colors",
                  "text-text-secondary hover:text-text hover:bg-surface-hover"
                ]}
              >
                {name}
              </a>
            </li>
          </ul>
        </div>
      </div>
    </nav>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".ScrollSpy">
      export default {
        mounted() {
          const links = this.el.querySelectorAll("a[data-section]")
          const ids = Array.from(links).map(a => a.dataset.section)
          const sections = ids.map(id => document.getElementById(id)).filter(Boolean)

          let active = null

          this._observer = new IntersectionObserver(entries => {
            for (const entry of entries) {
              if (entry.isIntersecting) {
                if (active) {
                  active.classList.remove("text-text", "font-medium", "bg-surface-alt")
                  active.classList.add("text-text-secondary")
                }
                const link = this.el.querySelector(`a[data-section="${entry.target.id}"]`)
                if (link) {
                  link.classList.add("text-text", "font-medium", "bg-surface-alt")
                  link.classList.remove("text-text-secondary")
                  active = link
                }
              }
            }
          }, { rootMargin: "-10% 0px -80% 0px" })

          sections.forEach(s => this._observer.observe(s))
        },

        destroyed() {
          this._observer?.disconnect()
        }
      }
    </script>
    """
  end

  attr :id, :string, required: true
  attr :label, :string, required: true

  defp category_header(assigns) do
    ~H"""
    <div id={@id} class="scroll-mt-8">
      <div class="flex items-center gap-3">
        <h2 class="text-xs font-bold uppercase tracking-widest text-text-muted whitespace-nowrap">
          {@label}
        </h2>
        <div class="flex-1 h-px bg-border" />
      </div>
    </div>
    """
  end

  # ── Event Handlers ──────────────────────────────────────────────

  @impl true
  def handle_event("toast_info", _, socket) do
    {:noreply, put_flash(socket, :info, "This is an info toast.")}
  end

  def handle_event("toast_success", _, socket) do
    {:noreply,
     push_event(socket, "toast:show", %{
       kind: "success",
       title: "Success!",
       description: "Your changes have been saved."
     })}
  end

  def handle_event("toast_warning", _, socket) do
    {:noreply,
     push_event(socket, "toast:show", %{
       kind: "warning",
       title: "Warning",
       description: "Disk space is running low.",
       duration: 8000
     })}
  end

  def handle_event("toast_error", _, socket) do
    {:noreply,
     push_event(socket, "toast:show", %{
       kind: "error",
       title: "Error",
       description: "Failed to save. Please try again."
     })}
  end

  def handle_event("toast_rich", _, socket) do
    {:noreply,
     push_event(socket, "toast:show", %{
       kind: "success",
       title: "Recipe published",
       description: "Your sourdough recipe is now live.",
       action_label: "View",
       action_event: "view_recipe",
       duration: 6000,
       progress: true
     })}
  end

  def handle_event("toast_position", %{"position" => position}, socket) do
    {:noreply,
     push_event(socket, "toast:show", %{
       kind: "info",
       title: format_position(position),
       description: "Toast from #{position}.",
       position: position,
       duration: 3000
     })}
  end

  def handle_event("toggle_rich_colors", _, socket) do
    {:noreply, assign(socket, :rich_colors, !socket.assigns.rich_colors)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", _params, socket) do
    {:noreply, put_flash(socket, :info, "Form submitted!")}
  end

  def handle_event("increment_progress", _, socket) do
    value = rem(socket.assigns.progress_value + 15, 101)
    {:noreply, assign(socket, :progress_value, value)}
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    {:noreply, assign(socket, :current_page, String.to_integer(page))}
  end

  def handle_event("view_recipe", _, socket) do
    {:noreply, put_flash(socket, :info, "Navigating to recipe...")}
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :files, ref)}
  end

  def handle_event("remove_uploaded_file", %{"ref" => ref}, socket) do
    {:noreply, update(socket, :uploaded_files, &Enum.reject(&1, fn f -> f.ref == ref end))}
  end

  def handle_event("sort", %{"field" => field}, socket) do
    {sort_by, sort_dir} =
      if socket.assigns.dt_sort_by == field do
        {field, if(socket.assigns.dt_sort_dir == "asc", do: "desc", else: "asc")}
      else
        {field, "asc"}
      end

    {:noreply, assign(socket, dt_sort_by: sort_by, dt_sort_dir: sort_dir)}
  end

  def handle_event("select_row", %{"id" => id}, socket) do
    selected =
      if id in socket.assigns.dt_selected do
        List.delete(socket.assigns.dt_selected, id)
      else
        [id | socket.assigns.dt_selected]
      end

    {:noreply, assign(socket, dt_selected: selected)}
  end

  def handle_event("select_all", _params, socket) do
    all_ids = Enum.map(sample_table_rows(), & &1.id)

    selected =
      if MapSet.new(all_ids) |> MapSet.subset?(MapSet.new(socket.assigns.dt_selected)) do
        []
      else
        all_ids
      end

    {:noreply, assign(socket, dt_selected: selected)}
  end

  defp format_position(pos), do: pos |> String.replace("-", " ") |> String.capitalize()

  # Auto-consume completed uploads — save metadata for display
  defp handle_upload_progress(:files, entry, socket) do
    if entry.done? do
      file_info = %{
        name: entry.client_name,
        size: entry.client_size,
        type: entry.client_type,
        ref: entry.ref
      }

      consume_uploaded_entry(socket, entry, fn %{path: _path} -> {:ok, file_info} end)

      {:noreply, update(socket, :uploaded_files, &[file_info | &1])}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({AyaWeb.UI.SearchSelect, :select, id, value}, socket) do
    key =
      case id do
        "ingredient-select" -> "ingredient_id"
        "grouped-select" -> "ingredient_id"
        "tags-select" -> "tags"
        "creatable-select" -> "tags"
        _ -> nil
      end

    if key do
      form = to_form(Map.put(socket.assigns.form.params, key, value), as: :demo)
      {:noreply, assign(socket, :form, form)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({AyaWeb.UI.SearchSelect, :search, _id, _query}, socket) do
    {:noreply, socket}
  end

  def handle_info({AyaWeb.UI.SearchSelect, :create, _id, _value}, socket) do
    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  # ── Sample Data ─────────────────────────────────────────────────

  defp sidebar_categories do
    [
      {"General",
       [
         {"Button", "button-section"},
         {"Badge", "badge-section"},
         {"Avatar", "avatar-section"},
         {"Link", "link-section"},
         {"Kbd", "kbd-section"},
         {"Divider", "divider-section"},
         {"Copy Button", "copy-button-section"},
         {"Spinner", "spinner-section"},
         {"Loading", "loading-section"}
       ]},
      {"Data Display",
       [
         {"Card", "card-section"},
         {"Expandable Cards", "expandable-cards-section"},
         {"Stat Card", "stat-card-section"},
         {"Table", "table-section"},
         {"Data Table", "data-table-section"},
         {"List", "list-section"},
         {"Progress", "progress-section"},
         {"Skeleton", "skeleton-section"},
         {"Engagement Stats", "engagement-stats-section"},
         {"Image", "image-section"},
         {"Empty State", "empty-state-section"},
         {"Description List", "description-list-section"},
         {"Timeline", "timeline-section"}
       ]},
      {"Forms & Input",
       [
         {"Input", "input-section"},
         {"Toggle", "toggle-section"},
         {"Checkbox", "checkbox-section"},
         {"Radio", "radio-section"},
         {"Search Select", "search-select-section"},
         {"Date Picker", "date-picker-section"},
         {"File Picker", "file-picker-section"},
         {"Image Field", "image-field-section"},
         {"Slider", "slider-section"},
         {"Color Picker", "color-picker-section"},
         {"Tag Input", "tag-input-section"}
       ]},
      {"Feedback",
       [
         {"Toast", "toast-section"},
         {"Inline Alert", "inline-alert-section"},
         {"Banner", "banner-section"}
       ]},
      {"Navigation",
       [
         {"Tabs", "tabs-section"},
         {"Accordion", "accordion-section"},
         {"Breadcrumb", "breadcrumb-section"},
         {"Pagination", "pagination-section"},
         {"Steps", "steps-section"},
         {"Multi Step", "multi-step-section"},
         {"Split Pane", "split-pane-section"},
         {"List Detail", "list-detail-section"}
       ]},
      {"Editors",
       [
         {"Rich Text Editor", "rich-editor-section"},
         {"Markdown Editor", "markdown-editor-section"}
       ]},
      {"Overlays",
       [
         {"Share Sheet", "share-sheet-section"},
         {"Morph Dialog", "morph-dialog-section"},
         {"Overlay", "overlay-section"},
         {"Drawer", "drawer-section"},
         {"Family Dialog", "family-dialog-section"},
         {"Hover Card", "hover-card-section"},
         {"Dropdown", "dropdown-section"},
         {"Tooltip", "tooltip-section"},
         {"Command Palette", "command-palette-section"}
       ]}
    ]
  end

  defp sample_options do
    [
      %{value: "1", label: "Salt", subtitle: "NaCl"},
      %{value: "2", label: "Sugar", subtitle: "Sucrose"},
      %{value: "3", label: "Flour", subtitle: "All-purpose"},
      %{value: "4", label: "Butter", subtitle: "Unsalted"},
      %{value: "5", label: "Olive Oil", subtitle: "Extra virgin"},
      %{value: "6", label: "Garlic", subtitle: "Fresh cloves"},
      %{value: "7", label: "Onion", subtitle: "Yellow"},
      %{value: "8", label: "Black Pepper", subtitle: "Ground"},
      %{value: "9", label: "Cumin", subtitle: "Ground"},
      %{value: "10", label: "Paprika", subtitle: "Smoked"},
      %{value: "11", label: "Oregano", subtitle: "Dried"},
      %{value: "12", label: "Basil", subtitle: "Fresh"}
    ]
  end

  defp sample_grouped_options do
    [
      %{value: "1", label: "Salt", subtitle: "NaCl", group: "Seasonings"},
      %{value: "8", label: "Black Pepper", subtitle: "Ground", group: "Seasonings"},
      %{value: "9", label: "Cumin", subtitle: "Ground", group: "Seasonings"},
      %{value: "10", label: "Paprika", subtitle: "Smoked", group: "Seasonings"},
      %{value: "11", label: "Oregano", subtitle: "Dried", group: "Herbs"},
      %{value: "12", label: "Basil", subtitle: "Fresh", group: "Herbs"},
      %{value: "3", label: "Flour", subtitle: "All-purpose", group: "Dry Goods"},
      %{value: "2", label: "Sugar", subtitle: "Sucrose", group: "Dry Goods"},
      %{value: "4", label: "Butter", subtitle: "Unsalted", group: "Dairy & Oils"},
      %{value: "5", label: "Olive Oil", subtitle: "Extra virgin", group: "Dairy & Oils"},
      %{value: "6", label: "Garlic", subtitle: "Fresh cloves", group: "Produce"},
      %{value: "7", label: "Onion", subtitle: "Yellow", group: "Produce"}
    ]
  end

  defp sample_tag_options do
    [
      %{value: "baking", label: "Baking"},
      %{value: "fermentation", label: "Fermentation"},
      %{value: "quick", label: "Quick Meal"},
      %{value: "vegetarian", label: "Vegetarian"},
      %{value: "gluten-free", label: "Gluten-free"},
      %{value: "dairy-free", label: "Dairy-free"},
      %{value: "spicy", label: "Spicy"},
      %{value: "comfort", label: "Comfort Food"}
    ]
  end

  defp sample_table_rows do
    [
      %{id: "1", name: "Sourdough Bread", category: "Baking", calories: "250"},
      %{id: "2", name: "Miso Ramen", category: "Soup", calories: "420"},
      %{id: "3", name: "Caesar Salad", category: "Salad", calories: "180"},
      %{id: "4", name: "Kimchi Fried Rice", category: "Rice", calories: "380"},
      %{id: "5", name: "Chocolate Mousse", category: "Dessert", calories: "310"}
    ]
  end
end
