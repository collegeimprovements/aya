defmodule AyaWeb.UI.Tooltip do
  @moduledoc """
  Tooltip component. Positioned via CSS Anchor Positioning.

  ## Examples

      <.tooltip id="save-tip" text="Save your changes">
        <button>Save</button>
      </.tooltip>

      <.tooltip id="info-tip" text="Click to learn more" placement="bottom">
        <.icon name="hero-question-mark-circle" class="size-5" />
      </.tooltip>
  """

  use Phoenix.Component

  attr :id, :string, required: true
  attr :text, :string, required: true
  attr :placement, :string, default: "top", values: ~w(top bottom left right)
  attr :class, :any, default: nil

  slot :inner_block, required: true

  def tooltip(assigns) do
    ~H"""
    <span
      class="inline-flex"
      phx-hook=".Tooltip"
      id={"#{@id}-trigger"}
      data-tooltip-id={@id}
      data-tooltip-placement={@placement}
      style={"anchor-name: --tt-#{@id}"}
    >
      {render_slot(@inner_block)}
    </span>
    <div
      id={@id}
      role="tooltip"
      class={[
        "tooltip-panel px-2.5 py-1.5 text-xs leading-tight rounded-md max-w-[240px]",
        "bg-surface-invert text-text-invert shadow-md",
        "pointer-events-none opacity-0 transition-opacity duration-fast",
        @class
      ]}
      style={"position-anchor: --tt-#{@id}"}
      data-placement={@placement}
      hidden
    >
      {@text}
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".Tooltip">
      export default {
        mounted() {
          const trigger = this.el
          const tipId = trigger.dataset.tooltipId
          const tip = document.getElementById(tipId)
          if (!tip) return

          let showTimeout, hideTimeout

          const show = () => {
            clearTimeout(hideTimeout)
            showTimeout = setTimeout(() => {
              tip.hidden = false
              requestAnimationFrame(() => {
                tip.style.opacity = "1"
              })
            }, 200)
          }

          const hide = () => {
            clearTimeout(showTimeout)
            hideTimeout = setTimeout(() => {
              tip.style.opacity = "0"
              setTimeout(() => { tip.hidden = true }, 150)
            }, 100)
          }

          trigger.addEventListener("mouseenter", show)
          trigger.addEventListener("mouseleave", hide)
          trigger.addEventListener("focusin", show)
          trigger.addEventListener("focusout", hide)

          this._cleanup = () => {
            trigger.removeEventListener("mouseenter", show)
            trigger.removeEventListener("mouseleave", hide)
            trigger.removeEventListener("focusin", show)
            trigger.removeEventListener("focusout", hide)
            tip.hidden = true
          }
        },

        destroyed() {
          this._cleanup?.()
        }
      }
    </script>
    """
  end
end
