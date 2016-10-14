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

    socket = save_worker_info(socket, worker_info)
    send(self, :after_join)

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

  def handle_info(:after_join, socket) do
    socket
    |> send_worker_info
    |> noreply
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

  intercept ["send_worker_info"]

  def handle_out("send_worker_info", _msg, socket) do
    Logger.debug "Received out event - send_worker_info"
    socket
    |> send_worker_info
    |> noreply
  end

  def terminate(reason, socket) do
    Logger.debug inspect(reason)
    Logger.debug inspect(self)
    Logger.debug inspect(socket)
    AMQP.Connection.close(socket.assigns[:rabb_conn])
    :ok
  end

  defp save_worker_info(socket, worker_info) do
    remote_ip = socket.assigns[:conn].remote_ip
    assign(socket, :worker_info, %{join: worker_info(worker_info, remote_ip)})
  end

  defp send_worker_info(socket) do
    ActiveWorkers.update_joined_worker_info(socket.assigns[:worker_info])
    socket
  end

  defp worker_info(worker_info, remote_ip) do
    worker_info
    |> Map.put(:remote_ip, remote_ip(remote_ip))
    |> Map.put(:country_code, country_code(remote_ip))
  end

  defp remote_ip(ip) do
    ip
    |> Tuple.to_list
    |> Enum.join(".")
  end

  defp country_code(ip) do
    case MicrocrawlerWebapp.IpInfo.for(ip) do
      {:ok, info} -> elem(info, 0)
      :error      -> ""
    end
  end

  defp noreply(socket), do: {:noreply, socket}
end
