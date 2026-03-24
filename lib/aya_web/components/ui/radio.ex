defmodule AyaWeb.UI.Radio do
  @moduledoc """
  Styled radio button group. Only one option can be selected.

  ## Examples

      <.radio_group field={@form[:role]} label="Role">
        <:option value="chef" label="Chef" />
        <:option value="scientist" label="Food Scientist" description="R&D" />
        <:option value="student" label="Student" disabled />
      </.radio_group>

  ## Card-style Focus Group

      <.radio_group field={@form[:plan]} label="Plan" variant="card">
        <:option value="free" label="Free" description="Basic access" />
        <:option value="pro" label="Pro" description="All features" />
      </.radio_group>
  """

  use Phoenix.Component

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :name, :string, default: nil
  attr :value, :any, default: nil
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :variant, :string, default: "default", values: ~w(default card)
  attr :class, :any, default: nil

  slot :option, required: true do
    attr :value, :string, required: true
    attr :label, :string, required: true
    attr :description, :string
    attr :disabled, :boolean
  end

  def radio_group(assigns) do
    assigns =
      if assigns.field do
        field = assigns.field

        assigns
        |> assign(:name, assigns.name || field.name)
        |> assign(:value, assigns.value || field.value)
      else
        assigns
      end

    assigns = assign_new(assigns, :value, fn -> nil end)

    ~H"""
    <fieldset class={[@class]}>
      <legend :if={@label} class="text-sm font-medium text-text mb-2">{@label}</legend>
      <p :if={@description} class="text-xs text-text-muted -mt-1 mb-3">{@description}</p>
      <div class={if @variant == "card", do: "grid gap-3", else: "space-y-3"}>
        <label
          :for={opt <- @option}
          class={[
            "group flex items-start gap-3 cursor-pointer select-none",
            opt[:disabled] && "opacity-50 cursor-not-allowed",
            @variant == "card" && "rb-card"
          ]}
        >
          <input
            type="radio"
            name={@name}
            value={opt.value}
            checked={if to_string(@value) == to_string(opt.value), do: true}
            disabled={opt[:disabled] || false}
            class="rb__input"
          />
          <span class="rb__circle">
            <span class="rb__dot" />
          </span>
          <span class="pt-px min-w-0">
            <span class="block text-sm font-medium text-text group-has-[:disabled]:text-text-muted">
              {opt.label}
            </span>
            <span :if={opt[:description]} class="block text-xs text-text-muted mt-0.5">
              {opt[:description]}
            </span>
          </span>
        </label>
      </div>
    </fieldset>
    """
  end
end
