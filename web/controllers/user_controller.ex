defmodule MicrocrawlerWebapp.UserController do
  use MicrocrawlerWebapp.Web, :controller

  require Logger

  alias MicrocrawlerWebapp.Users

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    {:ok, jwt, _} = Guardian.encode_and_sign(user, :worker)
    render conn, "index.html", user: user, jwt: jwt
  end

  def renew(conn, _params) do
    {:ok, user} = Users.renew_token(Guardian.Plug.current_resource(conn))
    conn
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/user")
  end
end
