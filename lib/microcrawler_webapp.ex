defmodule MicrocrawlerWebapp do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(MicrocrawlerWebapp.Repo, []),
      # Start the endpoint when the application starts
      supervisor(MicrocrawlerWebapp.Endpoint, []),
      # Start your own worker by calling: MicrocrawlerWebapp.Worker.start_link(arg1, arg2, arg3)
      # worker(MicrocrawlerWebapp.Worker, [arg1, arg2, arg3]),
      worker(MicrocrawlerWebapp.ActiveWorkers, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MicrocrawlerWebapp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MicrocrawlerWebapp.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule Gauc do
    require Logger
    require Rustler

    @on_load :load_nif
    def load_nif do
        path = :filelib.wildcard('native/gauc/target/debug/libgauc.*') |> hd |> :filename.rootname
        case :erlang.load_nif(path, 0) do
            :ok -> Logger.debug "Rustler Loaded"
            {:error, reason} -> IO.inspect(reason)
        end
    end

    # When your NIF is loaded, it will override this function.
    def add(_a, _b), do: throw :nif_not_loaded
end
