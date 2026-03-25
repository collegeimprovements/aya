defmodule AyaWeb.UI.Toast do
  @moduledoc """
  Sonner-style toast notification system.

  ## Setup

  Place `<.toast_container flash={@flash} />` in your LiveView or layout.
  Place `<.toast_trigger />` in LiveViews that use rich `push_event` toasts.

  ## Container attrs

  - `position` — one of `top-left`, `top-center`, `top-right`, `bottom-left`, `bottom-center`, `bottom-right` (default: `bottom-right`)
  - `dir` — text direction: `auto`, `ltr`, or `rtl` (default: `auto`)
  - `duration` — default auto-dismiss time in ms (default: `4000`). Error and loading toasts are infinite by default. Per-toast duration can override this via `push_event`.
  - `rich_colors` — type-specific colored backgrounds (success=green, error=red, etc.)

  ## Styles

  - Default: clean white/dark card (Sonner's signature look)
  - `rich_colors`: type-specific colored backgrounds

  ## Flash toasts

      put_flash(socket, :info, "Saved!")

  ## Rich toasts (via push_event)

      push_event(socket, "toast:show", %{
        kind: "success",
        title: "Published",
        description: "Your recipe is live.",
        duration: 6000
      })

  Per-toast `duration` overrides the container default. Set `0` for infinite.

  ## Examples

      <%!-- Default: bottom-right, 4s dismiss --%>
      <.toast_container flash={@flash} />

      <%!-- Top-center, colored, 6s default dismiss --%>
      <.toast_container flash={@flash} position="top-center" rich_colors duration={6000} />

      <%!-- RTL layout --%>
      <.toast_container flash={@flash} dir="rtl" />
  """

  use Phoenix.Component

  attr :position, :string,
    default: "bottom-right",
    values: ~w(top-left top-center top-right bottom-left bottom-center bottom-right)

  attr :dir, :string,
    default: "auto",
    values: ~w(auto ltr rtl),
    doc: "text direction — auto, ltr, or rtl"

  attr :duration, :integer,
    default: nil,
    doc: "default dismiss time in ms (nil = 4000; error/loading = infinite)"

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
      data-duration={@duration}
      dir={if @dir != "auto", do: @dir}
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
