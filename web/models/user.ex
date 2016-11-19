defmodule MicrocrawlerWebapp.User do
  @moduledoc """
  TODO
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Comeonin.Bcrypt
  alias Ecto.UUID

  schema "user" do
    field :email
    field :password
    field :password_confirmation
    field :password_hashed
    field :token
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email, :password, :password_confirmation])
    |> validate_required([:email, :password])
    |> validate_length(:email, min: 3)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 3)
    |> validate_confirmation(:password)
  end

  def hash_password(user) do
    %{user | password_hashed: Bcrypt.hashpwsalt(user.password)}
  end

  def generate_token(user) do
    %{user | token: UUID.generate}
  end
end
