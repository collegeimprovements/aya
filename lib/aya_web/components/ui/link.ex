defmodule AyaWeb.UI.Link do
  @moduledoc """
  Styled link component with prefetch/preload support.

  ## Prefetching

  - `prefetch` — prefetches the page on hover (injects `<link rel="prefetch">`)
  - `preload` — preloads the page eagerly on render (immediate fetch)
  - `prerender` — prerenders the page via Speculation Rules API (Chrome 109+)

  These use the browser-native Resource Hints API and Speculation Rules API
  for instant page transitions.

  ## Examples

      <.styled_link navigate={~p"/recipes"}>All Recipes</.styled_link>
      <.styled_link navigate={~p"/recipes"} prefetch>Prefetch on hover</.styled_link>
      <.styled_link navigate={~p"/recipes"} preload>Preload immediately</.styled_link>
      <.styled_link navigate={~p"/recipes"} prerender>Prerender (Chrome)</.styled_link>
      <.styled_link href="https://example.com" variant="muted">External</.styled_link>
  """

  use Phoenix.Component

  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :href, :any, default: nil
  attr :method, :string, default: nil
  attr :variant, :string, default: "default", values: ~w(default muted subtle)
  attr :prefetch, :boolean, default: false, doc: "prefetch page on hover"
  attr :preload, :boolean, default: false, doc: "preload page immediately on render"
  attr :prerender, :boolean, default: false, doc: "prerender page via Speculation Rules API"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def styled_link(assigns) do
    url = assigns.navigate || assigns.patch || assigns.href

    assigns = assign(assigns, :url, url)

    ~H"""
    <%!-- Eager preload: inject link tag on render --%>
    <link :if={@preload && @url} rel="prefetch" href={@url} />

    <%!-- Speculation Rules for prerender (Chrome 109+) --%>
    <script :if={@prerender && @url} type="speculationrules">
      {"prerender": [{"urls": ["{@url}"]}]}
    </script>

    <.link
      navigate={@navigate}
      patch={@patch}
      href={@href}
      method={@method}
      data-prefetch={if @prefetch && @url, do: @url}
      phx-hook={if @prefetch, do: ".PrefetchLink"}
      id={if @prefetch, do: "pl-#{System.unique_integer([:positive])}"}
      class={[
        "transition-colors duration-fast",
        "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring",
        variant_class(@variant),
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".PrefetchLink">
      export default {
        mounted() {
          const url = this.el.dataset.prefetch
          if (!url) return

          let prefetched = false
          this.el.addEventListener("mouseenter", () => {
            if (prefetched) return
            prefetched = true
            const link = document.createElement("link")
            link.rel = "prefetch"
            link.href = url
            link.as = "document"
            document.head.appendChild(link)
          }, { once: true })

          this.el.addEventListener("touchstart", () => {
            if (prefetched) return
            prefetched = true
            const link = document.createElement("link")
            link.rel = "prefetch"
            link.href = url
            link.as = "document"
            document.head.appendChild(link)
          }, { once: true, passive: true })
        }
      }
    </script>
    """
  end

  defp variant_class("default"), do: "text-link hover:text-link-hover"
  defp variant_class("muted"), do: "text-text-secondary hover:text-text"
  defp variant_class("subtle"), do: "text-text hover:text-link"
  defp variant_class(_), do: "text-link hover:text-link-hover"
end
