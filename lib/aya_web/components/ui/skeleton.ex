defmodule AyaWeb.UI.Skeleton do
  @moduledoc """
  Skeleton loading screen components.

  Use these instead of spinners to indicate content is loading.
  They match the eventual layout to reduce perceived load time.
  """
  use Phoenix.Component

  @doc """
  Renders a skeleton placeholder with pulse animation.

  ## Types

  - `"text"` — text lines (default)
  - `"card"` — card placeholder
  - `"avatar"` — circular avatar
  - `"image"` — rectangular image placeholder
  - `"table"` — table rows

  ## Examples

      <.skeleton type="text" lines={3} />
      <.skeleton type="card" />
      <.skeleton type="table" rows={5} cols={3} />
  """
  attr :type, :string, default: "text", values: ~w(text card avatar image table)
  attr :lines, :integer, default: 3, doc: "number of text lines"
  attr :rows, :integer, default: 3, doc: "number of table rows"
  attr :cols, :integer, default: 4, doc: "number of table columns"
  attr :class, :any, default: nil

  def skeleton(%{type: "text"} = assigns) do
    ~H"""
    <div class={["space-y-2", @class]}>
      <div
        :for={i <- 1..@lines}
        class={[
          "skeleton-pulse rounded h-4",
          i == @lines && "w-3/4"
        ]}
      />
    </div>
    """
  end

  def skeleton(%{type: "card"} = assigns) do
    ~H"""
    <div class={["rounded-lg border border-border p-6 space-y-4", @class]}>
      <div class="skeleton-pulse rounded h-40 w-full" />
      <div class="space-y-2">
        <div class="skeleton-pulse rounded h-5 w-2/3" />
        <div class="skeleton-pulse rounded h-4 w-full" />
        <div class="skeleton-pulse rounded h-4 w-4/5" />
      </div>
    </div>
    """
  end

  def skeleton(%{type: "avatar"} = assigns) do
    ~H"""
    <div class={["skeleton-pulse rounded-full size-10", @class]} />
    """
  end

  def skeleton(%{type: "image"} = assigns) do
    ~H"""
    <div class={["skeleton-pulse rounded-lg aspect-video w-full", @class]} />
    """
  end

  def skeleton(%{type: "table"} = assigns) do
    ~H"""
    <div class={["rounded-lg border border-border overflow-hidden", @class]}>
      <div class="bg-surface-alt border-b border-border px-4 py-3 flex gap-4">
        <div :for={_ <- 1..@cols} class="skeleton-pulse rounded h-4 flex-1" />
      </div>
      <div :for={_ <- 1..@rows} class="px-4 py-3 flex gap-4 border-b border-border last:border-0">
        <div :for={_ <- 1..@cols} class="skeleton-pulse rounded h-4 flex-1" />
      </div>
    </div>
    """
  end
end
