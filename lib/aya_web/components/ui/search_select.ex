defmodule AyaWeb.UI.SearchSelect do
  @moduledoc """
  Searchable select with composable options, multi-select chips, option groups,
  create new, clear button, and keyboard navigation.

  ## Basic usage

      <.live_component
        module={AyaWeb.UI.SearchSelect}
        id="ingredient-select"
        field={@form[:ingredient_id]}
        options={@ingredients}
        placeholder="Search ingredients..."
      />

  ## Options format

      # Simple
      [%{value: "1", label: "Salt"}]

      # With subtitle and image
      [%{value: "1", label: "Salt", subtitle: "NaCl", image: "/img/salt.jpg"}]

      # With groups
      [
        %{value: "1", label: "Salt", group: "Seasonings"},
        %{value: "2", label: "Flour", group: "Dry Goods"},
      ]

  ## Multi-select with chips

      <.live_component module={AyaWeb.UI.SearchSelect} id="tags"
        field={@form[:tags]} options={@tags} multiple placeholder="Add tags..." />

  ## Creatable

      <.live_component module={AyaWeb.UI.SearchSelect} id="tags"
        field={@form[:tags]} options={@tags} creatable placeholder="Search or create..." />

  ## Custom option rendering via inner_block

      <.live_component module={AyaWeb.UI.SearchSelect} id="users"
        field={@form[:user_id]} options={@users}>
        <:option :let={opt}>
          <img src={opt.image} class="size-6 rounded-full" />
          <span>{opt.label}</span>
        </:option>
      </.live_component>
  """

  use Phoenix.LiveComponent
  import AyaWeb.CoreComponents, only: [icon: 1]

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       open: false,
       search: "",
       highlighted: 0
     )}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:label, fn -> nil end)
      |> assign_new(:placeholder, fn -> "Search..." end)
      |> assign_new(:prompt, fn -> "Select..." end)
      |> assign_new(:multiple, fn -> false end)
      |> assign_new(:creatable, fn -> false end)
      |> assign_new(:on_search, fn -> nil end)
      |> assign_new(:on_create, fn -> nil end)
      |> assign_new(:on_load_more, fn -> nil end)
      |> assign_new(:loading, fn -> false end)
      |> assign_new(:class, fn -> nil end)
      |> assign_new(:option, fn -> [] end)
      |> assign_selected_labels()

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    filtered = filtered_options(assigns.options, assigns.search)
    grouped = group_options(filtered)

    has_exact =
      Enum.any?(
        filtered,
        &(String.downcase(to_string(&1.label)) == String.downcase(assigns.search))
      )

    show_create = assigns.creatable && assigns.search != "" && !has_exact
    assigns = assign(assigns, filtered: filtered, grouped: grouped, show_create: show_create)

    ~H"""
    <div class={["relative", @class]} id={@id} phx-hook=".SearchSelect">
      <label :if={@label} class="block text-sm font-medium text-text mb-1.5" for={"#{@id}-trigger"}>
        {@label}
      </label>

      <%!-- Hidden input(s) for form submission --%>
      <input :if={!@multiple} type="hidden" name={@field.name} value={@field.value} />
      <%= if @multiple do %>
        <%!-- Empty value when nothing selected so form clears properly --%>
        <input :if={List.wrap(@field.value) == []} type="hidden" name={"#{@field.name}[]"} value="" />
        <input
          :for={val <- List.wrap(@field.value || [])}
          type="hidden"
          name={"#{@field.name}[]"}
          value={val}
        />
      <% end %>

      <%!-- Trigger --%>
      <button
        type="button"
        id={"#{@id}-trigger"}
        phx-click="toggle"
        phx-target={@myself}
        class={[
          "flex items-center gap-2 w-full min-h-[2.5rem]",
          "rounded-md border border-border bg-surface px-3 py-1.5 text-sm",
          "text-left transition-colors hover:border-border-strong cursor-pointer",
          "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring",
          @open && "border-ring ring-2 ring-ring/20"
        ]}
        style={"anchor-name: --ss-#{@id}"}
        aria-expanded={"#{@open}"}
        aria-haspopup="listbox"
      >
        <%= if @multiple && List.wrap(@field.value) != [] do %>
          <%!-- Multi-select chips --%>
          <div class="flex flex-wrap gap-1 flex-1 py-0.5">
            <span
              :for={chip <- selected_chips(@options, @field.value)}
              class="inline-flex items-center gap-1 bg-surface-alt text-text text-xs font-medium pl-2 pr-1 py-0.5 rounded-md"
            >
              {chip.label}
              <span
                phx-click="remove_chip"
                phx-value-value={chip.value}
                phx-target={@myself}
                class="inline-flex items-center justify-center size-4 rounded hover:bg-surface-hover text-text-muted hover:text-text cursor-pointer"
                aria-label={"Remove #{chip.label}"}
              >
                <.icon name="hero-x-mark-mini" class="size-3" />
              </span>
            </span>
          </div>
        <% else %>
          <span class={[
            "flex-1 truncate",
            if(@selected_label, do: "text-text", else: "text-text-muted")
          ]}>
            {@selected_label || @prompt}
          </span>
        <% end %>
        <%!-- Clear button (single select only) --%>
        <span
          :if={!@multiple && @selected_label}
          phx-click="clear"
          phx-target={@myself}
          class="inline-flex items-center justify-center size-5 rounded hover:bg-surface-hover text-text-muted hover:text-text cursor-pointer shrink-0"
          aria-label="Clear selection"
        >
          <.icon name="hero-x-mark-mini" class="size-3.5" />
        </span>
        <.icon name="hero-chevron-up-down-mini" class="size-4 text-text-muted shrink-0" />
      </button>

      <%!-- Dropdown panel --%>
      <div
        :if={@open}
        id={"#{@id}-panel"}
        phx-click-away="close"
        phx-target={@myself}
        class="ss-panel"
        style={"position-anchor: --ss-#{@id}"}
        role="listbox"
        phx-window-keydown="keydown"
      >
        <%!-- Search input --%>
        <div class="flex items-center gap-2 px-3 py-2 border-b border-border">
          <.icon name="hero-magnifying-glass-mini" class="size-4 text-text-muted shrink-0" />
          <input
            type="text"
            id={"#{@id}-search"}
            value={@search}
            phx-keyup="search"
            phx-target={@myself}
            phx-debounce="150"
            placeholder={@placeholder}
            class="flex-1 bg-transparent text-sm text-text placeholder:text-text-muted outline-none"
            autocomplete="off"
            autofocus
          />
          <.icon
            :if={@loading}
            name="hero-arrow-path"
            class="size-4 text-text-muted motion-safe:animate-spin"
          />
        </div>

        <%!-- Options list --%>
        <div class="max-h-64 overflow-y-auto py-1" id={"#{@id}-options"}>
          <%= if @grouped != [] do %>
            <%= for {group, opts} <- @grouped do %>
              <div
                :if={group}
                class="px-3 pt-3 pb-1 text-[0.6875rem] font-semibold uppercase tracking-wider text-text-muted select-none"
              >
                {group}
              </div>
              <.render_option
                :for={{opt, _} <- opts}
                opt={opt}
                index={opt.__index__}
                highlighted={@highlighted}
                field={@field}
                multiple={@multiple}
                myself={@myself}
                custom_option={@option}
              />
            <% end %>
          <% end %>

          <%!-- Create new option --%>
          <div
            :if={@show_create}
            phx-click="create"
            phx-target={@myself}
            class="flex items-center gap-2 px-3 py-2 text-sm cursor-pointer transition-colors hover:bg-surface-hover text-primary font-medium"
          >
            <.icon name="hero-plus-mini" class="size-4" />
            <span>Create "{@search}"</span>
          </div>

          <%!-- Empty state --%>
          <div :if={@filtered == [] && !@show_create} class="px-3 py-8 text-center">
            <.icon
              name="hero-magnifying-glass"
              class="size-8 text-text-muted mx-auto mb-2 opacity-40"
            />
            <p class="text-sm text-text-muted">No results for "{@search}"</p>
            <p :if={@creatable} class="text-xs text-text-muted mt-1">Press Enter to create it</p>
          </div>

          <%!-- Infinite scroll sentinel --%>
          <div
            :if={@on_load_more}
            id={"#{@id}-sentinel"}
            phx-viewport-bottom="load_more"
            phx-target={@myself}
            class="h-px"
          />
        </div>
      </div>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".SearchSelect">
        export default {
          mounted() {
            this.focusSearch()
            this.scrollToHighlighted()
          },
          updated() {
            this.focusSearch()
            this.scrollToHighlighted()
          },
          focusSearch() {
            const input = this.el.querySelector("input[type=text][autofocus]")
            if (input && document.activeElement !== input) {
              requestAnimationFrame(() => input.focus())
            }
          },
          scrollToHighlighted() {
            const list = this.el.querySelector("[role=listbox] > div:last-child")
            const active = list?.querySelector("[data-highlighted]")
            if (active) active.scrollIntoView({ block: "nearest" })
          }
        }
      </script>
    </div>
    """
  end

  defp render_option(assigns) do
    selected = is_selected?(assigns.field.value, assigns.opt.value, assigns.multiple)
    assigns = assign(assigns, selected: selected)

    ~H"""
    <div
      phx-click="select"
      phx-value-value={@opt.value}
      phx-target={@myself}
      role="option"
      aria-selected={"#{@selected}"}
      data-highlighted={if @index == @highlighted, do: "true"}
      class={[
        "flex items-center gap-2.5 px-3 py-2 text-sm cursor-pointer transition-colors",
        "hover:bg-surface-hover",
        @index == @highlighted && "bg-surface-hover",
        @selected && "text-primary font-medium"
      ]}
    >
      <%!-- Check mark column --%>
      <.icon :if={@selected} name="hero-check-mini" class="size-4 text-primary shrink-0" />
      <span :if={!@selected} class="size-4 shrink-0" />

      <%!-- Custom or default option content --%>
      <%= if @custom_option != [] do %>
        {render_slot(@custom_option, @opt)}
      <% else %>
        <img
          :if={@opt[:image]}
          src={@opt[:image]}
          class="size-6 rounded-full object-cover shrink-0 outline-none"
          alt=""
        />
        <span class="truncate flex-1">{@opt.label}</span>
        <span :if={@opt[:subtitle]} class="text-xs text-text-muted shrink-0">{@opt[:subtitle]}</span>
      <% end %>
    </div>
    """
  end

  # ── Events ──────────────────────────────────────────────

  @impl true
  def handle_event("toggle", _, socket) do
    {:noreply, assign(socket, open: !socket.assigns.open, search: "", highlighted: 0)}
  end

  def handle_event("close", _, socket) do
    {:noreply, assign(socket, open: false)}
  end

  def handle_event("search", %{"value" => query}, socket) do
    socket = assign(socket, search: query, highlighted: 0)

    if socket.assigns.on_search do
      send(self(), {__MODULE__, :search, socket.assigns.id, query})
    end

    {:noreply, socket}
  end

  def handle_event("select", %{"value" => value}, socket) do
    %{field: field, multiple: multiple} = socket.assigns

    new_value =
      if multiple do
        current = List.wrap(field.value || [])
        if value in current, do: Enum.reject(current, &(&1 == value)), else: current ++ [value]
      else
        value
      end

    send(self(), {__MODULE__, :select, socket.assigns.id, new_value})

    socket = if multiple, do: socket, else: assign(socket, open: false)
    {:noreply, socket}
  end

  def handle_event("remove_chip", %{"value" => value}, socket) do
    current = List.wrap(socket.assigns.field.value || [])
    new_value = Enum.reject(current, &(&1 == value))
    send(self(), {__MODULE__, :select, socket.assigns.id, new_value})
    {:noreply, socket}
  end

  def handle_event("clear", _, socket) do
    send(self(), {__MODULE__, :select, socket.assigns.id, nil})
    {:noreply, assign(socket, open: false)}
  end

  def handle_event("create", _, socket) do
    value = socket.assigns.search

    if socket.assigns.on_create do
      send(self(), {__MODULE__, :create, socket.assigns.id, value})
    else
      # Auto-create: use the search text as both value and label
      send(
        self(),
        {__MODULE__, :select, socket.assigns.id,
         if(socket.assigns.multiple,
           do: List.wrap(socket.assigns.field.value || []) ++ [value],
           else: value
         )}
      )
    end

    {:noreply, assign(socket, open: false, search: "")}
  end

  def handle_event("keydown", %{"key" => "ArrowDown"}, socket) do
    max = length(filtered_options(socket.assigns.options, socket.assigns.search)) - 1
    {:noreply, assign(socket, highlighted: min(socket.assigns.highlighted + 1, max(max, 0)))}
  end

  def handle_event("keydown", %{"key" => "ArrowUp"}, socket) do
    {:noreply, assign(socket, highlighted: max(socket.assigns.highlighted - 1, 0))}
  end

  def handle_event("keydown", %{"key" => "Enter"}, socket) do
    opts = filtered_options(socket.assigns.options, socket.assigns.search)

    case Enum.at(opts, socket.assigns.highlighted) do
      nil ->
        if socket.assigns.creatable && socket.assigns.search != "" do
          handle_event("create", %{}, socket)
        else
          {:noreply, socket}
        end

      opt ->
        handle_event("select", %{"value" => opt.value}, socket)
    end
  end

  def handle_event("keydown", %{"key" => "Escape"}, socket) do
    {:noreply, assign(socket, open: false)}
  end

  def handle_event("keydown", _, socket), do: {:noreply, socket}

  def handle_event("load_more", _, socket) do
    if socket.assigns.on_load_more do
      send(self(), {__MODULE__, :load_more, socket.assigns.id})
    end

    {:noreply, socket}
  end

  # ── Helpers ──────────────────────────────────────────────

  defp filtered_options(options, "") when is_list(options), do: add_indices(options)

  defp filtered_options(options, search) when is_list(options) do
    query = String.downcase(search)

    options
    |> Enum.filter(fn opt ->
      label = String.downcase(to_string(opt.label))
      subtitle = String.downcase(to_string(opt[:subtitle] || ""))

      String.contains?(label, query) or String.contains?(subtitle, query) or
        fuzzy_match?(query, label)
    end)
    |> add_indices()
  end

  defp add_indices(opts) do
    Enum.with_index(opts, fn opt, i -> Map.put(opt, :__index__, i) end)
  end

  defp group_options(opts) do
    opts
    |> Enum.group_by(& &1[:group])
    |> Enum.sort_by(fn {group, _} -> group || "" end)
    |> Enum.map(fn {group, items} -> {group, Enum.map(items, &{&1, &1.__index__})} end)
  end

  defp fuzzy_match?(query, text) do
    fuzzy_match_chars(String.graphemes(query), String.graphemes(text))
  end

  defp fuzzy_match_chars([], _), do: true
  defp fuzzy_match_chars(_, []), do: false

  defp fuzzy_match_chars([q | qrest], [t | trest]) do
    if q == t, do: fuzzy_match_chars(qrest, trest), else: fuzzy_match_chars([q | qrest], trest)
  end

  defp is_selected?(current, value, true),
    do: to_string(value) in Enum.map(List.wrap(current || []), &to_string/1)

  defp is_selected?(current, value, false), do: to_string(current) == to_string(value)

  defp selected_chips(options, values) do
    string_values = Enum.map(List.wrap(values || []), &to_string/1)
    Enum.filter(options, fn opt -> to_string(opt.value) in string_values end)
  end

  defp assign_selected_labels(socket) do
    %{field: field, options: options, multiple: multiple} = socket.assigns

    label =
      if multiple do
        # Multi-select uses chips instead
        nil
      else
        case Enum.find(options, &(to_string(&1.value) == to_string(field.value))) do
          nil -> nil
          opt -> opt.label
        end
      end

    assign(socket, :selected_label, label)
  end
end
