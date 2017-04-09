defmodule MicrocrawlerWebapp.Npm do
  @moduledoc """
  Module for querying https://npmjs.org
  """

  def query(input_query) do
    args = [
      "search",
      "--json",
      input_query # TODO: Sanitize input_query!
    ]

    {output, _code} = MicrocrawlerWebapp.Commander.cmd("npm", args)

    case Poison.decode(output) do
      {:ok, res} ->
        res
      _ -> nil
    end
  end

  def update(package, version) do
  end
end
