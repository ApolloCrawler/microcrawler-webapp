defmodule MicrocrawlerWebapp.CrawlerManager do
  @moduledoc """
  Module for managing crawlers
  """

  @default_prefix "microcrawler-crawler-"

  def install_crawler(crawler) do
    {:ok, name} = Map.fetch(crawler, "name")
    {:ok, version} = Map.fetch(crawler, "version")

    package_full_name = "#{name}@#{version}"
    {output, _code} = MicrocrawlerWebapp.Commander.cmd("npm", ["install", package_full_name])

    {name, version}
  end

  def install_crawlers(crawlers) do
    Enum.map(crawlers, fn(crawler) -> install_crawler(crawler) end)
  end

  def query_crawlers(input_query \\ @default_prefix) do
    MicrocrawlerWebapp.Npm.query(input_query)
    |> Enum.filter(fn(x) -> String.starts_with?(Map.fetch!(x, "name"), input_query) end)
    |> Enum.reduce(%{}, fn(e, a) ->
      Map.put(a, Map.fetch!(e, "name"), e)
    end)
  end

  def update_crawlers(input_query \\ @default_prefix) do
    local_crawlers = list_existing(input_query)
    remote_crawlers = query_crawlers(input_query)

    to_install = Enum.map(Map.keys(remote_crawlers), fn(k) ->
      Map.fetch!(remote_crawlers, k)
    end)
    |> Enum.filter(fn(x) ->
      case Map.fetch(local_crawlers, Map.fetch!(x, "name")) do
        :error -> true
        {:ok, item} ->
          local_version = Map.fetch!(item, :version)
          remote_version = Map.fetch!(x, "version")
          local_version != remote_version
      end
    end)

    install_crawlers(to_install)

    path = "data/crawlers.json"
    write_crawlers_to_file(path, remote_crawlers)

    remote_crawlers
  end

  def write_crawlers_to_file(path, crawlers) do
    {:ok, file} = File.open(path, [:write])
    nice_json = Poison.encode_to_iodata!(crawlers, pretty: true)
    IO.binwrite(file, nice_json)
    File.close(file)
  end

  def list_existing(input_query \\ @default_prefix) do
    File.ls!("node_modules")
    |> Enum.filter(fn(x) -> String.starts_with?(x, input_query) end)
    |> Enum.map(fn(x) -> File.read!("node_modules/#{x}/package.json") end)
    |> Enum.map(fn(x) -> Poison.decode!(x) end)
    |> Enum.map(fn(x) -> %{
      name: Map.fetch!(x, "name"),
      version: Map.fetch!(x, "version"),
      description: Map.fetch!(x, "description"),
    } end)
    |> Enum.reduce(%{}, fn(e, a) ->
      Map.put(a, Map.fetch!(e, :name), e)
    end)
  end

end
