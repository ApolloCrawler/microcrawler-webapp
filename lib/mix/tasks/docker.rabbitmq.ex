defmodule Mix.Tasks.Docker.Rabbitmq do
  @moduledoc """
  TODO
  """

  use Mix.Task

  @shortdoc "Run RabbitMQ in Docker"

  def run(_) do
    IO.puts System.cwd!
    System.cmd("sh", ["./docks/rabbitmq/run.sh"])
  end
end
