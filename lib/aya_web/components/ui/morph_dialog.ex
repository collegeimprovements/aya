defmodule AyaWeb.UI.MorphDialog do
  @moduledoc """
  Confirmation dialog with FLIP morph animation from trigger to dialog.

  The trigger button smoothly morphs into the dialog surface on open,
  and reverses on close. Uses the native `<dialog>` element for accessibility.

  ## Positions

  | Position | Behavior |
  |---|---|
  | `"bottom"` | Dialog at bottom center (default, mobile-friendly) |
  | `"center"` | Dialog in the center of the screen |
  | `"top"` | Dialog at the top center |
  | `"origin"` | Dialog expands near the trigger's position |

  ## CTA Morphing

  When `morph_cta` is true, the trigger button visually travels to become
  the confirm button on open, and reverses on close — similar to Framer
  Motion's `layoutId` pattern. Use `confirm_class` to match the confirm
  button's appearance to the trigger.

  ## Examples

      <.morph_dialog id="confirm-action" confirm_label="Delete">
        <:trigger>Delete Item</:trigger>
        <:title>Confirm Deletion</:title>
        <:body><p>This action cannot be undone.</p></:body>
      </.morph_dialog>

      <.morph_dialog id="receive" morph_cta position="origin" origin_match_width
        confirm_label="Receive" confirm_class="!bg-secondary">
        <:trigger>Receive</:trigger>
        <:title>Confirm</:title>
        <:body><p>Are you sure?</p></:body>
      </.morph_dialog>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, required: true
  attr :position, :string, default: "bottom", values: ~w(bottom center top origin)

  attr :origin_direction, :string,
    default: "auto",
    values: ~w(auto up down),
    doc: "origin: expand direction"

  attr :origin_match_width, :boolean, default: false, doc: "origin: dialog matches trigger width"

  attr :width, :integer,
    default: nil,
    doc: "explicit dialog width in px (overrides default 400px / trigger width)"

  attr :morph_cta, :boolean,
    default: false,
    doc: "animate CTA between trigger and confirm positions"

  attr :confirm_label, :string, default: "Confirm"
  attr :cancel_label, :string, default: "Cancel"
  attr :on_confirm, :string, default: nil, doc: "phx-click event for confirm button"
  attr :trigger_class, :any, default: nil, doc: "additional classes for the trigger button"
  attr :confirm_class, :any, default: nil, doc: "additional classes for the confirm button"
  attr :class, :any, default: nil

  slot :trigger, required: true
  slot :title
  slot :body, required: true

  def morph_dialog(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook=".MorphDialog"
      data-morph-cta={to_string(@morph_cta)}
      class={["inline-block", @class]}
    >
      <button type="button" data-trigger class={["morph-dialog__trigger", @trigger_class]}>
        {render_slot(@trigger)}
      </button>

      <dialog
        data-dialog
        data-position={@position}
        data-origin-dir={@origin_direction}
        data-origin-match-width={if @origin_match_width, do: "true"}
        data-width={@width}
        class="morph-dialog"
      >
        <div data-overlay class="morph-dialog__overlay" />
        <div data-surface class="morph-dialog__surface" style={@width && "--md-width: #{@width}px"}>
          <div data-content class="morph-dialog__content">
            <div :if={@title != []} class="morph-dialog__title">
              {render_slot(@title)}
            </div>
            <div class="morph-dialog__body">
              {render_slot(@body)}
            </div>
            <div class="morph-dialog__actions">
              <button type="button" data-morph-close class="morph-dialog__cancel">
                {@cancel_label}
              </button>
              <button
                type="button"
                data-morph-close
                class={["morph-dialog__confirm", @confirm_class]}
                phx-click={@on_confirm}
              >
                {@confirm_label}
              </button>
            </div>
            <button type="button" data-morph-close class="morph-dialog__x" aria-label="Close">
              <.icon name="hero-x-mark" class="size-5" />
            </button>
          </div>
        </div>
      </dialog>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".MorphDialog">
      // FLIP layout animation from trigger → dialog surface.
      // When morph_cta is enabled, a ghost CTA button travels between
      // the trigger position and the confirm button position.
      export default {
        mounted() {
          this.trigger = this.el.querySelector("[data-trigger]")
          this.trigger.style.visibility = ""
          this.dialog = this.el.querySelector("[data-dialog]")
          this.surface = this.dialog.querySelector("[data-surface]")
          this.content = this.surface.querySelector("[data-content]")
          this.overlay = this.dialog.querySelector("[data-overlay]")
          this.confirmBtn = this.surface.querySelector(".morph-dialog__confirm")
          this.busy = false
          this.isOpen = false
          this.morphCta = this.el.dataset.morphCta === "true"
          this.ease = "cubic-bezier(0.22, 1.1, 0.36, 1)"

          this.trigger.addEventListener("click", () => this.open())
          this.dialog.querySelectorAll("[data-morph-close]").forEach(btn => {
            btn.addEventListener("click", () => this.close())
          })
          this.overlay.addEventListener("click", () => this.close())
          this.dialog.addEventListener("cancel", (e) => {
            e.preventDefault()
            this.close()
          })
        },

        // Create a fixed-position ghost element for CTA morphing
        _ghost(text, rect, styles) {
          const el = document.createElement("span")
          el.textContent = text
          Object.assign(el.style, {
            position: "fixed", zIndex: "100001",
            display: "flex", alignItems: "center", justifyContent: "center",
            pointerEvents: "none", margin: "0", border: "none",
            fontWeight: "600", whiteSpace: "nowrap",
            fontFamily: styles.fontFamily,
            left: `${rect.left}px`, top: `${rect.top}px`,
            width: `${rect.width}px`, height: `${rect.height}px`,
            borderRadius: styles.borderRadius,
            backgroundColor: styles.backgroundColor,
            color: styles.color, fontSize: styles.fontSize,
          })
          document.body.appendChild(el)
          return el
        },

        open() {
          if (this.busy || this.isOpen) return
          this.busy = true
          this.isOpen = true

          const position = this.dialog.dataset.position
          const tr = this.trigger.getBoundingClientRect()

          // Hide content BEFORE showing dialog to prevent flash
          this.content.style.opacity = "0"

          // Show dialog
          this.dialog.showModal()
          this.trigger.style.visibility = "hidden"
          document.documentElement.style.overflow = "hidden"

          // Position surface at origin if needed
          if (position === "origin") this.positionAtOrigin(tr)

          // Measure final positions (before animation mutates layout)
          const fin = this.surface.getBoundingClientRect()

          // ── CTA ghost: trigger → confirm ──
          let ctaAnim = null
          if (this.morphCta && this.confirmBtn) {
            const cfr = this.confirmBtn.getBoundingClientRect()
            const ts = getComputedStyle(this.trigger)
            const cs = getComputedStyle(this.confirmBtn)

            this.ctaGhost = this._ghost(this.trigger.textContent.trim(), tr, {
              fontFamily: ts.fontFamily, fontSize: ts.fontSize,
              borderRadius: `${tr.height / 2}px`,
              backgroundColor: ts.backgroundColor, color: ts.color,
            })

            ctaAnim = this.ctaGhost.animate([
              {
                left: `${tr.left}px`, top: `${tr.top}px`,
                width: `${tr.width}px`, height: `${tr.height}px`,
                borderRadius: `${tr.height / 2}px`,
                backgroundColor: ts.backgroundColor, color: ts.color,
                fontSize: ts.fontSize,
              },
              {
                left: `${cfr.left}px`, top: `${cfr.top}px`,
                width: `${cfr.width}px`, height: `${cfr.height}px`,
                borderRadius: cs.borderRadius || "9999px",
                backgroundColor: cs.backgroundColor, color: cs.color,
                fontSize: cs.fontSize,
              }
            ], { duration: 350, easing: this.ease, fill: "both" })

            // Swap label at midpoint if they differ
            const confirmText = this.confirmBtn.textContent.trim()
            if (confirmText !== this.ctaGhost.textContent) {
              setTimeout(() => { if (this.ctaGhost) this.ctaGhost.textContent = confirmText }, 175)
            }

            this.confirmBtn.style.visibility = "hidden"
          }

          // ── Surface morph: trigger rect → dialog rect ──
          // Fix surface to screen coords during animation
          this.surface.style.position = "fixed"
          const anim = this.surface.animate([
            {
              left: `${tr.left}px`, top: `${tr.top}px`,
              width: `${tr.width}px`, height: `${tr.height}px`,
              borderRadius: `${tr.height / 2}px`
            },
            {
              left: `${fin.left}px`, top: `${fin.top}px`,
              width: `${fin.width}px`, height: `${fin.height}px`,
              borderRadius: "20px"
            }
          ], { duration: 350, easing: this.ease, fill: "forwards" })

          // Backdrop fades in
          this.overlay.animate(
            [{ opacity: 0 }, { opacity: 1 }],
            { duration: 250, easing: "ease-out", fill: "both" }
          )

          anim.onfinish = () => {
            // Keep surface positioned via fill:forwards, cancel on close
            this._openAnim = anim
            // Reveal content with slide-up
            this.content.style.opacity = ""
            this.content.animate(
              [
                { opacity: 0, transform: "translateY(12px)" },
                { opacity: 1, transform: "translateY(0)" }
              ],
              { duration: 180, easing: this.ease, fill: "both" }
            ).onfinish = (e) => e.target.cancel()

            // Clean up CTA ghost (remove before cancel to prevent position snap flash)
            if (this.ctaGhost) {
              this.ctaGhost.remove()
              if (ctaAnim) ctaAnim.cancel()
              this.ctaGhost = null
              this.confirmBtn.style.visibility = ""
            }
            this.busy = false
          }
        },

        close() {
          if (this.busy || !this.isOpen) return
          this.busy = true

          const tr = this.trigger.getBoundingClientRect()
          const cur = this.surface.getBoundingClientRect()

          // Cancel open animation fill so we can re-animate
          if (this._openAnim) { this._openAnim.cancel(); this._openAnim = null }
          this.surface.style.position = ""

          // ── CTA ghost: confirm → trigger ──
          let ctaAnim = null
          if (this.morphCta && this.confirmBtn) {
            const cfr = this.confirmBtn.getBoundingClientRect()
            const cs = getComputedStyle(this.confirmBtn)
            const ts = getComputedStyle(this.trigger)

            this.ctaGhost = this._ghost(this.confirmBtn.textContent.trim(), cfr, {
              fontFamily: cs.fontFamily, fontSize: cs.fontSize,
              borderRadius: cs.borderRadius || "9999px",
              backgroundColor: cs.backgroundColor, color: cs.color,
            })

            ctaAnim = this.ctaGhost.animate([
              {
                left: `${cfr.left}px`, top: `${cfr.top}px`,
                width: `${cfr.width}px`, height: `${cfr.height}px`,
                borderRadius: cs.borderRadius || "9999px",
                backgroundColor: cs.backgroundColor, color: cs.color,
                fontSize: cs.fontSize,
              },
              {
                left: `${tr.left}px`, top: `${tr.top}px`,
                width: `${tr.width}px`, height: `${tr.height}px`,
                borderRadius: `${tr.height / 2}px`,
                backgroundColor: ts.backgroundColor, color: ts.color,
                fontSize: ts.fontSize,
              }
            ], { duration: 300, easing: this.ease, fill: "both" })

            // Swap label at midpoint
            const triggerText = this.trigger.textContent.trim()
            if (triggerText !== this.ctaGhost.textContent) {
              setTimeout(() => { if (this.ctaGhost) this.ctaGhost.textContent = triggerText }, 150)
            }
          }

          // Content slides down + fades out (simultaneous with surface morph)
          this.content.animate(
            [
              { opacity: 1, transform: "translateY(0)" },
              { opacity: 0, transform: "translateY(60px)" }
            ],
            { duration: 200, easing: "ease-in", fill: "forwards" }
          )

          // Surface morphs back to trigger rect — also fades out
          this.surface.style.position = "fixed"
          const anim = this.surface.animate([
            {
              left: `${cur.left}px`, top: `${cur.top}px`,
              width: `${cur.width}px`, height: `${cur.height}px`,
              borderRadius: "20px", opacity: 1
            },
            {
              left: `${tr.left}px`, top: `${tr.top}px`,
              width: `${tr.width}px`, height: `${tr.height}px`,
              borderRadius: `${tr.height / 2}px`, opacity: 0
            }
          ], { duration: 280, easing: this.ease, fill: "both" })

          // Backdrop fades out
          this.overlay.animate(
            [{ opacity: 1 }, { opacity: 0 }],
            { duration: 250, easing: "ease-out", fill: "both" }
          )

          // Show trigger early (surface is fading out, so trigger fades in underneath)
          setTimeout(() => {
            this.trigger.style.visibility = ""
          }, 150)

          anim.onfinish = () => {
            this.dialog.close()
            document.documentElement.style.overflow = ""
            this.surface.style.position = ""
            this.content.style.opacity = ""
            this.content.style.transform = ""
            this.resetOriginStyles()

            if (this.ctaGhost) {
              this.ctaGhost.remove()
              this.ctaGhost = null
            }
            this.isOpen = false
            this.busy = false

            // Defer animation cleanup — dialog is hidden by next paint
            requestAnimationFrame(() => {
              this.content.getAnimations().forEach(a => a.cancel())
              this.surface.getAnimations().forEach(a => a.cancel())
              this.overlay.getAnimations().forEach(a => a.cancel())
            })
          }
        },

        positionAtOrigin(triggerRect) {
          const pad = 16
          const dir = this.dialog.dataset.originDir || "auto"
          const matchWidth = this.dialog.dataset.originMatchWidth === "true"
          const vw = window.innerWidth
          const vh = window.innerHeight

          const customW = this.dialog.dataset.width ? parseInt(this.dialog.dataset.width) : null
          const w = customW
            ? Math.min(customW, vw - pad * 2)
            : matchWidth
              ? Math.max(280, triggerRect.width)
              : Math.min(400, vw - pad * 2)

          let left = triggerRect.left + triggerRect.width / 2 - w / 2
          left = Math.max(pad, Math.min(left, vw - w - pad))

          this.surface.style.position = "absolute"
          this.surface.style.left = `${left}px`
          this.surface.style.width = `${w}px`
          this.surface.style.margin = "0"

          this.surface.style.top = "-9999px"
          const surfaceH = this.surface.offsetHeight
          // Space available in each direction (from trigger edge, no gap)
          const spaceBelow = vh - triggerRect.top - pad
          const spaceAbove = triggerRect.bottom - pad

          let goDown
          if (dir === "down") goDown = true
          else if (dir === "up") goDown = false
          else goDown = spaceBelow >= surfaceH || spaceBelow >= spaceAbove

          if (goDown) {
            // Anchor top to trigger top — surface grows downward
            this.surface.style.top = `${triggerRect.top}px`
            this.surface.style.maxHeight = `${vh - triggerRect.top - pad}px`
          } else {
            // Anchor bottom to trigger bottom — surface grows upward
            const idealTop = triggerRect.bottom - surfaceH
            const top = Math.max(pad, idealTop)
            this.surface.style.top = `${top}px`
            this.surface.style.maxHeight = `${triggerRect.bottom - pad}px`
            this.surface.style.overflowY = "auto"
          }
        },

        resetOriginStyles() {
          const s = this.surface.style
          s.position = s.left = s.top = s.width = s.margin = s.maxHeight = s.overflowY = ""
        },

        destroyed() {
          if (this.isOpen) {
            this.dialog?.close()
            document.documentElement.style.overflow = ""
          }
          if (this.ctaGhost) {
            this.ctaGhost.remove()
            this.ctaGhost = null
          }
        }
      }
    </script>
    """
  end
end
