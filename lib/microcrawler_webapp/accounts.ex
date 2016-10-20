defmodule MicrocrawlerWebapp.Accounts do
  use GenServer

  alias MicrocrawlerWebapp.Account

  def start_link(dets_name) do
    GenServer.start_link(__MODULE__, dets_name, name: __MODULE__)
  end

  def insert(changeset) do
    changeset = %{changeset | action: :insert}
    case changeset.valid? do
      true ->
        account = changeset
                  |> Ecto.Changeset.apply_changes
                  |> Account.hash_password
                  |> Account.generate_token
        case GenServer.call(__MODULE__, {:create, account}) do
          {:ok, _account} = ok ->
            ok
          {:error, :already_exists} ->
            {:error, Ecto.Changeset.add_error(changeset, :email, "already exists")}
        end
      false ->
        {:error, changeset}
    end
  end

  def get(email) do
    GenServer.call(__MODULE__, {:get, email})
  end

  def renew_token(account) do
    GenServer.call(__MODULE__, {:update, Account.generate_token(account)})
  end

  def init(dets_name) do
    :dets.open_file(dets_name, [])
  end

  def handle_call({:create, account}, _from, dets) do
    {:reply, case :dets.insert_new(dets, row(account)) do
      true ->
        {:ok, account}
      false ->
        {:error, :already_exists}
      error ->
        error
    end, dets}
  end

  def handle_call({:get, email}, _from, dets) do
    {:reply, lookup(dets, email), dets}
  end

  def handle_call({:update, new_account}, _from, dets) do
    {:reply, case lookup(dets, new_account.email) do
      {:ok, old_account} ->
        new_account = %{old_account | token: new_account.token}
        case :dets.insert(dets, row(new_account)) do
          :ok ->
            {:ok, new_account}
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

  defp row(account) do
    [{account.email, account.password_hashed, account.token}]
  end

  defp lookup(dets, email) do
    case :dets.lookup(dets, email) do
      [{email, password, token}] ->
        {:ok, %Account{email: email, password_hashed: password, token: token}}
      [] ->
        {:error, :not_found}
      error ->
        error
    end
  end
end
