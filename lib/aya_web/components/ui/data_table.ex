defmodule AyaWeb.UI.DataTable do
  @moduledoc """
  A feature-rich data table with sorting, row selection, striped rows,
  compact mode, sticky header, and custom empty states.

  Sort and selection events are sent to the parent LiveView via `phx-click`
  — no JS hooks required.

  ## Examples

      <.data_table id="foods" rows={@foods} sortable sort_by={@sort_by} sort_dir={@sort_dir}>
        <:col :let={row} label="Name" field="name">{row.name}</:col>
        <:col :let={row} label="Calories" field="calories" align="right">{row.calories}</:col>
      </.data_table>

  With row selection:

      <.data_table id="foods" rows={@foods} selectable selected={@selected}>
        <:col :let={row} label="Name">{row.name}</:col>
      </.data_table>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "function for generating the row id"
  attr :row_click, :any, default: nil, doc: "function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "function for mapping each row before calling :col and :action slots"

  attr :sortable, :boolean, default: false, doc: "enable column sorting"
  attr :sort_by, :string, default: nil, doc: "current sort column"
  attr :sort_dir, :string, default: "asc", values: ~w(asc desc)
  attr :selectable, :boolean, default: false, doc: "show row checkboxes"
  attr :selected, :list, default: [], doc: "list of selected row IDs"
  attr :sticky_header, :boolean, default: false
  attr :striped, :boolean, default: false
  attr :compact, :boolean, default: false
  attr :empty_message, :string, default: "No data to display."
  attr :empty_icon, :string, default: "hero-table-cells"
  attr :class, :any, default: nil

  slot :col, required: true do
    attr :label, :string
    attr :field, :string
    attr :align, :string
    attr :width, :string
    attr :sortable, :boolean
  end

  slot :action, doc: "the slot for showing user actions in the last table column"
  slot :empty, doc: "optional custom empty state"

  def data_table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    is_stream = is_struct(assigns.rows, Phoenix.LiveView.LiveStream)
    rows_list = if is_stream, do: [], else: assigns.rows
    is_empty = rows_list == []

    all_row_ids =
      if assigns.selectable && !is_stream do
        Enum.map(rows_list, fn row ->
          if assigns.row_id, do: assigns.row_id.(row), else: Map.get(row, :id)
        end)
      else
        []
      end

    all_selected =
      if assigns.selectable && !is_stream && !is_empty do
        MapSet.new(all_row_ids) |> MapSet.subset?(MapSet.new(assigns.selected))
      else
        false
      end

    assigns =
      assigns
      |> assign(:is_stream, is_stream)
      |> assign(:is_empty, is_empty && !is_stream)
      |> assign(:all_selected, all_selected)
      |> assign(:selected_set, MapSet.new(assigns.selected))

    ~H"""
    <div class={["overflow-x-auto rounded-lg border border-border", @class]}>
      <table class="w-full text-sm">
        <thead class={[
          "bg-surface-alt border-b border-border",
          @sticky_header && "sticky top-0 z-10 bg-surface-alt"
        ]}>
          <tr>
            <%!-- Selection header checkbox --%>
            <th
              :if={@selectable}
              class={[
                "text-center",
                if(@compact, do: "px-3 py-2", else: "px-4 py-3")
              ]}
            >
              <label class="inline-flex cursor-pointer">
                <input
                  type="checkbox"
                  checked={@all_selected}
                  phx-click="select_all"
                  class="cb__input"
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
              </label>
            </th>
            <%!-- Column headers --%>
            <th
              :for={col <- @col}
              class={[
                "text-xs font-medium text-text-secondary uppercase tracking-wider",
                col_align_class(col[:align]),
                col[:width],
                if(@compact, do: "px-3 py-2", else: "px-4 py-3"),
                @sortable && col_sortable?(col) && "cursor-pointer select-none hover:text-text"
              ]}
              phx-click={@sortable && col_sortable?(col) && "sort"}
              phx-value-field={@sortable && col_sortable?(col) && col[:field]}
            >
              <span class={[
                "inline-flex items-center gap-1",
                col_justify_class(col[:align])
              ]}>
                {col[:label]}
                <.sort_indicator
                  :if={@sortable && col_sortable?(col)}
                  field={col[:field]}
                  sort_by={@sort_by}
                  sort_dir={@sort_dir}
                />
              </span>
            </th>
            <%!-- Actions header --%>
            <th :if={@action != []} class={if(@compact, do: "px-3 py-2", else: "px-4 py-3")}>
              <span class="sr-only">Actions</span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={@is_stream && "stream"}
          class="divide-y divide-border"
        >
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            class={[
              "transition-colors",
              !row_selected?(assigns, row) && "hover:bg-surface-alt/50",
              @striped && "even:bg-surface-alt/30",
              row_selected?(assigns, row) && "bg-accent/5"
            ]}
          >
            <%!-- Row checkbox --%>
            <td
              :if={@selectable}
              class={[
                "text-center",
                if(@compact, do: "px-3 py-2", else: "px-4 py-3")
              ]}
            >
              <label class="inline-flex cursor-pointer">
                <input
                  type="checkbox"
                  checked={row_selected?(assigns, row)}
                  phx-click="select_row"
                  phx-value-id={row_id_value(assigns, row)}
                  class="cb__input"
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
              </label>
            </td>
            <%!-- Data cells --%>
            <td
              :for={col <- @col}
              phx-click={@row_click && @row_click.(row)}
              class={[
                "text-text",
                col_align_class(col[:align]),
                col[:width],
                if(@compact, do: "px-3 py-2 text-xs", else: "px-4 py-3"),
                @row_click && "cursor-pointer"
              ]}
            >
              {render_slot(col, @row_item.(row))}
            </td>
            <%!-- Action cells --%>
            <td
              :if={@action != []}
              class={[
                "w-0 text-right font-medium",
                if(@compact, do: "px-3 py-2", else: "px-4 py-3")
              ]}
            >
              <div class="flex items-center justify-end gap-3">
                <%= for action <- @action do %>
                  {render_slot(action, @row_item.(row))}
                <% end %>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <%!-- Empty state --%>
      <div :if={@is_empty} class="flex flex-col items-center justify-center py-12 text-text-muted">
        <%= if @empty != [] do %>
          {render_slot(@empty)}
        <% else %>
          <.icon name={@empty_icon} class="size-10 opacity-40 mb-3" />
          <p class="text-sm">{@empty_message}</p>
        <% end %>
      </div>
    </div>
    """
  end

  # ── Sort indicator arrows ──────────────────────────────────────

  defp sort_indicator(%{field: field, sort_by: sort_by, sort_dir: sort_dir} = assigns)
       when field == sort_by do
    assigns =
      assign(
        assigns,
        :icon_name,
        if(sort_dir == "asc", do: "hero-chevron-up-mini", else: "hero-chevron-down-mini")
      )

    ~H"""
    <.icon name={@icon_name} class="size-3.5 text-accent" />
    """
  end

  defp sort_indicator(assigns) do
    ~H"""
    <.icon name="hero-chevron-up-down-mini" class="size-3.5 opacity-40" />
    """
  end

  # ── Helpers ────────────────────────────────────────────────────

  defp col_sortable?(col) do
    col[:field] != nil && col[:sortable] != false
  end

  defp col_align_class(nil), do: "text-left"
  defp col_align_class("left"), do: "text-left"
  defp col_align_class("center"), do: "text-center"
  defp col_align_class("right"), do: "text-right"

  defp col_justify_class(nil), do: ""
  defp col_justify_class("left"), do: ""
  defp col_justify_class("center"), do: "justify-center"
  defp col_justify_class("right"), do: "justify-end"

  defp row_id_value(assigns, row) do
    cond do
      assigns.row_id -> assigns.row_id.(row)
      is_map(row) && Map.has_key?(row, :id) -> row.id
      true -> nil
    end
  end

  defp row_selected?(assigns, row) do
    if assigns.selectable do
      id = row_id_value(assigns, row)
      id != nil && MapSet.member?(assigns.selected_set, id)
    else
      false
    end
  end
end
