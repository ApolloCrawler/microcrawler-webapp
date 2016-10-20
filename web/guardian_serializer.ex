defmodule MicrocrawlerWebapp.GuardianSerializer do
  @behaviour Guardian.Serializer

  use Guardian.Hooks

  alias MicrocrawlerWebapp.Account

  def for_token(%Account{:email => email, :token => token}) do
    {:ok, %{email: email, token: token}}
  end

  def from_token(%{"email" => email, "token" => token}) do
    {:ok, %Account{email: email, token: token}}
  end

  def before_encode_and_sign(account, :worker, _claims) do
    {:ok, {account, :worker, %{email: account.email, token: account.token}}}
  end

  def before_encode_and_sign(object, type, claims) do
    {:ok, {object, type, claims}}
  end
end
