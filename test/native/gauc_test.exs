defmodule Elixir.GaucTest do
  use MicrocrawlerWebapp.ConnCase

  test "add" do
#    conn = get conn, "/"
#    assert html_response(conn, 200) =~ "<div id=\"app\">"
    assert(Gauc.add(1,2) == 3)
  end
end
