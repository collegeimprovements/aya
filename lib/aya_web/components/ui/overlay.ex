defmodule AyaWeb.UI.Overlay do
  @moduledoc """
  Modal, sheet, and drawer system built on native `<dialog>`.
  Drawer physics inspired by [Vaul](https://vaul.emilkowal.ski/).

  ## Variants

  | Variant | Direction | Use case |
  |---|---|---|
  | `:modal` | Center, scale up | Confirmations, forms, detail views |
  | `:bottom_sheet` | Slides up | Mobile actions, filters, pickers |
  | `:top_sheet` | Slides down | Notifications, banners |
  | `:drawer_left` | Slides from left | Navigation, settings |
  | `:drawer_right` | Slides from right | Detail panels, filters |
  | `:page_sheet` | Full slide from bottom | Full-screen sub-flows |
  | `:lightbox` | Fade + scale | Image/media viewer |

  ## Snap Points (Vaul-style)

  Sheets can have snap points — positions where the drawer "catches" during drag.
  Values are fractions of viewport (0.0–1.0) or pixel strings ("148px").

      <.overlay id="my-sheet" variant={:bottom_sheet} snap_points={[0.3, 0.6, 1.0]}>
        ...
      </.overlay>

      <.overlay id="px-sheet" variant={:bottom_sheet} snap_points={["148px", "355px", 1]}>
        ...
      </.overlay>

  ## Depth Effect (iOS-style)

  Sheets can scale the page background to create a depth illusion.

      <.overlay id="depth-sheet" variant={:bottom_sheet} depth>
        ...
      </.overlay>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  @variants ~w(modal bottom_sheet detached_sheet top_sheet drawer_left drawer_right page_sheet lightbox)a
  @sizes ~w(sm md lg xl full)a
  @sheet_variants ~w(bottom_sheet detached_sheet top_sheet page_sheet)a

  attr :id, :string, required: true
  attr :variant, :atom, default: :modal, values: @variants
  attr :size, :atom, default: :md, values: @sizes
  attr :closedby, :string, default: "any", values: ~w(any closerequest none)

  attr :snap_points, :list,
    default: nil,
    doc: "list of snap positions: fractions (0.3) or pixel strings (\"148px\")"

  attr :snap_initial, :integer, default: 0, doc: "index of initial snap point (0-based)"

  attr :depth, :boolean,
    default: false,
    doc: "scale the background when sheet opens (iOS-style depth)"

  attr :position, :string, default: nil, doc: ~s("center" for centered detached sheets)
  attr :class, :any, default: nil
  attr :rest, :global

  slot :header
  slot :inner_block, required: true
  slot :footer

  def overlay(assigns) do
    assigns = assign(assigns, :is_sheet, assigns.variant in @sheet_variants)

    snap_json =
      if assigns.snap_points do
        Jason.encode!(assigns.snap_points)
      end

    assigns = assign(assigns, :snap_json, snap_json)

    ~H"""
    <dialog
      id={@id}
      phx-hook=".Overlay"
      class={["overlay", "overlay--#{@variant}", "overlay--#{@size}", @class]}
      data-variant={@variant}
      data-closedby={@closedby}
      data-snap-points={@snap_json}
      data-snap-initial={@snap_initial}
      data-depth={if @depth, do: "true"}
      data-position={@position}
      {@rest}
    >
      <div class="overlay__backdrop" aria-hidden="true" data-overlay-backdrop />
      <div class="overlay__surface">
        <%!-- Vaul-style drag handle for sheets --%>
        <div :if={@is_sheet} class="overlay__handle" aria-hidden="true" data-drag-handle>
          <div class="overlay__handle-bar" />
        </div>
        <header :if={@header != []} class="overlay__header">
          <div class="overlay__title">{render_slot(@header)}</div>
          <button type="button" data-overlay-close class="overlay__close" aria-label="Close">
            <.icon name="hero-x-mark" class="size-5" />
          </button>
        </header>
        <div class="overlay__body">{render_slot(@inner_block)}</div>
        <footer :if={@footer != []} class="overlay__footer">{render_slot(@footer)}</footer>
      </div>
    </dialog>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".Overlay">
      export default {
        mounted() {
          const dialog = this.el
          const surface = dialog.querySelector(".overlay__surface")
          const backdrop = dialog.querySelector("[data-overlay-backdrop]")
          const variant = dialog.dataset.variant
          const closedby = dialog.dataset.closedby || "any"
          const useDepth = dialog.dataset.depth === "true"
          const depthEase = "cubic-bezier(0.32, 0.72, 0, 1)"

          // Depth-effect: scale the page content when sheet opens (iOS-style).
          // <dialog showModal()> renders in the top layer, so parent transforms don't affect it.
          const depthTarget = useDepth
            ? (dialog.closest("[data-phx-main]") || document.body.firstElementChild)
            : null

          function applyDepth(on) {
            if (!depthTarget) return
            const dur = "400ms"
            if (on) {
              depthTarget.style.transition = `transform ${dur} ${depthEase}, border-radius ${dur} ${depthEase}`
              depthTarget.style.transformOrigin = "top center"
              depthTarget.style.transform = "scale(0.94)"
              depthTarget.style.borderRadius = "var(--radius-lg)"
              depthTarget.style.overflow = "hidden"
            } else {
              depthTarget.style.transition = `transform ${dur} ${depthEase}, border-radius ${dur} ${depthEase}`
              depthTarget.style.transform = ""
              depthTarget.style.borderRadius = ""
              const cleanup = () => {
                depthTarget.style.overflow = ""
                depthTarget.style.transition = ""
                depthTarget.style.transformOrigin = ""
              }
              depthTarget.addEventListener("transitionend", cleanup, { once: true })
              setTimeout(cleanup, 450)
            }
          }

          // ── Close triggers ──────────────────────────────────
          // For depth sheets, animate out before actually closing the dialog
          let closing = false
          const requestClose = () => {
            if (closing || !dialog.open) return
            if (useDepth) {
              closing = true
              applyDepth(false)
              // Fade backdrop
              if (backdrop) {
                backdrop.style.transition = `opacity 350ms ease-out`
                backdrop.style.opacity = "0"
              }
              // Slide surface down
              if (surface) {
                surface.style.transition = `transform 400ms ${depthEase}, opacity 300ms ease-out`
                surface.style.transform = "translateY(100%)"
                surface.style.opacity = "0"
              }
              setTimeout(() => {
                dialog.close()
                // Reset inline styles
                if (backdrop) { backdrop.style.transition = ""; backdrop.style.opacity = "" }
                if (surface) { surface.style.transition = ""; surface.style.transform = ""; surface.style.opacity = "" }
                closing = false
              }, 420)
            } else {
              dialog.close()
            }
          }

          if (closedby === "any" && backdrop)
            backdrop.addEventListener("click", requestClose)

          if (closedby !== "none")
            dialog.addEventListener("keydown", (e) => {
              if (e.key === "Escape") { e.preventDefault(); requestClose() }
            })

          dialog.querySelector("[data-overlay-close]")
            ?.addEventListener("click", requestClose)

          // ── Open/close handling ──────────────────────────────
          const onOpen = () => {
            document.documentElement.style.overflow = "hidden"
            if (useDepth) applyDepth(true)
            const af = dialog.querySelector("[autofocus]")
            if (af) requestAnimationFrame(() => af.focus())
            // Snap points: animate from off-screen to initial snap
            if (snapPoints.length > 0) {
              surface.style.transition = "none"
              surface.style.transform = `translateY(${window.innerHeight}px)`
              surface.style.height = "0px"
              if (backdrop) { backdrop.style.transition = "none"; backdrop.style.opacity = "0" }
              requestAnimationFrame(() => {
                requestAnimationFrame(() => snapTo(activeSnap))
              })
            }
          }

          // Intercept showModal/close for reliable open/close detection.
          const origShow = dialog.showModal.bind(dialog)
          const origClose = dialog.close.bind(dialog)
          dialog.showModal = (...args) => { origShow(...args); onOpen() }
          // For depth sheets, intercept close() so external callers (global commandfor)
          // also get the animated close sequence.
          dialog.close = (...args) => {
            if (useDepth && !closing) {
              requestClose()
              return
            }
            origClose(...args)
            document.documentElement.style.overflow = ""
          }

          dialog.addEventListener("close", () => {
            document.documentElement.style.overflow = ""
            // Depth cleanup is handled by requestClose — skip here to avoid double-animation
          })

          // ── Polyfill commandfor/command ──────────────────────
          const bindInvokers = () => {
            // Support both native commandfor and data-commandfor (LiveView strips non-standard attrs)
            document.querySelectorAll(`[data-commandfor="${dialog.id}"], [commandfor="${dialog.id}"]`).forEach(btn => {
              if (btn._bound === dialog.id) return; btn._bound = dialog.id
              btn.addEventListener("click", () => {
                const cmd = btn.getAttribute("data-command") || btn.getAttribute("command")
                if (cmd === "show-modal" && !dialog.open) dialog.showModal()
                else if (cmd === "close" && dialog.open) dialog.close()
              })
            })
          }
          // Bind immediately + after a microtask (ensures all hooks have mounted)
          bindInvokers()
          queueMicrotask(bindInvokers)
          const invObs = new MutationObserver(bindInvokers)
          invObs.observe(document.body, { childList: true, subtree: true })

          // ── Snap points (Vaul-style) ────────────────────────
          const snapRaw = dialog.dataset.snapPoints ? JSON.parse(dialog.dataset.snapPoints) : []
          const snapPoints = snapRaw // Array of numbers (fractions) or strings ("148px")
          let activeSnap = parseInt(dialog.dataset.snapInitial) || 0

          function getSnapOffsets() {
            if (!snapPoints.length) return []
            const isV = cfg?.axis === "y"
            const dim = isV ? window.innerHeight : window.innerWidth
            return snapPoints.map(sp => {
              if (typeof sp === "string" && sp.endsWith("px")) return parseInt(sp, 10)
              return Math.round(sp * dim)
            })
          }

          function snapTo(index) {
            const offsets = getSnapOffsets()
            if (!offsets.length || !surface) return
            activeSnap = Math.max(0, Math.min(index, offsets.length - 1))
            const targetHeight = offsets[activeSnap]
            const isV = cfg?.axis === "y"

            if (isV && (variant === "bottom_sheet" || variant === "page_sheet")) {
              const containerDim = window.innerHeight
              const translateY = containerDim - targetHeight
              surface.style.transition = "transform 500ms cubic-bezier(0.32, 0.72, 0, 1), height 500ms cubic-bezier(0.32, 0.72, 0, 1)"
              surface.style.transform = `translateY(${translateY}px)`
              surface.style.height = `${targetHeight}px`
              // Fade backdrop: fully visible at last snap, faded at first
              if (backdrop) {
                const progress = activeSnap / (offsets.length - 1)
                backdrop.style.transition = "opacity 500ms cubic-bezier(0.32, 0.72, 0, 1)"
                backdrop.style.opacity = String(progress)
              }
              // Reset transition after animation
              setTimeout(() => {
                if (surface) surface.style.transition = ""
                if (backdrop) backdrop.style.transition = ""
              }, 520)
            }
          }

          // ── Vaul-style drag for sheets/drawers ──────────────
          const configs = {
            bottom_sheet:   { axis: "y", dir: 1 },
            detached_sheet: { axis: "y", dir: 1 },
            top_sheet:      { axis: "y", dir: -1 },
            drawer_left:    { axis: "x", dir: -1 },
            drawer_right:   { axis: "x", dir: 1 },
            page_sheet:     { axis: "y", dir: 1 }
          }
          const cfg = configs[variant]
          if (!cfg || !surface) { this._invObs = invObs; return }

          const CLOSE_THRESHOLD = 0.25
          const SCROLL_LOCK_MS = 500
          const VELOCITY_THRESHOLD = 0.4
          const isV = cfg.axis === "y"
          let startPos = 0, delta = 0, dragging = false, startTime = 0
          let lastScrollPrevent = 0, dragStartTranslate = 0

          const dampen = (d) => Math.sign(d) * (Math.abs(d) / (1 + Math.abs(d) / 400))

          const getCurrentTranslateY = () => {
            if (!surface) return 0
            const transform = getComputedStyle(surface).transform
            if (!transform || transform === "none") return 0
            const m = transform.match(/matrix.*\((.+)\)/)
            if (!m) return 0
            const values = m[1].split(",").map(Number)
            return values.length === 6 ? values[5] : values[13] || 0
          }

          const onDown = (e) => {
            if (e.target.closest("button, a, input, textarea, select, [data-no-drag]")) return
            const body = dialog.querySelector(".overlay__body")
            if (body) {
              if (isV && cfg.dir === 1 && body.scrollTop > 0) { lastScrollPrevent = Date.now(); return }
              if (isV && cfg.dir === -1 && body.scrollTop < body.scrollHeight - body.clientHeight) { lastScrollPrevent = Date.now(); return }
            }
            if (Date.now() - lastScrollPrevent < SCROLL_LOCK_MS) return

            startPos = isV ? e.clientY : e.clientX
            startTime = Date.now()
            dragging = true
            dragStartTranslate = snapPoints.length > 0 ? getCurrentTranslateY() : 0
            surface.style.transition = "none"
            if (backdrop) backdrop.style.transition = "none"
          }

          const onMove = (e) => {
            if (!dragging) return
            const pos = isV ? e.clientY : e.clientX
            const raw = pos - startPos

            if (snapPoints.length > 0) {
              // Snap points mode: free movement within snap range
              const newTranslate = dragStartTranslate + raw
              const offsets = getSnapOffsets()
              const containerDim = window.innerHeight
              // Clamp: don't allow going above the largest snap point
              const maxHeight = offsets[offsets.length - 1]
              const minTranslate = containerDim - maxHeight
              const clampedTranslate = Math.max(minTranslate, newTranslate)
              // Allow slight overdrag with damping past the bottom
              if (newTranslate > containerDim) {
                delta = raw
                surface.style.transform = `translateY(${containerDim + dampen(newTranslate - containerDim)}px)`
              } else {
                delta = raw
                surface.style.transform = `translateY(${clampedTranslate}px)`
                // Update height to match
                const currentHeight = containerDim - clampedTranslate
                surface.style.height = `${currentHeight}px`
              }
              // Backdrop opacity: based on height fraction
              if (backdrop && offsets.length > 1) {
                const currentHeight = containerDim - Math.max(minTranslate, newTranslate)
                const progress = Math.max(0, Math.min(1, currentHeight / maxHeight))
                backdrop.style.opacity = String(progress)
              }
            } else {
              // No snap points: original behavior
              if (cfg.dir > 0) { delta = raw > 0 ? raw : dampen(raw) }
              else { delta = raw < 0 ? raw : dampen(raw) }
              const prop = isV ? "translateY" : "translateX"
              surface.style.transform = `${prop}(${delta}px)`
              if (backdrop) {
                const dim = isV ? surface.offsetHeight : surface.offsetWidth
                const progress = Math.max(0, Math.abs(delta) / dim)
                backdrop.style.opacity = String(Math.max(0, 1 - progress))
              }
            }
          }

          const onUp = () => {
            if (!dragging) return
            dragging = false
            surface.style.transition = ""
            if (backdrop) { backdrop.style.transition = ""; backdrop.style.opacity = "" }

            if (snapPoints.length > 0) {
              // Find closest snap point
              const offsets = getSnapOffsets()
              const containerDim = window.innerHeight
              const currentTranslate = dragStartTranslate + delta
              const currentHeight = containerDim - currentTranslate
              const velocity = Math.abs(delta) / (Date.now() - startTime)
              const draggedDown = delta > 0

              // High velocity: snap to next/prev
              if (velocity > VELOCITY_THRESHOLD && Math.abs(delta) > 10) {
                if (draggedDown) {
                  // Dragged down: go to smaller snap or close
                  if (activeSnap === 0 && closedby !== "none") {
                    dialog.close(); delta = 0; return
                  }
                  snapTo(activeSnap - 1)
                } else {
                  snapTo(activeSnap + 1)
                }
              } else {
                // Find closest snap point by height
                let closestIdx = 0, closestDist = Infinity
                offsets.forEach((h, i) => {
                  const dist = Math.abs(currentHeight - h)
                  if (dist < closestDist) { closestDist = dist; closestIdx = i }
                })
                // If closest is below dismiss threshold and at index 0, close
                if (closestIdx === 0 && currentHeight < offsets[0] * (1 - CLOSE_THRESHOLD) && closedby !== "none") {
                  dialog.close()
                } else {
                  snapTo(closestIdx)
                }
              }
              delta = 0
              return
            }

            // No snap points: original dismiss logic
            const dim = isV ? surface.offsetHeight : surface.offsetWidth
            const absDelta = Math.abs(delta)
            const velocity = absDelta / (Date.now() - startTime)
            if (absDelta / dim > CLOSE_THRESHOLD || velocity > 0.5) dialog.close()
            surface.style.transform = ""
            delta = 0
          }

          const dragTarget = dialog.querySelector("[data-drag-handle]") || surface
          dragTarget.addEventListener("pointerdown", onDown)
          dialog.addEventListener("pointermove", onMove)
          dialog.addEventListener("pointerup", onUp)
          dialog.addEventListener("pointercancel", onUp)
          surface.addEventListener("pointerdown", (e) => {
            if (e.target.closest(".overlay__header, [data-drag-handle]")) onDown(e)
          })

          this._invObs = invObs
          this._applyDepth = useDepth ? applyDepth : null
        },

        destroyed() {
          this._invObs?.disconnect()
          document.documentElement.style.overflow = ""
          this._applyDepth?.(false)
        }
      }
    </script>
    """
  end
end
