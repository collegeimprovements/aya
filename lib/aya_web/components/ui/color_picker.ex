defmodule AyaWeb.UI.ColorPicker do
  @moduledoc """
  Color picker with swatch grid and optional custom color input.

  ## Examples

      <.color_picker id="bg-color" field={@form[:bg_color]} label="Background" />

      <.color_picker
        id="accent"
        field={@form[:accent]}
        label="Accent color"
        swatches={~w(#c2410c #166534 #b45309 #0369a1 #7c3aed #be185d)}
      />

      <.color_picker id="simple" field={@form[:color]} allow_custom={false} />
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  @default_swatches ~w(
    #c2410c #ea580c #f97316 #f59e0b #eab308
    #84cc16 #22c55e #166534 #14b8a6 #06b6d4
    #0ea5e9 #0369a1 #6366f1 #7c3aed #a855f7
    #d946ef #ec4899 #be185d #f43f5e #ef4444
    #78716c #57534e #1c1917 #ffffff
  )

  attr :id, :string, required: true
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: nil, doc: "hex color string like #c2410c"
  attr :label, :string, default: nil
  attr :swatches, :list, default: nil, doc: "list of hex color strings (nil = default palette)"
  attr :allow_custom, :boolean, default: true, doc: "show hex text input for custom colors"
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil

  def color_picker(assigns) do
    assigns =
      assigns
      |> assign_field_attrs()
      |> assign_new(:current_color, fn -> assigns[:value] || "#c2410c" end)
      |> assign_new(:swatch_list, fn -> assigns[:swatches] || @default_swatches end)

    ~H"""
    <div
      id={@id}
      phx-hook=".ColorPicker"
      class={["relative inline-block", @disabled && "opacity-50 pointer-events-none", @class]}
      data-color={@current_color}
    >
      <%!-- Label --%>
      <label :if={@label} class="block text-sm font-medium text-text mb-1.5">{@label}</label>

      <%!-- Trigger button --%>
      <button
        type="button"
        data-cp-trigger
        style={"anchor-name: --cp-#{@id}"}
        class="flex items-center gap-2 px-3 py-2 rounded-md border border-border bg-surface text-sm text-text hover:bg-surface-hover transition-colors cursor-pointer focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring"
        aria-label={"Select color: #{@current_color}"}
      >
        <span
          class="size-5 rounded-full border border-border shrink-0"
          style={"background-color: #{@current_color}"}
          data-cp-preview
        />
        <span class="font-mono text-xs text-text-muted" data-cp-hex>{@current_color}</span>
        <.icon name="hero-chevron-down-mini" class="size-4 text-text-muted" />
      </button>

      <%!-- Dropdown panel --%>
      <div
        data-cp-panel
        style={"position-anchor: --cp-#{@id}"}
        class="fixed z-50 mt-1 p-3 rounded-lg border border-border bg-surface shadow-lg w-64 hidden [top:anchor(bottom)] [left:anchor(start)] [position-try-fallbacks:flip-block]"
      >
        <%!-- Swatch grid --%>
        <div class="grid grid-cols-8 gap-1.5 mb-3">
          <button
            :for={color <- @swatch_list}
            type="button"
            data-cp-swatch={color}
            class={[
              "size-6 rounded-full border cursor-pointer transition-transform hover:scale-110",
              "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring",
              if(String.downcase(color) == String.downcase(@current_color),
                do: "border-primary ring-2 ring-primary/30",
                else: "border-border/50"
              )
            ]}
            style={"background-color: #{color}"}
            aria-label={"Color #{color}"}
          />
        </div>

        <%!-- Custom hex input --%>
        <div :if={@allow_custom} class="flex items-center gap-2 pt-2 border-t border-border">
          <span
            class="size-8 rounded-md border border-border shrink-0"
            style={"background-color: #{@current_color}"}
            data-cp-large-preview
          />
          <div class="flex-1 relative">
            <span class="absolute left-2.5 top-1/2 -translate-y-1/2 text-xs text-text-muted font-mono">
              #
            </span>
            <input
              type="text"
              data-cp-input
              maxlength="6"
              value={String.trim_leading(@current_color, "#")}
              class="w-full pl-6 pr-2 py-1.5 text-xs font-mono rounded-md border border-border bg-surface text-text focus:outline-none focus:ring-2 focus:ring-ring"
              autocomplete="off"
              spellcheck="false"
            />
          </div>
        </div>
      </div>

      <%!-- Hidden form input --%>
      <input type="hidden" name={@name} value={@current_color} data-cp-value />

      <script :type={Phoenix.LiveView.ColocatedHook} name=".ColorPicker">
        export default {
          mounted() {
            const el = this.el
            const trigger = el.querySelector("[data-cp-trigger]")
            const panel = el.querySelector("[data-cp-panel]")
            const preview = el.querySelector("[data-cp-preview]")
            const largePreview = el.querySelector("[data-cp-large-preview]")
            const hexDisplay = el.querySelector("[data-cp-hex]")
            const input = el.querySelector("[data-cp-input]")
            const hidden = el.querySelector("[data-cp-value]")
            let open = false

            const setColor = (hex) => {
              hex = hex.startsWith("#") ? hex : "#" + hex
              if (!/^#[0-9a-fA-F]{6}$/.test(hex) && !/^#[0-9a-fA-F]{3}$/.test(hex)) return

              // Expand shorthand (#abc → #aabbcc)
              if (hex.length === 4) {
                hex = "#" + hex[1]+hex[1] + hex[2]+hex[2] + hex[3]+hex[3]
              }

              el.dataset.color = hex
              preview.style.backgroundColor = hex
              if (largePreview) largePreview.style.backgroundColor = hex
              hexDisplay.textContent = hex
              if (input) input.value = hex.slice(1)
              hidden.value = hex
              hidden.dispatchEvent(new Event("input", { bubbles: true }))

              // Update swatch selection
              el.querySelectorAll("[data-cp-swatch]").forEach(s => {
                const match = s.dataset.cpSwatch.toLowerCase() === hex.toLowerCase()
                s.classList.toggle("border-primary", match)
                s.classList.toggle("ring-2", match)
                s.classList.toggle("ring-primary/30", match)
                s.classList.toggle("border-border/50", !match)
              })
            }

            const toggle = () => {
              open = !open
              panel.classList.toggle("hidden", !open)
            }

            const close = () => {
              open = false
              panel.classList.add("hidden")
            }

            trigger.addEventListener("click", toggle)

            // Swatch click
            el.querySelectorAll("[data-cp-swatch]").forEach(s => {
              s.addEventListener("click", () => {
                setColor(s.dataset.cpSwatch)
              })
            })

            // Hex input
            if (input) {
              input.addEventListener("input", () => {
                const val = input.value.trim()
                if (/^[0-9a-fA-F]{6}$/.test(val) || /^[0-9a-fA-F]{3}$/.test(val)) {
                  setColor("#" + val)
                }
              })
              input.addEventListener("keydown", (e) => {
                if (e.key === "Enter") { e.preventDefault(); close() }
              })
            }

            // Click outside to close
            document.addEventListener("click", (e) => {
              if (open && !el.contains(e.target)) close()
            })

            // Escape to close
            document.addEventListener("keydown", (e) => {
              if (e.key === "Escape" && open) close()
            })
          }
        }
      </script>
    </div>
    """
  end

  defp assign_field_attrs(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
  end

  defp assign_field_attrs(assigns) do
    assigns
    |> assign_new(:name, fn -> nil end)
    |> assign_new(:value, fn -> nil end)
  end
end
