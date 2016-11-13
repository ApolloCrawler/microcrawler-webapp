defmodule MicrocrawlerWebapp.Coordinator do
  use GenServer

  @name __MODULE__

  require Logger

  require Record

  Record.defrecord :msg, [:type, :ttl, :pid, :key]

  Record.defrecord :item, [:type, :ttl, :pid, :waiting]

  Record.defrecord :state, [items: %{}, requesters: %{}]

  def start_link() do
    GenServer.start_link(@name, state(), name: @name)
  end

  # Use sha of {crawler, processor, url} as key for example.
  # Use (:os.system_time(:milli_seconds) + x) as ttl for example.
  def requested(key, ttl) do
    GenServer.call(@name, request(:requested, key, ttl), :infinity)
  end

  def commited(key, ttl) do
    GenServer.cast(@name, request(:commited, key, ttl))
  end

  defp request(type, key, ttl) do
    msg(type: type, ttl: ttl, pid: self, key: key)
  end

  def handle_call(msg(type: :requested) = request, from, state) do
    case is_already_requester(state, msg(request, :pid)) do
      true -> reply(state, {:error, :already_requester})
      false -> handle_requested(state, request, from)
    end |> lg
  end

  def handle_cast(msg(type: :commited) = request, state) do
    state |> handle_commited(request) |> noreply |> lg
  end

  defp lg(x) do
    Logger.debug "XXX: #{inspect(x)}"
    x
  end

  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    state |> delete_requester(pid, reason) |> accept_next_waiting |> noreply |> lg
  end

  def handle_info(msg, state) do
    Logger.debug inspect(msg)
    {:noreply, state}
  end

  defp handle_requested(state, request, from) do
    case find_item(state, msg(request, :key)) do
      nil ->
        state |> monitor(request) |> put(request) |> accept
      item(type: :requested) = existing ->
        state |> wait(existing, request, from) |> noreply
      item(type: :commited, ttl: ttl) when ttl > msg(request, :ttl) ->
        state |> reject
      item(type: :commited) ->
        state |> monitor(request) |> put(request) |> accept
    end
  end

  defp handle_commited(state, request) do
    case find_item(state, msg(request, :key)) do
      nil ->
        # coordinator was probably restarted
        Logger.warn "commiting #{inspect(request)} which is not requested"
      item(type: :requested, pid: pid, waiting: waiting) = value->
        if pid != msg(request, :pid) do
          # coordinator was probably restarted
          Logger.warn "commiting #{inspect(request)} which is requested by someone else as #{inspect(value)}"
        end
        reject_waiting(waiting)
      item(type: :commited) = value ->
        # coordinator was probably restarted
        Logger.warn "commiting #{inspect(request)} which is already commited as #{inspect(value)}"
    end
    state |> demonitor(request) |> put(request)
  end

  defp is_already_requester(state, pid) do
    Map.has_key?(requesters(state), pid)
  end

  defp find_item(state, key) do
    case Map.fetch(items(state), key) do
      {:ok, item} -> item
      :error -> nil
    end
  end

  defp monitor(state, request) do
    key = msg(request, :key)
    pid = msg(request, :pid)
    Logger.debug "actual requester for '#{key}': #{inspect(pid)}"
    mon = Process.monitor(pid)
    state(state, requesters: Map.put(requesters(state), pid, {key, mon}))
  end

  defp demonitor(state, request) do
    case Map.pop(requesters(state), msg(request, :pid), :not_found) do
      {:not_found, _} ->
        # coordinator was probably restarted
        Logger.warn "requester #{inspect(request)} not found"
        state
      {{_key, mon}, requesters} ->
        Process.demonitor(mon, [:flush])
        state(state, requesters: requesters)
    end
  end

  defp put(state, request, waiting \\ []) do
    value = item(
      type: msg(request, :type),
      ttl: msg(request, :ttl),
      pid: msg(request, :pid),
      waiting: waiting
    )
    state(state, items: Map.put(items(state), msg(request, :key), value))
  end

  defp wait(state, existing, request, from) do
    waiting = [{request, from} | item(existing, :waiting)]
    updated = item(existing, waiting: waiting)
    state(state, items: Map.put(items(state), msg(request, :key), updated))
  end

  defp reject_waiting(waiting) do
    Enum.each(waiting, fn({_, from}) -> GenServer.reply(from, :rejected) end)
  end

  defp delete_requester(state, pid, reason) do
    {{key, _mon}, requesters} = Map.pop(requesters(state), pid)
    Logger.debug "requester for '#{key}' failed: #{inspect({pid, reason})}"
    {state(state, requesters: requesters), key, pid}
  end

  defp accept_next_waiting({state, key, pid}) do
    value = Map.fetch!(items(state), key)
    item(type: :requested, pid: ^pid, waiting: waiting) = value
    case waiting do
      [] ->
        state(state, items: Map.delete(items(state), key))
      [{request, from}|rest_waiting] ->
        GenServer.reply(from, :accepted)
        state |> monitor(request) |> put(request, rest_waiting)
    end
  end

  defp items(state), do: state(state, :items)

  defp requesters(state), do: state(state, :requesters)

  defp reply(state, result), do: {:reply, result, state}

  defp noreply(state), do: {:noreply, state}

  defp accept(state), do: reply(state, :accepted)

  defp reject(state), do: reply(state, :rejected)
end
