defmodule Mix.Tasks.Docker.Postgresql do
  @moduledoc """
  TODO
  """

  use Mix.Task

  @shortdoc "Run PostgreSQL in Docker"

  def run(_) do
    IO.puts System.cwd!
    System.cmd("sh", ["./docks/postgresql/run.sh"])
  end
end
