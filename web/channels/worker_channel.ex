defmodule MicrocrawlerWebapp.WorkerChannel do
  use Phoenix.Channel

  require Logger

  def join("worker:lobby", payload, socket) do
    Logger.debug "Received join - worker:lobby"
    Logger.debug Poison.encode_to_iodata!(payload, pretty: true)
    Logger.debug inspect(self)

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
    Logger.debug "Received event - ping"
    Logger.debug Poison.encode_to_iodata!(payload, pretty: true)
    push socket, "pong", Map.merge(payload, %{ts: :os.system_time(:milli_seconds)})
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("done", payload, socket) do
    Logger.debug "Received event - done"
    Logger.debug Poison.encode_to_iodata!(payload, pretty: true)
    AMQP.Basic.ack(
      socket.assigns[:rabb_chan],
      socket.assigns[:rabb_meta].delivery_tag
    )
    {:noreply, socket}
  end

  def handle_in(event, payload, socket) do
    Logger.debug "Received event - #{event}"
    Logger.debug Poison.encode_to_iodata!(payload, pretty: true)
    {:noreply, socket}
  end

  def handle_info({:basic_deliver, payload, meta}, socket) do
    Logger.debug "Received from rabbit - #{payload}"
    push socket, "crawl", %{payload: payload}
    {:noreply, assign(socket, :rabb_meta, meta)}
  end

  def handle_info(msg, socket) do
    Logger.debug inspect(msg)
    Logger.debug inspect(self)
    # IO.inspect socket
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    Logger.debug inspect(reason)
    Logger.debug inspect(self)
    Logger.debug inspect(socket)
    AMQP.Connection.close(socket.assigns[:rabb_conn])
    :ok
  end
end
