defmodule AyaWeb.UI.CopyButton do
  @moduledoc """
  Copy-to-clipboard button with visual feedback.

  Uses a colocated JS hook for clipboard access.
  """
  use Phoenix.Component

  import AyaWeb.CoreComponents, only: [icon: 1]

  @doc """
  Renders a copy-to-clipboard button.

  ## Examples

      <.copy_button content={@article.url} />
      <.copy_button content={@code_snippet} label="Copy code" />
  """
  attr :content, :string, required: true, doc: "the text to copy"
  attr :label, :string, default: "Copy"
  attr :id, :string, required: true
  attr :class, :any, default: nil

  def copy_button(assigns) do
    ~H"""
    <div id={@id} phx-hook=".CopyToClipboard" data-content={@content} class={["inline-flex", @class]}>
      <button
        type="button"
        class={[
          "inline-flex items-center gap-1.5 px-2.5 py-1.5 text-xs font-medium rounded-md",
          "border border-border text-text-secondary",
          "hover:bg-surface-hover hover:text-text",
          "transition-colors cursor-pointer",
          "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring"
        ]}
        data-role="copy-trigger"
      >
        <span data-role="icon-default">
          <.icon name="hero-clipboard-document" class="size-3.5" />
        </span>
        <span data-role="icon-success" class="hidden text-success">
          <.icon name="hero-check" class="size-3.5" />
        </span>
        <span data-role="copy-label">{@label}</span>
      </button>
    </div>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".CopyToClipboard">
      export default {
        mounted() {
          const btn = this.el.querySelector("[data-role='copy-trigger']")
          const iconDefault = this.el.querySelector("[data-role='icon-default']")
          const iconSuccess = this.el.querySelector("[data-role='icon-success']")
          const label = this.el.querySelector("[data-role='copy-label']")

          btn.addEventListener("click", async () => {
            try {
              await navigator.clipboard.writeText(this.el.dataset.content)
              iconDefault.classList.add("hidden")
              iconSuccess.classList.remove("hidden")
              const origLabel = label.textContent
              label.textContent = "Copied!"

              setTimeout(() => {
                iconDefault.classList.remove("hidden")
                iconSuccess.classList.add("hidden")
                label.textContent = origLabel
              }, 2000)
            } catch (err) {
              console.error("Copy failed:", err)
            }
          })
        }
      }
    </script>
    """
  end
end
