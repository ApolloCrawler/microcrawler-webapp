defmodule MicrocrawlerWebapp.AccountController do
  use MicrocrawlerWebapp.Web, :controller

  require Logger

  alias MicrocrawlerWebapp.Accounts

  def index(conn, _params) do
    account = Guardian.Plug.current_resource(conn)
    {:ok, jwt, _} = Guardian.encode_and_sign(account, :worker)
    render conn, "index.html", account: account, jwt: jwt
  end

  def renew(conn, _params) do
    {:ok, account} = Accounts.renew_token(Guardian.Plug.current_resource(conn))
    conn
    |> Guardian.Plug.sign_in(account)
    |> redirect(to: "/account")
  end
end
