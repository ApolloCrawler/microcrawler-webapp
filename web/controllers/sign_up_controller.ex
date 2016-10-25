defmodule MicrocrawlerWebapp.SignUpController do
  use MicrocrawlerWebapp.Web, :controller

  alias MicrocrawlerWebapp.Account
  alias MicrocrawlerWebapp.Accounts

  def index(conn, _params) do
    render conn, "index.html", changeset: Account.changeset(%Account{})
  end

  def sign_up(conn, %{"account" => params}) do
    case Accounts.insert(Account.changeset(%Account{}, params)) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "account #{account.email} created")
        |> redirect(to: sign_in_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "check the errors below")
        |> render("index.html", changeset: changeset)
    end
  end
end
