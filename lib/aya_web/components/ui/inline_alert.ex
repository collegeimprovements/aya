defmodule AyaWeb.UI.InlineAlert do
  @moduledoc """
  Inline alert components for success, error, warning, and info messages.

  Unlike flash/toast notifications, these are rendered inline within the page
  content. Useful for form feedback, operation status, etc.
  """
  use Phoenix.Component

  import AyaWeb.CoreComponents, only: [icon: 1]

  @doc """
  Renders an inline alert message.

  ## Examples

      <.inline_alert type={:success}>Item saved successfully</.inline_alert>
      <.inline_alert type={:error}>Failed to save. Please try again.</.inline_alert>
      <.inline_alert type={:info} dismissible>New version available</.inline_alert>
  """
  attr :type, :atom,
    default: :info,
    values: [:info, :success, :warning, :error]

  attr :dismissible, :boolean, default: false
  attr :class, :any, default: nil
  attr :id, :string, default: nil

  slot :inner_block, required: true

  def inline_alert(assigns) do
    ~H"""
    <div
      id={@id}
      role="alert"
      class={[
        "flex items-start gap-3 rounded-md border px-4 py-3 text-sm",
        alert_style(@type),
        @class
      ]}
    >
      <.icon name={alert_icon(@type)} class="size-5 shrink-0 mt-0.5" />
      <div class="flex-1 min-w-0">
        {render_slot(@inner_block)}
      </div>
      <button
        :if={@dismissible}
        type="button"
        class="shrink-0 opacity-50 hover:opacity-80 cursor-pointer transition-opacity"
        aria-label="Dismiss"
        phx-click={@id && Phoenix.LiveView.JS.hide(to: "##{@id}")}
      >
        <.icon name="hero-x-mark" class="size-4" />
      </button>
    </div>
    """
  end

  defp alert_style(:info), do: "bg-info-soft border-info/20 text-info-text"
  defp alert_style(:success), do: "bg-success-soft border-success/20 text-success-text"
  defp alert_style(:warning), do: "bg-warning-soft border-warning/20 text-warning-text"
  defp alert_style(:error), do: "bg-error-soft border-error/20 text-error-text"

  defp alert_icon(:info), do: "hero-information-circle"
  defp alert_icon(:success), do: "hero-check-circle"
  defp alert_icon(:warning), do: "hero-exclamation-triangle"
  defp alert_icon(:error), do: "hero-exclamation-circle"
end
