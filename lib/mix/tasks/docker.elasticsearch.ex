defmodule Mix.Tasks.Docker.Elasticsearch do
  use Mix.Task

  @shortdoc "Run Elasticsearch in Docker"

  def run(_) do
    IO.puts System.cwd!
    System.cmd("sh", ["./docks/elasticsearch/run.sh"])
  end
end
