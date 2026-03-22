defmodule AyaWeb.CoreComponents do
  @moduledoc """
  Core UI components for Aya.

  Built with pure Tailwind CSS v4 + design tokens. No DaisyUI.
  All colors reference the semantic token classes defined in app.css.

  Components:
  - `flash/1` — toast notification
  - `button/1` — button / link-button with variants
  - `input/1` — form input with label + error messages
  - `header/1` — page header with title, subtitle, actions
  - `table/1` — data table with streaming support
  - `list/1` — data list
  - `icon/1` — Heroicon wrapper
  - `show/2`, `hide/2` — JS transition helpers
  """
  use Phoenix.Component
  use Gettext, backend: AyaWeb.Gettext

  alias Phoenix.LiveView.JS

  # ── Flash ──────────────────────────────────────────────────────

  @doc """
  Renders flash notices as toast-style notifications.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class="fixed top-4 right-4 z-50 flash-enter"
      data-auto-dismiss={@kind == :info && "5000"}
      {@rest}
    >
      <div class={[
        "w-80 sm:w-96 rounded-lg p-4",
        "flex items-start gap-3",
        "shadow-border",
        @kind == :info && "bg-info-soft text-info-text",
        @kind == :error && "bg-error-soft text-error-text"
      ]}>
        <.icon :if={@kind == :info} name="hero-information-circle" class="size-5 shrink-0 text-info" />
        <.icon
          :if={@kind == :error}
          name="hero-exclamation-circle"
          class="size-5 shrink-0 text-error"
        />
        <div class="flex-1 min-w-0">
          <p :if={@title} class="font-semibold text-sm">{@title}</p>
          <p class="text-sm">{msg}</p>
        </div>
        <button
          type="button"
          class="shrink-0 cursor-pointer opacity-40 hover:opacity-70 transition-[opacity] duration-150"
          aria-label={gettext("close")}
        >
          <.icon name="hero-x-mark" class="size-5" />
        </button>
      </div>
    </div>
    """
  end

  # ── Button ─────────────────────────────────────────────────────

  @doc """
  Renders a button with variant support and navigation.

  ## Variants

  - `"primary"` — solid primary background
  - `"secondary"` — solid secondary background
  - `"ghost"` — transparent with hover background
  - `"soft"` (default) — soft primary background

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" variant="primary">Send!</.button>
      <.button navigate={~p"/"} variant="ghost">Home</.button>
  """
  attr :rest, :global, include: ~w(href navigate patch method download name value disabled)
  attr :class, :any, default: nil
  attr :variant, :string, default: "soft", values: ~w(primary secondary ghost soft)
  attr :size, :string, default: "md", values: ~w(sm md lg)

  slot :inner_block, required: true

  def button(%{rest: rest} = assigns) do
    assigns =
      assign_new(assigns, :computed_class, fn ->
        [
          # Base styles
          "inline-flex items-center justify-center gap-2 font-medium",
          "rounded-md cursor-pointer",
          "transition-[color,background-color,scale] duration-150 ease-out",
          "active:not-disabled:scale-[0.96]",
          "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          # Loading states
          "phx-click-loading:opacity-70 phx-submit-loading:opacity-70",
          # Size
          variant_size(assigns.size),
          # Variant
          variant_style(assigns.variant),
          # Custom overrides
          assigns.class
        ]
      end)

    case {rest[:href], rest[:navigate], rest[:patch]} do
      {nil, nil, nil} ->
        ~H"""
        <button class={@computed_class} {@rest}>
          {render_slot(@inner_block)}
        </button>
        """

      _ ->
        ~H"""
        <.link class={@computed_class} {@rest}>
          {render_slot(@inner_block)}
        </.link>
        """
    end
  end

  defp variant_size("sm"), do: "px-3 py-1.5 text-xs"
  defp variant_size("md"), do: "px-4 py-2 text-sm"
  defp variant_size("lg"), do: "px-6 py-3 text-base"

  defp variant_style("primary"),
    do: "bg-primary text-primary-text hover:bg-primary-hover"

  defp variant_style("secondary"),
    do: "bg-secondary text-secondary-text hover:bg-secondary-hover"

  defp variant_style("ghost"),
    do: "bg-transparent text-text hover:bg-surface-hover"

  defp variant_style("soft"),
    do: "bg-primary-soft text-primary hover:bg-primary/10"

  # ── Input ──────────────────────────────────────────────────────

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  Accepts all HTML input types, plus:
  - `type="select"` to render a `<select>` tag
  - `type="checkbox"` for boolean values
  - `type="textarea"` for multi-line text

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               search select tel text textarea time url week hidden)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :class, :any, default: nil, doc: "the input class to use over defaults"
  attr :error_class, :any, default: nil, doc: "the input error class to use over defaults"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input type="hidden" id={@id} name={@name} value={@value} {@rest} />
    """
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class="mb-3">
      <label for={@id} class="flex items-center gap-2 cursor-pointer">
        <input
          type="hidden"
          name={@name}
          value="false"
          disabled={@rest[:disabled]}
          form={@rest[:form]}
        />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class={[
            @class ||
              "size-4 rounded border-border-strong text-primary",
            "focus:ring-2 focus:ring-ring focus:ring-offset-1"
          ]}
          {@rest}
        />
        <span :if={@label} class="text-sm text-text">{@label}</span>
      </label>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class="mb-3">
      <label for={@id}>
        <span :if={@label} class="block text-sm font-medium text-text mb-1">{@label}</span>
        <select
          id={@id}
          name={@name}
          class={[
            @class ||
              "w-full rounded-md border border-border bg-surface px-3 py-2 text-sm text-text",
            "focus:border-ring focus:ring-2 focus:ring-ring/20 focus:outline-none",
            "transition-colors",
            @errors != [] && (@error_class || "border-error focus:border-error focus:ring-error/20")
          ]}
          multiple={@multiple}
          {@rest}
        >
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options, @value)}
        </select>
      </label>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class="mb-3">
      <label for={@id}>
        <span :if={@label} class="block text-sm font-medium text-text mb-1">{@label}</span>
        <textarea
          id={@id}
          name={@name}
          class={[
            @class ||
              "w-full rounded-md border border-border bg-surface px-3 py-2 text-sm text-text",
            "focus:border-ring focus:ring-2 focus:ring-ring/20 focus:outline-none",
            "transition-colors min-h-[80px]",
            @errors != [] && (@error_class || "border-error focus:border-error focus:ring-error/20")
          ]}
          {@rest}
        >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      </label>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    """
  end

  # All other inputs: text, datetime-local, url, password, etc.
  def input(assigns) do
    ~H"""
    <div class="mb-3">
      <label for={@id}>
        <span :if={@label} class="block text-sm font-medium text-text mb-1">{@label}</span>
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[
            @class ||
              "w-full rounded-md border border-border bg-surface px-3 py-2 text-sm text-text",
            "focus:border-ring focus:ring-2 focus:ring-ring/20 focus:outline-none",
            "placeholder:text-text-muted transition-colors",
            @errors != [] && (@error_class || "border-error focus:border-error focus:ring-error/20")
          ]}
          {@rest}
        />
      </label>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    """
  end

  defp field_error(assigns) do
    ~H"""
    <p class="mt-1 flex items-center gap-1.5 text-xs text-error">
      <.icon name="hero-exclamation-circle" class="size-4" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ── Header ─────────────────────────────────────────────────────

  @doc """
  Renders a page header with title, optional subtitle, and action buttons.
  """
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={["pb-6", @actions != [] && "flex items-center justify-between gap-6"]}>
      <div>
        <h1 class="text-xl font-semibold text-text leading-8">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="mt-1 text-sm text-text-secondary">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div :if={@actions != []} class="flex-none flex items-center gap-3">
        {render_slot(@actions)}
      </div>
    </header>
    """
  end

  # ── Table ──────────────────────────────────────────────────────

  @doc """
  Renders a data table with generic styling and streaming support.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id">{user.id}</:col>
        <:col :let={user} label="username">{user.username}</:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-x-auto rounded-lg border border-border">
      <table class="w-full text-sm">
        <thead class="bg-surface-alt border-b border-border">
          <tr>
            <th
              :for={col <- @col}
              class="px-4 py-3 text-left text-xs font-medium text-text-secondary uppercase tracking-wider"
            >
              {col[:label]}
            </th>
            <th :if={@action != []} class="px-4 py-3">
              <span class="sr-only">{gettext("Actions")}</span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={is_struct(@rows, Phoenix.LiveView.LiveStream) && "stream"}
          class="divide-y divide-border"
        >
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            class="hover:bg-surface-alt/50 transition-colors"
          >
            <td
              :for={col <- @col}
              phx-click={@row_click && @row_click.(row)}
              class={["px-4 py-3 text-text", @row_click && "cursor-pointer"]}
            >
              {render_slot(col, @row_item.(row))}
            </td>
            <td :if={@action != []} class="px-4 py-3 w-0 text-right font-medium">
              <div class="flex items-center justify-end gap-3">
                <%= for action <- @action do %>
                  {render_slot(action, @row_item.(row))}
                <% end %>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  # ── List ───────────────────────────────────────────────────────

  @doc """
  Renders a data list with label-value pairs.

  ## Examples

      <.list>
        <:item title="Title">{@post.title}</:item>
        <:item title="Views">{@post.views}</:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <dl class="divide-y divide-border">
      <div :for={item <- @item} class="flex gap-4 py-3 sm:gap-8">
        <dt class="w-1/4 flex-none text-sm font-medium text-text-secondary">{item.title}</dt>
        <dd class="text-sm text-text">{render_slot(item)}</dd>
      </div>
    </dl>
    """
  end

  # ── Icon ───────────────────────────────────────────────────────

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  ## Examples

      <.icon name="hero-x-mark" />
      <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :any, default: "size-4"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  # ── JS Commands ────────────────────────────────────────────────

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  # ── Translation Helpers ────────────────────────────────────────

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    case Keyword.fetch(opts, :count) do
      {:ok, count} ->
        Gettext.dngettext(AyaWeb.Gettext, "errors", msg, msg, count, opts)

      :error ->
        Gettext.dgettext(AyaWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
