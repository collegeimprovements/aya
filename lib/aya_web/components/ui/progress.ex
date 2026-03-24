defmodule AyaWeb.UI.Progress do
  @moduledoc """
  Determinate progress bar.

  ## Examples

      <.progress value={45} />
      <.progress value={80} color="success" size="lg" show_value />
      <.progress value={@upload_progress} label="Uploading..." />
  """

  use Phoenix.Component

  @sizes %{
    "sm" => "h-1",
    "md" => "h-2",
    "lg" => "h-3"
  }

  attr :value, :integer, default: 0
  attr :max, :integer, default: 100
  attr :size, :string, default: "md", values: Map.keys(@sizes)
  attr :color, :string, default: "primary", values: ~w(primary secondary success warning error)
  attr :label, :string, default: nil
  attr :show_value, :boolean, default: false
  attr :class, :any, default: nil

  def progress(assigns) do
    pct = min(100, max(0, round(assigns.value / assigns.max * 100)))
    assigns = assign(assigns, :pct, pct)

    ~H"""
    <div
      class={["w-full", @class]}
      role="progressbar"
      aria-valuenow={@pct}
      aria-valuemin="0"
      aria-valuemax="100"
      aria-label={@label || "Progress"}
    >
      <div :if={@label || @show_value} class="flex items-center justify-between mb-1.5">
        <span :if={@label} class="text-sm font-medium text-text">{@label}</span>
        <span :if={@show_value} class="text-sm tabular-nums text-text-secondary">{@pct}%</span>
      </div>
      <div class={["w-full rounded-full bg-surface-alt overflow-hidden", bar_size(@size)]}>
        <div
          class={["h-full rounded-full transition-[width] duration-300 ease-out", fill_color(@color)]}
          style={"width: #{@pct}%"}
        />
      </div>
    </div>
    """
  end

  defp bar_size("sm"), do: "h-1"
  defp bar_size("md"), do: "h-2"
  defp bar_size("lg"), do: "h-3"

  defp fill_color("primary"), do: "bg-primary"
  defp fill_color("secondary"), do: "bg-secondary"
  defp fill_color("success"), do: "bg-success"
  defp fill_color("warning"), do: "bg-warning"
  defp fill_color("error"), do: "bg-error"
  defp fill_color(_), do: "bg-primary"
end
