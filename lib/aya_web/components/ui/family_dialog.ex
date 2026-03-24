defmodule AyaWeb.UI.FamilyDialog do
  @moduledoc """
  Family-style dialog: a compact list where clicking an item expands it
  into a centered dialog card using View Transitions API.

  ## Examples

      <.family_dialog id="recipes">
        <:item id="bread" title="Sourdough Bread" subtitle="Baking · 4h"
               image="https://picsum.photos/seed/bread/80/80">
          <p>A classic artisan bread with crispy crust and chewy interior.</p>
          <p>Requires active sourdough starter and patience for bulk fermentation.</p>
        </:item>
        <:item id="ramen" title="Miso Ramen" subtitle="Soup · 45min"
               image="https://picsum.photos/seed/ramen/80/80">
          <p>Rich umami broth with handmade noodles.</p>
        </:item>
      </.family_dialog>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, required: true
  attr :class, :any, default: nil

  slot :item, required: true do
    attr :id, :string, required: true
    attr :title, :string, required: true
    attr :subtitle, :string
    attr :image, :string
  end

  def family_dialog(assigns) do
    ~H"""
    <div id={@id} phx-hook=".FamilyDialog" class={["fd", @class]}>
      <ul class="fd__list">
        <li :for={item <- @item} class="fd__item" data-fd-id={item.id}>
          <button type="button" class="fd__trigger" data-fd-open={item.id}>
            <img :if={item[:image]} src={item[:image]} alt="" class="fd__avatar" loading="lazy" />
            <div :if={!item[:image]} class="fd__avatar fd__avatar--placeholder">
              {String.first(item.title)}
            </div>
            <div class="fd__info">
              <span class="fd__title">{item.title}</span>
              <span :if={item[:subtitle]} class="fd__subtitle">{item[:subtitle]}</span>
            </div>
            <.icon name="hero-chevron-right-mini" class="size-4 text-text-muted shrink-0" />
          </button>
        </li>
      </ul>

      <%!-- Expanded dialog (hidden, populated by JS) --%>
      <dialog data-fd-dialog class="fd__dialog">
        <div data-fd-backdrop class="fd__backdrop" />
        <div data-fd-card class="fd__card">
          <%!-- Header with image + title (populated by JS from the clicked item) --%>
          <div class="fd__card-header">
            <div data-fd-card-avatar class="fd__card-avatar"></div>
            <div>
              <h3 data-fd-card-title class="fd__card-title"></h3>
              <p data-fd-card-subtitle class="fd__card-subtitle"></p>
            </div>
            <button type="button" data-fd-close class="fd__card-close" aria-label="Close">
              <.icon name="hero-x-mark" class="size-4" />
            </button>
          </div>
          <%!-- Detail content for each item (hidden until that item is selected) --%>
          <div :for={item <- @item} data-fd-content={item.id} class="fd__card-body" hidden>
            {render_slot(item)}
          </div>
        </div>
      </dialog>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".FamilyDialog">
      export default {
        mounted() {
          this.dialog = this.el.querySelector("[data-fd-dialog]")
          this.backdrop = this.dialog.querySelector("[data-fd-backdrop]")
          this.card = this.dialog.querySelector("[data-fd-card]")
          this.activeId = null
          this.busy = false

          // Open triggers
          this.el.querySelectorAll("[data-fd-open]").forEach(btn => {
            btn.addEventListener("click", () => this.open(btn.dataset.fdOpen))
          })

          // Close
          this.backdrop.addEventListener("click", () => this.close())
          this.dialog.querySelector("[data-fd-close]").addEventListener("click", () => this.close())
          document.addEventListener("keydown", this._onKey = (e) => {
            if (e.key === "Escape" && this.activeId) { e.preventDefault(); this.close() }
          })
        },

        open(id) {
          if (this.busy || this.activeId) return
          this.busy = true
          this.activeId = id

          const item = this.el.querySelector(`[data-fd-id="${id}"]`)
          const trigger = item.querySelector(".fd__trigger")
          const avatar = item.querySelector(".fd__avatar")
          const title = item.querySelector(".fd__title")
          const subtitle = item.querySelector(".fd__subtitle")

          // Populate dialog card
          const cardAvatar = this.card.querySelector("[data-fd-card-avatar]")
          const cardTitle = this.card.querySelector("[data-fd-card-title]")
          const cardSubtitle = this.card.querySelector("[data-fd-card-subtitle]")

          if (avatar?.tagName === "IMG") {
            cardAvatar.innerHTML = `<img src="${avatar.src}" alt="" class="fd__avatar" />`
          } else if (avatar) {
            cardAvatar.innerHTML = `<div class="fd__avatar fd__avatar--placeholder">${avatar.textContent}</div>`
          }
          cardTitle.textContent = title?.textContent || ""
          cardSubtitle.textContent = subtitle?.textContent || ""

          // Show correct content panel
          this.dialog.querySelectorAll("[data-fd-content]").forEach(el => {
            el.hidden = el.dataset.fdContent !== id
          })

          const apply = () => {
            item.style.opacity = "0"
            this.dialog.showModal()
            document.documentElement.style.overflow = "hidden"
          }

          if (document.startViewTransition) {
            trigger.style.viewTransitionName = "fd-item"
            this.card.style.viewTransitionName = "fd-item"
            const t = document.startViewTransition(apply)
            t.finished.then(() => {
              trigger.style.viewTransitionName = ""
              this.card.style.viewTransitionName = ""
              this.busy = false
            }).catch(() => { this.busy = false })
          } else {
            apply()
            this.busy = false
          }
        },

        close() {
          if (this.busy || !this.activeId) return
          this.busy = true

          const item = this.el.querySelector(`[data-fd-id="${this.activeId}"]`)
          const trigger = item?.querySelector(".fd__trigger")

          const apply = () => {
            this.dialog.close()
            if (item) item.style.opacity = ""
            document.documentElement.style.overflow = ""
          }

          if (document.startViewTransition && trigger) {
            trigger.style.viewTransitionName = "fd-item"
            this.card.style.viewTransitionName = "fd-item"
            const t = document.startViewTransition(apply)
            t.finished.then(() => {
              trigger.style.viewTransitionName = ""
              this.card.style.viewTransitionName = ""
              this.activeId = null
              this.busy = false
            }).catch(() => { this.activeId = null; this.busy = false })
          } else {
            apply()
            this.activeId = null
            this.busy = false
          }
        },

        destroyed() {
          document.removeEventListener("keydown", this._onKey)
          document.documentElement.style.overflow = ""
        }
      }
    </script>
    """
  end
end
