defmodule MicrocrawlerWebapp.WorkerChannel do
  use Phoenix.Channel

  def join("worker:lobby", _message, socket) do
    {:ok, %{msg: "Welcome!"}, socket}
  end

  def join("worker:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end
end
