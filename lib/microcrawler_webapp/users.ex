defmodule MicrocrawlerWebapp.Users do
  @moduledoc """
  TODO
  """

  use GenServer

  alias MicrocrawlerWebapp.User
  alias Ecto.Changeset

  def start_link(dets_name) do
    GenServer.start_link(__MODULE__, dets_name, name: __MODULE__)
  end

  def insert(changeset) do
    changeset = %{changeset | action: :insert}
    case changeset.valid? do
      true ->
        user = changeset
               |> Changeset.apply_changes
               |> User.hash_password
               |> User.generate_token
        case GenServer.call(__MODULE__, {:create, user}) do
          {:ok, _user} = ok ->
            ok
          {:error, :already_exists} ->
            {:error, Changeset.add_error(changeset, :email, "already exists")}
        end
      false ->
        {:error, changeset}
    end
  end

  def get(email) do
    GenServer.call(__MODULE__, {:get, email})
  end

  def renew_token(user) do
    GenServer.call(__MODULE__, {:update, User.generate_token(user)})
  end

  def init(dets_name) do
    :dets.open_file(dets_name, [])
  end

  def handle_call({:create, user}, _from, dets) do
    {:reply, case :dets.insert_new(dets, row(user)) do
      true ->
        {:ok, user}
      false ->
        {:error, :already_exists}
      error ->
        error
    end, dets}
  end

  def handle_call({:get, email}, _from, dets) do
    {:reply, lookup(dets, email), dets}
  end

  def handle_call({:update, new_user}, _from, dets) do
    {:reply, case lookup(dets, new_user.email) do
      {:ok, old_user} ->
        new_user = %{old_user | token: new_user.token}
        case :dets.insert(dets, row(new_user)) do
          :ok ->
            {:ok, new_user}
          error ->
            error
        end
      error ->
        error
    end, dets}
  end

  def terminate(_reason, dets) do
    :dets.close(dets)
  end

  defp row(user) do
    [{user.email, user.password_hashed, user.token}]
  end

  defp lookup(dets, email) do
    case :dets.lookup(dets, email) do
      [{email, password, token}] ->
        {:ok, %User{email: email, password_hashed: password, token: token}}
      [] ->
        {:error, :not_found}
      error ->
        error
    end
  end
end
