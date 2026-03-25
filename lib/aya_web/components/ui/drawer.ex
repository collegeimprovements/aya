defmodule AyaWeb.UI.Drawer do
  @moduledoc """
  Thin convenience wrapper around `AyaWeb.UI.Overlay` with drawer-specific defaults
  for easy slide-in panel usage.

  Maps a simple `side` + `size` API onto the overlay's variant system so callers
  don't need to think about `:drawer_left` / `:drawer_right` / `:bottom_sheet`.

  ## Examples

      <.drawer id="settings-panel" title="Settings">
        <p>Panel content here.</p>
      </.drawer>

      <.drawer id="nav" side="left" size="lg" title="Navigation" description="Main menu">
        <nav>...</nav>
        <:footer>
          <button>Close</button>
        </:footer>
      </.drawer>

  Open with the standard overlay invoker pattern:

      <button data-commandfor="settings-panel" data-command="show-modal">
        Open drawer
      </button>
  """

  use Phoenix.Component
  import AyaWeb.UI.Overlay, only: [overlay: 1]

  @sides ~w(left right bottom)
  @sizes ~w(sm md lg xl full)

  @side_to_variant %{
    "left" => :drawer_left,
    "right" => :drawer_right,
    "bottom" => :bottom_sheet
  }

  # Width classes for left/right drawers
  @horizontal_size_classes %{
    "sm" => "w-80",
    "md" => "w-96",
    "lg" => "w-[480px]",
    "xl" => "w-[600px]",
    "full" => "w-screen"
  }

  # Height classes for bottom drawer
  @vertical_size_classes %{
    "sm" => "h-60",
    "md" => "h-80",
    "lg" => "h-[480px]",
    "xl" => "h-[600px]",
    "full" => "h-screen"
  }

  attr :id, :string, required: true
  attr :side, :string, default: "right", values: @sides
  attr :title, :string, default: nil
  attr :description, :string, default: nil
  attr :size, :string, default: "md", values: @sizes
  attr :closedby, :string, default: "any"
  attr :class, :any, default: nil

  slot :inner_block, required: true
  slot :footer

  def drawer(assigns) do
    variant = Map.fetch!(@side_to_variant, assigns.side)

    size_class =
      if assigns.side == "bottom" do
        Map.fetch!(@vertical_size_classes, assigns.size)
      else
        Map.fetch!(@horizontal_size_classes, assigns.size)
      end

    assigns =
      assigns
      |> assign(:variant, variant)
      |> assign(:size_class, size_class)

    ~H"""
    <.overlay id={@id} variant={@variant} closedby={@closedby} class={[@size_class, @class]}>
      <:header>
        <div class="flex flex-col gap-0.5">
          <span :if={@title} class="text-base font-semibold">{@title}</span>
          <span :if={@description} class="text-sm text-text-muted">{@description}</span>
        </div>
      </:header>
      {render_slot(@inner_block)}
      <:footer :if={@footer != []}>
        {render_slot(@footer)}
      </:footer>
    </.overlay>
    """
  end
end
