defmodule AyaWeb.UI.Steps do
  @moduledoc """
  Multi-step wizard/progress indicator.

  ## Examples

      <.steps>
        <:step label="Account" status={:complete} />
        <:step label="Profile" description="Add your details" status={:current} />
        <:step label="Review" status={:upcoming} />
      </.steps>

      <.steps orientation="vertical">
        <:step label="Order Placed" status={:complete} />
        <:step label="Processing" status={:current} />
        <:step label="Shipped" status={:upcoming} />
      </.steps>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :orientation, :string, default: "horizontal", values: ~w(horizontal vertical)
  attr :class, :any, default: nil
  attr :rest, :global

  slot :step, required: true do
    attr :label, :string, required: true
    attr :description, :string
    attr :status, :atom, values: [:complete, :current, :upcoming]
  end

  def steps(%{orientation: "vertical"} = assigns) do
    ~H"""
    <ol class={["flex flex-col", @class]} {@rest}>
      <li :for={{step, index} <- Enum.with_index(@step)} class="flex gap-3">
        <div class="flex flex-col items-center">
          <.step_circle status={step[:status] || :upcoming} number={index + 1} />
          <div
            :if={index < length(@step) - 1}
            class={[
              "w-px flex-1 min-h-8 my-1",
              if(step[:status] == :complete, do: "bg-primary", else: "bg-border")
            ]}
          />
        </div>
        <div class={["pb-6", if(index == length(@step) - 1, do: "pb-0")]}>
          <p class={["text-sm font-medium", step_text_color(step[:status])]}>
            {step[:label] || step.label}
          </p>
          <p :if={step[:description]} class="mt-0.5 text-xs text-text-muted">
            {step[:description]}
          </p>
        </div>
      </li>
    </ol>
    """
  end

  def steps(assigns) do
    ~H"""
    <ol class={["flex items-start", @class]} {@rest}>
      <li
        :for={{step, index} <- Enum.with_index(@step)}
        class="flex items-center flex-1 last:flex-none"
      >
        <div class="flex flex-col items-center gap-1.5">
          <.step_circle status={step[:status] || :upcoming} number={index + 1} />
          <p class={["text-xs font-medium text-center", step_text_color(step[:status])]}>
            {step[:label] || step.label}
          </p>
          <p :if={step[:description]} class="text-[0.65rem] text-text-muted text-center max-w-[100px]">
            {step[:description]}
          </p>
        </div>
        <div
          :if={index < length(@step) - 1}
          class={[
            "h-px flex-1 mx-2 mt-4 self-start",
            if(step[:status] == :complete, do: "bg-primary", else: "bg-border")
          ]}
        />
      </li>
    </ol>
    """
  end

  attr :status, :atom, required: true
  attr :number, :integer, required: true

  defp step_circle(%{status: :complete} = assigns) do
    ~H"""
    <div class="flex items-center justify-center size-8 rounded-full bg-primary text-primary-text shrink-0">
      <.icon name="hero-check-mini" class="size-4" />
    </div>
    """
  end

  defp step_circle(%{status: :current} = assigns) do
    ~H"""
    <div class="flex items-center justify-center size-8 rounded-full border-2 border-primary text-primary font-semibold text-xs shrink-0">
      {@number}
    </div>
    """
  end

  defp step_circle(assigns) do
    ~H"""
    <div class="flex items-center justify-center size-8 rounded-full border-2 border-border text-text-muted font-medium text-xs shrink-0">
      {@number}
    </div>
    """
  end

  defp step_text_color(:complete), do: "text-primary"
  defp step_text_color(:current), do: "text-text"
  defp step_text_color(_), do: "text-text-muted"
end
