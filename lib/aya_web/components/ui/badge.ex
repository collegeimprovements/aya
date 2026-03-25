defmodule AyaWeb.UI.Badge do
  @moduledoc """
  Status and category badge components.
  """
  use Phoenix.Component

  @doc """
  Renders a badge with semantic color variants.

  ## Examples

      <.badge>Default</.badge>
      <.badge variant="success">Published</.badge>
      <.badge variant="warning" size="lg">Draft</.badge>
  """
  attr :variant, :string,
    default: "default",
    values: ~w(default primary secondary accent info success warning error)

  attr :size, :string, default: "sm", values: ~w(sm md lg)
  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def badge(assigns) do
    ~H"""
    <span
      class={[
        "inline-flex items-center font-medium rounded-full max-w-full",
        badge_size(@size),
        badge_variant(@variant),
        @class
      ]}
      {@rest}
    >
      <span class="truncate">{render_slot(@inner_block)}</span>
    </span>
    """
  end

  defp badge_size("sm"), do: "px-2 py-0.5 text-xs"
  defp badge_size("md"), do: "px-2.5 py-1 text-xs"
  defp badge_size("lg"), do: "px-3 py-1 text-sm"

  defp badge_variant("default"), do: "bg-surface-alt text-text-secondary"
  defp badge_variant("primary"), do: "bg-primary-soft text-primary"
  defp badge_variant("secondary"), do: "bg-secondary-soft text-secondary"
  defp badge_variant("accent"), do: "bg-accent-soft text-accent"
  defp badge_variant("info"), do: "bg-info-soft text-info"
  defp badge_variant("success"), do: "bg-success-soft text-success"
  defp badge_variant("warning"), do: "bg-warning-soft text-warning"
  defp badge_variant("error"), do: "bg-error-soft text-error"
end
