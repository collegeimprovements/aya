defmodule AyaWeb.PageControllerTest do
  use AyaWeb.ConnCase

  test "GET / returns 200 with Aya home page", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Everything about"
  end
end
