defmodule AyaWeb.UI.Loading do
  @moduledoc """
  Loading indicators with multiple visual styles.

  ## Types

  - `"shimmer"` — text with a diagonal light sweep (like Claude Code)
  - `"dots"` — bouncing dots
  - `"pulse"` — pulsing text opacity
  - `"bar"` — indeterminate progress bar
  - `"typing"` — chat-style typing indicator

  ## Examples

      <.loading type="shimmer" text="Thinking..." />
      <.loading type="dots" />
      <.loading type="bar" />
      <.loading type="pulse" text="Loading recipes..." />
      <.loading type="typing" />
  """

  use Phoenix.Component

  attr :type, :string, default: "shimmer", values: ~w(shimmer shimmer-slide dots pulse bar typing)
  attr :text, :string, default: "Loading..."
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :speed, :string, default: nil, doc: "animation duration override, e.g. \"0.8s\" or \"3s\""
  attr :class, :any, default: nil

  def loading(%{type: "shimmer"} = assigns) do
    ~H"""
    <div
      class={["inline-flex items-center gap-2", size_class(@size), @class]}
      role="status"
      aria-label={@text}
    >
      <span class="loading-shimmer" style={@speed && "animation-duration: #{@speed}"}>{@text}</span>
    </div>
    """
  end

  def loading(%{type: "shimmer-slide"} = assigns) do
    ~H"""
    <div
      class={["inline-flex items-center gap-2", size_class(@size), @class]}
      role="status"
      aria-label={@text}
    >
      <span class="loading-shimmer-slide" style={@speed && "animation-duration: #{@speed}"}>
        {@text}
      </span>
    </div>
    """
  end

  def loading(%{type: "dots"} = assigns) do
    ~H"""
    <div class={["inline-flex items-center gap-1.5", @class]} role="status" aria-label={@text}>
      <span class="sr-only">{@text}</span>
      <span
        :for={i <- 1..3}
        class={["loading-dot", size_dot(@size)]}
        style={"animation-delay: #{(i - 1) * 160}ms"}
      />
    </div>
    """
  end

  def loading(%{type: "pulse"} = assigns) do
    ~H"""
    <div
      class={["inline-flex items-center gap-2", size_class(@size), @class]}
      role="status"
      aria-label={@text}
    >
      <span class="loading-pulse">{@text}</span>
    </div>
    """
  end

  def loading(%{type: "bar"} = assigns) do
    ~H"""
    <div class={["w-full", @class]} role="status" aria-label={@text}>
      <span class="sr-only">{@text}</span>
      <div class={["loading-bar", bar_height(@size)]} />
    </div>
    """
  end

  def loading(%{type: "typing"} = assigns) do
    ~H"""
    <div
      class={["inline-flex items-center gap-1 px-4 py-2.5 rounded-2xl bg-surface-alt", @class]}
      role="status"
      aria-label={@text}
    >
      <span class="sr-only">{@text}</span>
      <span :for={i <- 1..3} class="loading-typing-dot" style={"animation-delay: #{(i - 1) * 200}ms"} />
    </div>
    """
  end

  defp size_class("sm"), do: "text-xs"
  defp size_class("md"), do: "text-sm"
  defp size_class("lg"), do: "text-base"

  defp size_dot("sm"), do: "size-1"
  defp size_dot("md"), do: "size-1.5"
  defp size_dot("lg"), do: "size-2"

  defp bar_height("sm"), do: "h-0.5"
  defp bar_height("md"), do: "h-1"
  defp bar_height("lg"), do: "h-1.5"
end
