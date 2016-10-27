defmodule MicrocrawlerWebapp.SignInController do
  use MicrocrawlerWebapp.Web, :controller

  require Logger

  alias MicrocrawlerWebapp.Account
  alias MicrocrawlerWebapp.Accounts

  def index(conn, _params) do
    render conn, "index.html"
  end

  def sign_in(conn, %{"creds" => %{"email" => email, "password" => password}}) do
    case Accounts.get(email) do
      {:ok, account} ->
        case Comeonin.Bcrypt.checkpw(password, account.password_hashed) do
          true ->
            conn
            |> Guardian.Plug.sign_in(account)
            |> redirect(to: account_path(conn, :index))
          false ->
            failure(conn)
        end
      error ->
        Logger.debug inspect(error)
        Comeonin.Bcrypt.dummy_checkpw()
        failure(conn)
    end
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "authentication required")
    |> redirect(to: "/signin")
    |> halt
  end

  defp failure(conn) do
    conn
    |> put_flash(:error, "authentication failed")
    |> render("index.html")
  end
end
