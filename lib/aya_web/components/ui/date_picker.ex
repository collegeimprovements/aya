defmodule AyaWeb.UI.DatePicker do
  @moduledoc """
  Date picker with calendar dropdown. Form-integrated.

  ## Examples

      <.date_picker id="due-date" field={@form[:due_date]} label="Due date" />
      <.date_picker id="start" field={@form[:start_date]} label="Start" min="2024-01-01" max="2026-12-31" />
      <.date_picker id="standalone" name="date" label="Pick a date" value="2026-03-23" />
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, required: true
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :label, :string, default: nil
  attr :placeholder, :string, default: "Pick a date"
  attr :min, :string, default: nil
  attr :max, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :icon_calendar, :string, default: "hero-calendar", doc: "calendar trigger icon"
  attr :icon_prev, :string, default: "hero-chevron-left-mini", doc: "previous month icon"
  attr :icon_next, :string, default: "hero-chevron-right-mini", doc: "next month icon"
  attr :class, :any, default: nil

  def date_picker(assigns) do
    assigns =
      assigns
      |> assign_field_attrs()
      |> assign_new(:display_value, fn -> nil end)

    ~H"""
    <div id={@id} phx-hook=".DatePicker" class={["relative", @class]} data-min={@min} data-max={@max}>
      <label :if={@label} class="block text-sm font-medium text-text mb-1.5" for={"#{@id}-input"}>
        {@label}
      </label>
      <%!-- Hidden native input for form submission --%>
      <input type="hidden" name={@name} value={@value} data-date-value />

      <%!-- Visible trigger --%>
      <button
        type="button"
        id={"#{@id}-input"}
        disabled={@disabled}
        data-date-trigger
        style={"anchor-name: --dp-#{@id}"}
        class={[
          "flex items-center justify-between w-full",
          "rounded-md border border-border bg-surface px-3 py-2 text-sm text-left",
          "transition-colors hover:border-border-strong",
          "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring",
          "cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
        ]}
      >
        <span
          data-date-display
          class={if(@value && @value != "", do: "text-text", else: "text-text-muted")}
        >
          {if @value && @value != "", do: format_display(@value), else: @placeholder}
        </span>
        <.icon name={@icon_calendar} class="size-4 text-text-muted shrink-0" />
      </button>

      <%!-- Calendar dropdown --%>
      <div
        data-date-panel
        class="dp-panel w-[280px] p-3 opacity-0 scale-95 pointer-events-none transition-[opacity,transform] duration-150 ease-out"
        style={"position-anchor: --dp-#{@id}"}
        hidden
      >
        <%!-- Month/year header --%>
        <div class="flex items-center justify-between mb-3">
          <button
            type="button"
            data-prev-month
            class="p-1 rounded-md hover:bg-surface-hover transition-colors cursor-pointer"
            aria-label="Previous month"
          >
            <.icon name={@icon_prev} class="size-5 text-text-secondary" />
          </button>
          <span data-month-label class="text-sm font-semibold text-text" />
          <button
            type="button"
            data-next-month
            class="p-1 rounded-md hover:bg-surface-hover transition-colors cursor-pointer"
            aria-label="Next month"
          >
            <.icon name={@icon_next} class="size-5 text-text-secondary" />
          </button>
        </div>
        <%!-- Day headers --%>
        <div class="grid grid-cols-7 mb-1">
          <span
            :for={d <- ~w(Su Mo Tu We Th Fr Sa)}
            class="text-center text-[0.65rem] font-medium text-text-muted py-1"
          >
            {d}
          </span>
        </div>
        <%!-- Day grid (filled by JS) --%>
        <div data-days-grid class="grid grid-cols-7" />
        <%!-- Today shortcut --%>
        <div class="mt-2 pt-2 border-t border-border">
          <button
            type="button"
            data-today
            class="w-full text-center text-xs font-medium text-link hover:text-link-hover transition-colors cursor-pointer py-1"
          >
            Today
          </button>
        </div>
      </div>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".DatePicker">
        export default {
          mounted() {
            const root = this.el
            const trigger = root.querySelector("[data-date-trigger]")
            const panel = root.querySelector("[data-date-panel]")
            const hidden = root.querySelector("[data-date-value]")
            const display = root.querySelector("[data-date-display]")
            const grid = root.querySelector("[data-days-grid]")
            const monthLabel = root.querySelector("[data-month-label]")
            const minDate = root.dataset.min ? new Date(root.dataset.min + "T00:00:00") : null
            const maxDate = root.dataset.max ? new Date(root.dataset.max + "T00:00:00") : null
            let open = false
            let viewDate = hidden.value ? new Date(hidden.value + "T00:00:00") : new Date()
            let selected = hidden.value ? new Date(hidden.value + "T00:00:00") : null

            const MONTHS = ["January","February","March","April","May","June",
                            "July","August","September","October","November","December"]

            const pad = n => String(n).padStart(2, "0")

            const toISO = d => `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`

            const formatDisplay = d => {
              return d.toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" })
            }

            const isSameDay = (a, b) => a && b &&
              a.getFullYear() === b.getFullYear() &&
              a.getMonth() === b.getMonth() &&
              a.getDate() === b.getDate()

            const isToday = d => isSameDay(d, new Date())

            const inRange = d => {
              if (minDate && d < minDate) return false
              if (maxDate && d > maxDate) return false
              return true
            }

            const render = () => {
              monthLabel.textContent = `${MONTHS[viewDate.getMonth()]} ${viewDate.getFullYear()}`
              grid.innerHTML = ""

              const year = viewDate.getFullYear(), month = viewDate.getMonth()
              const firstDay = new Date(year, month, 1).getDay()
              const daysInMonth = new Date(year, month + 1, 0).getDate()

              // Empty cells for offset
              for (let i = 0; i < firstDay; i++) {
                grid.appendChild(Object.assign(document.createElement("span"), { className: "py-1" }))
              }

              for (let d = 1; d <= daysInMonth; d++) {
                const date = new Date(year, month, d)
                const btn = document.createElement("button")
                btn.type = "button"
                btn.textContent = d
                const sel = isSameDay(date, selected)
                const today = isToday(date)
                const disabled = !inRange(date)

                btn.className = [
                  "h-8 w-8 mx-auto rounded-md text-xs font-medium flex items-center justify-center transition-colors cursor-pointer",
                  sel ? "bg-primary text-primary-text" :
                  today ? "border border-primary text-primary" :
                  disabled ? "text-text-muted cursor-not-allowed opacity-40" :
                  "text-text hover:bg-surface-hover"
                ].join(" ")

                if (!disabled) {
                  btn.addEventListener("click", () => {
                    selected = date
                    hidden.value = toISO(date)
                    display.textContent = formatDisplay(date)
                    display.className = "text-text"
                    // Dispatch input event for LiveView
                    hidden.dispatchEvent(new Event("input", { bubbles: true }))
                    hide()
                    render()
                  })
                }
                grid.appendChild(btn)
              }
            }

            const show = () => {
              if (open) return
              open = true
              viewDate = selected ? new Date(selected) : new Date()
              render()
              panel.hidden = false
              requestAnimationFrame(() => {
                panel.classList.remove("opacity-0", "scale-95", "pointer-events-none")
                panel.classList.add("opacity-100", "scale-100")
              })
            }

            const hide = () => {
              if (!open) return
              open = false
              panel.classList.remove("opacity-100", "scale-100")
              panel.classList.add("opacity-0", "scale-95", "pointer-events-none")
              panel.addEventListener("transitionend", () => { panel.hidden = true }, { once: true })
            }

            trigger.addEventListener("click", (e) => { e.stopPropagation(); open ? hide() : show() })
            document.addEventListener("click", (e) => { if (open && !root.contains(e.target) && !panel.contains(e.target)) hide() })
            document.addEventListener("keydown", (e) => { if (open && e.key === "Escape") { e.preventDefault(); hide() } })

            root.querySelector("[data-prev-month]").addEventListener("click", () => {
              viewDate.setMonth(viewDate.getMonth() - 1); render()
            })
            root.querySelector("[data-next-month]").addEventListener("click", () => {
              viewDate.setMonth(viewDate.getMonth() + 1); render()
            })
            root.querySelector("[data-today]").addEventListener("click", () => {
              const today = new Date()
              if (inRange(today)) {
                selected = today; hidden.value = toISO(today)
                display.textContent = formatDisplay(today); display.className = "text-text"
                hidden.dispatchEvent(new Event("input", { bubbles: true }))
                viewDate = new Date(today); render(); hide()
              }
            })

            this._hide = hide
            this._syncValue = () => {
              const newVal = hidden.value
              if (newVal && newVal !== "") {
                const newDate = new Date(newVal + "T00:00:00")
                if (!selected || newDate.getTime() !== selected.getTime()) {
                  selected = newDate
                  viewDate = new Date(selected)
                  display.textContent = formatDisplay(selected)
                  display.className = "text-text"
                  if (open) render()
                }
              } else if (selected) {
                selected = null
                display.textContent = display.parentElement?.dataset?.placeholder || "Pick a date"
                display.className = "text-text-muted"
                if (open) render()
              }
            }
          },

          updated() {
            // Sync selected date if the server pushed a new value
            this._syncValue?.()
          },

          destroyed() { this._hide?.() }
        }
      </script>
    </div>
    """
  end

  defp assign_field_attrs(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value && to_string(field.value) end)
  end

  defp assign_field_attrs(assigns) do
    assigns
    |> assign_new(:name, fn -> assigns[:name] end)
    |> assign_new(:value, fn -> assigns[:value] end)
  end

  # ── Date Range Picker ──────────────────────────────────────────

  @doc """
  Date range picker with two-month calendar view.

  ## Examples

      <.date_range_picker id="trip" start_name="check_in" end_name="check_out" label="Trip dates" />
      <.date_range_picker id="report" start_name="from" end_name="to" start_value="2026-03-01" end_value="2026-03-15" />
  """

  attr :id, :string, required: true
  attr :start_name, :string, required: true
  attr :end_name, :string, required: true
  attr :start_value, :string, default: nil
  attr :end_value, :string, default: nil
  attr :label, :string, default: nil
  attr :placeholder, :string, default: "Select date range"
  attr :min, :string, default: nil
  attr :max, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil

  def date_range_picker(assigns) do
    display =
      cond do
        assigns.start_value && assigns.end_value && assigns.start_value != "" &&
            assigns.end_value != "" ->
          "#{format_display(assigns.start_value)} — #{format_display(assigns.end_value)}"

        assigns.start_value && assigns.start_value != "" ->
          "#{format_display(assigns.start_value)} — ..."

        true ->
          nil
      end

    assigns = assign(assigns, :display, display)

    ~H"""
    <div
      id={@id}
      phx-hook=".DateRangePicker"
      class={["relative", @class]}
      data-min={@min}
      data-max={@max}
    >
      <label :if={@label} class="block text-sm font-medium text-text mb-1.5">{@label}</label>
      <input type="hidden" name={@start_name} value={@start_value} data-range-start />
      <input type="hidden" name={@end_name} value={@end_value} data-range-end />

      <button
        type="button"
        disabled={@disabled}
        data-range-trigger
        style={"anchor-name: --drp-#{@id}"}
        class={[
          "flex items-center justify-between w-full",
          "rounded-md border border-border bg-surface px-3 py-2 text-sm text-left",
          "transition-colors hover:border-border-strong",
          "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring",
          "cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
        ]}
      >
        <span data-range-display class={if(@display, do: "text-text", else: "text-text-muted")}>
          {@display || @placeholder}
        </span>
        <.icon name="hero-calendar-days" class="size-4 text-text-muted shrink-0" />
      </button>

      <%!-- Two-month calendar panel --%>
      <div
        data-range-panel
        class="dp-panel p-3 opacity-0 scale-95 pointer-events-none transition-[opacity,transform] duration-150 ease-out"
        style={"position-anchor: --drp-#{@id}"}
        hidden
      >
        <div class="flex gap-4">
          <%!-- Left month --%>
          <div class="w-[240px]">
            <div class="flex items-center justify-between mb-3">
              <button
                type="button"
                data-prev-month
                class="p-1 rounded-md hover:bg-surface-hover transition-colors cursor-pointer"
                aria-label="Previous month"
              >
                <.icon name="hero-chevron-left-mini" class="size-5 text-text-secondary" />
              </button>
              <span data-month-label-left class="text-sm font-semibold text-text" />
              <span class="w-7" />
            </div>
            <div class="grid grid-cols-7 mb-1">
              <span
                :for={d <- ~w(Su Mo Tu We Th Fr Sa)}
                class="text-center text-[0.65rem] font-medium text-text-muted py-1"
              >
                {d}
              </span>
            </div>
            <div data-days-left class="grid grid-cols-7" />
          </div>
          <%!-- Right month --%>
          <div class="w-[240px]">
            <div class="flex items-center justify-between mb-3">
              <span class="w-7" />
              <span data-month-label-right class="text-sm font-semibold text-text" />
              <button
                type="button"
                data-next-month
                class="p-1 rounded-md hover:bg-surface-hover transition-colors cursor-pointer"
                aria-label="Next month"
              >
                <.icon name="hero-chevron-right-mini" class="size-5 text-text-secondary" />
              </button>
            </div>
            <div class="grid grid-cols-7 mb-1">
              <span
                :for={d <- ~w(Su Mo Tu We Th Fr Sa)}
                class="text-center text-[0.65rem] font-medium text-text-muted py-1"
              >
                {d}
              </span>
            </div>
            <div data-days-right class="grid grid-cols-7" />
          </div>
        </div>
        <div class="mt-2 pt-2 border-t border-border flex items-center justify-between">
          <button
            type="button"
            data-clear
            class="text-xs font-medium text-text-muted hover:text-text transition-colors cursor-pointer py-1"
          >
            Clear
          </button>
          <button
            type="button"
            data-range-done
            class="text-xs font-medium text-link hover:text-link-hover transition-colors cursor-pointer py-1"
          >
            Done
          </button>
        </div>
      </div>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".DateRangePicker">
        export default {
          mounted() {
            const root = this.el
            const trigger = root.querySelector("[data-range-trigger]")
            const panel = root.querySelector("[data-range-panel]")
            const startInput = root.querySelector("[data-range-start]")
            const endInput = root.querySelector("[data-range-end]")
            const display = root.querySelector("[data-range-display]")
            const gridL = root.querySelector("[data-days-left]")
            const gridR = root.querySelector("[data-days-right]")
            const labelL = root.querySelector("[data-month-label-left]")
            const labelR = root.querySelector("[data-month-label-right]")
            const minDate = root.dataset.min ? new Date(root.dataset.min + "T00:00:00") : null
            const maxDate = root.dataset.max ? new Date(root.dataset.max + "T00:00:00") : null

            let open = false, hovered = null
            let viewMonth = new Date() // left month
            let rangeStart = startInput.value ? new Date(startInput.value + "T00:00:00") : null
            let rangeEnd = endInput.value ? new Date(endInput.value + "T00:00:00") : null

            const MONTHS = ["January","February","March","April","May","June",
                            "July","August","September","October","November","December"]
            const pad = n => String(n).padStart(2, "0")
            const toISO = d => `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`
            const fmt = d => d.toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" })
            const sameDay = (a, b) => a && b && a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate()
            const inRange = d => { if (minDate && d < minDate) return false; if (maxDate && d > maxDate) return false; return true }

            const isBetween = (d, s, e) => {
              if (!s || !e) return false
              const t = d.getTime(), a = Math.min(s.getTime(), e.getTime()), b = Math.max(s.getTime(), e.getTime())
              return t >= a && t <= b
            }

            const renderMonth = (grid, label, year, month) => {
              label.textContent = `${MONTHS[month]} ${year}`
              const firstDay = new Date(year, month, 1).getDay()
              const daysInMonth = new Date(year, month + 1, 0).getDate()
              const totalCells = firstDay + daysInMonth

              // Reuse existing cells or create new ones
              while (grid.children.length > totalCells) grid.lastChild.remove()
              while (grid.children.length < totalCells) grid.appendChild(document.createElement("button"))

              // Empty offset cells
              for (let i = 0; i < firstDay; i++) {
                const el = grid.children[i]
                el.className = "h-8"; el.textContent = ""; el.type = "button"
                el.onclick = null; el.onmouseenter = null; el.disabled = true
              }

              for (let d = 1; d <= daysInMonth; d++) {
                const idx = firstDay + d - 1
                const btn = grid.children[idx]
                const date = new Date(year, month, d)
                btn.type = "button"
                btn.textContent = d
                const disabled = !inRange(date)
                const isStart = sameDay(date, rangeStart)
                const isEnd = sameDay(date, rangeEnd)
                const isEdge = isStart || isEnd
                const previewEnd = rangeStart && !rangeEnd ? hovered : rangeEnd
                const between = isBetween(date, rangeStart, previewEnd)

                btn.className = [
                  "h-8 w-8 mx-auto text-xs font-medium flex items-center justify-center cursor-pointer",
                  isEdge ? "rounded-md bg-primary text-primary-text" :
                  between ? "bg-primary/10 text-primary" :
                  disabled ? "text-text-muted cursor-not-allowed opacity-40" :
                  "rounded-md text-text hover:bg-surface-hover"
                ].join(" ")

                btn.disabled = disabled
                btn.onclick = disabled ? null : () => selectDate(date)
                btn.onmouseenter = disabled ? null : () => { hovered = date; updateStyles() }
              }
            }

            // Fast style-only update (no DOM rebuild) for hover preview
            const updateStyles = () => {
              const lY = viewMonth.getFullYear(), lM = viewMonth.getMonth()
              const rDate = new Date(lY, lM + 1, 1)
              updateMonthStyles(gridL, lY, lM)
              updateMonthStyles(gridR, rDate.getFullYear(), rDate.getMonth())
            }

            const updateMonthStyles = (grid, year, month) => {
              const firstDay = new Date(year, month, 1).getDay()
              const daysInMonth = new Date(year, month + 1, 0).getDate()
              for (let d = 1; d <= daysInMonth; d++) {
                const btn = grid.children[firstDay + d - 1]
                if (!btn) continue
                const date = new Date(year, month, d)
                if (!inRange(date)) continue
                const isStart = sameDay(date, rangeStart)
                const isEnd = sameDay(date, rangeEnd)
                const isEdge = isStart || isEnd
                const previewEnd = rangeStart && !rangeEnd ? hovered : rangeEnd
                const between = isBetween(date, rangeStart, previewEnd)
                btn.className = [
                  "h-8 w-8 mx-auto text-xs font-medium flex items-center justify-center cursor-pointer",
                  isEdge ? "rounded-md bg-primary text-primary-text" :
                  between ? "bg-primary/10 text-primary" :
                  "rounded-md text-text hover:bg-surface-hover"
                ].join(" ")
              }
            }

            const selectDate = (date) => {
              if (!rangeStart || (rangeStart && rangeEnd)) {
                // Start new range
                rangeStart = date; rangeEnd = null
              } else {
                // Complete range
                if (date < rangeStart) {
                  rangeEnd = rangeStart; rangeStart = date
                } else {
                  rangeEnd = date
                }
              }
              updateInputs()
              render()
            }

            const updateInputs = () => {
              startInput.value = rangeStart ? toISO(rangeStart) : ""
              endInput.value = rangeEnd ? toISO(rangeEnd) : ""
              if (rangeStart && rangeEnd) {
                display.textContent = `${fmt(rangeStart)} — ${fmt(rangeEnd)}`
                display.className = "text-text"
              } else if (rangeStart) {
                display.textContent = `${fmt(rangeStart)} — ...`
                display.className = "text-text"
              } else {
                display.textContent = trigger.dataset.placeholder || "Select date range"
                display.className = "text-text-muted"
              }
              startInput.dispatchEvent(new Event("input", { bubbles: true }))
            }

            const render = () => {
              const lY = viewMonth.getFullYear(), lM = viewMonth.getMonth()
              const rDate = new Date(lY, lM + 1, 1)
              renderMonth(gridL, labelL, lY, lM)
              renderMonth(gridR, labelR, rDate.getFullYear(), rDate.getMonth())
            }

            const show = () => {
              if (open) return; open = true
              if (rangeStart) viewMonth = new Date(rangeStart.getFullYear(), rangeStart.getMonth(), 1)
              else viewMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1)
              render()
              panel.hidden = false
              requestAnimationFrame(() => {
                panel.classList.remove("opacity-0", "scale-95", "pointer-events-none")
                panel.classList.add("opacity-100", "scale-100")
              })
            }

            const hide = () => {
              if (!open) return; open = false
              panel.classList.remove("opacity-100", "scale-100")
              panel.classList.add("opacity-0", "scale-95", "pointer-events-none")
              panel.addEventListener("transitionend", () => { panel.hidden = true }, { once: true })
            }

            trigger.addEventListener("click", (e) => { e.stopPropagation(); open ? hide() : show() })
            document.addEventListener("click", (e) => { if (open && !root.contains(e.target) && !panel.contains(e.target)) hide() })
            document.addEventListener("keydown", (e) => { if (open && e.key === "Escape") { e.preventDefault(); hide() } })

            root.querySelector("[data-prev-month]").addEventListener("click", () => { viewMonth.setMonth(viewMonth.getMonth() - 1); render() })
            root.querySelector("[data-next-month]").addEventListener("click", () => { viewMonth.setMonth(viewMonth.getMonth() + 1); render() })
            root.querySelector("[data-clear]").addEventListener("click", () => {
              rangeStart = null; rangeEnd = null; hovered = null; updateInputs(); render()
            })
            root.querySelector("[data-range-done]").addEventListener("click", () => hide())

            panel.addEventListener("mouseleave", () => { hovered = null; render() })

            this._hide = hide
          },
          destroyed() { this._hide?.() }
        }
      </script>
    </div>
    """
  end

  defp format_display(nil), do: nil
  defp format_display(""), do: nil

  defp format_display(date_str) when is_binary(date_str) do
    case Date.from_iso8601(date_str) do
      {:ok, date} ->
        Calendar.strftime(date, "%b %d, %Y")

      _ ->
        date_str
    end
  end

  defp format_display(_), do: nil
end
