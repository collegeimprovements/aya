defmodule AyaWeb.UI.Tabs do
  @moduledoc """
  Tab navigation. Supports URL-based routing and client-side panel switching.

  ## URL-based tabs (LiveView navigation)

      <.tabs>
        <:tab label="Overview" icon="hero-home" active={@live_action == :overview}
              patch={~p"/recipes/1"} />
        <:tab label="Nutrition" active={@live_action == :nutrition}
              patch={~p"/recipes/1/nutrition"} />
        <:tab label="Reviews" badge="12" active={@live_action == :reviews}
              patch={~p"/recipes/1/reviews"} />
      </.tabs>

  ## Client-side panel tabs

      <.tabs id="recipe-tabs">
        <:tab label="Ingredients" panel="ingredients-panel" active />
        <:tab label="Instructions" panel="instructions-panel" />
      </.tabs>
      <div id="ingredients-panel">...</div>
      <div id="instructions-panel" hidden>...</div>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, default: nil
  attr :variant, :string, default: "underline", values: ~w(underline pill)
  attr :class, :any, default: nil

  slot :tab, required: true do
    attr :label, :string, required: true
    attr :icon, :string
    attr :active, :boolean
    attr :badge, :string
    attr :navigate, :string
    attr :patch, :string
    attr :href, :string
    attr :panel, :string
  end

  def tabs(assigns) do
    has_panels = Enum.any?(assigns.tab, & &1[:panel])
    assigns = assign(assigns, :has_panels, has_panels)
    assigns = assign_new(assigns, :id, fn -> "tabs-#{System.unique_integer([:positive])}" end)

    ~H"""
    <nav
      id={@id}
      role="tablist"
      phx-hook=".Tabs"
      data-variant={@variant}
      class={[
        "flex gap-1",
        if(@variant == "underline",
          do: "border-b border-border",
          else: "bg-surface-alt rounded-lg p-1"
        ),
        @class
      ]}
    >
      <.tab_item
        :for={tab <- @tab}
        tab={tab}
        variant={@variant}
      />
    </nav>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".Tabs">
      export default {
        mounted() {
          this.el.querySelectorAll("[role=tab]").forEach(tab => {
            tab.addEventListener("click", (e) => {
              e.preventDefault();
              this.activate(tab);
            });
            tab.addEventListener("keydown", (e) => {
              const tabs = Array.from(this.el.querySelectorAll("[role=tab]"));
              const index = tabs.indexOf(tab);
              let next;
              if (e.key === "ArrowRight") next = tabs[(index + 1) % tabs.length];
              else if (e.key === "ArrowLeft") next = tabs[(index - 1 + tabs.length) % tabs.length];
              else if (e.key === "Home") next = tabs[0];
              else if (e.key === "End") next = tabs[tabs.length - 1];
              if (next) {
                e.preventDefault();
                next.focus();
                this.activate(next);
              }
            });
          });
        },

        activate(tab) {
          // Deactivate all tabs
          this.el.querySelectorAll("[role=tab]").forEach(t => {
            t.setAttribute("aria-selected", "false");
            t.setAttribute("tabindex", "-1");
            t.classList.remove("tab--active");
            const panelId = t.dataset.panel;
            if (panelId) {
              const panel = document.getElementById(panelId);
              if (panel) panel.hidden = true;
            }
          });

          // Activate clicked tab
          tab.setAttribute("aria-selected", "true");
          tab.setAttribute("tabindex", "0");
          tab.classList.add("tab--active");
          const panelId = tab.dataset.panel;
          if (panelId) {
            const panel = document.getElementById(panelId);
            if (panel) panel.hidden = false;
          }
        }
      }
    </script>
    """
  end

  defp tab_item(%{tab: tab, variant: _variant} = assigns) do
    is_active = tab[:active] || false
    has_link = tab[:navigate] || tab[:patch] || tab[:href]
    assigns = assign(assigns, %{is_active: is_active, has_link: has_link, tab: tab})

    ~H"""
    <%= if @has_link do %>
      <.link
        navigate={@tab[:navigate]}
        patch={@tab[:patch]}
        href={@tab[:href]}
        role="tab"
        aria-selected={"#{@is_active}"}
        tabindex={if @is_active, do: "0", else: "-1"}
        class={[tab_base_class(@variant), if(@is_active, do: "tab--active")]}
      >
        <.tab_content tab={@tab} />
      </.link>
    <% else %>
      <button
        type="button"
        role="tab"
        aria-selected={"#{@is_active}"}
        aria-controls={@tab[:panel]}
        data-panel={@tab[:panel]}
        tabindex={if @is_active, do: "0", else: "-1"}
        class={[tab_base_class(@variant), if(@is_active, do: "tab--active")]}
      >
        <.tab_content tab={@tab} />
      </button>
    <% end %>
    """
  end

  defp tab_content(assigns) do
    ~H"""
    <.icon :if={@tab[:icon]} name={@tab[:icon]} class="size-4" />
    <span>{@tab[:label] || @tab.label}</span>
    <span
      :if={@tab[:badge]}
      class="inline-flex items-center justify-center min-w-[1.25rem] h-5 px-1.5 rounded-full bg-surface-alt text-[0.65rem] font-medium text-text-secondary"
    >
      {@tab[:badge]}
    </span>
    """
  end

  # Layout-only base classes — visual active/inactive/focus states handled in CSS via .tab--active
  defp tab_base_class("underline") do
    "inline-flex items-center gap-1.5 px-3 py-2.5 text-sm font-medium border-b-2 -mb-px transition-colors cursor-pointer"
  end

  defp tab_base_class("pill") do
    "inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium rounded-md transition-all cursor-pointer"
  end

  # ────────────────────────────────────────────────────────────
  # Smooth Tabs — animated indicator + content transitions
  # ────────────────────────────────────────────────────────────

  @doc """
  Smooth animated tabs with a sliding indicator and content transitions.

  Client-side only — ideal for polished panel switching with motion.

  ## Examples

      <.smooth_tabs id="recipe-tabs">
        <:tab label="Overview" icon="hero-home" active>
          <p>Overview content here...</p>
        </:tab>
        <:tab label="Nutrition">
          <p>Nutrition info...</p>
        </:tab>
        <:tab label="Reviews" badge="12">
          <p>Reviews content...</p>
        </:tab>
      </.smooth_tabs>

      <%!-- Underline variant --%>
      <.smooth_tabs id="section-tabs" variant="underline">
        <:tab label="Details" active>...</:tab>
        <:tab label="History">...</:tab>
      </.smooth_tabs>
  """

  attr :id, :string, required: true
  attr :variant, :string, default: "pill", values: ~w(pill underline)
  attr :class, :any, default: nil

  slot :tab, required: true do
    attr :label, :string, required: true
    attr :icon, :string
    attr :active, :boolean
    attr :badge, :string
  end

  def smooth_tabs(assigns) do
    active_index = Enum.find_index(assigns.tab, & &1[:active]) || 0
    assigns = assign(assigns, :active_index, active_index)

    ~H"""
    <div id={@id} phx-hook=".SmoothTabs" class={["flex flex-col gap-3", @class]}>
      <nav
        role="tablist"
        class={["relative flex", smooth_nav_class(@variant)]}
      >
        <div
          data-indicator
          class={["absolute pointer-events-none", smooth_indicator_class(@variant)]}
        />
        <button
          :for={{tab, index} <- Enum.with_index(@tab)}
          type="button"
          role="tab"
          aria-selected={to_string(index == @active_index)}
          aria-controls={"#{@id}-panel-#{index}"}
          tabindex={if(index == @active_index, do: "0", else: "-1")}
          data-index={index}
          class={[
            "relative z-[1] cursor-pointer",
            smooth_tab_class(@variant),
            if(index == @active_index, do: "tab--active")
          ]}
        >
          <.icon :if={tab[:icon]} name={tab[:icon]} class="size-4" />
          <span>{tab[:label]}</span>
          <span
            :if={tab[:badge]}
            class="inline-flex items-center justify-center min-w-[1.25rem] h-5 px-1.5 rounded-full bg-surface-alt text-[0.65rem] font-medium text-text-secondary"
          >
            {tab[:badge]}
          </span>
        </button>
      </nav>

      <div data-panels class="relative overflow-hidden">
        <div
          :for={{tab, index} <- Enum.with_index(@tab)}
          id={"#{@id}-panel-#{index}"}
          role="tabpanel"
          data-panel={index}
          hidden={index != @active_index}
        >
          {render_slot(tab)}
        </div>
      </div>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".SmoothTabs">
      export default {
        mounted() {
          this.indicator = this.el.querySelector("[data-indicator]")
          this.panels = Array.from(this.el.querySelectorAll("[data-panel]"))
          this.tabs = Array.from(this.el.querySelectorAll("[role=tab]"))
          this.activeIndex = Math.max(0, this.tabs.findIndex(t => t.getAttribute("aria-selected") === "true"))
          this.busy = false

          // Position indicator instantly, then enable transitions
          this.moveIndicator(this.tabs[this.activeIndex], false)
          requestAnimationFrame(() => {
            const ease = "cubic-bezier(0.25, 1, 0.5, 1)"
            this.indicator.style.transition = `left 0.25s ${ease}, width 0.25s ${ease}`
          })

          this.tabs.forEach((tab, i) => {
            tab.addEventListener("click", () => this.activate(i))
            tab.addEventListener("keydown", (e) => {
              const len = this.tabs.length
              let next
              if (e.key === "ArrowRight") next = (i + 1) % len
              else if (e.key === "ArrowLeft") next = (i - 1 + len) % len
              else if (e.key === "Home") next = 0
              else if (e.key === "End") next = len - 1
              if (next != null) { e.preventDefault(); this.tabs[next].focus(); this.activate(next) }
            })
          })

          // Reposition indicator on resize
          this.ro = new ResizeObserver(() => {
            if (!this.busy) this.moveIndicator(this.tabs[this.activeIndex], false)
          })
          this.ro.observe(this.el.querySelector("[role=tablist]"))
        },

        updated() {
          this.tabs = Array.from(this.el.querySelectorAll("[role=tab]"))
          this.panels = Array.from(this.el.querySelectorAll("[data-panel]"))
          const serverActive = Math.max(0, this.tabs.findIndex(t => t.getAttribute("aria-selected") === "true"))
          if (serverActive !== this.activeIndex) this.activeIndex = serverActive
          this.moveIndicator(this.tabs[this.activeIndex], false)
          this.panels.forEach((p, i) => { p.hidden = i !== this.activeIndex })
        },

        moveIndicator(tab, animate = true) {
          if (!tab) return
          if (!animate) this.indicator.style.transitionDuration = "0s"
          this.indicator.style.left = tab.offsetLeft + "px"
          this.indicator.style.width = tab.offsetWidth + "px"
          if (!animate) {
            this.indicator.offsetHeight // force reflow
            this.indicator.style.transitionDuration = ""
          }
        },

        async activate(index) {
          if (index === this.activeIndex || this.busy) return
          this.busy = true

          const dir = index > this.activeIndex ? 1 : -1
          const oldPanel = this.panels[this.activeIndex]
          const newPanel = this.panels[index]

          // Update ARIA + visual states
          this.tabs.forEach((t, i) => {
            const active = i === index
            t.setAttribute("aria-selected", String(active))
            t.setAttribute("tabindex", active ? "0" : "-1")
            t.classList.toggle("tab--active", active)
          })

          // Slide indicator
          this.moveIndicator(this.tabs[index])

          // Animate content panels
          if (oldPanel && newPanel) {
            // Exit current panel
            const exit = oldPanel.animate([
              { opacity: 1, transform: "translateX(0)", filter: "blur(0px)" },
              { opacity: 0, transform: `translateX(${dir * -30}px)`, filter: "blur(3px)" }
            ], { duration: 120, easing: "ease-in", fill: "forwards" })
            await exit.finished
            oldPanel.hidden = true
            exit.cancel()

            // Enter new panel
            newPanel.hidden = false
            const enter = newPanel.animate([
              { opacity: 0, transform: `translateX(${dir * 30}px)`, filter: "blur(3px)" },
              { opacity: 1, transform: "translateX(0)", filter: "blur(0px)" }
            ], { duration: 200, easing: "cubic-bezier(0.25, 1, 0.5, 1)", fill: "forwards" })
            await enter.finished
            enter.cancel()
          }

          this.activeIndex = index
          this.busy = false
        },

        destroyed() {
          this.ro?.disconnect()
        }
      }
    </script>
    """
  end

  defp smooth_nav_class("pill"), do: "bg-surface-alt rounded-lg p-1"
  defp smooth_nav_class("underline"), do: "border-b border-border"

  defp smooth_indicator_class("pill"), do: "top-1 bottom-1 rounded-md bg-surface shadow-sm"
  defp smooth_indicator_class("underline"), do: "bottom-0 h-0.5 bg-primary rounded-full"

  defp smooth_tab_class("pill") do
    "flex-1 inline-flex items-center justify-center gap-1.5 px-3 py-2 text-sm font-medium rounded-md text-text-secondary transition-colors hover:text-text"
  end

  defp smooth_tab_class("underline") do
    "inline-flex items-center gap-1.5 px-3 py-2.5 text-sm font-medium text-text-secondary transition-colors hover:text-text"
  end
end
