defmodule MicrocrawlerWebapp.SignInController do
  use MicrocrawlerWebapp.Web, :controller

  require Logger

  alias MicrocrawlerWebapp.Users
  alias Comeonin.Bcrypt
  alias Guardian.Plug

  def index(conn, _params) do
    render conn, "index.html"
  end

  def sign_in(conn, %{"creds" => %{"email" => email, "password" => password}}) do
    case Users.get(email) do
      {:ok, user} ->
        case Bcrypt.checkpw(password, user.password_hashed) do
          true ->
            conn
            |> Plug.sign_in(user)
            |> redirect(to: user_path(conn, :index))
          false ->
            failure(conn)
        end
      error ->
        Logger.debug inspect(error)
        Bcrypt.dummy_checkpw()
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
