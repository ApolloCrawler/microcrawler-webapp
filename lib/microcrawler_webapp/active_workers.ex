defmodule MicrocrawlerWebapp.ActiveWorkers do
  use GenServer

  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def joined_workers() do
    GenServer.call(__MODULE__, :joined_workers)
  end

  def worker_joined(user) do
    GenServer.cast(__MODULE__, {:worker_joined, self, user})
  end

  def handle_call(:joined_workers, _from, state) do
    {:reply, Map.values(state), state}
  end

  def handle_cast({:worker_joined, pid, user}, state) do
    ref = Process.monitor(pid)
    {:noreply, Map.put(state, {ref, pid}, user)}
  end

  def handle_info({:DOWN, ref, :process, pid, reason}, state) do
    Logger.debug inspect(reason)
    {:noreply, Map.delete(state, {ref, pid})}
  end
end
