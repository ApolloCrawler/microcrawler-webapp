defmodule MicrocrawlerWebapp.WorkerChannel do
  use Phoenix.Channel

  require Logger

  alias MicrocrawlerWebapp.ActiveWorkers
  alias MicrocrawlerWebapp.Endpoint

  def send_joined_workers_info() do
    Endpoint.broadcast("worker:lobby", "send_worker_info", %{})
  end

  def join("worker:lobby", worker_info, socket) do
    Logger.debug "Received join - worker:lobby"
    Logger.debug Poison.encode_to_iodata!(worker_info, pretty: true)
    Logger.debug inspect(self)
    Logger.debug inspect(socket.assigns[:conn].remote_ip)

    ActiveWorkers.update_joined_worker_info(%{join: worker_info})
    socket = assign(socket, :worker_info, worker_info)

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
    ActiveWorkers.update_joined_worker_info(%{ping: payload})
    push socket, "pong", Map.merge(payload, %{ts: :os.system_time(:milli_seconds)})
    Logger.debug "Connected: #{inspect(ActiveWorkers.joined_workers)}"
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

  intercept ["send_worker_info"]

  def handle_out("send_worker_info", _msg, socket) do
    Logger.debug "Received out event - send_worker_info"
    ActiveWorkers.update_joined_worker_info(socket.assigns[:worker_info])
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
