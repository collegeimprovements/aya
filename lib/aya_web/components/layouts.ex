defmodule AyaWeb.Layouts do
  @moduledoc """
  Layout components for Aya.

  Provides the app chrome (navigation, footer) and flash group.
  Built with pure Tailwind CSS v4 + design tokens. No DaisyUI.
  """
  use AyaWeb, :html

  embed_templates "layouts/*"

  @nav_items [
    %{href: "/", label: "Home", icon: "hero-home-micro"},
    %{href: "/news", label: "News", icon: "hero-newspaper-micro"},
    %{href: "/recipes", label: "Recipes", icon: "hero-book-open-micro"},
    %{href: "/research", label: "Research", icon: "hero-beaker-micro"}
  ]

  @doc """
  Renders the main app layout with navigation and content area.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :inner_content, :any, default: nil, doc: "content from LiveView layout system"
  slot :inner_block

  def app(assigns) do
    assigns = assign(assigns, :nav_items, @nav_items)

    ~H"""
    <header class="sticky top-0 z-40 bg-surface/95 backdrop-blur shadow-border">
      <nav class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div class="flex h-14 items-center justify-between">
          <%!-- Logo --%>
          <div class="flex items-center gap-3">
            <a href="/" class="flex items-center gap-2 text-text hover:text-text">
              <span class="text-lg font-bold tracking-tight">Aya</span>
              <span class="text-xs font-medium text-text-muted px-1.5 py-0.5 rounded bg-surface-alt">
                Food & Science
              </span>
            </a>
          </div>

          <%!-- Desktop nav links --%>
          <div class="hidden sm:flex items-center gap-1">
            <.nav_link :for={item <- @nav_items} href={item.href} label={item.label} />
          </div>

          <%!-- Right side: theme toggle + mobile menu button --%>
          <div class="flex items-center gap-2">
            <.theme_toggle />
            <%!-- Mobile menu toggle --%>
            <button
              id="mobile-menu-toggle"
              class="sm:hidden p-2 rounded-md text-text-secondary hover:text-text hover:bg-surface-hover transition-[color,background-color] duration-150 cursor-pointer"
              phx-click={toggle_mobile_menu()}
              aria-label="Toggle menu"
            >
              <span id="mobile-menu-open-icon"><.icon name="hero-bars-3" class="size-5" /></span>
              <span id="mobile-menu-close-icon" class="hidden">
                <.icon name="hero-x-mark" class="size-5" />
              </span>
            </button>
          </div>
        </div>
      </nav>

      <%!-- Mobile nav panel --%>
      <div
        id="mobile-nav"
        class="hidden sm:hidden border-t border-border bg-surface"
      >
        <div class="px-4 py-3 space-y-1">
          <a
            :for={item <- @nav_items}
            href={item.href}
            class="flex items-center gap-3 px-3 py-2.5 text-sm font-medium text-text-secondary hover:text-text hover:bg-surface-hover rounded-md transition-[color,background-color] duration-150"
          >
            <.icon name={item.icon} class="size-4" />
            {item.label}
          </a>
        </div>
      </div>
    </header>

    <main class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
      {@inner_content || render_slot(@inner_block)}
    </main>
    """
  end

  defp toggle_mobile_menu do
    JS.toggle(to: "#mobile-nav")
    |> JS.toggle(to: "#mobile-menu-open-icon")
    |> JS.toggle(to: "#mobile-menu-close-icon")
  end

  attr :href, :string, required: true
  attr :label, :string, required: true

  defp nav_link(assigns) do
    ~H"""
    <a
      href={@href}
      class="px-3 py-1.5 text-sm font-medium text-text-secondary hover:text-text hover:bg-surface-hover rounded-md transition-[color,background-color] duration-150"
    >
      {@label}
    </a>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Dark / light / system theme toggle.

  Persists choice to localStorage. Applied via data-theme attribute
  on <html> before first paint (see root.html.heex).
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="flex items-center rounded-full border border-border bg-surface-alt p-0.5 gap-0.5">
      <button
        class="p-1.5 rounded-full cursor-pointer text-text-muted hover:text-text hover:bg-surface-hover transition-[color,background-color] duration-150 [[data-theme=light]_&]:hidden [[data-theme=dark]_&]:hidden"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
        aria-label="System theme"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4" />
      </button>

      <button
        class="p-1.5 rounded-full cursor-pointer text-text-muted hover:text-text hover:bg-surface-hover transition-[color,background-color] duration-150 [html:not([data-theme])_&]:hidden [[data-theme=dark]_&]:hidden"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
        aria-label="Light theme"
      >
        <.icon name="hero-sun-micro" class="size-4" />
      </button>

      <button
        class="p-1.5 rounded-full cursor-pointer text-text-muted hover:text-text hover:bg-surface-hover transition-[color,background-color] duration-150 [html:not([data-theme])_&]:hidden [[data-theme=light]_&]:hidden"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
        aria-label="Dark theme"
      >
        <.icon name="hero-moon-micro" class="size-4" />
      </button>
    </div>
    """
  end
end
