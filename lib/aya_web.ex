defmodule AyaWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use AyaWeb, :controller
      use AyaWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json]

      use Gettext, backend: AyaWeb.Gettext

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # Translation
      use Gettext, backend: AyaWeb.Gettext

      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components
      import AyaWeb.CoreComponents

      # UI component library
      import AyaWeb.UI.Accordion
      import AyaWeb.UI.Avatar
      import AyaWeb.UI.Badge
      import AyaWeb.UI.Banner
      import AyaWeb.UI.Breadcrumb
      import AyaWeb.UI.Card
      import AyaWeb.UI.Checkbox
      import AyaWeb.UI.CommandPalette
      import AyaWeb.UI.CopyButton
      import AyaWeb.UI.DatePicker
      import AyaWeb.UI.Divider
      import AyaWeb.UI.Dropdown
      import AyaWeb.UI.EmptyState
      import AyaWeb.UI.EngagementStats
      import AyaWeb.UI.ExpandableCards
      import AyaWeb.UI.FilePicker
      import AyaWeb.UI.FamilyDialog
      import AyaWeb.UI.HoverCard
      import AyaWeb.UI.Image
      import AyaWeb.UI.InlineAlert
      import AyaWeb.UI.Kbd
      import AyaWeb.UI.Link
      import AyaWeb.UI.ListDetail
      import AyaWeb.UI.Loading
      import AyaWeb.UI.MorphDialog
      import AyaWeb.UI.MultiStep
      import AyaWeb.UI.Overlay
      import AyaWeb.UI.Pagination
      import AyaWeb.UI.Progress
      import AyaWeb.UI.Radio
      import AyaWeb.UI.ShareSheet
      import AyaWeb.UI.Skeleton
      import AyaWeb.UI.SplitPane
      import AyaWeb.UI.Spinner
      import AyaWeb.UI.StatCard
      import AyaWeb.UI.Steps
      import AyaWeb.UI.Tabs
      import AyaWeb.UI.Toast
      import AyaWeb.UI.Toggle
      import AyaWeb.UI.Tooltip

      # Common modules used in templates
      alias Phoenix.LiveView.JS
      alias AyaWeb.Layouts

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: AyaWeb.Endpoint,
        router: AyaWeb.Router,
        statics: AyaWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
