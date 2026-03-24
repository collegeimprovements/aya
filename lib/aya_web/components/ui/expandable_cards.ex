defmodule AyaWeb.UI.ExpandableCards do
  @moduledoc """
  App Store-style expandable card grid using the View Transitions API.

  Cards display in an alternating 60/40% flex grid. Clicking a card
  morphs it to a centered detail view using browser-native view transitions —
  no scale distortion, no manual FLIP, 120fps compositor-driven.

  Falls back to instant state change on unsupported browsers.

  ## Examples

      <.expandable_cards id="featured">
        <:header>
          <h2 class="text-2xl font-bold tracking-tight">Today</h2>
        </:header>
        <:card id="travel" image="/images/travel.jpg" category="Travel" title="5 Inspiring Apps">
          <p>Detail content shown when expanded...</p>
        </:card>
        <:card id="hats" image="/images/hats.jpg" category="Style" title="Hat Life" theme="dark">
          <p>More detail content...</p>
        </:card>
      </.expandable_cards>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, required: true
  attr :class, :any, default: nil

  slot :header

  slot :card, required: true do
    attr :id, :string, required: true
    attr :image, :string
    attr :category, :string
    attr :title, :string, required: true
    attr :theme, :string, doc: ~s("dark" for dark text on light images)
  end

  def expandable_cards(assigns) do
    ~H"""
    <div id={@id} phx-hook=".ExpandableCards" class={["ec", @class]}>
      <div :if={@header != []} class="ec__header">
        {render_slot(@header)}
      </div>
      <ul class="ec__grid">
        <li
          :for={card <- @card}
          class={["ec__item", card[:theme] && "ec__item--#{card[:theme]}"]}
          data-card-id={card.id}
        >
          <div data-card class="ec__card">
            <div class="ec__image">
              <img :if={card[:image]} src={card[:image]} alt="" loading="lazy" />
              <div :if={!card[:image]} class="ec__image-placeholder" />
            </div>
            <div class="ec__info">
              <span :if={card[:category]} class="ec__category">{card[:category]}</span>
              <h3 class="ec__title">{card.title}</h3>
            </div>
            <div data-detail class="ec__detail" hidden>
              {render_slot(card)}
            </div>
            <button type="button" data-card-close class="ec__close" hidden aria-label="Close">
              <.icon name="hero-x-mark" class="size-5" />
            </button>
          </div>
        </li>
      </ul>
      <div data-overlay class="ec__overlay" />
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".ExpandableCards">
      export default {
        mounted() {
          this.overlay = this.el.querySelector("[data-overlay]")
          this.expanded = null
          this.busy = false

          this.el.querySelectorAll("[data-card]").forEach(card => {
            card.addEventListener("click", (e) => {
              if (this.expanded || e.target.closest("[data-card-close]")) return
              this.open(card.closest("[data-card-id]"))
            })
          })

          this.el.querySelectorAll("[data-card-close]").forEach(btn => {
            btn.addEventListener("click", () => this.close())
          })

          this.overlay.addEventListener("click", () => this.close())
          this._onKey = (e) => { if (e.key === "Escape" && this.expanded) this.close() }
          document.addEventListener("keydown", this._onKey)
        },

        open(item) {
          if (this.busy) return
          this.busy = true

          const card = item.querySelector("[data-card]")
          const detail = card.querySelector("[data-detail]")
          const closeBtn = card.querySelector("[data-card-close]")
          const itemH = item.offsetHeight

          const apply = () => {
            item.style.minHeight = `${itemH}px`
            item.style.visibility = "hidden"
            card.dataset.expanded = ""
            card.style.visibility = "visible"
            detail.hidden = false
            closeBtn.hidden = false
            this.overlay.classList.add("active")
            document.documentElement.style.overflow = "hidden"
          }

          this.morph("ec-open", card, apply, () => { this.busy = false })
          this.expanded = { item, card, detail, closeBtn }
        },

        close() {
          if (this.busy || !this.expanded) return
          this.busy = true

          const { item, card, detail, closeBtn } = this.expanded

          const apply = () => {
            delete card.dataset.expanded
            card.style.visibility = ""
            detail.hidden = true
            closeBtn.hidden = true
            item.style.minHeight = ""
            item.style.visibility = ""
            this.overlay.classList.remove("active")
            document.documentElement.style.overflow = ""
          }

          this.morph("ec-close", card, apply, () => {
            this.expanded = null
            this.busy = false
          })
        },

        // View Transitions API wrapper with instant fallback
        morph(name, el, apply, done) {
          if (!document.startViewTransition) {
            apply()
            done()
            return
          }

          el.style.viewTransitionName = name
          const t = document.startViewTransition(() => apply())

          t.finished.then(() => {
            el.style.viewTransitionName = ""
            done()
          }).catch(() => {
            el.style.viewTransitionName = ""
            done()
          })
        },

        destroyed() {
          document.removeEventListener("keydown", this._onKey)
          if (this.expanded) document.documentElement.style.overflow = ""
        }
      }
    </script>
    """
  end
end
