defmodule AyaWeb.UI.EmptyState do
  @moduledoc """
  Empty state component for when there's no data to display.
  """
  use Phoenix.Component

  import AyaWeb.CoreComponents, only: [icon: 1]

  @doc """
  Renders an empty state with icon, message, and optional action.

  ## Examples

      <.empty_state icon="hero-newspaper" title="No articles yet">
        <:description>Articles will appear here once news feeds are configured.</:description>
        <:action>
          <.button variant="primary">Add Feed</.button>
        </:action>
      </.empty_state>
  """
  attr :icon, :string, default: "hero-inbox"
  attr :title, :string, required: true
  attr :class, :any, default: nil
  attr :rest, :global

  slot :description
  slot :action

  def empty_state(assigns) do
    ~H"""
    <div class={["flex flex-col items-center justify-center py-16 text-center", @class]} {@rest}>
      <div class="size-12 rounded-full bg-surface-alt flex items-center justify-center mb-4">
        <.icon name={@icon} class="size-6 text-text-muted" />
      </div>
      <h3 class="text-sm font-semibold text-text">{@title}</h3>
      <p :for={desc <- @description} class="mt-1 text-sm text-text-muted max-w-sm">
        {render_slot(desc)}
      </p>
      <div :for={action <- @action} class="mt-6">
        {render_slot(action)}
      </div>
    </div>
    """
  end
end
