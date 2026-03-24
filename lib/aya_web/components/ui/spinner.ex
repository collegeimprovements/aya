defmodule AyaWeb.UI.Spinner do
  @moduledoc """
  Animated loading spinner.

  ## Examples

      <.spinner />
      <.spinner size="sm" color="current" />
      <.button variant="primary" phx-click="save">
        <.spinner :if={@saving} size="xs" color="current" /> Save
      </.button>
  """

  use Phoenix.Component

  @sizes %{
    "xs" => "size-3.5",
    "sm" => "size-4",
    "md" => "size-5",
    "lg" => "size-6",
    "xl" => "size-8"
  }

  attr :size, :string, default: "md", values: Map.keys(@sizes)
  attr :color, :string, default: "primary", values: ~w(primary secondary current muted)
  attr :label, :string, default: "Loading..."
  attr :class, :any, default: nil

  def spinner(assigns) do
    ~H"""
    <svg
      class={[
        "motion-safe:animate-spin",
        color_class(@color),
        spinner_size(@size),
        @class
      ]}
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      aria-hidden="true"
    >
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
    </svg>
    <span class="sr-only">{@label}</span>
    """
  end

  defp spinner_size("xs"), do: "size-3.5"
  defp spinner_size("sm"), do: "size-4"
  defp spinner_size("md"), do: "size-5"
  defp spinner_size("lg"), do: "size-6"
  defp spinner_size("xl"), do: "size-8"

  defp color_class("primary"), do: "text-primary"
  defp color_class("secondary"), do: "text-secondary"
  defp color_class("current"), do: "text-current"
  defp color_class("muted"), do: "text-text-muted"
  defp color_class(_), do: "text-primary"
end
