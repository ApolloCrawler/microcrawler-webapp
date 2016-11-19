defmodule MicrocrawlerWebapp.API.V1.CrawlersController do
  use MicrocrawlerWebapp.Web, :controller

  def index(conn, _params) do
    package_jsons = Enum.reject(
      Path.wildcard("node_modules/microcrawler-crawler-*/package.json"),
      fn(x) ->
        String.contains?(x, "microcrawler-crawler-all") ||
        String.contains?(x, "microcrawler-crawler-base")
      end
    )

    crawlers = Enum.map(
      package_jsons,
      fn(x) ->
        case File.read(x) do
          {:ok, content} ->
            {:ok, pkg} = Poison.decode(content)
            %{
              author: Map.fetch!(pkg, "author"),
              name: Map.fetch!(pkg, "name"),
              description: Map.fetch!(pkg, "description"),
              crawler: Map.fetch!(pkg, "crawler")
            }
          _ -> nil
        end
      end
    )

    conn
    |> json(crawlers)
  end
end
