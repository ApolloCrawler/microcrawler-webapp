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

  alias AMQP.Basic
  alias AMQP.Connection
  alias AMQP.Channel
  alias AMQP.Queue
  alias AMQP.Basic
  alias MicrocrawlerWebapp.IpInfo

  def send_joined_workers_info() do
    Endpoint.broadcast("worker:lobby", "send_worker_info", %{})
  end

  def join("worker:lobby", worker_info, socket) do
    Logger.debug "Received join - worker:lobby"
    Logger.debug Poison.encode_to_iodata!(worker_info, pretty: true)
    Logger.debug inspect(self())

    socket = save_worker_info(socket, worker_info)
    send(self(), :after_join)

    amqp_username = Application.fetch_env!(:amqp, :username)
    amqp_password = Application.fetch_env!(:amqp, :password)
    amqp_hostname = Application.fetch_env!(:amqp, :hostname)
    amqp_uri = "amqp://#{amqp_username}:#{amqp_password}@#{amqp_hostname}"

    {:ok, conn} = Connection.open(amqp_uri)
    {:ok, chan} = Channel.open(conn)

    socket = assign(socket, :rabb_conn, conn)
    socket = assign(socket, :rabb_chan, chan)

    Queue.declare(chan, "workq", durable: true)
    Basic.qos(chan, prefetch_count: 1)
    Basic.consume(chan, "workq", nil)

    # TODO:
    # - nejak je potreba resit, kdyz conn spadne a take obracene,
    #   ze by link na conn?
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
    Logger.debug inspect(self())
    # IO.inspect socket
    {:noreply, socket}
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
    Basic.ack(
      socket.assigns[:rabb_chan],
      socket.assigns[:rabb_meta].delivery_tag
    )

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
          channel = socket.assigns[:rabb_chan]
          payload = Poison.encode!(res)
          Basic.publish(channel, "", "workq", payload, persistent: true)
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
    Connection.close(socket.assigns[:rabb_conn])
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
    case IpInfo.for(ip) do
      {:ok, info} -> info
      :error      -> ""
    end
  end

  defp noreply(socket), do: {:noreply, socket}
end
