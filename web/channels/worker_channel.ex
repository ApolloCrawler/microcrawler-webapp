defmodule MicrocrawlerWebapp.WorkerChannel do
  use Phoenix.Channel

  def join("worker:lobby", payload, socket) do
    IO.puts "Received join - worker:lobby"
    IO.puts Poison.encode_to_iodata!(payload, pretty: true)
    IO.inspect self

    {:ok, conn} = AMQP.Connection.open
    {:ok, chan} = AMQP.Channel.open(conn)

    socket = assign(socket, :rabb_conn, conn)
    socket = assign(socket, :rabb_chan, chan)

    AMQP.Queue.declare(chan, "workq", durable: true)
    AMQP.Basic.qos(chan, prefetch_count: 1)
    AMQP.Basic.consume(chan, "workq", nil)

    # TODO:
    # - nejak je potreba resit, kdyz conn spadne a take obracene, ze by link na conn?
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

  def handle_info({:basic_deliver, payload, meta}, socket) do
    IO.puts "Received from rabbit - #{payload}"
    AMQP.Basic.ack(socket.assigns[:rabb_chan], meta.delivery_tag)
    {:noreply, socket}
    # TODO
    # - misto ack poslat pozdeji zpravu do workeru a az se vrati odpoved, tak poslat ack
  end

  def handle_info(msg, socket) do
    IO.inspect msg
    IO.inspect self
    # IO.inspect socket
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    IO.inspect reason
    IO.inspect self
    IO.inspect socket
    AMQP.Connection.close(socket.assigns[:rabb_conn])
    :ok
  end
end
