defmodule MicrocrawlerWebapp.API.V1.ApiController do
  use MicrocrawlerWebapp.Web, :controller

  def index(conn, _params) do
    json conn, %{id: 1}
  end
end
