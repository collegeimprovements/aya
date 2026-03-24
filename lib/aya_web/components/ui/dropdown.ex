defmodule AyaWeb.UI.Dropdown do
  @moduledoc """
  Dropdown menu. JS-positioned, works in all browsers.

  ## Examples

      <.dropdown id="actions-menu">
        <:trigger>
          <.button variant="ghost" size="sm">
            <.icon name="hero-ellipsis-vertical" class="size-5" />
          </.button>
        </:trigger>
        <:item icon="hero-pencil" navigate={~p"/recipes/1/edit"}>Edit</:item>
        <:item icon="hero-document-duplicate">Duplicate</:item>
        <:separator />
        <:item icon="hero-trash" variant="danger">Delete</:item>
      </.dropdown>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, required: true
  attr :class, :any, default: nil

  slot :trigger, required: true

  slot :item do
    attr :href, :string
    attr :navigate, :string
    attr :patch, :string
    attr :icon, :string
    attr :variant, :string
    attr :disabled, :boolean
  end

  slot :separator

  def dropdown(assigns) do
    ~H"""
    <div class="inline-block" id={@id} phx-hook=".Dropdown">
      <div data-dropdown-trigger>
        {render_slot(@trigger)}
      </div>

      <div
        id={"#{@id}-panel"}
        data-dropdown-panel
        class={[
          "fixed z-[9999] min-w-[180px]",
          "rounded-lg bg-surface border border-border shadow-lg",
          "p-1 opacity-0 scale-95 pointer-events-none",
          "transition-[opacity,transform] duration-150 ease-out",
          @class
        ]}
        style="top:0;left:0"
        hidden
      >
        <.dropdown_item :for={item <- @item} item={item} dropdown_id={@id} />
      </div>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".Dropdown">
        export default {
          mounted() {
            const root = this.el
            const trigger = root.querySelector("[data-dropdown-trigger]")
            const panel = root.querySelector("[data-dropdown-panel]")
            if (!trigger || !panel) return

            let open = false

            const position = () => {
              const tr = trigger.getBoundingClientRect()
              const pw = panel.offsetWidth
              // Default: below trigger, right-aligned
              let top = tr.bottom + 4
              let left = tr.right - pw
              // Clamp to viewport
              if (left < 8) left = tr.left
              if (top + panel.offsetHeight > window.innerHeight - 8) top = tr.top - panel.offsetHeight - 4
              panel.style.top = top + "px"
              panel.style.left = left + "px"
            }

            const show = () => {
              open = true
              panel.hidden = false
              position()
              requestAnimationFrame(() => {
                panel.classList.remove("opacity-0", "scale-95", "pointer-events-none")
                panel.classList.add("opacity-100", "scale-100")
              })
            }

            const hide = () => {
              if (!open) return
              open = false
              panel.classList.remove("opacity-100", "scale-100")
              panel.classList.add("opacity-0", "scale-95", "pointer-events-none")
              panel.addEventListener("transitionend", () => { panel.hidden = true }, { once: true })
            }

            trigger.addEventListener("click", (e) => {
              e.stopPropagation()
              open ? hide() : show()
            })

            document.addEventListener("click", (e) => {
              if (open && !root.contains(e.target) && !panel.contains(e.target)) hide()
            })

            document.addEventListener("keydown", (e) => {
              if (open && e.key === "Escape") { e.preventDefault(); hide() }
            })

            panel.addEventListener("click", (e) => {
              if (e.target.closest("a, button")) hide()
            })

            this._hide = hide
          },

          destroyed() {
            this._hide?.()
          }
        }
      </script>
    </div>
    """
  end

  defp dropdown_item(%{item: %{navigate: nav}} = assigns) when is_binary(nav) do
    ~H"""
    <.link navigate={@item.navigate} class={item_class(@item[:variant], @item[:disabled])}>
      <.icon :if={@item[:icon]} name={@item[:icon]} class="size-4 shrink-0" />
      {render_slot(@item)}
    </.link>
    """
  end

  defp dropdown_item(%{item: %{patch: patch}} = assigns) when is_binary(patch) do
    ~H"""
    <.link patch={@item.patch} class={item_class(@item[:variant], @item[:disabled])}>
      <.icon :if={@item[:icon]} name={@item[:icon]} class="size-4 shrink-0" />
      {render_slot(@item)}
    </.link>
    """
  end

  defp dropdown_item(%{item: %{href: href}} = assigns) when is_binary(href) do
    ~H"""
    <.link href={@item.href} class={item_class(@item[:variant], @item[:disabled])}>
      <.icon :if={@item[:icon]} name={@item[:icon]} class="size-4 shrink-0" />
      {render_slot(@item)}
    </.link>
    """
  end

  defp dropdown_item(assigns) do
    ~H"""
    <button
      type="button"
      class={item_class(@item[:variant], @item[:disabled])}
      disabled={@item[:disabled]}
    >
      <.icon :if={@item[:icon]} name={@item[:icon]} class="size-4 shrink-0" />
      {render_slot(@item)}
    </button>
    """
  end

  defp item_class(variant, disabled) do
    [
      "flex w-full items-center gap-2 rounded-md px-2.5 py-2 text-sm text-left",
      "transition-colors cursor-pointer",
      "focus-visible:outline-2 focus-visible:outline-offset-0 focus-visible:outline-ring",
      if(variant == "danger",
        do: "text-error hover:bg-error-soft",
        else: "text-text hover:bg-surface-hover"
      ),
      if(disabled, do: "opacity-50 pointer-events-none")
    ]
  end
end
