defmodule MicrocrawlerWebapp.ClientChannel do
  use Phoenix.Channel

  require Logger

  def join("client:lobby", payload, socket) do
    Logger.debug "Received join - client:lobby"
    Logger.debug Poison.encode_to_iodata!(payload, pretty: true)
    Logger.debug inspect(self)

    {:ok, %{msg: "Welcome!"}, socket}
  end

  def join("client:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info(msg, socket) do
    Logger.debug inspect(msg)
    Logger.debug inspect(self)

    {:noreply, socket}
  end

  def terminate(reason, socket) do
    Logger.debug inspect(reason)
    Logger.debug inspect(self)
    Logger.debug inspect(socket)
    :ok
  end
end
