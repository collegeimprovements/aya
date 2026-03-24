defmodule AyaWeb.UI.Banner do
  @moduledoc """
  Full-width notification banner for announcements, alerts, maintenance notices.

  ## Examples

      <.banner variant={:info}>
        New recipes are published every Monday.
      </.banner>

      <.banner variant={:warning} dismissible={false}>
        Scheduled maintenance on Sunday 2am-4am UTC.
        <:action>
          <.styled_link href="/status" variant="subtle">Details</.styled_link>
        </:action>
      </.banner>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, default: nil
  attr :variant, :atom, default: :info, values: [:info, :success, :warning, :error]
  attr :dismissible, :boolean, default: true
  attr :class, :any, default: nil

  slot :inner_block, required: true
  slot :action

  def banner(assigns) do
    assigns =
      assign_new(assigns, :generated_id, fn ->
        assigns[:id] || "banner-#{System.unique_integer([:positive])}"
      end)

    ~H"""
    <div
      id={@generated_id}
      role="alert"
      class={[
        "flex items-center gap-3 px-4 py-3 text-sm",
        banner_style(@variant),
        @class
      ]}
    >
      <.icon name={banner_icon(@variant)} class="size-5 shrink-0" />
      <div class="flex-1 min-w-0">
        {render_slot(@inner_block)}
      </div>
      <div :if={@action != []} class="shrink-0">
        {render_slot(@action)}
      </div>
      <button
        :if={@dismissible}
        type="button"
        phx-click={
          Phoenix.LiveView.JS.hide(
            to: "##{@generated_id}",
            transition: {"transition-opacity duration-200", "opacity-100", "opacity-0"}
          )
        }
        class="shrink-0 rounded-md p-1 transition-colors hover:bg-black/5 dark:hover:bg-white/10 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring cursor-pointer"
        aria-label="Dismiss"
      >
        <.icon name="hero-x-mark-mini" class="size-4" />
      </button>
    </div>
    """
  end

  defp banner_style(:info), do: "bg-info-soft text-info-text border-b border-info/20"
  defp banner_style(:success), do: "bg-success-soft text-success-text border-b border-success/20"
  defp banner_style(:warning), do: "bg-warning-soft text-warning-text border-b border-warning/20"
  defp banner_style(:error), do: "bg-error-soft text-error-text border-b border-error/20"

  defp banner_icon(:info), do: "hero-information-circle"
  defp banner_icon(:success), do: "hero-check-circle"
  defp banner_icon(:warning), do: "hero-exclamation-triangle"
  defp banner_icon(:error), do: "hero-exclamation-circle"
end
