defmodule Mix.Tasks.Docker.Couchbase do
  @moduledoc """
  TODO
  """

  use Mix.Task

  @shortdoc "Run Couchbase in Docker"

  def run(_) do
    IO.puts System.cwd!
    System.cmd("sh", ["./docks/couchbase/run.sh"])
  end
end
