defmodule AyaWeb.UI.RichEditor do
  @moduledoc """
  Tiptap-based rich text editor with toolbar, table support, and AI selection menu.

  Content is synced as HTML to a hidden input for form submission.

  ## Examples

      <.rich_editor id="body" field={@form[:body]} label="Content" />

      <.rich_editor
        id="article"
        field={@form[:content]}
        label="Article body"
        placeholder="Write your article..."
        ai_enabled
      />

  ## AI Selection Menu

  When `ai_enabled` is set, selecting text shows a floating menu with AI actions
  (Expand, Summarize, Fix Language, etc.). The parent LiveView receives events:

      def handle_event("ai_action", %{"action" => action, "text" => text}, socket)

  Where `action` is one of: "expand", "summarize", "fix_language", "simplify",
  "formal", "casual".

  ## Features

  - **Text formatting**: Bold, italic, underline, strikethrough, code, highlight
  - **Headings**: H1, H2, H3
  - **Block elements**: Blockquote, code block
  - **Lists**: Bullet list, ordered list
  - **Text alignment**: Left, center, right
  - **Tables**: Insert table, add/remove rows and columns
  - **Undo/Redo**
  - **AI menu**: Context menu on text selection (opt-in)
  """

  use Phoenix.Component

  attr :id, :string, required: true
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: nil, doc: "initial HTML content"
  attr :label, :string, default: nil
  attr :placeholder, :string, default: "Start writing..."
  attr :ai_enabled, :boolean, default: false, doc: "show AI actions on text selection"
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil

  def rich_editor(assigns) do
    assigns = assign_field_attrs(assigns)

    ~H"""
    <div
      id={@id}
      phx-hook="RichEditor"
      phx-update="ignore"
      data-placeholder={@placeholder}
      data-ai-enabled={if @ai_enabled, do: "true"}
      class={["re", @disabled && "re--disabled", @class]}
    >
      <label :if={@label} class="block text-sm font-medium text-text mb-1.5">{@label}</label>

      <div data-re-wrapper class="re-wrapper">
        <%!-- Toolbar (populated by JS) --%>
        <div data-re-toolbar class="re-toolbar" role="toolbar" aria-label="Formatting options" />

        <%!-- Editor area (Tiptap mounts here) --%>
        <div data-re-editor class="re-editor" />
      </div>

      <%!-- Hidden input for form submission --%>
      <textarea data-re-input name={@name} class="hidden" aria-hidden="true">{@value}</textarea>
    </div>
    """
  end

  defp assign_field_attrs(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
  end

  defp assign_field_attrs(assigns) do
    assigns
    |> assign_new(:name, fn -> nil end)
    |> assign_new(:value, fn -> nil end)
  end
end
