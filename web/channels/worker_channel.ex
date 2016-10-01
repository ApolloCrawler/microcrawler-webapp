defmodule MicrocrawlerWebapp.WorkerChannel do
  use Phoenix.Channel

  def join("worker:lobby", payload, socket) do
    IO.puts "Received join - worker:lobby"
    IO.puts Poison.encode_to_iodata!(payload, pretty: true)
    {:ok, %{msg: "Welcome!"}, socket}
  end

  def join("worker:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("ping", payload, socket) do
    IO.puts "Received event - ping"
    IO.puts Poison.encode_to_iodata!(payload, pretty: true)
    push socket, "pong", Map.merge(payload, %{ts: :os.system_time(:milli_seconds)})
    {:reply, {:ok, payload}, socket}
  end

  def handle_in(event, payload, socket) do
    IO.puts "Received event - #{event}"
    IO.puts Poison.encode_to_iodata!(payload, pretty: true)
    {:noreply, socket}
  end
end
