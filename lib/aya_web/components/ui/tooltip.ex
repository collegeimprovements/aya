defmodule AyaWeb.UI.Tooltip do
  @moduledoc """
  Tooltip component. Positioned via JS for cross-browser support.

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
    >
      {render_slot(@inner_block)}
    </span>
    <div
      id={@id}
      role="tooltip"
      class={[
        "fixed z-[9999] px-2.5 py-1.5 text-xs leading-tight rounded-md max-w-[240px]",
        "bg-surface-invert text-text-invert shadow-md",
        "pointer-events-none opacity-0 transition-opacity duration-fast",
        @class
      ]}
      style="top:0;left:0"
      hidden
    >
      {@text}
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".Tooltip">
      export default {
        mounted() {
          const trigger = this.el
          const tipId = trigger.dataset.tooltipId
          const placement = trigger.dataset.tooltipPlacement || "top"
          const tip = document.getElementById(tipId)
          if (!tip) return

          const GAP = 8
          let showTimeout, hideTimeout

          const position = () => {
            const tr = trigger.getBoundingClientRect()
            const tip_rect = tip.getBoundingClientRect()
            const tw = tip_rect.width, th = tip_rect.height
            let top, left

            switch (placement) {
              case "bottom":
                top = tr.bottom + GAP
                left = tr.left + (tr.width - tw) / 2
                break
              case "left":
                top = tr.top + (tr.height - th) / 2
                left = tr.left - tw - GAP
                break
              case "right":
                top = tr.top + (tr.height - th) / 2
                left = tr.right + GAP
                break
              default: // top
                top = tr.top - th - GAP
                left = tr.left + (tr.width - tw) / 2
            }

            // Clamp to viewport
            left = Math.max(8, Math.min(left, window.innerWidth - tw - 8))
            top = Math.max(8, Math.min(top, window.innerHeight - th - 8))

            tip.style.top = top + "px"
            tip.style.left = left + "px"
          }

          const show = () => {
            clearTimeout(hideTimeout)
            showTimeout = setTimeout(() => {
              tip.hidden = false
              // Measure after visible
              requestAnimationFrame(() => {
                position()
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
