defmodule AyaWeb.UI.Accordion do
  @moduledoc """
  Collapsible sections using native `<details>`/`<summary>`.

  ## Variants

  - `"default"` — minimal with dividers
  - `"card"` — bordered card per item
  - `"block"` — filled background blocks
  - `"separated"` — cards with gap between items

  ## Examples

      <.accordion>
        <:item title="What is Aya?">A food platform.</:item>
      </.accordion>

      <.accordion variant="card">
        <:item title="Ingredients" icon="hero-beaker" open>...</:item>
      </.accordion>

      <.accordion variant="block">
        <:item title="Step 1" subtitle="Prepare ingredients">...</:item>
      </.accordion>

      <.accordion variant="separated" exclusive>
        <:item title="FAQ 1">Answer</:item>
      </.accordion>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, default: nil
  attr :exclusive, :boolean, default: false
  attr :variant, :string, default: "default", values: ~w(default card block separated horizontal)
  attr :chevron, :boolean, default: true, doc: "show/hide the collapse chevron icon"
  attr :class, :any, default: nil

  slot :item, required: true do
    attr :title, :string, required: true
    attr :subtitle, :string
    attr :icon, :string
    attr :image, :string
    attr :badge, :string
    attr :open, :boolean
  end

  def accordion(assigns) do
    assigns =
      assign_new(assigns, :group_name, fn ->
        if assigns.exclusive,
          do: assigns[:id] || "accordion-#{System.unique_integer([:positive])}"
      end)

    ~H"""
    <div class={[wrapper_class(@variant), @class]}>
      <details
        :for={item <- @item}
        name={if @exclusive, do: @group_name}
        open={item[:open]}
        class={["group", item_class(@variant)]}
      >
        <summary class={[summary_class(@variant)]}>
          <span class="flex items-center gap-3 min-w-0">
            <img
              :if={item[:image]}
              src={item[:image]}
              alt=""
              class="size-10 rounded-lg object-cover shrink-0 outline-none"
              loading="lazy"
            />
            <.icon
              :if={item[:icon] && !item[:image]}
              name={item[:icon]}
              class="size-4.5 text-text-muted shrink-0 group-open:text-primary transition-colors"
            />
            <span class="min-w-0">
              <span class="block text-sm font-medium text-text">{item[:title] || item.title}</span>
              <span :if={item[:subtitle]} class="block text-xs text-text-muted mt-0.5">
                {item[:subtitle]}
              </span>
            </span>
          </span>
          <span class="flex items-center gap-2 shrink-0">
            <span
              :if={item[:badge]}
              class="inline-flex items-center justify-center min-w-[1.25rem] h-5 px-1.5 rounded-full bg-surface-alt text-[0.65rem] font-medium text-text-secondary"
            >
              {item[:badge]}
            </span>
            <.icon
              :if={@chevron}
              name="hero-chevron-down-mini"
              class="size-5 text-text-muted transition-transform duration-normal group-open:rotate-180 rtl:rotate-180 rtl:group-open:rotate-0"
            />
          </span>
        </summary>
        <div class={content_class(@variant)}>
          {render_slot(item)}
        </div>
      </details>
    </div>
    """
  end

  # ── Variant styles ──

  defp wrapper_class("default"), do: "accordion divide-y divide-border"

  defp wrapper_class("card"),
    do: "accordion rounded-lg border border-border divide-y divide-border overflow-hidden"

  defp wrapper_class("block"), do: "accordion space-y-2"
  defp wrapper_class("separated"), do: "accordion space-y-3"

  defp wrapper_class("horizontal"),
    do: "accordion flex rounded-lg border border-border overflow-hidden divide-x divide-border"

  defp item_class("default"), do: ""
  defp item_class("card"), do: ""
  defp item_class("block"), do: "rounded-lg bg-surface-alt"
  defp item_class("separated"), do: "rounded-lg border border-border bg-surface"
  defp item_class("horizontal"), do: "flex-1 min-w-0"

  defp summary_class(variant) do
    base = [
      "flex items-center justify-between gap-3",
      "text-sm font-medium text-text cursor-pointer select-none",
      "list-none [&::-webkit-details-marker]:hidden",
      "transition-colors",
      "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring"
    ]

    padding =
      case variant do
        "default" -> "py-4 px-1"
        "card" -> "py-3.5 px-4"
        "block" -> "py-3 px-4"
        "separated" -> "py-3.5 px-4"
        "horizontal" -> "py-3 px-4"
      end

    hover =
      case variant do
        "default" -> "hover:text-text"
        "card" -> "hover:text-primary"
        "block" -> "hover:text-primary rounded-lg"
        "separated" -> "hover:text-primary rounded-lg"
        "horizontal" -> "hover:text-primary hover:bg-surface-alt"
      end

    base ++ [padding, hover]
  end

  defp content_class(variant) do
    base = "accordion__content text-sm text-text-secondary"

    case variant do
      "default" -> "#{base} pb-4 px-1"
      "card" -> "#{base} pb-4 px-4"
      "block" -> "#{base} pb-3 px-4"
      "separated" -> "#{base} pb-4 px-4"
      "horizontal" -> "#{base} pb-3 px-4"
    end
  end
end
