defmodule MicrocrawlerWebapp.API.V1.AuthController do
  use MicrocrawlerWebapp.Web, :controller

  require Logger

  alias MicrocrawlerWebapp.Account
  alias MicrocrawlerWebapp.Accounts

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.get(email) do
      {:ok, user} ->
        case Comeonin.Bcrypt.checkpw(password, user.password_hashed) do
          true ->
            new_conn = Guardian.Plug.api_sign_in(conn, user)
            jwt = Guardian.Plug.current_token(new_conn)
            new_conn
            |> put_resp_header("authorization", "Bearer #{jwt}")
            |> json(%{"user": %{"email": user.email}})
          false ->
            failure(conn)
        end
      error ->
        Logger.debug inspect(error)
        Comeonin.Bcrypt.dummy_checkpw()

        conn
        |> put_status(:unauthorized)
        |> json(%{"error": "Invalid username or password"})
      end

  end

  def sign_out(conn, _params) do
    jwt = Guardian.Plug.current_token(conn)
    case jwt do
      {:ok, _} ->
        conn
        |> json(%{"user": nil})
      _ ->
        conn
        |> json(%{"user": nil})
    end
  end

  def sign_up(conn, %{"email" => email, "password" => password}) do
    data = %{"email" => email, "password" => password, "password_confirmation" => password}
    case Accounts.insert(Account.changeset(%Account{}, data)) do
      {:ok, user} -> {}
        conn
        |> json(%{"user": %{email: user.email}})
      {:error, changeset} ->
        IO.inspect changeset
        conn
        |> put_status(400)
        |> json(%{"errors": ["Some error ocurred"]})
    end
  end

  def user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    case user do
      nil ->
        conn
        |> json(%{})
      _ ->
        conn
        |> json(%{"user": %{email: user.email}})
    end

    conn
    |> json(%{"user": %{}})
  end

  defp failure(conn) do
    conn
    |> put_status(:unauthorized)
    |> json(%{message: "Authentication failed"})
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> json(%{message: "Authentication required"})
  end
end
