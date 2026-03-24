defmodule AyaWeb.UI.Avatar do
  @moduledoc """
  User/entity avatar with image or initials fallback.

  ## Examples

      <.avatar src="/images/user.jpg" alt="Jane" />
      <.avatar name="Jane Doe" size="lg" />
      <.avatar name="System" size="xs" />
  """

  use Phoenix.Component

  @sizes %{
    "xs" => "size-6 text-[0.5rem]",
    "sm" => "size-8 text-xs",
    "md" => "size-10 text-sm",
    "lg" => "size-12 text-base",
    "xl" => "size-16 text-lg"
  }

  @colors ~w(primary secondary accent info success)

  attr :src, :string, default: nil
  attr :alt, :string, default: ""
  attr :name, :string, default: nil
  attr :size, :string, default: "md", values: Map.keys(@sizes)
  attr :class, :any, default: nil
  attr :rest, :global

  def avatar(%{src: src} = assigns) when is_binary(src) and src != "" do
    ~H"""
    <span
      class={[
        "inline-flex shrink-0 rounded-full overflow-hidden",
        "shadow-border",
        avatar_size(@size),
        @class
      ]}
      {@rest}
    >
      <img
        src={@src}
        alt={@alt}
        class="size-full object-cover outline-0"
        loading="lazy"
      />
    </span>
    """
  end

  def avatar(assigns) do
    assigns = assign(assigns, :initials, initials(assigns.name))
    assigns = assign(assigns, :bg_color, initials_color(assigns.name))

    ~H"""
    <span
      class={[
        "inline-flex shrink-0 items-center justify-center rounded-full",
        "font-medium select-none shadow-border",
        initials_bg(@bg_color),
        avatar_size(@size),
        @class
      ]}
      aria-label={@alt || @name}
      {@rest}
    >
      {@initials}
    </span>
    """
  end

  defp avatar_size("xs"), do: "size-6 text-[0.5rem]"
  defp avatar_size("sm"), do: "size-8 text-xs"
  defp avatar_size("md"), do: "size-10 text-sm"
  defp avatar_size("lg"), do: "size-12 text-base"
  defp avatar_size("xl"), do: "size-16 text-lg"

  defp initials(nil), do: "?"
  defp initials(""), do: "?"

  defp initials(name) do
    name
    |> String.split(~r/\s+/, trim: true)
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
  end

  defp initials_color(nil), do: Enum.at(@colors, 0)
  defp initials_color(""), do: Enum.at(@colors, 0)

  defp initials_color(name) do
    index = name |> String.to_charlist() |> Enum.sum() |> rem(length(@colors))
    Enum.at(@colors, index)
  end

  defp initials_bg("primary"), do: "bg-primary-soft text-primary"
  defp initials_bg("secondary"), do: "bg-secondary-soft text-secondary"
  defp initials_bg("accent"), do: "bg-accent-soft text-accent"
  defp initials_bg("info"), do: "bg-info-soft text-info"
  defp initials_bg("success"), do: "bg-success-soft text-success"
  defp initials_bg(_), do: "bg-surface-alt text-text-secondary"
end
