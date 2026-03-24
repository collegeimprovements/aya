defmodule AyaWeb.UI.Checkbox do
  @moduledoc """
  Styled checkbox with label and optional description.

  ## Examples

      <.checkbox field={@form[:terms]} label="Accept terms" />

      <.checkbox
        field={@form[:newsletter]}
        label="Email newsletter"
        description="Receive weekly updates about new recipes"
      />

  ## Checkbox Group

      <.checkbox_group label="Dietary Preferences">
        <:option field={@form[:vegan]} label="Vegan" />
        <:option field={@form[:gluten_free]} label="Gluten-free" />
      </.checkbox_group>

  ## Card-style Focus Group

      <.checkbox_group label="Features" variant="card">
        <:option field={@form[:organic]} label="Organic" description="Certified organic" />
        <:option field={@form[:local]} label="Local" description="Farm to table" />
      </.checkbox_group>
  """

  use Phoenix.Component

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any, default: nil
  attr :value, :any, default: nil
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :checked, :boolean, default: nil
  attr :disabled, :boolean, default: false
  attr :variant, :string, default: "default", values: ~w(default card)
  attr :class, :any, default: nil
  attr :rest, :global

  def checkbox(assigns) do
    assigns =
      if assigns.field do
        field = assigns.field

        assigns
        |> assign_new(:id, fn -> field.id end)
        |> assign_new(:name, fn -> field.name end)
        |> assign_new(:value, fn -> field.value end)
      else
        assigns
      end

    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <label class={[
      "group flex items-start gap-3 cursor-pointer select-none",
      @disabled && "opacity-50 cursor-not-allowed",
      @variant == "card" && "cb-card",
      @class
    ]}>
      <input type="hidden" name={@name} value="false" disabled={@disabled} />
      <input
        type="checkbox"
        id={@id}
        name={@name}
        value="true"
        checked={@checked}
        disabled={@disabled}
        class="cb__input"
        {@rest}
      />
      <span class="cb__box">
        <svg class="cb__check" viewBox="0 0 12 12" fill="none">
          <path
            d="M2.5 6.5L5 9L9.5 3.5"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
      </span>
      <span :if={@label || @description} class="pt-px min-w-0">
        <span
          :if={@label}
          class="block text-sm font-medium text-text group-has-[:disabled]:text-text-muted"
        >
          {@label}
        </span>
        <span :if={@description} class="block text-xs text-text-muted mt-0.5">{@description}</span>
      </span>
    </label>
    """
  end

  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :variant, :string, default: "default", values: ~w(default card)
  attr :class, :any, default: nil

  slot :option, required: true do
    attr :field, Phoenix.HTML.FormField
    attr :label, :string, required: true
    attr :description, :string
    attr :checked, :boolean
    attr :disabled, :boolean
  end

  def checkbox_group(assigns) do
    ~H"""
    <fieldset class={[@class]}>
      <legend :if={@label} class="text-sm font-medium text-text mb-2">{@label}</legend>
      <p :if={@description} class="text-xs text-text-muted -mt-1 mb-3">{@description}</p>
      <div class={if @variant == "card", do: "grid gap-3", else: "space-y-3"}>
        <.checkbox
          :for={opt <- @option}
          field={opt[:field]}
          label={opt.label}
          description={opt[:description]}
          checked={opt[:checked]}
          disabled={opt[:disabled] || false}
          variant={@variant}
        />
      </div>
    </fieldset>
    """
  end
end
