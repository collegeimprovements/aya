defmodule AyaWeb.UI.SplitPane do
  @moduledoc """
  Master-detail split pane — sidebar list on the left, detail panel on the right.
  Clicking a sidebar item reveals its content in the detail panel with a smooth transition.

  ## Examples

      <.split_pane id="recipes">
        <:item id="bread" title="Sourdough Bread" subtitle="Baking · 4h" image="/img/bread.jpg">
          <h3 class="text-lg font-bold">Sourdough Bread</h3>
          <p>Full recipe details...</p>
        </:item>
        <:item id="ramen" title="Miso Ramen" subtitle="Soup · 45min">
          <p>Ramen details...</p>
        </:item>
      </.split_pane>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, required: true
  attr :sidebar_width, :string, default: "w-80", doc: "Tailwind width class for sidebar"
  attr :searchable, :boolean, default: false, doc: "show search input in sidebar"
  attr :search_placeholder, :string, default: "Search..."

  attr :transition, :string,
    default: "fade",
    values: ~w(fade left right top bottom),
    doc: "content panel enter direction"

  attr :class, :any, default: nil

  slot :item, required: true do
    attr :id, :string, required: true
    attr :title, :string, required: true
    attr :subtitle, :string
    attr :image, :string
    attr :icon, :string
    attr :badge, :string
    attr :active, :boolean
  end

  def split_pane(assigns) do
    active_id =
      Enum.find_value(assigns.item, fn item ->
        if item[:active], do: item.id
      end) || hd(assigns.item).id

    assigns = assign(assigns, :active_id, active_id)

    ~H"""
    <div
      id={@id}
      phx-hook=".SplitPane"
      class={["sp", @class]}
      data-active={@active_id}
      data-transition={@transition}
    >
      <%!-- Sidebar --%>
      <div class={["sp__sidebar", @sidebar_width]}>
        <div :if={@searchable} class="sp__search">
          <.icon name="hero-magnifying-glass-mini" class="size-4 text-text-muted shrink-0" />
          <input
            type="text"
            placeholder={@search_placeholder}
            data-sp-search
            class="sp__search-input"
            autocomplete="off"
          />
        </div>
        <div role="tablist">
          <button
            :for={item <- @item}
            type="button"
            role="tab"
            class="sp__item"
            data-sp-id={item.id}
            aria-selected={to_string(item.id == @active_id)}
          >
            <img :if={item[:image]} src={item[:image]} alt="" class="sp__thumb" loading="lazy" />
            <div :if={item[:icon] && !item[:image]} class="sp__icon-box">
              <.icon name={item[:icon]} class="size-4.5" />
            </div>
            <div class="sp__text">
              <span class="sp__title">{item.title}</span>
              <span :if={item[:subtitle]} class="sp__subtitle">{item[:subtitle]}</span>
            </div>
            <span
              :if={item[:badge]}
              class="sp__badge"
            >
              {item[:badge]}
            </span>
          </button>
        </div>
      </div>

      <%!-- Detail panel --%>
      <div class="sp__detail">
        <div
          :for={item <- @item}
          class="sp__panel"
          data-sp-panel={item.id}
          hidden={item.id != @active_id}
        >
          {render_slot(item)}
        </div>
        <%!-- Empty state --%>
        <div class="sp__empty" hidden>
          <.icon name="hero-cursor-arrow-ripple" class="size-10 text-text-muted opacity-40" />
          <p class="text-sm text-text-muted mt-2">Select an item to view details</p>
        </div>
      </div>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".SplitPane">
      export default {
        mounted() {
          this.items = this.el.querySelectorAll("[data-sp-id]")
          this.panels = this.el.querySelectorAll("[data-sp-panel]")
          this.activeId = this.el.dataset.active

          this.items.forEach(item => {
            item.addEventListener("click", () => this.select(item.dataset.spId))
          })

          // Sidebar search filtering
          const searchInput = this.el.querySelector("[data-sp-search]")
          if (searchInput) {
            searchInput.addEventListener("input", () => {
              const q = searchInput.value.toLowerCase()
              this.items.forEach(item => {
                const title = item.querySelector(".sp__title")?.textContent.toLowerCase() || ""
                const sub = item.querySelector(".sp__subtitle")?.textContent.toLowerCase() || ""
                item.style.display = (title.includes(q) || sub.includes(q)) ? "" : "none"
              })
            })
          }
        },

        select(id) {
          if (id === this.activeId) return
          const oldPanel = this.el.querySelector(`[data-sp-panel="${this.activeId}"]`)
          const newPanel = this.el.querySelector(`[data-sp-panel="${id}"]`)
          const dir = this.el.dataset.transition || "fade"

          // Transition offsets
          const enters = {
            fade:   { transform: "none",              opacity: 0 },
            left:   { transform: "translateX(-16px)",  opacity: 0 },
            right:  { transform: "translateX(16px)",   opacity: 0 },
            top:    { transform: "translateY(-12px)",  opacity: 0 },
            bottom: { transform: "translateY(12px)",   opacity: 0 }
          }
          const from = enters[dir] || enters.fade
          const to = { transform: "none", opacity: 1 }

          // Update sidebar active state
          this.items.forEach(item => {
            item.setAttribute("aria-selected", String(item.dataset.spId === id))
          })

          // Animate panel transition
          if (oldPanel) {
            oldPanel.animate(
              [{ opacity: 1 }, { opacity: 0 }],
              { duration: 100, easing: "ease-out", fill: "forwards" }
            ).onfinish = () => {
              oldPanel.hidden = true
              oldPanel.getAnimations().forEach(a => a.cancel())

              if (newPanel) {
                newPanel.hidden = false
                newPanel.animate(
                  [from, to],
                  { duration: 200, easing: "cubic-bezier(0.22, 1.1, 0.36, 1)", fill: "forwards" }
                ).onfinish = (e) => e.target.cancel()
              }
            }
          } else if (newPanel) {
            newPanel.hidden = false
          }

          this.activeId = id
        }
      }
    </script>
    """
  end
end
