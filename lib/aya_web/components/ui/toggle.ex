defmodule AyaWeb.UI.Toggle do
  @moduledoc """
  Switch-style toggle for boolean values. Form-integrated via hidden checkbox.

  ## Examples

      <.toggle field={@form[:notifications]} label="Push notifications" />
      <.toggle
        field={@form[:dark_mode]}
        label="Dark mode"
        description="Use dark theme across the app"
        size="lg"
      />
  """

  use Phoenix.Component

  @size_values ~w(sm md lg)

  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :field, Phoenix.HTML.FormField, doc: "form field for binding"
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :size, :string, default: "md", values: @size_values
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global

  def toggle(assigns) do
    assigns =
      assigns
      |> assign_field_attrs()
      |> assign_new(:checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <label class={[
      "inline-flex gap-3 select-none",
      if(@description, do: "items-start", else: "items-center"),
      if(@disabled, do: "opacity-50 cursor-not-allowed", else: "cursor-pointer"),
      @class
    ]}>
      <span class={["relative inline-flex shrink-0", if(@description, do: "mt-0.5")]}>
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          disabled={@disabled}
          class="peer sr-only"
          {@rest}
        />
        <%!-- Track --%>
        <span class={[
          "block rounded-full bg-border-strong transition-colors duration-fast",
          "peer-checked:bg-primary",
          "peer-focus-visible:ring-2 peer-focus-visible:ring-ring peer-focus-visible:ring-offset-2 peer-focus-visible:ring-offset-surface",
          track_size(@size)
        ]} />
        <%!-- Knob: centered vertically with equal inset --%>
        <span class={[
          "absolute top-[3px] left-[3px] rounded-full bg-white shadow-sm",
          "transition-transform duration-fast ease-out",
          knob_size(@size)
        ]} />
      </span>
      <span :if={@label || @description}>
        <span :if={@label} class="block text-sm font-medium text-text leading-tight">{@label}</span>
        <span :if={@description} class="block mt-0.5 text-xs text-text-muted leading-tight">
          {@description}
        </span>
      </span>
    </label>
    """
  end

  defp track_size("sm"), do: "w-[36px] h-[20px]"
  defp track_size("md"), do: "w-[44px] h-[24px]"
  defp track_size("lg"), do: "w-[52px] h-[28px]"

  # knob = track_height - 6px; translate = track_width - knob - 6px
  defp knob_size("sm"), do: "size-[14px] peer-checked:translate-x-[16px]"
  defp knob_size("md"), do: "size-[18px] peer-checked:translate-x-[20px]"
  defp knob_size("lg"), do: "size-[22px] peer-checked:translate-x-[24px]"

  defp assign_field_attrs(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign_new(:id, fn -> field.id end)
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
  end

  defp assign_field_attrs(assigns) do
    assigns
    |> assign_new(:id, fn -> assigns[:name] end)
    |> assign_new(:name, fn -> nil end)
    |> assign_new(:value, fn -> nil end)
  end
end
