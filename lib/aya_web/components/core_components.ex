defmodule AyaWeb.CoreComponents do
  @moduledoc """
  Core UI components for Aya.

  Built with pure Tailwind CSS v4 + design tokens. No DaisyUI.
  All colors reference the semantic token classes defined in app.css.

  Components:
  - `flash/1` — toast notification
  - `button/1` — button / link-button with variants
  - `input/1` — form input with label + error messages
  - `header/1` — page header with title, subtitle, actions
  - `table/1` — data table with streaming support
  - `list/1` — data list
  - `icon/1` — Heroicon wrapper
  - `show/2`, `hide/2` — JS transition helpers
  """
  use Phoenix.Component
  import Phoenix.Component, except: [link: 1]
  use Gettext, backend: AyaWeb.Gettext

  alias Phoenix.LiveView.JS

  # ── Link (extended) ──────────────────────────────────────────────

  @link_hook_name (Module.split(__MODULE__) |> Enum.join(".")) <> ".LinkHook"

  @doc """
  Extended `<.link>` — drop-in replacement for `Phoenix.Component.link/1`.

  Wraps `Phoenix.Component.link/1` with design-system variants, speculation
  rules, and convenience attrs. Accepts all standard Phoenix link attrs
  (`navigate`, `patch`, `href`, `method`, `replace`, `csrf_token`) plus
  the extensions below.

  ## Navigation

  Use exactly one of `navigate`, `patch`, or `href`:

      <.link navigate={~p"/recipes"}>Full page nav</.link>
      <.link patch={~p"/recipes?sort=name"}>Patch (same LiveView)</.link>
      <.link href="https://github.com">Standard href</.link>

  ## Variants

  Controls text color, hover state, and underline treatment. Default is
  `"plain"` (no styling) so existing unstyled `<.link>` calls keep working.

  | Variant            | Color                        | Underline              |
  |--------------------|------------------------------|------------------------|
  | `"default"`        | link color → link-hover      | none                   |
  | `"muted"`          | secondary text → text        | none                   |
  | `"subtle"`         | body text → link color       | none                   |
  | `"underline"`      | link color → link-hover      | ::after always visible (30% → 100% on hover) |
  | `"underline-hover"`| link color → link-hover      | ::after slides in on hover (left→right) |
  | `"plain"`          | inherit                      | none                   |

  All non-plain variants include `focus-visible` outline and `transition-colors`.

  The underline is a `::after` pseudo-element (not `text-decoration`), so
  width, opacity, thickness, and transforms are all independently animatable.
  To change the animation, edit `link_underline_class/1`.

      <.link navigate={~p"/recipes"} variant="default">Default</.link>
      <.link navigate={~p"/recipes"} variant="underline">Underline</.link>

  ## Speculation Rules (prefetch / preload / prerender)

  Resource hints for instant page transitions. Uses the Speculation Rules
  API (Chrome 109+) with `<link rel="prefetch">` as a cross-browser
  fallback. All requests are deduplicated at the action+URL level — the
  same URL is only fetched/prerendered once regardless of how many links
  reference it.

  | Attr        | When it fires            | Chrome 109+               | Firefox / Safari          |
  |-------------|--------------------------|---------------------------|---------------------------|
  | `prefetch`  | hover / focus / touch    | Speculation Rules prefetch | `<link rel="prefetch">`   |
  | `preload`   | immediately on mount     | Speculation Rules prefetch | `<link rel="prefetch">`   |
  | `prerender` | immediately on mount     | Speculation Rules prerender| no-op (Chrome only)       |

  `preload` supersedes `prefetch` (fires immediately, so hover listeners
  are never attached). `prerender` is the most aggressive — Chrome renders
  the page in a hidden tab for instant swap on click.

      <.link navigate={~p"/recipes"} prefetch variant="default">Hover to prefetch</.link>
      <.link navigate={~p"/recipes"} preload variant="default">Prefetch on mount</.link>
      <.link navigate={~p"/recipes"} prerender variant="default">Prerender (Chrome)</.link>

  ## External links

  Adds `target="_blank"` and `rel="noopener noreferrer"` automatically.
  The caller's explicit `target`/`rel` in `@rest` takes precedence for `target`.

      <.link href="https://github.com" external>GitHub</.link>

  ## Active state

  Apply a class when the link matches the current page. Useful for nav menus.

      <.link navigate={~p"/recipes"} active={@live_action == :index}>Recipes</.link>
      <.link navigate={~p"/recipes"} active={@active} active_class="font-bold border-b-2 border-link">
        Custom active style
      </.link>

  Sets `aria-current="page"` when active.

  ## Disabled state

  Strips `navigate`/`patch`/`href` (no navigation), dims the element,
  removes it from tab order (`tabindex="-1"`), and sets `aria-disabled`.

      <.link navigate={~p"/settings"} disabled={!@can_access} variant="default">
        Settings
      </.link>

  ## Loading spinner

  Shows an inline spinner on click, hides it when navigation completes
  (`phx:page-loading-stop`). The spinner is a hidden `<svg>` toggled via
  the `.LinkHook` — no extra assigns needed.

      <.link navigate={~p"/slow-page"} loading variant="default">Submit</.link>

  ## Hook & ID behavior

  `prefetch`, `preload`, `prerender`, and `loading` all require a LiveView
  hook (`.LinkHook`). The hook needs an `id` on the element. IDs are
  resolved in this order:

  1. Explicit `id` from the caller (always wins)
  2. Stable hash of the URL (`pl-<8 hex chars>`) — survives re-renders
  3. `System.unique_integer` fallback (loading-only links with no URL)

  When multiple links on the same page share a URL and use speculation
  attrs, provide explicit `id`s to avoid duplicate DOM IDs:

      <.link navigate={~p"/"} prefetch variant="default" id="nav-home">Home</.link>
      <.link navigate={~p"/"} prefetch variant="muted" id="footer-home">Home</.link>

  ## All examples

      <%!-- Basic --%>
      <.link navigate={~p"/recipes"}>Plain (no styling)</.link>
      <.link navigate={~p"/recipes"} variant="default">Styled link</.link>

      <%!-- Speculation --%>
      <.link navigate={~p"/recipes"} prefetch variant="default">Prefetch on hover</.link>
      <.link navigate={~p"/recipes"} preload variant="default">Prefetch on mount</.link>
      <.link navigate={~p"/recipes"} prerender variant="default">Prerender (Chrome)</.link>

      <%!-- External --%>
      <.link href="https://github.com" external variant="default">GitHub</.link>

      <%!-- Active / disabled --%>
      <.link navigate={~p"/recipes"} active={@live_action == :index}>Recipes</.link>
      <.link navigate={~p"/settings"} disabled={!@can_access}>Settings</.link>

      <%!-- Loading --%>
      <.link navigate={~p"/slow"} loading variant="default">Submit</.link>
  """
  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :href, :any, default: nil
  attr :replace, :boolean, default: false
  attr :method, :string, default: nil
  attr :csrf_token, :any, default: true

  attr :variant, :string,
    default: "plain",
    values: ~w(default muted subtle underline underline-hover plain)

  attr :prefetch, :boolean, default: false, doc: "prefetch on hover/focus"
  attr :preload, :boolean, default: false, doc: "prefetch immediately on mount"
  attr :prerender, :boolean, default: false, doc: "prerender on mount (Chrome 109+)"
  attr :external, :boolean, default: false, doc: "open in new tab with noopener"
  attr :active, :boolean, default: false, doc: "whether this link is currently active"
  attr :active_class, :string, default: "text-text font-medium", doc: "class when active"
  attr :disabled, :boolean, default: false, doc: "prevent navigation, dim the link"
  attr :loading, :boolean, default: false, doc: "show spinner on click, hide on nav complete"
  attr :rest, :global, include: ~w(download hreflang referrerpolicy rel target type class id)
  slot :inner_block, required: true

  def link(assigns) do
    url = assigns.navigate || assigns.patch || assigns.href
    url_string = if url, do: to_string(url)

    has_speculation? =
      (assigns.prefetch or assigns.preload or assigns.prerender) and url_string != nil

    needs_hook? = has_speculation? or assigns.loading

    # External: override target + rel
    {target, rel} =
      if assigns.external do
        {assigns.rest[:target] || "_blank", "noopener noreferrer"}
      else
        {assigns.rest[:target], assigns.rest[:rel]}
      end

    # Stable ID for hook (survives re-renders), or explicit id from caller
    id =
      cond do
        assigns.rest[:id] -> assigns.rest[:id]
        needs_hook? && url_string -> stable_link_id(url_string)
        needs_hook? -> "lh-#{System.unique_integer([:positive])}"
        true -> nil
      end

    # Disabled: strip navigation attrs, remove from tab order
    {nav, pat, hr} =
      if assigns.disabled do
        {nil, nil, nil}
      else
        {assigns.navigate, assigns.patch, assigns.href}
      end

    # Build class list
    extra_class =
      [
        link_variant_class(assigns.variant),
        assigns.active && assigns.active_class,
        assigns.disabled && "opacity-50 pointer-events-none cursor-not-allowed"
      ]

    assigns =
      assign(assigns,
        _url: url,
        _url_string: url_string,
        _nav: nav,
        _pat: pat,
        _hr: hr,
        _extra_class: extra_class,
        _target: target,
        _rel: rel,
        _id: id,
        _has_speculation: has_speculation?,
        _hook: if(needs_hook?, do: @link_hook_name)
      )

    ~H"""
    <Phoenix.Component.link
      navigate={@_nav}
      patch={@_pat}
      href={@_hr}
      replace={@replace}
      method={@method}
      csrf_token={@csrf_token}
      target={@_target}
      rel={@_rel}
      id={@_id}
      tabindex={if @disabled, do: "-1"}
      data-spec-url={if @_has_speculation, do: @_url_string}
      data-spec-eager={if @preload, do: "true"}
      data-spec-prerender={if @prerender, do: "true"}
      data-link-loading={if @loading, do: "true"}
      phx-hook={@_hook}
      aria-disabled={if @disabled, do: "true"}
      aria-current={if @active, do: "page"}
      class={@_extra_class}
      {@rest}
    >
      {render_slot(@inner_block)}
      <svg
        :if={@loading}
        class="link-spinner hidden animate-spin size-3 ml-1 inline-block align-[-0.125em]"
        viewBox="0 0 24 24"
        fill="none"
        aria-hidden="true"
      >
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
        <path
          class="opacity-75"
          fill="currentColor"
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
        />
      </svg>
    </Phoenix.Component.link>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".LinkHook">
      const speculated = new Set()
      const supportsSpecRules = HTMLScriptElement.supports?.("speculationrules")

      function speculate(url, action = "prefetch") {
        const key = action + ":" + url
        if (speculated.has(key)) return
        speculated.add(key)

        if (supportsSpecRules) {
          // Chrome 109+: Speculation Rules API — reliable, eagerly executed,
          // purpose-built for navigation prefetch and prerender.
          const s = document.createElement("script")
          s.type = "speculationrules"
          s.textContent = JSON.stringify({ [action]: [{ urls: [url] }] })
          document.head.appendChild(s)
        } else if (action === "prefetch") {
          // Firefox/Safari: <link rel="prefetch"> fallback.
          // No cross-browser fallback for prerender — it's Chrome-only.
          const link = document.createElement("link")
          link.rel = "prefetch"
          link.href = url
          link.as = "document"
          document.head.appendChild(link)
        }
      }

      function setupSpeculation(el) {
        const url = el.dataset.specUrl
        if (!url) return

        // Prerender: inject immediately (Chrome-only, falls through silently elsewhere)
        if (el.dataset.specPrerender != null) {
          speculate(url, "prerender")
          return
        }

        // Eager prefetch (preload): inject immediately
        if (el.dataset.specEager != null) {
          speculate(url, "prefetch")
          return
        }

        // Hover/focus/touch prefetch
        const trigger = () => speculate(url, "prefetch")
        el.addEventListener("mouseenter", trigger, { once: true })
        el.addEventListener("touchstart", trigger, { once: true, passive: true })
        el.addEventListener("focusin", trigger, { once: true })
      }

      function setupLoading(hook) {
        const spinner = hook.el.querySelector(".link-spinner")
        if (!spinner) return

        hook._clickHandler = () => spinner.classList.remove("hidden")
        hook._loadingStop = () => spinner.classList.add("hidden")

        hook.el.addEventListener("click", hook._clickHandler)
        window.addEventListener("phx:page-loading-stop", hook._loadingStop)
      }

      export default {
        mounted() {
          this._specUrl = this.el.dataset.specUrl
          setupSpeculation(this.el)

          if (this.el.dataset.linkLoading != null) {
            setupLoading(this)
          }
        },
        updated() {
          const newUrl = this.el.dataset.specUrl
          if (newUrl && newUrl !== this._specUrl) {
            this._specUrl = newUrl
            setupSpeculation(this.el)
          }
        },
        destroyed() {
          if (this._loadingStop) {
            window.removeEventListener("phx:page-loading-stop", this._loadingStop)
          }
        }
      }
    </script>
    """
  end

  defp stable_link_id(url) do
    hash = :crypto.hash(:md5, url) |> Base.encode16(case: :lower) |> binary_part(0, 8)
    "pl-#{hash}"
  end

  @link_focus "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring"

  defp link_variant_class("default"),
    do: ["text-link hover:text-link-hover transition-colors duration-fast", @link_focus]

  defp link_variant_class("muted"),
    do: ["text-text-secondary hover:text-text transition-colors duration-fast", @link_focus]

  defp link_variant_class("subtle"),
    do: ["text-text hover:text-link transition-colors duration-fast", @link_focus]

  defp link_variant_class("underline"),
    do: [
      "text-link hover:text-link-hover transition-colors duration-fast",
      @link_focus,
      link_underline_class(:always)
    ]

  defp link_variant_class("underline-hover"),
    do: [
      "text-link hover:text-link-hover transition-colors duration-fast",
      @link_focus,
      link_underline_class(:hover)
    ]

  defp link_variant_class("plain"), do: nil
  defp link_variant_class(_), do: nil

  # Pseudo-element underline — swap this function to change animation style.
  # Uses ::after so width, opacity, thickness, and transforms are all animatable.
  defp link_underline_class(:hover) do
    [
      "relative",
      "after:absolute after:inset-x-0 after:bottom-0 after:h-px after:bg-current after:content-['']",
      "after:origin-left after:scale-x-0 hover:after:scale-x-100",
      "after:transition-transform after:duration-fast"
    ]
  end

  defp link_underline_class(:always) do
    [
      "relative",
      "after:absolute after:inset-x-0 after:bottom-0 after:h-px after:bg-current after:content-['']",
      "after:opacity-30 hover:after:opacity-100",
      "after:transition-opacity after:duration-fast"
    ]
  end

  # ── Flash ──────────────────────────────────────────────────────

  @doc """
  Renders flash notices as toast-style notifications.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class="fixed top-4 right-4 z-toast flash-enter"
      data-auto-dismiss={@kind == :info && "5000"}
      {@rest}
    >
      <div class={[
        "w-80 sm:w-96 rounded-lg p-4",
        "flex items-start gap-3",
        "shadow-border",
        @kind == :info && "bg-info-soft text-info-text",
        @kind == :error && "bg-error-soft text-error-text"
      ]}>
        <.icon :if={@kind == :info} name="hero-information-circle" class="size-5 shrink-0 text-info" />
        <.icon
          :if={@kind == :error}
          name="hero-exclamation-circle"
          class="size-5 shrink-0 text-error"
        />
        <div class="flex-1 min-w-0">
          <p :if={@title} class="font-semibold text-sm">{@title}</p>
          <p class="text-sm">{msg}</p>
        </div>
        <button
          type="button"
          class="shrink-0 cursor-pointer opacity-40 hover:opacity-70 transition-[opacity] duration-150"
          aria-label={gettext("close")}
        >
          <.icon name="hero-x-mark" class="size-5" />
        </button>
      </div>
    </div>
    """
  end

  # ── Button ─────────────────────────────────────────────────────

  @doc """
  Renders a button with variant support and navigation.

  ## Variants

  - `"primary"` — solid primary background
  - `"secondary"` — solid secondary background
  - `"ghost"` — transparent with hover background
  - `"soft"` (default) — soft primary background

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" variant="primary">Send!</.button>
      <.button navigate={~p"/"} variant="ghost">Home</.button>
  """
  attr :rest, :global, include: ~w(href navigate patch method download name value disabled)
  attr :class, :any, default: nil
  attr :variant, :string, default: "soft", values: ~w(primary secondary ghost soft)
  attr :size, :string, default: "md", values: ~w(sm md lg)

  slot :inner_block, required: true

  def button(%{rest: rest} = assigns) do
    assigns =
      assign_new(assigns, :computed_class, fn ->
        [
          # Base styles
          "inline-flex items-center justify-center gap-2 font-medium",
          "rounded-md cursor-pointer",
          "transition-[color,background-color,scale] duration-150 ease-out",
          "active:not-disabled:scale-[0.96]",
          "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          # Loading states
          "phx-click-loading:opacity-70 phx-submit-loading:opacity-70",
          # Size
          variant_size(assigns.size),
          # Variant
          variant_style(assigns.variant),
          # Custom overrides
          assigns.class
        ]
      end)

    case {rest[:href], rest[:navigate], rest[:patch]} do
      {nil, nil, nil} ->
        ~H"""
        <button class={@computed_class} {@rest}>
          {render_slot(@inner_block)}
        </button>
        """

      _ ->
        ~H"""
        <.link class={@computed_class} {@rest}>
          {render_slot(@inner_block)}
        </.link>
        """
    end
  end

  defp variant_size("sm"), do: "px-3 py-1.5 text-xs"
  defp variant_size("md"), do: "px-4 py-2 text-sm"
  defp variant_size("lg"), do: "px-6 py-3 text-base"

  defp variant_style("primary"),
    do: "bg-primary text-primary-text hover:bg-primary-hover"

  defp variant_style("secondary"),
    do: "bg-secondary text-secondary-text hover:bg-secondary-hover"

  defp variant_style("ghost"),
    do: "bg-transparent text-text hover:bg-surface-hover"

  defp variant_style("soft"),
    do: "bg-primary-soft text-primary hover:bg-primary/10"

  # ── Input ──────────────────────────────────────────────────────

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  Accepts all HTML input types, plus:
  - `type="select"` to render a `<select>` tag
  - `type="checkbox"` for boolean values
  - `type="textarea"` for multi-line text

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               search select tel text textarea time url week hidden)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :class, :any, default: nil, doc: "the input class to use over defaults"
  attr :error_class, :any, default: nil, doc: "the input error class to use over defaults"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input type="hidden" id={@id} name={@name} value={@value} {@rest} />
    """
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class="mb-3">
      <label for={@id} class="flex items-center gap-2 cursor-pointer">
        <input
          type="hidden"
          name={@name}
          value="false"
          disabled={@rest[:disabled]}
          form={@rest[:form]}
        />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class={[
            @class ||
              "size-4 rounded border-border-strong text-primary",
            "focus:ring-2 focus:ring-ring focus:ring-offset-1"
          ]}
          {@rest}
        />
        <span :if={@label} class="text-sm text-text">{@label}</span>
      </label>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class="mb-3">
      <label for={@id}>
        <span :if={@label} class="block text-sm font-medium text-text mb-1">{@label}</span>
        <div class="relative">
          <select
            id={@id}
            name={@name}
            class={[
              @class ||
                "w-full rounded-md border border-border bg-surface pl-3 pr-8 py-2 text-sm text-text",
              "appearance-none",
              "focus:border-ring focus:ring-2 focus:ring-ring/20 focus:outline-none",
              "transition-colors cursor-pointer",
              @errors != [] && (@error_class || "border-error focus:border-error focus:ring-error/20")
            ]}
            multiple={@multiple}
            {@rest}
          >
            <option :if={@prompt} value="">{@prompt}</option>
            {Phoenix.HTML.Form.options_for_select(@options, @value)}
          </select>
          <.icon
            :if={!@multiple}
            name="hero-chevron-down-mini"
            class="size-4 text-text-muted absolute right-2.5 top-1/2 -translate-y-1/2 pointer-events-none"
          />
        </div>
      </label>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class="mb-3">
      <label for={@id}>
        <span :if={@label} class="block text-sm font-medium text-text mb-1">{@label}</span>
        <textarea
          id={@id}
          name={@name}
          class={[
            @class ||
              "w-full rounded-md border border-border bg-surface px-3 py-2 text-sm text-text",
            "focus:border-ring focus:ring-2 focus:ring-ring/20 focus:outline-none",
            "transition-colors min-h-[80px]",
            @errors != [] && (@error_class || "border-error focus:border-error focus:ring-error/20")
          ]}
          {@rest}
        >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      </label>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    """
  end

  # All other inputs: text, datetime-local, url, password, etc.
  def input(assigns) do
    ~H"""
    <div class="mb-3">
      <label for={@id}>
        <span :if={@label} class="block text-sm font-medium text-text mb-1">{@label}</span>
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[
            @class ||
              "w-full rounded-md border border-border bg-surface px-3 py-2 text-sm text-text",
            "focus:border-ring focus:ring-2 focus:ring-ring/20 focus:outline-none",
            "placeholder:text-text-muted transition-colors",
            @errors != [] && (@error_class || "border-error focus:border-error focus:ring-error/20")
          ]}
          {@rest}
        />
      </label>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    """
  end

  defp field_error(assigns) do
    ~H"""
    <p class="mt-1 flex items-center gap-1.5 text-xs text-error">
      <.icon name="hero-exclamation-circle" class="size-4" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ── Header ─────────────────────────────────────────────────────

  @doc """
  Renders a page header with title, optional subtitle, and action buttons.
  """
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={["pb-6", @actions != [] && "flex items-center justify-between gap-6"]}>
      <div>
        <h1 class="text-xl font-semibold text-text leading-8">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="mt-1 text-sm text-text-secondary">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div :if={@actions != []} class="flex-none flex items-center gap-3">
        {render_slot(@actions)}
      </div>
    </header>
    """
  end

  # ── Table ──────────────────────────────────────────────────────

  @doc """
  Renders a data table with generic styling and streaming support.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id">{user.id}</:col>
        <:col :let={user} label="username">{user.username}</:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-x-auto rounded-lg border border-border">
      <table class="w-full text-sm">
        <thead class="bg-surface-alt border-b border-border">
          <tr>
            <th
              :for={col <- @col}
              class="px-4 py-3 text-left text-xs font-medium text-text-secondary uppercase tracking-wider"
            >
              {col[:label]}
            </th>
            <th :if={@action != []} class="px-4 py-3">
              <span class="sr-only">{gettext("Actions")}</span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={is_struct(@rows, Phoenix.LiveView.LiveStream) && "stream"}
          class="divide-y divide-border"
        >
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            class="hover:bg-surface-alt/50 transition-colors"
          >
            <td
              :for={col <- @col}
              phx-click={@row_click && @row_click.(row)}
              class={["px-4 py-3 text-text", @row_click && "cursor-pointer"]}
            >
              {render_slot(col, @row_item.(row))}
            </td>
            <td :if={@action != []} class="px-4 py-3 w-0 text-right font-medium">
              <div class="flex items-center justify-end gap-3">
                <%= for action <- @action do %>
                  {render_slot(action, @row_item.(row))}
                <% end %>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  # ── List ───────────────────────────────────────────────────────

  @doc """
  Renders a data list with label-value pairs.

  ## Examples

      <.list>
        <:item title="Title">{@post.title}</:item>
        <:item title="Views">{@post.views}</:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <dl class="divide-y divide-border">
      <div :for={item <- @item} class="flex gap-4 py-3 sm:gap-8">
        <dt class="w-1/4 flex-none text-sm font-medium text-text-secondary">{item.title}</dt>
        <dd class="text-sm text-text">{render_slot(item)}</dd>
      </div>
    </dl>
    """
  end

  # ── Icon ───────────────────────────────────────────────────────

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  ## Examples

      <.icon name="hero-x-mark" />
      <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :any, default: "size-4"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  # ── JS Commands ────────────────────────────────────────────────

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-[opacity,transform] ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-[opacity,transform] ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  # ── Translation Helpers ────────────────────────────────────────

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    case Keyword.fetch(opts, :count) do
      {:ok, count} ->
        Gettext.dngettext(AyaWeb.Gettext, "errors", msg, msg, count, opts)

      :error ->
        Gettext.dgettext(AyaWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
