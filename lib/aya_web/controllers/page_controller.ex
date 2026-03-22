defmodule AyaWeb.PageController do
  use AyaWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
