defmodule AyaWeb.UI.Card do
  @moduledoc """
  Content card components for displaying articles, recipes, etc.

  Uses shadow-border instead of solid borders for natural depth.
  Image hover zoom for engagement on content-heavy food app.
  """
  use Phoenix.Component

  @doc """
  Renders a content card with optional image, title, and metadata.

  ## Examples

      <.card>
        <:image src="/images/dish.jpg" alt="A dish" />
        <:title>Amazing Recipe</:title>
        <:meta>Published 2 hours ago</:meta>
        <:body>A brief description of the recipe...</:body>
      </.card>
  """
  attr :class, :any, default: nil
  attr :href, :string, default: nil, doc: "optional link destination"
  attr :rest, :global

  slot :image do
    attr :src, :string, required: true
    attr :alt, :string
  end

  slot :title
  slot :meta
  slot :body
  slot :footer
  slot :inner_block

  def card(assigns) do
    ~H"""
    <div
      class={[
        "rounded-lg bg-surface overflow-hidden",
        "shadow-border transition-[box-shadow] duration-150 ease-out",
        "hover:shadow-border-hover",
        @href && "cursor-pointer",
        @class
      ]}
      {@rest}
    >
      <div :for={img <- @image} class="aspect-video overflow-hidden">
        <img
          src={img.src}
          alt={Map.get(img, :alt, "")}
          class={[
            "w-full h-full object-cover",
            "transition-[transform] duration-300 ease-out",
            "group-hover:scale-[1.03]"
          ]}
          loading="lazy"
        />
      </div>

      <div class="p-4 sm:p-6 space-y-2">
        <p :for={meta <- @meta} class="text-xs text-text-muted tabular-nums">
          {render_slot(meta)}
        </p>

        <h3 :for={title <- @title} class="font-semibold text-text leading-snug">
          <%= case @href do %>
            <% nil -> %>
              {render_slot(title)}
            <% href -> %>
              <a href={href} class="text-text hover:text-primary transition-[color] duration-150">
                {render_slot(title)}
              </a>
          <% end %>
        </h3>

        <div :for={body <- @body} class="text-sm text-text-secondary leading-relaxed">
          {render_slot(body)}
        </div>

        {render_slot(@inner_block)}

        <div :for={footer <- @footer} class="pt-3 border-t border-border">
          {render_slot(footer)}
        </div>
      </div>
    </div>
    """
  end
end
