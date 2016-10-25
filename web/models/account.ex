defmodule MicrocrawlerWebapp.Account do

  use Ecto.Schema
  import Ecto.Changeset

  schema "account" do
    field :email
    field :password
    field :password_confirmation
    field :password_hashed
    field :token
  end

  def changeset(account, params \\ %{}) do
    account
    |> cast(params, [:email, :password, :password_confirmation])
    |> validate_required([:email, :password])
    |> validate_length(:email, min: 3)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 3)
    |> validate_confirmation(:password)
  end

  def hash_password(account) do
    %{account | password_hashed: Comeonin.Bcrypt.hashpwsalt(account.password)}
  end

  def generate_token(account) do
    %{account | token: Ecto.UUID.generate}
  end
end
