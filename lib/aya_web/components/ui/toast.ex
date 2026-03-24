defmodule AyaWeb.UI.Toast do
  @moduledoc """
  Sonner-style toast notification system.

  ## Setup

  Place `<.toast_container flash={@flash} />` in your LiveView or layout.
  Place `<.toast_trigger />` in LiveViews that use rich `push_event` toasts.

  ## Styles

  - Default: clean white/dark card (Sonner's signature look)
  - `rich_colors`: type-specific colored backgrounds (success=green, error=red, etc.)

  ## Flash toasts

      put_flash(socket, :info, "Saved!")

  ## Rich toasts

      push_event(socket, "toast:show", %{
        kind: "success", title: "Published", description: "Your recipe is live.", duration: 6000
      })
  """

  use Phoenix.Component

  attr :position, :string,
    default: "bottom-right",
    values: ~w(top-left top-center top-right bottom-left bottom-center bottom-right)

  attr :rich_colors, :boolean, default: false, doc: "use type-specific colored backgrounds"
  attr :flash, :map, default: %{}
  attr :class, :any, default: nil

  def toast_container(assigns) do
    [y, x] =
      case assigns.position do
        "top-left" -> ["top", "left"]
        "top-center" -> ["top", "center"]
        "top-right" -> ["top", "right"]
        "bottom-left" -> ["bottom", "left"]
        "bottom-center" -> ["bottom", "center"]
        _ -> ["bottom", "right"]
      end

    assigns = assign(assigns, y: y, x: x)

    ~H"""
    <ol
      data-aya-toaster
      data-y={@y}
      data-x={@x}
      data-rich-colors={@rich_colors && "true"}
      class={@class}
    >
    </ol>
    <span
      :if={Phoenix.Flash.get(@flash, :info)}
      id="toast-flash-info"
      data-toast-flash="info"
      data-toast-message={Phoenix.Flash.get(@flash, :info)}
      hidden
    />
    <span
      :if={Phoenix.Flash.get(@flash, :error)}
      id="toast-flash-error"
      data-toast-flash="error"
      data-toast-message={Phoenix.Flash.get(@flash, :error)}
      hidden
    />
    """
  end

  attr :id, :string, default: "toast-trigger"

  def toast_trigger(assigns) do
    ~H"""
    <div id={@id} phx-hook=".ToastTrigger" class="hidden">
      <script :type={Phoenix.LiveView.ColocatedHook} name=".ToastTrigger">
        export default {
          mounted() {
            this.handleEvent("toast:show", (data) => {
              window.AyaToast?.addToast(data);
            });
          }
        }
      </script>
    </div>
    """
  end
end
