defmodule AyaWeb.UI.ListDetail do
  @moduledoc """
  A list where clicking an item reveals a detail panel that slides in from the right.
  The list and detail panel sit side by side — clicking another item swaps the detail content.
  Clicking the same item or a close button collapses the panel.

  ## Examples

      <.list_detail id="recipes">
        <:item id="bread" title="Sourdough Bread" subtitle="Baking · 4h" image="/img/bread.jpg">
          <h3>Sourdough Bread</h3>
          <p>Full recipe details...</p>
        </:item>
        <:item id="ramen" title="Miso Ramen" subtitle="Soup · 45min">
          <p>Ramen details...</p>
        </:item>
      </.list_detail>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, required: true
  attr :detail_width, :string, default: "w-96", doc: "Tailwind width class for detail panel"

  attr :list_width, :string,
    default: nil,
    doc: "fixed Tailwind width for list (e.g. w-72). If set, list doesn't shrink."

  attr :direction, :string,
    default: "right",
    values: ~w(left right),
    doc: "content animation direction"

  attr :class, :any, default: nil

  slot :item, required: true do
    attr :id, :string, required: true
    attr :title, :string, required: true
    attr :subtitle, :string
    attr :image, :string
    attr :icon, :string
    attr :badge, :string
  end

  def list_detail(assigns) do
    ~H"""
    <div id={@id} phx-hook=".ListDetail" class={["ld", @class]} data-direction={@direction}>
      <%!-- List --%>
      <div class={["ld__list", @list_width && "shrink-0 #{@list_width}"]}>
        <button
          :for={item <- @item}
          type="button"
          class="ld__item"
          data-ld-id={item.id}
          aria-selected="false"
        >
          <img :if={item[:image]} src={item[:image]} alt="" class="ld__thumb" loading="lazy" />
          <div :if={item[:icon] && !item[:image]} class="ld__icon-box">
            <.icon name={item[:icon]} class="size-4.5" />
          </div>
          <div class="ld__text">
            <span class="ld__title">{item.title}</span>
            <span :if={item[:subtitle]} class="ld__subtitle">{item[:subtitle]}</span>
          </div>
          <span :if={item[:badge]} class="ld__badge">{item[:badge]}</span>
          <.icon name="hero-chevron-right-mini" class="size-4 text-text-muted shrink-0 ld__chevron" />
        </button>
      </div>

      <%!-- Detail panel (always on the right) --%>
      <div class={["ld__detail", @detail_width]} data-ld-detail hidden>
        <div class="ld__detail-header">
          <button type="button" data-ld-close class="ld__close" aria-label="Close">
            <.icon name="hero-x-mark" class="size-4" />
          </button>
        </div>
        <div :for={item <- @item} class="ld__panel" data-ld-panel={item.id} hidden>
          {render_slot(item)}
        </div>
      </div>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".ListDetail">
      export default {
        mounted() {
          this.items = this.el.querySelectorAll("[data-ld-id]")
          this.detail = this.el.querySelector("[data-ld-detail]")
          this.panels = this.el.querySelectorAll("[data-ld-panel]")
          this.closeBtn = this.el.querySelector("[data-ld-close]")
          this.activeId = null
          this.ease = "cubic-bezier(0.22, 1.1, 0.36, 1)"
          this.dir = this.el.dataset.direction || "right"
          this.slideIn = this.dir === "left" ? "translateX(-20px)" : "translateX(20px)"
          this.contentSlide = this.dir === "left" ? "translateX(-12px)" : "translateX(12px)"

          this.items.forEach(item => {
            item.addEventListener("click", () => {
              const id = item.dataset.ldId
              if (id === this.activeId) {
                this.collapse()
              } else {
                this.expand(id)
              }
            })
          })

          this.closeBtn.addEventListener("click", () => this.collapse())
        },

        expand(id) {
          const isFirst = !this.activeId

          // Update list selection
          this.items.forEach(item => {
            item.setAttribute("aria-selected", String(item.dataset.ldId === id))
          })

          // Show detail panel
          if (isFirst) {
            this.detail.hidden = false
            this.detail.animate(
              [
                { transform: this.slideIn, opacity: 0, width: "0px" },
                { transform: "none", opacity: 1, width: "" }
              ],
              { duration: 300, easing: this.ease, fill: "both" }
            ).onfinish = (e) => e.target.cancel()
          }

          // Swap panel content
          const oldPanel = this.activeId ? this.el.querySelector(`[data-ld-panel="${this.activeId}"]`) : null
          const newPanel = this.el.querySelector(`[data-ld-panel="${id}"]`)

          if (oldPanel) {
            oldPanel.animate(
              [{ opacity: 1 }, { opacity: 0 }],
              { duration: 80, fill: "forwards" }
            ).onfinish = () => {
              oldPanel.hidden = true
              oldPanel.getAnimations().forEach(a => a.cancel())
              if (newPanel) {
                newPanel.hidden = false
                newPanel.animate(
                  [{ opacity: 0, transform: this.contentSlide }, { opacity: 1, transform: "none" }],
                  { duration: 200, easing: this.ease, fill: "forwards" }
                ).onfinish = (e) => e.target.cancel()
              }
            }
          } else if (newPanel) {
            newPanel.hidden = false
            newPanel.animate(
              [{ opacity: 0, transform: this.contentSlide }, { opacity: 1, transform: "none" }],
              { duration: 200, easing: this.ease, fill: "forwards" }
            ).onfinish = (e) => e.target.cancel()
          }

          this.activeId = id
        },

        collapse() {
          this.items.forEach(item => item.setAttribute("aria-selected", "false"))

          this.detail.animate(
            [
              { transform: "none", opacity: 1 },
              { transform: this.slideIn, opacity: 0 }
            ],
            { duration: 200, easing: "ease-in", fill: "forwards" }
          ).onfinish = () => {
            this.detail.hidden = true
            this.detail.getAnimations().forEach(a => a.cancel())
            this.panels.forEach(p => { p.hidden = true; p.getAnimations().forEach(a => a.cancel()) })
            this.activeId = null
          }
        }
      }
    </script>
    """
  end
end
