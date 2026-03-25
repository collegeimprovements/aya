defmodule AyaWeb.UI.Kbd do
  @moduledoc """
  Keyboard shortcut display.

  ## Examples

      <.kbd>⌘K</.kbd>
      <.kbd>Ctrl</.kbd> + <.kbd>Shift</.kbd> + <.kbd>K</.kbd>
  """

  use Phoenix.Component

  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def kbd(assigns) do
    ~H"""
    <kbd
      class={[
        "inline-flex items-center justify-center min-w-[1.5rem]",
        "rounded-md border border-border bg-surface-alt",
        "px-1.5 py-0.5 text-xs font-mono font-medium text-text-secondary",
        "shadow-sm select-none",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </kbd>
    """
  end
end
