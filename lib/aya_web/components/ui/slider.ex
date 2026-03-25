defmodule AyaWeb.UI.Slider do
  @moduledoc """
  Range slider for numeric values. Form-integrated via hidden input.

  Supports single-thumb and dual-thumb (range) modes, optional tick marks,
  value display, and labeled marks.

  ## Examples

      <.slider id="volume" field={@form[:volume]} label="Volume" />

      <.slider
        id="price"
        field={@form[:price]}
        min={0}
        max={200}
        step={5}
        label="Price"
        show_value
        suffix="$"
      />

      <.slider
        id="range"
        field={@form[:range]}
        min={0}
        max={100}
        range
        label="Price range"
        show_value
      />

      <.slider
        id="temp"
        field={@form[:temp]}
        min={0}
        max={500}
        step={25}
        marks={[
          %{value: 0, label: "0°F"},
          %{value: 212, label: "Boil"},
          %{value: 350, label: "Bake"},
          %{value: 500, label: "Broil"}
        ]}
      />
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, required: true
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :name, :string, default: nil
  attr :value, :any, default: nil, doc: "number or [min, max] list for range mode"
  attr :min, :integer, default: 0
  attr :max, :integer, default: 100
  attr :step, :integer, default: 1
  attr :label, :string, default: nil
  attr :show_value, :boolean, default: false, doc: "display current value next to slider"
  attr :show_ticks, :boolean, default: false, doc: "show tick marks at each step"
  attr :range, :boolean, default: false, doc: "dual-thumb range mode"
  attr :marks, :list, default: nil, doc: "list of %{value: n, label: \"...\"} for labeled marks"
  attr :prefix, :string, default: nil, doc: "prefix for value display (e.g. \"$\")"
  attr :suffix, :string, default: nil, doc: "suffix for value display (e.g. \"%\")"
  attr :disabled, :boolean, default: false
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :class, :any, default: nil

  def slider(assigns) do
    assigns =
      assigns
      |> assign_field_attrs()
      |> assign_value()

    ~H"""
    <div
      id={@id}
      phx-hook=".Slider"
      class={["slider", size_class(@size), @disabled && "slider--disabled", @class]}
      data-min={@min}
      data-max={@max}
      data-step={@step}
      data-range={if @range, do: "true"}
      data-value={
        if @range, do: "#{elem(@current_range, 0)},#{elem(@current_range, 1)}", else: @current_value
      }
    >
      <%!-- Label row --%>
      <div :if={@label || @show_value} class="flex items-center justify-between mb-2">
        <label :if={@label} for={"#{@id}-input"} class="text-sm font-medium text-text">
          {@label}
        </label>
        <span
          :if={@show_value}
          class="text-sm tabular-nums text-text-muted"
          data-slider-display
        >
          {format_display(assigns)}
        </span>
      </div>

      <%!-- Track --%>
      <div class="slider__track" data-slider-track>
        <%!-- Fill bar --%>
        <div class="slider__fill" data-slider-fill style={fill_style(assigns)} />

        <%!-- Thumb(s) --%>
        <%= if @range do %>
          <div
            class="slider__thumb"
            data-slider-thumb="low"
            role="slider"
            tabindex={if @disabled, do: "-1", else: "0"}
            aria-valuemin={@min}
            aria-valuemax={@max}
            aria-valuenow={elem(@current_range, 0)}
            aria-label={"#{@label || "Range"} minimum"}
            style={"left: #{pct(elem(@current_range, 0), @min, @max)}%"}
          />
          <div
            class="slider__thumb"
            data-slider-thumb="high"
            role="slider"
            tabindex={if @disabled, do: "-1", else: "0"}
            aria-valuemin={@min}
            aria-valuemax={@max}
            aria-valuenow={elem(@current_range, 1)}
            aria-label={"#{@label || "Range"} maximum"}
            style={"left: #{pct(elem(@current_range, 1), @min, @max)}%"}
          />
        <% else %>
          <div
            class="slider__thumb"
            data-slider-thumb="single"
            role="slider"
            tabindex={if @disabled, do: "-1", else: "0"}
            aria-valuemin={@min}
            aria-valuemax={@max}
            aria-valuenow={@current_value}
            aria-label={@label}
            style={"left: #{pct(@current_value, @min, @max)}%"}
          />
        <% end %>

        <%!-- Tick marks --%>
        <div :if={@show_ticks} class="slider__ticks">
          <span
            :for={tick <- tick_values(@min, @max, @step)}
            class="slider__tick"
            style={"left: #{pct(tick, @min, @max)}%"}
          />
        </div>
      </div>

      <%!-- Labeled marks --%>
      <div :if={@marks} class="slider__marks">
        <span
          :for={mark <- @marks}
          class="slider__mark-label"
          style={"left: #{pct(mark.value, @min, @max)}%"}
        >
          {mark.label}
        </span>
      </div>

      <%!-- Hidden input(s) for form submission --%>
      <%= if @range do %>
        <input
          type="hidden"
          name={"#{@name}[]"}
          value={elem(@current_range, 0)}
          data-slider-input="low"
        />
        <input
          type="hidden"
          name={"#{@name}[]"}
          value={elem(@current_range, 1)}
          data-slider-input="high"
        />
      <% else %>
        <input
          type="hidden"
          id={"#{@id}-input"}
          name={@name}
          value={@current_value}
          data-slider-input="single"
        />
      <% end %>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".Slider">
        export default {
          mounted() {
            const el = this.el
            const track = el.querySelector("[data-slider-track]")
            const fill = el.querySelector("[data-slider-fill]")
            const display = el.querySelector("[data-slider-display]")
            const isRange = el.dataset.range === "true"
            const min = parseFloat(el.dataset.min)
            const max = parseFloat(el.dataset.max)
            const step = parseFloat(el.dataset.step)
            const prefix = el.dataset.prefix || ""
            const suffix = el.dataset.suffix || ""

            const clamp = (v) => Math.round(Math.min(max, Math.max(min, Math.round(v / step) * step)) * 1e6) / 1e6
            const pct = (v) => ((v - min) / (max - min)) * 100

            // Parse initial value
            let values = isRange
              ? el.dataset.value.split(",").map(Number)
              : [parseFloat(el.dataset.value)]

            const thumbs = el.querySelectorAll("[data-slider-thumb]")
            const inputs = el.querySelectorAll("[data-slider-input]")

            const update = () => {
              if (isRange) {
                const [lo, hi] = values
                fill.style.left = pct(lo) + "%"
                fill.style.width = (pct(hi) - pct(lo)) + "%"
                thumbs[0].style.left = pct(lo) + "%"
                thumbs[1].style.left = pct(hi) + "%"
                thumbs[0].setAttribute("aria-valuenow", lo)
                thumbs[1].setAttribute("aria-valuenow", hi)
                inputs[0].value = lo
                inputs[1].value = hi
                if (display) display.textContent = prefix + lo + suffix + " – " + prefix + hi + suffix
              } else {
                const v = values[0]
                fill.style.width = pct(v) + "%"
                thumbs[0].style.left = pct(v) + "%"
                thumbs[0].setAttribute("aria-valuenow", v)
                inputs[0].value = v
                if (display) display.textContent = prefix + v + suffix
              }
            }

            // Pointer drag
            const startDrag = (thumbIdx) => (e) => {
              if (el.classList.contains("slider--disabled")) return
              e.preventDefault()
              const rect = track.getBoundingClientRect()

              const onMove = (e2) => {
                const x = (e2.clientX || e2.touches?.[0]?.clientX || 0)
                const ratio = Math.max(0, Math.min(1, (x - rect.left) / rect.width))
                let v = clamp(min + ratio * (max - min))

                if (isRange) {
                  if (thumbIdx === 0) v = Math.min(v, values[1])
                  else v = Math.max(v, values[0])
                  values[thumbIdx] = v
                } else {
                  values[0] = v
                }
                update()
              }

              const onUp = () => {
                document.removeEventListener("pointermove", onMove)
                document.removeEventListener("pointerup", onUp)
                // Notify server
                inputs[0].dispatchEvent(new Event("input", { bubbles: true }))
              }

              document.addEventListener("pointermove", onMove)
              document.addEventListener("pointerup", onUp)
              onMove(e)
            }

            thumbs.forEach((thumb, i) => {
              thumb.addEventListener("pointerdown", startDrag(i))
            })

            // Click on track to jump
            track.addEventListener("pointerdown", (e) => {
              if (e.target.closest("[data-slider-thumb]")) return
              const rect = track.getBoundingClientRect()
              const ratio = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width))
              const v = clamp(min + ratio * (max - min))

              if (isRange) {
                // Move closest thumb
                const dLo = Math.abs(v - values[0])
                const dHi = Math.abs(v - values[1])
                const idx = dLo <= dHi ? 0 : 1
                values[idx] = v
              } else {
                values[0] = v
              }
              update()
              inputs[0].dispatchEvent(new Event("input", { bubbles: true }))
            })

            // Keyboard
            thumbs.forEach((thumb, i) => {
              thumb.addEventListener("keydown", (e) => {
                if (el.classList.contains("slider--disabled")) return
                let v = isRange ? values[i] : values[0]
                const bigStep = step * 10

                switch (e.key) {
                  case "ArrowRight": case "ArrowUp": v += step; break
                  case "ArrowLeft": case "ArrowDown": v -= step; break
                  case "PageUp": v += bigStep; break
                  case "PageDown": v -= bigStep; break
                  case "Home": v = min; break
                  case "End": v = max; break
                  default: return
                }
                e.preventDefault()
                v = clamp(v)

                if (isRange) {
                  if (i === 0) v = Math.min(v, values[1])
                  else v = Math.max(v, values[0])
                  values[i] = v
                } else {
                  values[0] = v
                }
                update()
                inputs[0].dispatchEvent(new Event("input", { bubbles: true }))
              })
            })

            update()
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

  defp assign_value(%{range: true} = assigns) do
    {lo, hi} =
      case assigns.value do
        [lo, hi] -> {to_number(lo, assigns.min), to_number(hi, assigns.max)}
        _ -> {assigns.min, assigns.max}
      end

    assign(assigns, current_range: {lo, hi}, current_value: nil)
  end

  defp assign_value(assigns) do
    val = to_number(assigns.value, assigns.min)
    assign(assigns, current_value: val, current_range: nil)
  end

  defp to_number(nil, default), do: default
  defp to_number(v, _default) when is_number(v), do: v

  defp to_number(v, default) when is_binary(v) do
    case Float.parse(v) do
      {n, _} -> n
      :error -> default
    end
  end

  defp to_number(_, default), do: default

  defp pct(value, min, max) when max > min do
    Float.round((value - min) / (max - min) * 100, 2)
  end

  defp pct(_, _, _), do: 0

  defp fill_style(%{range: true, current_range: {lo, hi}, min: min, max: max}) do
    "left: #{pct(lo, min, max)}%; width: #{pct(hi, min, max) - pct(lo, min, max)}%"
  end

  defp fill_style(%{current_value: val, min: min, max: max}) do
    "width: #{pct(val, min, max)}%"
  end

  defp format_display(%{range: true, current_range: {lo, hi}, prefix: prefix, suffix: suffix}) do
    p = prefix || ""
    s = suffix || ""
    "#{p}#{format_num(lo)}#{s} – #{p}#{format_num(hi)}#{s}"
  end

  defp format_display(%{current_value: val, prefix: prefix, suffix: suffix}) do
    p = prefix || ""
    s = suffix || ""
    "#{p}#{format_num(val)}#{s}"
  end

  defp format_num(n) when is_float(n) and trunc(n) == n, do: trunc(n)
  defp format_num(n), do: n

  defp tick_values(min, max, step) do
    count = trunc((max - min) / step)
    Enum.map(0..count, fn i -> min + i * step end)
  end

  defp size_class("sm"), do: "slider--sm"
  defp size_class("md"), do: "slider--md"
  defp size_class("lg"), do: "slider--lg"
  defp size_class(_), do: "slider--md"
end
