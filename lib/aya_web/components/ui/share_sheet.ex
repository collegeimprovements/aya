defmodule AyaWeb.UI.ShareSheet do
  @moduledoc """
  iOS-style share sheet with drag-to-dismiss and spring physics.

  ## Positions

  Controls where the sheet appears relative to the trigger:

  - `"bottom"` (default) — bottom-center of viewport, slides up
  - `"top-start"` / `"top"` / `"top-end"` — above trigger
  - `"bottom-start"` / `"bottom-center"` / `"bottom-end"` — below trigger
  - `"left"` / `"right"` — beside trigger
  - `"center"` — centered on viewport

  ## Examples

      <.share_sheet id="share">
        <:contact name="Alice" initial="A" color="#ff0088" />
        <:action label="Copy Link" icon="hero-link" />
      </.share_sheet>

      <.share_sheet id="share2" position="right">
        <:action label="Copy Link" icon="hero-link" />
      </.share_sheet>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  @positions ~w(bottom center top-start top top-end bottom-start bottom-center bottom-end left right)

  attr :id, :string, required: true
  attr :title, :string, default: "Share"
  attr :trigger_label, :string, default: "Share"
  attr :position, :string, default: "bottom", values: @positions
  attr :class, :any, default: nil

  slot :contact do
    attr :name, :string, required: true
    attr :initial, :string, required: true
    attr :color, :string, required: true
  end

  slot :action do
    attr :label, :string, required: true
    attr :icon, :string, required: true
  end

  def share_sheet(assigns) do
    ~H"""
    <div id={@id} phx-hook=".ShareSheet" data-position={@position} class={["inline-block", @class]}>
      <button type="button" data-trigger class="ss__trigger">
        <.icon name="hero-share" class="size-5" />
        <span>{@trigger_label}</span>
      </button>

      <div data-root class="ss__root" hidden>
        <button data-backdrop type="button" class="ss__backdrop" aria-label="Close sheet" />
        <section data-sheet class="ss" role="dialog" aria-modal="true" aria-label={@title}>
          <div class="ss__handle-row"><div class="ss__handle" /></div>
          <div class="ss__close-row">
            <button type="button" data-close class="ss__close" aria-label="Close">
              <.icon name="hero-x-mark" class="size-3" />
            </button>
          </div>
          <h3 class="ss__title">{@title}</h3>
          <div :if={@contact != []} class="ss__contacts">
            <button :for={c <- @contact} type="button" data-close class="ss__contact">
              <div class="ss__avatar" style={"background-color: #{c.color}"}>{c.initial}</div>
              <span class="ss__contact-name">{c.name}</span>
            </button>
          </div>
          <div class="ss__divider" />
          <div :if={@action != []} class="ss__actions">
            <button :for={a <- @action} type="button" data-close class="ss__action">
              <.icon name={a.icon} class="size-[18px] opacity-70" />
              <span>{a.label}</span>
            </button>
          </div>
        </section>
      </div>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".ShareSheet">
      export default {
        mounted() {
          this.root = this.el.querySelector("[data-root]")
          this.backdrop = this.root.querySelector("[data-backdrop]")
          this.sheet = this.root.querySelector("[data-sheet]")
          this.trigger = this.el.querySelector("[data-trigger]")
          this.position = this.el.dataset.position || "bottom"
          this.isOpen = false
          this.dragging = false
          this.dy = 0
          this.hiddenY = 420

          const DISMISS_PX = 92
          const DISMISS_VEL = 840
          const SPRING = "cubic-bezier(0.25, 1, 0.5, 1)"
          const DUR = 380

          // ── Positioning ──
          const isAnchored = this.position !== "bottom" && this.position !== "center"

          const positionSheet = () => {
            if (!isAnchored) return

            const tr = this.trigger.getBoundingClientRect()
            const pad = 8
            const vw = window.innerWidth
            const vh = window.innerHeight

            // Let sheet be its natural size first
            this.sheet.style.position = "fixed"
            this.sheet.style.maxWidth = "26rem"
            this.sheet.style.width = "auto"
            this.sheet.style.minWidth = "20rem"

            // Measure sheet
            const sw = this.sheet.offsetWidth
            const sh = this.sheet.offsetHeight

            let left, top

            switch (this.position) {
              case "top-start":
                left = tr.left; top = tr.top - sh - pad; break
              case "top":
                left = tr.left + tr.width / 2 - sw / 2; top = tr.top - sh - pad; break
              case "top-end":
                left = tr.right - sw; top = tr.top - sh - pad; break
              case "bottom-start":
                left = tr.left; top = tr.bottom + pad; break
              case "bottom-center":
                left = tr.left + tr.width / 2 - sw / 2; top = tr.bottom + pad; break
              case "bottom-end":
                left = tr.right - sw; top = tr.bottom + pad; break
              case "left":
                left = tr.left - sw - pad; top = tr.top + tr.height / 2 - sh / 2; break
              case "right":
                left = tr.right + pad; top = tr.top + tr.height / 2 - sh / 2; break
            }

            // Clamp to viewport
            left = Math.max(pad, Math.min(left, vw - sw - pad))
            top = Math.max(pad, Math.min(top, vh - sh - pad))

            this.sheet.style.left = `${left}px`
            this.sheet.style.top = `${top}px`
            this.sheet.style.bottom = "auto"
            this.sheet.style.margin = "0"
          }

          // ── Open ──
          this.trigger.addEventListener("click", () => {
            if (this.isOpen) return
            this.isOpen = true
            this.root.hidden = false
            document.documentElement.style.overflow = "hidden"

            if (isAnchored) {
              positionSheet()
              // Animate: scale in from trigger direction
              const origins = {
                "top-start": "bottom left", "top": "bottom center", "top-end": "bottom right",
                "bottom-start": "top left", "bottom-center": "top center", "bottom-end": "top right",
                "left": "center right", "right": "center left"
              }
              this.sheet.style.transformOrigin = origins[this.position] || "center"
              this.sheet.style.transform = "scale(0.9)"
              this.sheet.style.opacity = "0"

              requestAnimationFrame(() => {
                const a = this.sheet.animate(
                  [{ transform: "scale(0.9)", opacity: 0 }, { transform: "scale(1)", opacity: 1 }],
                  { duration: 250, easing: SPRING, fill: "both" }
                )
                a.onfinish = () => {
                  this.sheet.style.transform = ""; this.sheet.style.opacity = ""
                  a.cancel()
                }
                this.backdrop.animate(
                  [{ opacity: 0 }, { opacity: 0.5 }],
                  { duration: 250, easing: "ease-out", fill: "both" }
                )
              })
            } else if (this.position === "center") {
              this.sheet.style.position = "fixed"
              this.sheet.style.top = "50%"
              this.sheet.style.left = "50%"
              this.sheet.style.transform = "translate(-50%, -50%) scale(0.95)"
              this.sheet.style.opacity = "0"
              this.sheet.style.bottom = "auto"
              this.sheet.style.margin = "0"

              requestAnimationFrame(() => {
                const a = this.sheet.animate(
                  [
                    { transform: "translate(-50%, -50%) scale(0.95)", opacity: 0 },
                    { transform: "translate(-50%, -50%) scale(1)", opacity: 1 }
                  ],
                  { duration: 300, easing: SPRING, fill: "both" }
                )
                a.onfinish = () => {
                  this.sheet.style.transform = "translate(-50%, -50%)"
                  this.sheet.style.opacity = ""
                  a.cancel()
                }
                this.backdrop.animate(
                  [{ opacity: 0 }, { opacity: 0.5 }],
                  { duration: 250, easing: "ease-out", fill: "both" }
                )
              })
            } else {
              // Default bottom: slide up
              this.hiddenY = Math.max(this.sheet.offsetHeight + 24, 420)
              this.sheet.style.transform = `translateY(${this.hiddenY}px)`

              requestAnimationFrame(() => {
                const a = this.sheet.animate(
                  [{ transform: `translateY(${this.hiddenY}px)` }, { transform: "translateY(0)" }],
                  { duration: DUR, easing: SPRING, fill: "both" }
                )
                a.onfinish = () => { this.sheet.style.transform = "translateY(0)"; a.cancel() }
                this.backdrop.animate(
                  [{ opacity: 0 }, { opacity: 0.5 }],
                  { duration: 300, easing: "ease-out", fill: "both" }
                )
              })
            }
          })

          // ── Close ──
          const close = () => {
            if (!this.isOpen || this.dragging) return
            dismiss(this.dy)
          }

          const dismiss = (fromY) => {
            if (isAnchored) {
              // Scale out
              this.sheet.animate(
                [{ transform: "scale(1)", opacity: 1 }, { transform: "scale(0.9)", opacity: 0 }],
                { duration: 200, easing: "ease-in", fill: "both" }
              )
            } else if (this.position === "center") {
              this.sheet.animate(
                [
                  { transform: "translate(-50%, -50%) scale(1)", opacity: 1 },
                  { transform: "translate(-50%, -50%) scale(0.95)", opacity: 0 }
                ],
                { duration: 200, easing: "ease-in", fill: "both" }
              )
            } else {
              // Slide down
              this.sheet.animate(
                [{ transform: `translateY(${fromY}px)` }, { transform: `translateY(${this.hiddenY}px)` }],
                { duration: DUR, easing: SPRING, fill: "both" }
              )
            }
            this.backdrop.animate(
              [{ opacity: this.backdrop.style.opacity || "0.5" }, { opacity: 0 }],
              { duration: 280, easing: "ease-out", fill: "both" }
            )
            const delay = isAnchored || this.position === "center" ? 220 : DUR
            setTimeout(() => {
              this.root.hidden = true
              this.sheet.style.cssText = ""
              this.backdrop.style.opacity = ""
              this.sheet.getAnimations().forEach(a => a.cancel())
              this.backdrop.getAnimations().forEach(a => a.cancel())
              this.dy = 0
              this.isOpen = false
              document.documentElement.style.overflow = ""
            }, delay)
          }

          // Close triggers
          this.backdrop.addEventListener("click", close)
          this.root.querySelectorAll("[data-close]").forEach(b => b.addEventListener("click", close))
          this._onKey = (e) => { if (e.key === "Escape") close() }
          document.addEventListener("keydown", this._onKey)

          // ── Drag-to-dismiss (bottom position only) ──
          if (!isAnchored && this.position !== "center") {
            let startY = 0, startTime = 0

            this.sheet.addEventListener("pointerdown", (e) => {
              if (!this.isOpen || e.target.closest("button")) return
              this.dragging = true
              startY = e.clientY
              startTime = Date.now()
              this.dy = 0
              this.sheet.style.transition = "none"
              this.sheet.style.cursor = "grabbing"
              this.sheet.setPointerCapture(e.pointerId)
            })

            this.sheet.addEventListener("pointermove", (e) => {
              if (!this.dragging) return
              let raw = e.clientY - startY
              this.dy = raw < 0 ? raw * 0.15 : raw * 0.8
              this.sheet.style.transform = `translateY(${this.dy}px)`
              const p = Math.max(0, 1 - Math.max(0, this.dy) / this.hiddenY)
              this.backdrop.style.opacity = String(p * 0.5)
            })

            const endDrag = () => {
              if (!this.dragging) return
              this.dragging = false
              this.sheet.style.transition = ""
              this.sheet.style.cursor = ""

              const vel = (this.dy / (Date.now() - startTime)) * 1000
              if (this.dy > DISMISS_PX || vel > DISMISS_VEL) {
                dismiss(this.dy)
              } else {
                const a = this.sheet.animate(
                  [{ transform: `translateY(${this.dy}px)` }, { transform: "translateY(0)" }],
                  { duration: DUR, easing: SPRING, fill: "both" }
                )
                a.onfinish = () => { this.sheet.style.transform = "translateY(0)"; a.cancel() }
                this.backdrop.animate(
                  [{ opacity: this.backdrop.style.opacity }, { opacity: "0.5" }],
                  { duration: 250, fill: "both" }
                )
                this.dy = 0
              }
            }

            this.sheet.addEventListener("pointerup", endDrag)
            this.sheet.addEventListener("pointercancel", endDrag)
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
