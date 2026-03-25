defmodule AyaWeb.UI.Breadcrumb do
  @moduledoc """
  Navigation breadcrumb trail.

  ## Examples

      <.breadcrumb>
        <:crumb navigate={~p"/"} icon="hero-home">Home</:crumb>
        <:crumb navigate={~p"/recipes"}>Recipes</:crumb>
        <:crumb>Sourdough Bread</:crumb>
      </.breadcrumb>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :class, :any, default: nil
  attr :rest, :global

  slot :crumb, required: true do
    attr :navigate, :string
    attr :patch, :string
    attr :href, :string
    attr :icon, :string
  end

  def breadcrumb(assigns) do
    ~H"""
    <nav aria-label="Breadcrumb" class={@class} {@rest}>
      <ol class="flex items-center gap-1.5 text-sm">
        <li :for={{crumb, index} <- Enum.with_index(@crumb)} class="flex items-center gap-1.5">
          <.icon
            :if={index > 0}
            name="hero-chevron-right-mini"
            class="size-4 text-text-muted shrink-0"
          />
          {render_crumb(crumb, index == length(@crumb) - 1)}
        </li>
      </ol>
    </nav>
    """
  end

  defp render_crumb(crumb, true = _is_last) do
    assigns = %{crumb: crumb}

    ~H"""
    <span class="font-medium text-text truncate max-w-[200px]" aria-current="page">
      <.icon
        :if={@crumb[:icon]}
        name={@crumb[:icon]}
        class="size-4 inline-block mr-1 align-text-bottom"
      />
      {render_slot(@crumb)}
    </span>
    """
  end

  defp render_crumb(%{navigate: nav} = crumb, false) when is_binary(nav) do
    assigns = %{crumb: crumb}

    ~H"""
    <.link
      navigate={@crumb.navigate}
      class="text-text-secondary hover:text-text transition-colors truncate max-w-[200px] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring"
    >
      <.icon
        :if={@crumb[:icon]}
        name={@crumb[:icon]}
        class="size-4 inline-block mr-1 align-text-bottom"
      />
      {render_slot(@crumb)}
    </.link>
    """
  end

  defp render_crumb(%{patch: patch} = crumb, false) when is_binary(patch) do
    assigns = %{crumb: crumb}

    ~H"""
    <.link
      patch={@crumb.patch}
      class="text-text-secondary hover:text-text transition-colors truncate max-w-[200px] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring"
    >
      <.icon
        :if={@crumb[:icon]}
        name={@crumb[:icon]}
        class="size-4 inline-block mr-1 align-text-bottom"
      />
      {render_slot(@crumb)}
    </.link>
    """
  end

  defp render_crumb(%{href: href} = crumb, false) when is_binary(href) do
    assigns = %{crumb: crumb}

    ~H"""
    <.link
      href={@crumb.href}
      class="text-text-secondary hover:text-text transition-colors truncate max-w-[200px] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring"
    >
      <.icon
        :if={@crumb[:icon]}
        name={@crumb[:icon]}
        class="size-4 inline-block mr-1 align-text-bottom"
      />
      {render_slot(@crumb)}
    </.link>
    """
  end

  defp render_crumb(crumb, false) do
    assigns = %{crumb: crumb}

    ~H"""
    <span class="text-text-secondary truncate max-w-[200px]">
      <.icon
        :if={@crumb[:icon]}
        name={@crumb[:icon]}
        class="size-4 inline-block mr-1 align-text-bottom"
      />
      {render_slot(@crumb)}
    </span>
    """
  end
end
