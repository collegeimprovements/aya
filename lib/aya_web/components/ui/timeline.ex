defmodule AyaWeb.UI.Timeline do
  @moduledoc """
  Timeline / Activity Feed component for displaying event history.

  ## Examples

      <.timeline>
        <:item title="Order Placed" timestamp="2 hours ago" status="complete">
          Your order has been confirmed.
        </:item>
        <:item title="Processing" timestamp="1 hour ago" status="current" icon_color="primary">
          We're preparing your items.
        </:item>
        <:item title="Shipped" status="upcoming" />
      </.timeline>

      <.timeline variant="compact">
        <:item title="Logged in" timestamp="Today, 9:00 AM" />
        <:item title="Updated profile" timestamp="Today, 9:15 AM" />
      </.timeline>

      <.timeline variant="card">
        <:item
          title="Deployment succeeded"
          description="v2.4.1 deployed to production"
          timestamp="5 min ago"
          icon="hero-rocket-launch"
          icon_color="success"
          status="complete"
        />
      </.timeline>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :variant, :string, default: "default", values: ~w(default compact card)
  attr :direction, :string, default: "vertical", values: ~w(vertical horizontal)
  attr :class, :any, default: nil
  attr :rest, :global

  slot :item, required: true do
    attr :title, :string, required: true
    attr :description, :string
    attr :timestamp, :string
    attr :icon, :string
    attr :icon_color, :string, values: ~w(default primary success warning error info)
    attr :status, :string, values: ~w(complete current upcoming)
  end

  def timeline(%{direction: "horizontal"} = assigns) do
    ~H"""
    <div class={["overflow-x-auto", @class]} {@rest}>
      <div class="flex items-start min-w-max">
        <div
          :for={{item, index} <- Enum.with_index(@item)}
          class="flex flex-col items-center text-center"
          style="min-width: 140px; max-width: 180px;"
        >
          <%!-- Icon row with connector line --%>
          <div class="flex items-center w-full">
            <%!-- Left connector --%>
            <div class={[
              "flex-1 h-px",
              if(index > 0,
                do: connector_color(Enum.at(@item, index - 1)[:status]),
                else: "bg-transparent"
              )
            ]} />
            <%!-- Icon --%>
            <.timeline_icon
              icon={item[:icon]}
              icon_color={item[:icon_color] || "default"}
              variant={@variant}
            />
            <%!-- Right connector --%>
            <div class={[
              "flex-1 h-px",
              if(index < length(@item) - 1,
                do: connector_color(item[:status]),
                else: "bg-transparent"
              )
            ]} />
          </div>

          <%!-- Content below --%>
          <div class="mt-2 px-2">
            <p class={["font-medium", title_size(@variant)]}>{item.title}</p>
            <span
              :if={item[:timestamp]}
              class={["text-text-muted block mt-0.5", timestamp_size(@variant)]}
            >
              {item[:timestamp]}
            </span>
            <p
              :if={item[:description]}
              class={["text-text-secondary mt-0.5", description_size(@variant)]}
            >
              {item[:description]}
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def timeline(assigns) do
    ~H"""
    <div class={["relative", @class]} {@rest}>
      <div :for={{item, index} <- Enum.with_index(@item)} class="flex gap-3">
        <%!-- Icon column with connector line --%>
        <div class="flex flex-col items-center">
          <.timeline_icon
            icon={item[:icon]}
            icon_color={item[:icon_color] || "default"}
            variant={@variant}
          />
          <div
            :if={index < length(@item) - 1}
            class={[
              "w-px flex-1 min-h-4 my-1",
              connector_color(item[:status])
            ]}
          />
        </div>

        <%!-- Content --%>
        <div class={[
          "pb-6 flex-1 min-w-0",
          if(index == length(@item) - 1, do: "pb-0"),
          item_variant_class(@variant)
        ]}>
          <div class="flex items-start justify-between gap-2">
            <p class={["font-medium", title_size(@variant)]}>{item.title}</p>
            <span
              :if={item[:timestamp]}
              class={["text-text-muted whitespace-nowrap shrink-0", timestamp_size(@variant)]}
            >
              {item[:timestamp]}
            </span>
          </div>
          <p
            :if={item[:description]}
            class={["text-text-secondary mt-0.5", description_size(@variant)]}
          >
            {item[:description]}
          </p>
          <div
            :if={item[:inner_block] && item[:inner_block] != []}
            class={["mt-1.5", description_size(@variant)]}
          >
            {render_slot(item)}
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :icon, :string, default: nil
  attr :icon_color, :string, required: true
  attr :variant, :string, required: true

  defp timeline_icon(%{icon: nil} = assigns) do
    ~H"""
    <div class={[
      "rounded-full shrink-0 flex items-center justify-center",
      dot_size(@variant),
      icon_color_class(@icon_color)
    ]}>
      <div class={[
        "rounded-full",
        if(@variant == "compact", do: "size-1.5 bg-current", else: "size-2.5 bg-current")
      ]} />
    </div>
    """
  end

  defp timeline_icon(assigns) do
    ~H"""
    <div class={[
      "rounded-full shrink-0 flex items-center justify-center",
      icon_wrapper_size(@variant),
      icon_bg_class(@icon_color)
    ]}>
      <.icon name={@icon} class={icon_size(@variant)} />
    </div>
    """
  end

  defp dot_size("compact"), do: "size-5"
  defp dot_size(_), do: "size-7"

  defp icon_wrapper_size("compact"), do: "size-5"
  defp icon_wrapper_size(_), do: "size-7"

  defp icon_size("compact"), do: "size-3"
  defp icon_size(_), do: "size-4"

  defp title_size("compact"), do: "text-sm"
  defp title_size(_), do: "text-sm"

  defp description_size("compact"), do: "text-xs"
  defp description_size(_), do: "text-sm"

  defp timestamp_size("compact"), do: "text-[0.65rem]"
  defp timestamp_size(_), do: "text-xs"

  defp item_variant_class("card"), do: "bg-surface rounded-lg shadow-border p-3 mb-2"
  defp item_variant_class(_), do: nil

  defp connector_color("complete"), do: "bg-primary"
  defp connector_color(_), do: "bg-border"

  defp icon_color_class("primary"), do: "text-primary"
  defp icon_color_class("success"), do: "text-success"
  defp icon_color_class("warning"), do: "text-warning"
  defp icon_color_class("error"), do: "text-error"
  defp icon_color_class("info"), do: "text-info"
  defp icon_color_class(_), do: "text-text-muted"

  defp icon_bg_class("primary"), do: "bg-primary text-primary-text"
  defp icon_bg_class("success"), do: "bg-success text-white"
  defp icon_bg_class("warning"), do: "bg-warning text-white"
  defp icon_bg_class("error"), do: "bg-error text-white"
  defp icon_bg_class("info"), do: "bg-info text-white"
  defp icon_bg_class(_), do: "bg-surface-alt text-text-muted"
end
