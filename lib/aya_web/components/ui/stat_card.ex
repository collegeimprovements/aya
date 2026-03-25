defmodule AyaWeb.UI.StatCard do
  @moduledoc """
  Dashboard metric card with value and trend indicator.

  ## Examples

      <.stat_card label="Total Recipes" value="1,234" trend="+12%" trend_direction={:up} />
      <.stat_card label="Active Users" value="89" icon="hero-users" />
      <.stat_card label="Revenue" value="$4,200" trend="-3%" trend_direction={:down}>
        <:footer>Last 30 days</:footer>
      </.stat_card>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :label, :string, required: true
  attr :value, :string, required: true
  attr :trend, :string, default: nil
  attr :trend_direction, :atom, default: nil, values: [nil, :up, :down, :neutral]
  attr :icon, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  slot :footer

  def stat_card(assigns) do
    ~H"""
    <div
      class={[
        "rounded-lg bg-surface p-5",
        "shadow-border transition-shadow duration-normal",
        "hover:shadow-border-hover",
        @class
      ]}
      {@rest}
    >
      <div class="flex items-start justify-between gap-3">
        <div class="min-w-0">
          <p class="text-sm font-medium text-text-secondary truncate">{@label}</p>
          <p class="mt-1 text-2xl font-semibold text-text tabular-nums">{@value}</p>
        </div>
        <div :if={@icon} class="shrink-0 rounded-lg bg-surface-alt p-2.5">
          <.icon name={@icon} class="size-5 text-text-muted" />
        </div>
      </div>

      <div :if={@trend} class="mt-3 flex items-center gap-1.5">
        <span class={[
          "inline-flex items-center gap-0.5 text-sm font-medium tabular-nums",
          trend_color(@trend_direction)
        ]}>
          <.icon :if={@trend_direction == :up} name="hero-arrow-up-mini" class="size-4" />
          <.icon :if={@trend_direction == :down} name="hero-arrow-down-mini" class="size-4" />
          <.icon :if={@trend_direction == :neutral} name="hero-minus-mini" class="size-4" />
          {@trend}
        </span>
      </div>

      <div :if={@footer != []} class="mt-3 pt-3 border-t border-border text-xs text-text-muted">
        {render_slot(@footer)}
      </div>
    </div>
    """
  end

  defp trend_color(:up), do: "text-success"
  defp trend_color(:down), do: "text-error"
  defp trend_color(:neutral), do: "text-text-muted"
  defp trend_color(_), do: "text-text-secondary"
end
