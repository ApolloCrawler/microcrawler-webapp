defmodule MicrocrawlerWebapp.Coordinator do
  @moduledoc """
  TODO
  """

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

  # Resets coordinator clean state as it was after start.
  # It should be used only in tests to gen fresh instance of coordinator.
  def reset do
    GenServer.cast(@name, :reset)
  end

  defp request(type, key, ttl) do
    msg(type: type, ttl: ttl, pid: self, key: key)
  end

  def handle_call(msg(type: :requested) = request, from, state) do
    case is_already_requester(state, msg(request, :pid)) do
      true -> reply(state, {:error, :already_requester})
      false -> handle_requested(state, request, from)
    end
  end

  def handle_cast(msg(type: :commited) = request, state) do
    state |> handle_commited(request) |> noreply
  end

  def handle_cast(:reset, state) do
    demonitor_all(requesters(state))
    reset_all_waiting(items(state))
    noreply(state())
  end

  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    state |> delete_requester(pid, reason) |> accept_next_waiting |> noreply
  end

  defp handle_requested(state, request, from) do
    case find_item(state, msg(request, :key)) do
      nil ->
        state |> monitor(request) |> put(request) |> accept
      item(type: :requested) = existing ->
        state |> wait(existing, request, from) |> noreply
      item(type: :commited, ttl: ttl) when ttl >= msg(request, :ttl) ->
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
        state |> put(request)
      item(type: :requested, pid: pid, waiting: waiting) = value ->
        reject_waiting(waiting)
        if pid != msg(request, :pid) do
          # coordinator was probably restarted
          Logger.warn(
            "commiting #{inspect(request)} which is " <>
            "requested by someone else as #{inspect(value)}"
          )
          state |> demonitor(pid) |> put(request)
        else
          state |> demonitor(request) |> put(request)
        end
      item(type: :commited) = value ->
        # coordinator was probably restarted
        Logger.warn(
          "commiting #{inspect(request)} which is " <>
          "already commited as #{inspect(value)}"
        )
        state |> put(request)
    end
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

  defp demonitor(state, msg(pid: pid)) do
    demonitor(state, pid)
  end

  defp demonitor(state, pid) do
    case Map.pop(requesters(state), pid, :not_found) do
      {:not_found, _} ->
        # coordinator was probably restarted
        Logger.warn "requester #{inspect(pid)} not found"
        state
      {{_key, mon}, other_requesters} ->
        Process.demonitor(mon, [:flush])
        state(state, requesters: other_requesters)
    end
  end

  defp demonitor_all(requesters) do
    requesters
    |> Map.values
    |> Enum.each(fn({_key, mon}) -> Process.demonitor(mon, [:flush]) end)
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

  defp reset_all_waiting(items) do
    items
    |> Map.values
    |> Enum.each(fn(item(waiting: waiting)) -> reset_waiting(waiting) end)
  end

  defp reset_waiting(waiting) do
    reply_waiting(waiting, :reset)
  end

  defp reject_waiting(waiting) do
    reply_waiting(waiting, :rejected)
  end

  defp reply_waiting(waiting, reply) do
    Enum.each(waiting, fn({_, from}) -> GenServer.reply(from, reply) end)
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
