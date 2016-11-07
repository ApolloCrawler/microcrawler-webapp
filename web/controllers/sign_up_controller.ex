defmodule MicrocrawlerWebapp.SignUpController do
  use MicrocrawlerWebapp.Web, :controller

  alias MicrocrawlerWebapp.User
  alias MicrocrawlerWebapp.Users

  def index(conn, _params) do
    render conn, "index.html", changeset: User.changeset(%User{})
  end

  def sign_up(conn, %{"user" => params}) do
    case Users.insert(User.changeset(%User{}, params)) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "user #{user.email} created")
        |> redirect(to: sign_in_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "check the errors below")
        |> render("index.html", changeset: changeset)
    end
  end
end
