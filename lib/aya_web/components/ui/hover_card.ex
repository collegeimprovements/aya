defmodule AyaWeb.UI.HoverCard do
  @moduledoc """
  Content card that appears on hover/focus with smooth enter/exit animations.
  Uses CSS `@starting-style` and `popover` API for native, performant positioning.

  ## Variants

  - `"card"` — rich content card (user profiles, previews)
  - `"sheet"` — wider panel for detailed content

  ## Placements

  `"top"`, `"bottom"` (default), `"left"`, `"right"`

  ## Examples

      <.hover_card>
        <:trigger>Hover me</:trigger>
        <:content>
          <p>Rich preview content here</p>
        </:content>
      </.hover_card>

      <.hover_card variant="sheet" placement="right" width="w-96">
        <:trigger>
          <span class="text-primary cursor-pointer">@alice</span>
        </:trigger>
        <:content>
          <div class="flex gap-3">
            <img src="/img/alice.jpg" class="size-12 rounded-full" />
            <div>
              <p class="font-bold">Alice Baker</p>
              <p class="text-sm text-text-muted">Chef & Food Scientist</p>
            </div>
          </div>
        </:content>
      </.hover_card>
  """

  use Phoenix.Component

  attr :id, :string, default: nil
  attr :variant, :string, default: "card", values: ~w(card sheet)
  attr :placement, :string, default: "bottom", values: ~w(top bottom left right)
  attr :width, :string, default: nil, doc: "Tailwind width class override"
  attr :delay, :integer, default: 200, doc: "show delay in ms"
  attr :class, :any, default: nil

  slot :trigger, required: true
  slot :content, required: true

  def hover_card(assigns) do
    assigns = assign(assigns, :id, assigns.id || "hc-#{System.unique_integer([:positive])}")

    default_width = if assigns.variant == "sheet", do: "w-80", else: "w-64"
    assigns = assign(assigns, :computed_width, assigns.width || default_width)

    ~H"""
    <div
      id={@id}
      phx-hook=".HoverCard"
      class={["hc", @class]}
      data-placement={@placement}
      data-delay={@delay}
    >
      <span class="hc__trigger" data-hc-trigger>
        {render_slot(@trigger)}
      </span>
      <div
        data-hc-panel
        class={[
          "hc__panel",
          "hc__panel--#{@variant}",
          "hc__panel--#{@placement}",
          @computed_width
        ]}
        role="tooltip"
      >
        <div class="hc__arrow" data-hc-arrow />
        <div class="hc__body">
          {render_slot(@content)}
        </div>
      </div>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".HoverCard">
      export default {
        mounted() {
          this.trigger = this.el.querySelector("[data-hc-trigger]")
          this.panel = this.el.querySelector("[data-hc-panel]")
          this.arrow = this.el.querySelector("[data-hc-arrow]")
          this.placement = this.el.dataset.placement || "bottom"
          this.delay = parseInt(this.el.dataset.delay) || 200
          this.showTimer = null
          this.hideTimer = null
          this.visible = false

          const show = () => {
            clearTimeout(this.hideTimer)
            if (this.visible) return
            this.showTimer = setTimeout(() => {
              this.position()
              this.panel.classList.add("hc__panel--visible")
              this.visible = true
            }, this.delay)
          }

          const hide = () => {
            clearTimeout(this.showTimer)
            if (!this.visible) return
            this.hideTimer = setTimeout(() => {
              this.panel.classList.remove("hc__panel--visible")
              this.visible = false
            }, 150)
          }

          // Keep open when hovering panel
          this.trigger.addEventListener("mouseenter", show)
          this.trigger.addEventListener("mouseleave", hide)
          this.trigger.addEventListener("focusin", show)
          this.trigger.addEventListener("focusout", hide)
          this.panel.addEventListener("mouseenter", () => {
            clearTimeout(this.hideTimer)
          })
          this.panel.addEventListener("mouseleave", hide)
        },

        position() {
          const tr = this.trigger.getBoundingClientRect()
          const gap = 8
          const pad = 12
          const vw = window.innerWidth
          const vh = window.innerHeight

          // Reset to measure natural size
          this.panel.style.left = ""
          this.panel.style.top = ""
          const pw = this.panel.offsetWidth
          const ph = this.panel.offsetHeight

          let left, top

          switch (this.placement) {
            case "top":
              left = tr.left + tr.width / 2 - pw / 2
              top = tr.top - ph - gap
              break
            case "bottom":
              left = tr.left + tr.width / 2 - pw / 2
              top = tr.bottom + gap
              break
            case "left":
              left = tr.left - pw - gap
              top = tr.top + tr.height / 2 - ph / 2
              break
            case "right":
              left = tr.right + gap
              top = tr.top + tr.height / 2 - ph / 2
              break
          }

          // Clamp to viewport
          left = Math.max(pad, Math.min(left, vw - pw - pad))
          top = Math.max(pad, Math.min(top, vh - ph - pad))

          this.panel.style.left = `${left}px`
          this.panel.style.top = `${top}px`

          // Position arrow
          if (this.arrow) {
            const tcx = tr.left + tr.width / 2
            const tcy = tr.top + tr.height / 2
            if (this.placement === "top" || this.placement === "bottom") {
              this.arrow.style.left = `${Math.max(12, Math.min(tcx - left, pw - 12))}px`
            } else {
              this.arrow.style.top = `${Math.max(12, Math.min(tcy - top, ph - 12))}px`
            }
          }
        }
      }
    </script>
    """
  end
end
