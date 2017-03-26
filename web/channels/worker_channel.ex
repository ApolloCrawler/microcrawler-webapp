defmodule MicrocrawlerWebapp.WorkerChannel do
  @moduledoc """
  TODO
  """

  use Phoenix.Channel

  require Logger

  alias MicrocrawlerWebapp.ActiveWorkers
  alias MicrocrawlerWebapp.Couchbase
  alias MicrocrawlerWebapp.Elasticsearch
  alias MicrocrawlerWebapp.Endpoint
  alias MicrocrawlerWebapp.IpInfo
  alias MicrocrawlerWebapp.WorkQueue

  def send_joined_workers_info do
    Endpoint.broadcast("worker:lobby", "send_worker_info", %{})
  end

  def join("worker:lobby", worker_info, socket) do
    false = Process.flag(:trap_exit, true)
    Logger.debug "Received join - worker:lobby"
    Logger.debug Poison.encode_to_iodata!(worker_info, pretty: true)
    Logger.debug inspect(self())

    socket = save_worker_info(socket, worker_info)
    send(self(), :after_join)

    {:ok, %{msg: "Welcome!"}, socket}
  end

  def join("worker:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info(:after_join, socket) do
    socket
    |> consume_work_queue
    |> send_worker_info
    |> noreply
  end

  def handle_info({:basic_deliver, payload, meta}, socket) do
    Logger.debug "Received from rabbit - #{payload}"
    push socket, "crawl", %{payload: payload}
    {:noreply, assign(socket, :rabb_meta, meta)}
  end

  def handle_info({:basic_consume_ok, some_map}, socket) do
    Logger.debug "Rabbit consume ok: #{inspect(some_map)}"
    {:noreply, socket}
  end

  def handle_info(:retry_consume, socket) do
    socket
    |> consume_work_queue
    |> noreply
  end

  def handle_info({:EXIT, pid, reason} = msg, socket) do
    if socket.assigns.work_queue.conn.pid == pid do
      Logger.debug "Rabbit conn closed #{inspect(reason)}"
      {:stop, {:rabbit_conn_closed, reason}, socket}
    else
      Logger.debug inspect(msg)
      Logger.debug inspect(self())
      {:stop, {:unknown_exit, msg}, socket}
    end
  end

  def handle_in("ping", payload, socket) do
    Logger.debug "Received event - ping"
    Logger.debug Poison.encode_to_iodata!(payload, pretty: true)
    ActiveWorkers.update_joined_worker_info(%{ping: payload})
    push(
      socket, "pong", Map.merge(payload, %{ts: :os.system_time(:milli_seconds)})
    )
    Logger.debug "Connected: #{inspect(ActiveWorkers.joined_workers)}"
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("done", payload, socket) do
    Logger.debug "Received event - done"
    Logger.debug Poison.encode_to_iodata!(payload, pretty: true)

    request = payload
    |> Map.get("request")
    |> Map.delete("type")
    results = Map.get(payload, "results")

    results
    |> Enum.filter(fn(res) ->
      Map.fetch!(res, "type") == "url"
    end)
    |> Enum.uniq
    |> Enum.shuffle
    # |> Logger.debug
    |> Enum.each(fn(res) ->
      # TODO: Use key 'crawler' instead of 'processor'
      key = "url-#{Map.fetch!(res, "processor")}-#{Map.fetch!(res, "url")}"
      key_hash = Base.encode16(:crypto.hash(:sha256, key))

      case Couchbase.get(key_hash) do
        %{"error" => "The key does not exist on the server"} ->
          new_doc = res
          # |> Map.put_new("type", "url")
          |> Map.put_new("uuid", UUID.uuid4())
          Couchbase.set(key_hash, new_doc)
          Elasticsearch.index(key_hash, new_doc)
          payload = Poison.encode!(res)
          WorkQueue.publish!(socket.assigns[:work_queue], payload)
        _ -> nil
      end
    end)

    results
    |> Enum.filter(fn(res) ->
      Map.fetch!(res, "type") == "data"
    end)
    |> Enum.uniq
    # |> Logger.debug
    |> Enum.each(fn(res) ->
      key = "data-#{Poison.encode!(res)}"
      key_hash = Base.encode16(:crypto.hash(:sha256, key))

      case Couchbase.get(key_hash) do
        %{"error" => "The key does not exist on the server"} ->
          new_doc = res
          # |> Map.put_new("type", "url")
          |> Map.put_new("request", request)
          Couchbase.set(key_hash, new_doc)
          Elasticsearch.index(key_hash, new_doc)
        _ -> nil
      end
    end)

    WorkQueue.ack!(socket.assigns[:work_queue], socket.assigns[:rabb_meta])

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
    Logger.debug inspect(self())
    Logger.debug inspect(socket)
    if Map.has_key?(socket.assigns, :work_queue) do
      WorkQueue.close(socket.assigns[:work_queue])
    end
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

  defp consume_work_queue(socket) do
    with {:ok, work_queue} <- WorkQueue.open,
         {:ok, _consumer_tag} = WorkQueue.consume(work_queue)
    do
      assign(socket, :work_queue, work_queue)
    else
      error ->
        Logger.error "Rabbit conn failed: #{inspect(error)}"
        Process.send_after(self(), :retry_consume, 5000)
        socket
    end
  end

  defp remote_ip(ip) do
    ip
    |> Tuple.to_list
    |> Enum.join(".")
  end

  defp country_code(ip) do
    case IpInfo.for(ip) do
      {:ok, info} -> info
      :error      -> ""
    end
  end

  defp noreply(socket), do: {:noreply, socket}
end
