defmodule MicrocrawlerWebapp.ActiveWorkers do
  use GenServer

  require Logger

  alias MicrocrawlerWebapp.WorkerChannel

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def joined_workers() do
    GenServer.call(__MODULE__, :joined_workers)
  end

  def update_joined_worker_info(user) do
    GenServer.cast(__MODULE__, {:update_joined_worker_info, self, user})
  end

  def init(state) do
    WorkerChannel.send_joined_workers_info()
    {:ok, state}
  end

  def handle_call(:joined_workers, _from, state) do
    {:reply, Map.values(state), state}
  end

  def handle_cast({:update_joined_worker_info, pid, user}, state) do
    unless Map.has_key?(state, pid) do
        Process.monitor(pid)
    end
    {:noreply, Map.put(state, pid, user)}
  end

  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    Logger.debug inspect(reason)
    {:noreply, Map.delete(state, pid)}
  end
end
