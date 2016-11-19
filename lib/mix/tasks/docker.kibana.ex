defmodule Mix.Tasks.Docker.Kibana do
  @moduledoc """
  TODO
  """

  use Mix.Task

  @shortdoc "Run Kibana in Docker"

  def run(_) do
    IO.puts System.cwd!
    System.cmd("sh", ["./docks/kibana/run.sh"])
  end
end
