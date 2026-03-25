defmodule AyaWeb.UI.Pagination do
  @moduledoc """
  Page navigation with ellipsis for large page counts.

  ## Examples

      <.pagination page={@page} total_pages={@total_pages} on_page="paginate" />
      <.pagination page={1} total_pages={20} path_fun={&~p"/recipes?page=\#{&1}"} />
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :page, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :on_page, :string, default: nil
  attr :path_fun, :any, default: nil
  attr :sibling_count, :integer, default: 1
  attr :class, :any, default: nil

  def pagination(%{total_pages: total} = assigns) when total <= 1 do
    ~H"""
    """
  end

  def pagination(assigns) do
    assigns =
      assign(
        assigns,
        :pages,
        page_range(assigns.page, assigns.total_pages, assigns.sibling_count)
      )

    ~H"""
    <nav aria-label="Pagination" class={["flex items-center gap-1", @class]}>
      <.page_button
        page={@page - 1}
        disabled={@page <= 1}
        on_page={@on_page}
        path_fun={@path_fun}
        aria-label="Previous page"
      >
        <.icon name="hero-chevron-left-mini" class="size-4" />
      </.page_button>

      <.page_item
        :for={item <- @pages}
        item={item}
        current_page={@page}
        on_page={@on_page}
        path_fun={@path_fun}
      />

      <.page_button
        page={@page + 1}
        disabled={@page >= @total_pages}
        on_page={@on_page}
        path_fun={@path_fun}
        aria-label="Next page"
      >
        <.icon name="hero-chevron-right-mini" class="size-4" />
      </.page_button>
    </nav>
    """
  end

  defp page_item(%{item: :ellipsis} = assigns) do
    ~H"""
    <span class="px-2 text-text-muted select-none" aria-hidden="true">...</span>
    """
  end

  defp page_item(assigns) do
    ~H"""
    <.page_button
      page={@item}
      active={@item == @current_page}
      on_page={@on_page}
      path_fun={@path_fun}
      aria-label={"Page #{@item}"}
      aria-current={if @item == @current_page, do: "page"}
    >
      {@item}
    </.page_button>
    """
  end

  attr :page, :integer, required: true
  attr :active, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :on_page, :string, default: nil
  attr :path_fun, :any, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  defp page_button(%{path_fun: path_fun} = assigns) when is_function(path_fun) do
    ~H"""
    <.link
      navigate={if !@disabled, do: @path_fun.(@page)}
      class={[page_button_base(), page_button_state(@active, @disabled)]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  defp page_button(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={@on_page}
      phx-value-page={@page}
      disabled={@disabled}
      class={[page_button_base(), page_button_state(@active, @disabled)]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp page_button_base do
    "min-w-11 h-11 inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring cursor-pointer"
  end

  defp page_button_state(true, _), do: "bg-primary text-primary-text"
  defp page_button_state(_, true), do: "text-text-muted cursor-not-allowed opacity-50"
  defp page_button_state(_, _), do: "text-text-secondary hover:bg-surface-hover"

  @doc false
  def page_range(current, total, sibling_count) do
    left = max(current - sibling_count, 2)
    right = min(current + sibling_count, total - 1)

    show_left_ellipsis = left > 2
    show_right_ellipsis = right < total - 1

    [1] ++
      if(show_left_ellipsis, do: [:ellipsis], else: Enum.to_list(2..(left - 1)//1)) ++
      Enum.to_list(left..right//1) ++
      if(show_right_ellipsis, do: [:ellipsis], else: Enum.to_list((right + 1)..(total - 1)//1)) ++
      if(total > 1, do: [total], else: [])
  end
end
