defmodule AyaWeb.UI.MultiStep do
  @moduledoc """
  Animated multi-step wizard with spring-like slide transitions.

  Content slides between steps with smooth height animation.
  Direction-aware: forward slides left-to-right, backward slides right-to-left.

  ## Examples

      <.multi_step id="onboarding" class="max-w-lg mx-auto">
        <:step>
          <h2 class="text-base font-semibold mb-2">Step one</h2>
          <p class="text-sm text-text-secondary">Content for the first step.</p>
        </:step>
        <:step>
          <h2 class="text-base font-semibold mb-2">Step two</h2>
          <p class="text-sm text-text-secondary">Content for the second step.</p>
        </:step>
        <:step>
          <h2 class="text-base font-semibold mb-2">Step three</h2>
          <p class="text-sm text-text-secondary">Content for the third step.</p>
        </:step>
      </.multi_step>
  """

  use Phoenix.Component

  attr :id, :string, required: true
  attr :back_label, :string, default: "Back"
  attr :continue_label, :string, default: "Continue"
  attr :class, :any, default: nil

  slot :step, required: true

  def multi_step(assigns) do
    assigns = assign(assigns, :step_count, length(assigns.step))

    ~H"""
    <div
      id={@id}
      phx-hook=".MultiStep"
      class={["multi-step", @class]}
      data-step-count={@step_count}
    >
      <div class="multi-step__inner" data-inner>
        <div
          :for={{step, index} <- Enum.with_index(@step)}
          class="multi-step__panel"
          data-step-index={index}
          aria-hidden={to_string(index != 0)}
          hidden={index != 0}
        >
          {render_slot(step)}
        </div>
        <div class="multi-step__actions">
          <button type="button" class="multi-step__back" disabled data-back>
            {@back_label}
          </button>
          <button type="button" class="multi-step__continue" data-continue>
            {@continue_label}
          </button>
        </div>
      </div>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".MultiStep">
      export default {
        mounted() {
          const el = this.el
          this.step = 0
          this.count = parseInt(el.dataset.stepCount)
          this.inner = el.querySelector("[data-inner]")
          this.panels = Array.from(el.querySelectorAll("[data-step-index]"))
          this.backBtn = el.querySelector("[data-back]")
          this.contBtn = el.querySelector("[data-continue]")
          this.busy = false
          this.reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
          this.dur = this.reduceMotion ? 0 : 500
          this.ease = "cubic-bezier(0.32, 0.72, 0, 1)"

          // Set initial explicit height for future transitions
          el.style.height = this.inner.offsetHeight + "px"

          this.backBtn.addEventListener("click", () => this.go(-1))
          this.contBtn.addEventListener("click", () => this.go(1))
          this.contBtn.disabled = this.count <= 1
        },

        go(dir) {
          if (this.busy) return
          const next = this.step + dir
          if (next < 0 || next >= this.count) return

          this.busy = true
          const fwd = dir > 0
          const old = this.panels[this.step]
          const nxt = this.panels[next]

          // Pop old panel out of flow (position absolute within inner)
          old.style.position = "absolute"
          old.style.top = "0"
          old.style.left = "0"
          old.style.right = "0"

          // Show new panel in normal flow
          nxt.hidden = false
          nxt.setAttribute("aria-hidden", "false")

          // Animate wrapper height to match new content
          this.el.style.height = this.inner.offsetHeight + "px"

          // Direction-aware slide
          const enterFrom = fwd ? "110%" : "-110%"
          const exitTo = fwd ? "-110%" : "110%"
          const opts = { duration: this.dur, easing: this.ease, fill: "both" }

          // Animate old panel out
          old.animate(
            [
              { transform: "translateX(0)", opacity: 1 },
              { transform: `translateX(${exitTo})`, opacity: 0 }
            ],
            opts
          )

          // Animate new panel in
          const anim = nxt.animate(
            [
              { transform: `translateX(${enterFrom})`, opacity: 0 },
              { transform: "translateX(0)", opacity: 1 }
            ],
            opts
          )

          anim.onfinish = () => {
            // Clean up old panel
            old.hidden = true
            old.setAttribute("aria-hidden", "true")
            old.getAnimations().forEach(a => a.cancel())
            old.style.position = ""
            old.style.top = ""
            old.style.left = ""
            old.style.right = ""

            // Clean up new panel (natural state matches end keyframe)
            nxt.getAnimations().forEach(a => a.cancel())

            // Update state
            this.step = next
            this.busy = false
            this.backBtn.disabled = this.step === 0
            this.contBtn.disabled = this.step === this.count - 1
          }
        }
      }
    </script>
    """
  end
end
