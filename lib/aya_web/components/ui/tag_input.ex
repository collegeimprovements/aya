defmodule AyaWeb.UI.TagInput do
  @moduledoc """
  Free-form tag input with autocomplete suggestions and removable chips.

  Tags are submitted as a list via hidden inputs (`name[]`).
  Type text and press Enter to add a tag. Backspace on empty input removes
  the last tag. Paste comma-separated values to add multiple tags at once.

  ## Examples

      <.live_component
        module={AyaWeb.UI.TagInput}
        id="recipe-tags"
        field={@form[:tags]}
        placeholder="Add tags..."
      />

      <.live_component
        module={AyaWeb.UI.TagInput}
        id="ingredients"
        field={@form[:ingredients]}
        suggestions={["Salt", "Pepper", "Garlic", "Onion", "Olive Oil"]}
        max_tags={10}
        placeholder="Type to add..."
      />

  ## Receiving changes

  The parent LiveView receives tag changes via:

      def handle_info({AyaWeb.UI.TagInput, :change, id, tags}, socket)
  """

  use Phoenix.LiveComponent
  import AyaWeb.CoreComponents, only: [icon: 1]

  @impl true
  def mount(socket) do
    {:ok, assign(socket, search: "", focused: false)}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:tags, fn ->
        case assigns[:field] do
          %Phoenix.HTML.FormField{value: val} when is_list(val) -> val
          _ -> assigns[:value] || []
        end
      end)
      |> assign_new(:suggestions, fn -> [] end)
      |> assign_new(:max_tags, fn -> nil end)
      |> assign_new(:allow_create, fn -> true end)
      |> assign_new(:placeholder, fn -> "Add a tag..." end)
      |> assign_new(:label, fn -> nil end)
      |> assign_new(:disabled, fn -> false end)
      |> assign_new(:class, fn -> nil end)

    field_name =
      case assigns[:field] do
        %Phoenix.HTML.FormField{name: name} -> name
        _ -> assigns[:name] || "tags"
      end

    {:ok, assign(socket, field_name: field_name)}
  end

  @impl true
  def render(assigns) do
    filtered =
      if assigns.search != "" do
        q = String.downcase(assigns.search)

        assigns.suggestions
        |> Enum.filter(fn s ->
          String.contains?(String.downcase(s), q) and s not in assigns.tags
        end)
        |> Enum.take(8)
      else
        []
      end

    at_max? =
      is_integer(assigns.max_tags) and length(assigns.tags) >= assigns.max_tags

    assigns = assign(assigns, filtered: filtered, at_max: at_max?)

    ~H"""
    <div
      id={@id}
      class={["relative", @disabled && "opacity-50 pointer-events-none", @class]}
      phx-hook=".TagInput"
    >
      <label :if={@label} class="block text-sm font-medium text-text mb-1.5">{@label}</label>

      <%!-- Tag container --%>
      <div
        class={[
          "flex flex-wrap items-center gap-1.5 px-2.5 py-2 rounded-md border bg-surface text-sm min-h-[38px] cursor-text transition-colors",
          if(@focused,
            do: "border-ring ring-2 ring-ring/20",
            else: "border-border hover:border-border-strong"
          )
        ]}
        data-tag-container
        style={"anchor-name: --ti-#{@id}"}
      >
        <%!-- Chips --%>
        <span
          :for={tag <- @tags}
          class="inline-flex items-center gap-1 bg-surface-alt text-text text-xs font-medium pl-2 pr-1 py-0.5 rounded-md"
        >
          {tag}
          <button
            type="button"
            class="p-0.5 rounded hover:bg-surface-hover text-text-muted hover:text-text transition-colors cursor-pointer"
            phx-click="remove_tag"
            phx-value-tag={tag}
            phx-target={@myself}
            aria-label={"Remove #{tag}"}
          >
            <.icon name="hero-x-mark-mini" class="size-3" />
          </button>
        </span>

        <%!-- Inline text input --%>
        <input
          id={"#{@id}-input"}
          type="text"
          class="flex-1 min-w-[80px] bg-transparent border-none outline-none text-sm text-text placeholder:text-text-muted p-0"
          placeholder={if(@tags == [], do: @placeholder, else: "")}
          phx-focus="input_focus"
          phx-blur="input_blur"
          phx-target={@myself}
          autocomplete="off"
          spellcheck="false"
          disabled={@disabled || @at_max}
          data-tag-input
        />
      </div>

      <%!-- Suggestions dropdown --%>
      <div
        :if={@filtered != [] && @focused}
        style={"position-anchor: --ti-#{@id}"}
        class="fixed z-50 mt-1 max-h-48 overflow-auto rounded-md border border-border bg-surface shadow-lg [top:anchor(bottom)] [left:anchor(start)] [width:anchor-size(width)] [position-try-fallbacks:flip-block]"
      >
        <button
          :for={suggestion <- @filtered}
          type="button"
          class="w-full text-left px-3 py-2 text-sm text-text hover:bg-surface-hover cursor-pointer transition-colors"
          phx-click="add_suggestion"
          phx-value-tag={suggestion}
          phx-target={@myself}
        >
          {suggestion}
        </button>
      </div>

      <%!-- Hidden inputs for form submission --%>
      <input :if={@tags == []} type="hidden" name={"#{@field_name}[]"} value="" />
      <input :for={tag <- @tags} type="hidden" name={"#{@field_name}[]"} value={tag} />

      <script :type={Phoenix.LiveView.ColocatedHook} name=".TagInput">
        export default {
          mounted() {
            const input = this.el.querySelector("[data-tag-input]")
            const container = this.el.querySelector("[data-tag-container]")
            if (!input) return

            // Click container to focus input
            container.addEventListener("click", () => input.focus())

            // Track input value and send key events with value
            input.addEventListener("keydown", (e) => {
              if (e.key === "Enter") {
                e.preventDefault()
                const val = input.value.trim()
                if (val) {
                  this.pushEventTo(this.el, "add_tag", { value: val })
                  input.value = ""
                  // Also update search for suggestions
                  this.pushEventTo(this.el, "search", { value: "" })
                }
              } else if (e.key === "Backspace" && input.value === "") {
                this.pushEventTo(this.el, "remove_last", {})
              }
            })

            // Track typing for suggestions
            input.addEventListener("input", () => {
              this.pushEventTo(this.el, "search", { value: input.value })
            })

            // Paste: split by comma and add as tags
            input.addEventListener("paste", (e) => {
              const text = (e.clipboardData || window.clipboardData).getData("text")
              if (text.includes(",")) {
                e.preventDefault()
                const tags = text.split(",").map(t => t.trim()).filter(Boolean)
                if (tags.length) {
                  this.pushEventTo(this.el, "paste_tags", { tags })
                  input.value = ""
                }
              }
            })
          }
        }
      </script>
    </div>
    """
  end

  @impl true
  def handle_event("add_tag", %{"value" => value}, socket) do
    add_tag(socket, value)
  end

  def handle_event("remove_last", _, socket) do
    if socket.assigns.tags != [] do
      tags = Enum.drop(socket.assigns.tags, -1)
      {:noreply, socket |> assign(tags: tags, search: "") |> notify_change(tags)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("search", %{"value" => value}, socket) do
    {:noreply, assign(socket, search: value)}
  end

  def handle_event("remove_tag", %{"tag" => tag}, socket) do
    tags = Enum.reject(socket.assigns.tags, &(&1 == tag))
    {:noreply, socket |> assign(tags: tags) |> notify_change(tags)}
  end

  def handle_event("add_suggestion", %{"tag" => tag}, socket) do
    if tag not in socket.assigns.tags do
      tags = socket.assigns.tags ++ [tag]
      {:noreply, socket |> assign(tags: tags, search: "") |> notify_change(tags)}
    else
      {:noreply, assign(socket, search: "")}
    end
  end

  def handle_event("paste_tags", %{"tags" => pasted}, socket) do
    max = socket.assigns.max_tags
    existing = socket.assigns.tags

    new_tags =
      pasted
      |> Enum.map(&String.trim/1)
      |> Enum.filter(&(&1 != "" and &1 not in existing))
      |> then(fn tags ->
        if is_integer(max), do: Enum.take(tags, max - length(existing)), else: tags
      end)

    tags = existing ++ new_tags
    {:noreply, socket |> assign(tags: tags, search: "") |> notify_change(tags)}
  end

  def handle_event("input_focus", _, socket), do: {:noreply, assign(socket, focused: true)}
  def handle_event("input_blur", _, socket), do: {:noreply, assign(socket, focused: false)}

  defp add_tag(socket, value) do
    tag = String.trim(value)

    cond do
      tag == "" ->
        {:noreply, socket}

      not socket.assigns.allow_create and tag not in socket.assigns.suggestions ->
        {:noreply, socket}

      tag in socket.assigns.tags ->
        {:noreply, assign(socket, search: "")}

      is_integer(socket.assigns.max_tags) and
          length(socket.assigns.tags) >= socket.assigns.max_tags ->
        {:noreply, socket}

      true ->
        tags = socket.assigns.tags ++ [tag]
        {:noreply, socket |> assign(tags: tags, search: "") |> notify_change(tags)}
    end
  end

  defp notify_change(socket, tags) do
    send(self(), {__MODULE__, :change, socket.assigns.id, tags})
    socket
  end
end
