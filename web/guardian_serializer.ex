defmodule MicrocrawlerWebapp.GuardianSerializer do
  @moduledoc """
  TODO
  """

  @behaviour Guardian.Serializer

  use Guardian.Hooks

  alias MicrocrawlerWebapp.User

  def for_token(%User{:email => email, :token => token}) do
    {:ok, %{email: email, token: token}}
  end

  def from_token(%{"email" => email, "token" => token}) do
    {:ok, %User{email: email, token: token}}
  end

  def before_encode_and_sign(user, :worker, _claims) do
    {
      :ok,
      {user, :worker, %{email: user.email, token: user.token, typ: "worker"}}
    }
  end

  def before_encode_and_sign(object, type, claims) do
    {:ok, {object, type, claims}}
  end
end
