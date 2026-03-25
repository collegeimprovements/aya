defmodule AyaWeb.UI.MarkdownEditor do
  @moduledoc """
  CodeMirror 6 markdown editor with syntax highlighting, toolbar, and live preview.

  Content is synced as raw markdown to a hidden textarea for form submission.

  ## Examples

      <.markdown_editor id="notes" field={@form[:notes]} label="Notes" />

      <.markdown_editor
        id="readme"
        field={@form[:readme]}
        label="README"
        placeholder="Write markdown..."
      />
  """

  use Phoenix.Component

  attr :id, :string, required: true
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: nil, doc: "initial markdown content"
  attr :label, :string, default: nil
  attr :placeholder, :string, default: "Write markdown..."
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil

  def markdown_editor(assigns) do
    assigns = assign_field_attrs(assigns)

    ~H"""
    <div
      id={@id}
      phx-hook="MarkdownEditor"
      phx-update="ignore"
      data-placeholder={@placeholder}
      class={["re", @disabled && "re--disabled", @class]}
    >
      <label :if={@label} class="block text-sm font-medium text-text mb-1.5">{@label}</label>

      <div data-re-wrapper class="re-wrapper">
        <%!-- Toolbar --%>
        <div data-md-toolbar class="re-toolbar" role="toolbar" aria-label="Markdown formatting" />

        <%!-- Editor (CodeMirror mounts here) --%>
        <div data-md-editor />

        <%!-- Preview (hidden by default) --%>
        <div data-md-preview class="re-preview" style="display:none" />
      </div>

      <%!-- Hidden input for form submission --%>
      <textarea data-md-input name={@name} class="hidden" aria-hidden="true">{@value}</textarea>
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
