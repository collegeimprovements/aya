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
  - `"card"` — card placeholder with image + text
  - `"avatar"` — circular avatar
  - `"image"` — rectangular image placeholder
  - `"table"` — table rows with header
  - `"profile"` — avatar + name + bio
  - `"comment"` — avatar + text block (chat/comment)
  - `"feed"` — social feed post (header + image + text)
  - `"stats"` — row of stat cards
  - `"form"` — form fields
  - `"list"` — list items with icon + text

  ## Examples

      <.skeleton type="text" lines={3} />
      <.skeleton type="card" />
      <.skeleton type="profile" />
      <.skeleton type="feed" />
      <.skeleton type="table" rows={5} cols={3} />
  """
  attr :type, :string,
    default: "text",
    values: ~w(text card avatar image table profile comment feed stats form list)

  attr :lines, :integer, default: 3, doc: "number of text lines"
  attr :rows, :integer, default: 3, doc: "number of table/list rows"
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

  def skeleton(%{type: "profile"} = assigns) do
    ~H"""
    <div class={["flex flex-col items-center gap-3", @class]}>
      <div class="skeleton-pulse rounded-full size-16" />
      <div class="skeleton-pulse rounded h-5 w-32" />
      <div class="skeleton-pulse rounded h-3 w-48" />
      <div class="flex gap-6 mt-2">
        <div class="flex flex-col items-center gap-1">
          <div class="skeleton-pulse rounded h-5 w-8" />
          <div class="skeleton-pulse rounded h-3 w-12" />
        </div>
        <div class="flex flex-col items-center gap-1">
          <div class="skeleton-pulse rounded h-5 w-8" />
          <div class="skeleton-pulse rounded h-3 w-12" />
        </div>
        <div class="flex flex-col items-center gap-1">
          <div class="skeleton-pulse rounded h-5 w-8" />
          <div class="skeleton-pulse rounded h-3 w-12" />
        </div>
      </div>
    </div>
    """
  end

  def skeleton(%{type: "comment"} = assigns) do
    ~H"""
    <div class={["space-y-4", @class]}>
      <div :for={_ <- 1..@rows} class="flex gap-3">
        <div class="skeleton-pulse rounded-full size-8 shrink-0" />
        <div class="flex-1 space-y-2">
          <div class="flex gap-2 items-center">
            <div class="skeleton-pulse rounded h-3.5 w-24" />
            <div class="skeleton-pulse rounded h-3 w-16" />
          </div>
          <div class="skeleton-pulse rounded h-3.5 w-full" />
          <div class="skeleton-pulse rounded h-3.5 w-3/5" />
        </div>
      </div>
    </div>
    """
  end

  def skeleton(%{type: "feed"} = assigns) do
    ~H"""
    <div class={["rounded-lg border border-border overflow-hidden", @class]}>
      <div class="p-4 flex items-center gap-3">
        <div class="skeleton-pulse rounded-full size-10" />
        <div class="flex-1 space-y-1.5">
          <div class="skeleton-pulse rounded h-4 w-28" />
          <div class="skeleton-pulse rounded h-3 w-20" />
        </div>
        <div class="skeleton-pulse rounded h-6 w-6" />
      </div>
      <div class="skeleton-pulse w-full aspect-[4/3]" />
      <div class="p-4 space-y-2">
        <div class="flex gap-3">
          <div class="skeleton-pulse rounded h-5 w-5" />
          <div class="skeleton-pulse rounded h-5 w-5" />
          <div class="skeleton-pulse rounded h-5 w-5" />
        </div>
        <div class="skeleton-pulse rounded h-3.5 w-24" />
        <div class="skeleton-pulse rounded h-3.5 w-full" />
        <div class="skeleton-pulse rounded h-3.5 w-2/3" />
      </div>
    </div>
    """
  end

  def skeleton(%{type: "stats"} = assigns) do
    ~H"""
    <div class={["grid grid-cols-3 gap-4", @class]}>
      <div :for={_ <- 1..3} class="rounded-lg border border-border p-4 space-y-2">
        <div class="flex items-center justify-between">
          <div class="skeleton-pulse rounded h-3.5 w-20" />
          <div class="skeleton-pulse rounded h-5 w-5" />
        </div>
        <div class="skeleton-pulse rounded h-7 w-16" />
        <div class="skeleton-pulse rounded h-3 w-24" />
      </div>
    </div>
    """
  end

  def skeleton(%{type: "form"} = assigns) do
    ~H"""
    <div class={["space-y-5", @class]}>
      <div :for={_ <- 1..@rows} class="space-y-1.5">
        <div class="skeleton-pulse rounded h-3.5 w-20" />
        <div class="skeleton-pulse rounded-md h-10 w-full" />
      </div>
      <div class="flex gap-3 pt-1">
        <div class="skeleton-pulse rounded-md h-10 w-24" />
        <div class="skeleton-pulse rounded-md h-10 w-32" />
      </div>
    </div>
    """
  end

  def skeleton(%{type: "list"} = assigns) do
    ~H"""
    <div class={["space-y-1", @class]}>
      <div :for={_ <- 1..@rows} class="flex items-center gap-3 px-3 py-2.5 rounded-lg">
        <div class="skeleton-pulse rounded-md size-8 shrink-0" />
        <div class="flex-1 space-y-1.5">
          <div class="skeleton-pulse rounded h-3.5 w-2/5" />
          <div class="skeleton-pulse rounded h-3 w-3/5" />
        </div>
        <div class="skeleton-pulse rounded h-3 w-10 shrink-0" />
      </div>
    </div>
    """
  end
end
