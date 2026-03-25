defmodule AyaWeb.UI.Divider do
  @moduledoc """
  Separator line with optional centered label.

  ## Examples

      <.divider />
      <.divider label="or" />
      <.divider orientation="vertical" />
  """

  use Phoenix.Component

  attr :label, :string, default: nil
  attr :orientation, :string, default: "horizontal", values: ~w(horizontal vertical)
  attr :class, :any, default: nil
  attr :rest, :global

  def divider(%{orientation: "vertical"} = assigns) do
    ~H"""
    <div
      role="separator"
      aria-orientation="vertical"
      class={["w-px self-stretch bg-border", @class]}
      {@rest}
    />
    """
  end

  def divider(%{label: nil} = assigns) do
    ~H"""
    <hr class={["border-t border-border", @class]} {@rest} />
    """
  end

  def divider(assigns) do
    ~H"""
    <div role="separator" class={["flex items-center gap-3", @class]} {@rest}>
      <span class="flex-1 border-t border-border" />
      <span class="text-xs font-medium text-text-muted select-none">{@label}</span>
      <span class="flex-1 border-t border-border" />
    </div>
    """
  end
end
