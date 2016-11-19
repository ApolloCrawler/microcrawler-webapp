defmodule MicrocrawlerWebapp.ActiveWorkers do
  @moduledoc """
  TODO
  """

  use GenServer

  require Logger

  alias MicrocrawlerWebapp.WorkerChannel
  alias MicrocrawlerWebapp.ClientChannel

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def joined_workers() do
    GenServer.call(__MODULE__, :joined_workers)
  end

  def update_joined_worker_info(worker) do
    GenServer.cast(__MODULE__, {:update_joined_worker_info, self, worker})
  end

  def init(state) do
    ClientChannel.clear_worker_list()
    WorkerChannel.send_joined_workers_info()
    {:ok, state}
  end

  def handle_call(:joined_workers, _from, state) do
    {:reply, Map.values(state), state}
  end

  def handle_cast({:update_joined_worker_info, pid, new_info}, state) do
    info = case Map.fetch(state, pid) do
      {:ok, current_info} ->
        Map.merge(current_info, new_info)
      :error ->
        Process.monitor(pid)
        new_info
    end
    ClientChannel.update_worker(add_uuid(new_info, info))
    {:noreply, Map.put(state, pid, info)}
  end

  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    Logger.debug inspect(reason)
    ClientChannel.remove_worker(Map.fetch!(state, pid))
    {:noreply, Map.delete(state, pid)}
  end

  defp add_uuid(new_info, info) do
    case Map.has_key?(new_info, :join) do
      true ->
        new_info
      false ->
        Map.merge(new_info, %{join: %{uuid: info.join["uuid"]}})
    end
  end
end
