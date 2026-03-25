defmodule AyaWeb.UI.EngagementStats do
  @moduledoc """
  Social-style engagement stats bar with animated number counters
  and toggleable like/bookmark/repost buttons.

  ## Examples

      <.engagement_stats
        id="post-stats"
        views={1200}
        reposts={15}
        likes={97}
        bookmarks={10}
      />
  """

  use Phoenix.Component

  attr :id, :string, required: true
  attr :views, :integer, default: 0
  attr :reposts, :integer, default: 0
  attr :likes, :integer, default: 0
  attr :bookmarks, :integer, default: 0
  attr :class, :any, default: nil

  def engagement_stats(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook=".EngagementStats"
      class={["es", @class]}
      data-views={@views}
      data-reposts={@reposts}
      data-likes={@likes}
      data-bookmarks={@bookmarks}
    >
      <%!-- Views (not toggleable) --%>
      <div class="es__item">
        <svg
          class="es__icon"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <line x1="18" x2="18" y1="20" y2="10" /><line x1="12" x2="12" y1="20" y2="4" /><line
            x1="6"
            x2="6"
            y1="20"
            y2="14"
          />
        </svg>
        <span class="es__count" data-stat="views">{format_compact(@views)}</span>
      </div>

      <%!-- Repost --%>
      <button
        type="button"
        class="es__item es__btn"
        data-toggle="reposts"
        aria-label={"Repost #{format_compact(@reposts)}"}
      >
        <svg
          class="es__icon es__icon--repost"
          viewBox="0 0 24 20"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <path d="m2 9 3-3 3 3" /><path d="M13 18H7a2 2 0 0 1-2-2V6" /><path d="m22 15-3 3-3-3" /><path d="M11 6h6a2 2 0 0 1 2 2v10" />
        </svg>
        <span class="es__count" data-stat="reposts">{format_compact(@reposts)}</span>
      </button>

      <%!-- Like --%>
      <button
        type="button"
        class="es__item es__btn"
        data-toggle="likes"
        aria-label={"Like #{format_compact(@likes)}"}
      >
        <svg
          class="es__icon es__icon--like"
          viewBox="0 0 24 22"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <path
            class="es__fill"
            d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"
          />
        </svg>
        <span class="es__count" data-stat="likes">{format_compact(@likes)}</span>
      </button>

      <%!-- Bookmark --%>
      <button
        type="button"
        class="es__item es__btn"
        data-toggle="bookmarks"
        aria-label={"Bookmark #{format_compact(@bookmarks)}"}
      >
        <svg
          class="es__icon es__icon--bookmark"
          viewBox="0 0 24 22"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <path class="es__fill" d="m19 21-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z" />
        </svg>
        <span class="es__count" data-stat="bookmarks">{format_compact(@bookmarks)}</span>
      </button>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".EngagementStats">
      export default {
        mounted() {
          this.stats = {
            views: parseInt(this.el.dataset.views),
            reposts: parseInt(this.el.dataset.reposts),
            likes: parseInt(this.el.dataset.likes),
            bookmarks: parseInt(this.el.dataset.bookmarks)
          }
          this.selected = { reposts: false, likes: false, bookmarks: false }

          // Toggle buttons
          this.el.querySelectorAll("[data-toggle]").forEach(btn => {
            btn.addEventListener("click", () => {
              const key = btn.dataset.toggle
              this.selected[key] = !this.selected[key]
              btn.classList.toggle("es__btn--active", this.selected[key])

              // Animate icon
              const icon = btn.querySelector(".es__icon")
              icon.animate([
                { transform: "scale(1)" },
                { transform: this.selected[key] ? "scale(1.3)" : "scale(0.8)" },
                { transform: "scale(1)" }
              ], { duration: 300, easing: "cubic-bezier(0.22, 1.1, 0.36, 1)" })

              // Update count with animated number transition
              const delta = this.selected[key] ? 1 : -1
              const countEl = btn.querySelector("[data-stat]")
              this.animateCount(countEl, this.stats[key] + (this.selected[key] ? 1 : 0))
            })
          })

          // Auto-increment views periodically
          this.interval = setInterval(() => {
            this.stats.views += Math.floor(Math.random() * 900) + 100
            this.animateCount(
              this.el.querySelector('[data-stat="views"]'),
              this.stats.views
            )
            // Randomly bump other stats
            if (Math.random() > 0.5) {
              this.stats.likes += Math.floor(Math.random() * 50) + 10
              this.animateCount(
                this.el.querySelector('[data-stat="likes"]'),
                this.stats.likes + (this.selected.likes ? 1 : 0)
              )
            }
            if (Math.random() > 0.7) {
              this.stats.reposts += Math.floor(Math.random() * 3) + 1
              this.animateCount(
                this.el.querySelector('[data-stat="reposts"]'),
                this.stats.reposts + (this.selected.reposts ? 1 : 0)
              )
            }
            if (Math.random() > 0.8) {
              this.stats.bookmarks += Math.floor(Math.random() * 5) + 1
              this.animateCount(
                this.el.querySelector('[data-stat="bookmarks"]'),
                this.stats.bookmarks + (this.selected.bookmarks ? 1 : 0)
              )
            }
          }, 5000)
        },

        animateCount(el, newValue) {
          const formatted = this.formatCompact(newValue)
          if (el.textContent === formatted) return

          // Slide old number out, new number in
          el.animate([
            { transform: "translateY(0)", opacity: 1 },
            { transform: "translateY(-100%)", opacity: 0 }
          ], { duration: 150, easing: "ease-in", fill: "forwards" }).onfinish = () => {
            el.textContent = formatted
            el.animate([
              { transform: "translateY(100%)", opacity: 0 },
              { transform: "translateY(0)", opacity: 1 }
            ], { duration: 200, easing: "cubic-bezier(0.22, 1.1, 0.36, 1)", fill: "both" })
              .onfinish = (e) => e.target.cancel()
          }
        },

        formatCompact(n) {
          if (n >= 1000000) return (n / 1000000).toFixed(1).replace(/\.0$/, "") + "M"
          if (n >= 1000) return (n / 1000).toFixed(1).replace(/\.0$/, "") + "K"
          return String(n)
        },

        destroyed() {
          clearInterval(this.interval)
        }
      }
    </script>
    """
  end

  defp format_compact(n) when n >= 1_000_000, do: "#{Float.round(n / 1_000_000, 1)}M"
  defp format_compact(n) when n >= 1_000, do: "#{Float.round(n / 1_000, 1)}K"
  defp format_compact(n), do: "#{n}"
end
