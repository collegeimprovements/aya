defmodule AyaWeb.UI.DescriptionList do
  @moduledoc """
  Description list component for displaying structured key-value metadata.

  ## Examples

      <.description_list>
        <:item label="Prep Time">15 minutes</:item>
        <:item label="Cook Time">30 minutes</:item>
        <:item label="Servings">4</:item>
      </.description_list>

      <.description_list variant="inline">
        <:item label="Calories" icon="hero-fire">240 kcal</:item>
        <:item label="Protein">12g</:item>
        <:item label="Status"><.badge variant="success">Published</.badge></:item>
      </.description_list>

      <.description_list variant="grid" columns={2}>
        <:item label="Category">Main Course</:item>
        <:item label="Cuisine">Italian</:item>
        <:item label="Description" span={2}>A rich and creamy pasta dish.</:item>
      </.description_list>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  @doc """
  Renders a description list with semantic `<dl>`, `<dt>`, `<dd>` elements.
  """
  attr :variant, :string,
    default: "stacked",
    values: ~w(stacked inline grid striped)

  attr :dividers, :boolean, default: true
  attr :columns, :integer, default: 1, doc: "grid columns for 'grid' variant (1-3)"
  attr :class, :any, default: nil

  slot :item, required: true do
    attr :label, :string, required: true
    attr :icon, :string
    attr :span, :integer
  end

  def description_list(assigns) do
    ~H"""
    <dl class={[dl_classes(@variant, @columns), @class]}>
      <div
        :for={{item, index} <- Enum.with_index(@item)}
        class={item_classes(@variant, @dividers, index, length(@item), item[:span])}
      >
        <dt class="text-sm font-medium text-text-muted">
          <span :if={item[:icon]} class="inline-flex items-center gap-1.5">
            <.icon name={item[:icon]} class="size-4 shrink-0" />
            {item[:label] || item.label}
          </span>
          <span :if={!item[:icon]}>
            {item[:label] || item.label}
          </span>
        </dt>
        <dd class={dd_classes(@variant)}>
          {render_slot(item)}
        </dd>
      </div>
    </dl>
    """
  end

  defp dl_classes("stacked", _columns), do: "flex flex-col"
  defp dl_classes("inline", _columns), do: "flex flex-col"
  defp dl_classes("grid", columns), do: ["grid gap-4", grid_cols(columns)]
  defp dl_classes("striped", _columns), do: "flex flex-col"

  defp grid_cols(1), do: "grid-cols-1"
  defp grid_cols(2), do: "grid-cols-1 sm:grid-cols-2"
  defp grid_cols(3), do: "grid-cols-1 sm:grid-cols-2 lg:grid-cols-3"
  defp grid_cols(_), do: "grid-cols-1"

  defp item_classes("stacked", dividers, index, total, _span) do
    [
      "py-3",
      dividers && index < total - 1 && "border-b border-border"
    ]
  end

  defp item_classes("inline", dividers, index, total, _span) do
    [
      "flex items-baseline justify-between gap-4 py-3",
      dividers && index < total - 1 && "border-b border-border"
    ]
  end

  defp item_classes("grid", _dividers, _index, _total, span) do
    [
      "p-3",
      col_span(span)
    ]
  end

  defp item_classes("striped", dividers, index, total, _span) do
    [
      "px-4 py-3",
      rem(index, 2) == 1 && "bg-surface-alt",
      dividers && index < total - 1 && "border-b border-border"
    ]
  end

  defp col_span(nil), do: nil
  defp col_span(1), do: nil
  defp col_span(2), do: "sm:col-span-2"
  defp col_span(3), do: "sm:col-span-3"
  defp col_span(_), do: nil

  defp dd_classes("inline"), do: "text-sm text-text text-right"
  defp dd_classes(_variant), do: "mt-1 text-sm text-text"
end
