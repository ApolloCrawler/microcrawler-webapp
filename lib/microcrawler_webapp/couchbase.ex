defmodule MicrocrawlerWebapp.Couchbase do
  require Logger

  def add(id, doc) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.add(#{inspect(id)})")
    case Poison.encode(doc) do
      {:ok, json} -> HTTPoison.post! "#{url_doc_id(id)}/add", json
    end
  end

  def append(id, doc) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.append(#{inspect(id)})")
    case Poison.encode(doc) do
      {:ok, json} -> HTTPoison.post! "#{url_doc_id(id)}/append", json
    end
  end

  def get(id) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.get(#{inspect(id)})")
    HTTPoison.get! url_doc_id(id)
  end

  def get!(id) do
    case Poison.decode(get(id).body) do
      {:ok, res} ->
        res
      _ -> nil
    end
  end

  def prepend(id, doc) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.prepend(#{inspect(id)})")
    case Poison.encode(doc) do
      {:ok, json} -> HTTPoison.post! "#{url_doc_id(id)}/prepend", json
    end
  end

  def remove(id) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.remove(#{inspect(id)})")
    HTTPoison.delete! url_doc_id(id)
  end

  def replace(id, doc) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.replace(#{inspect(id)})")
    case Poison.encode(doc) do
      {:ok, json} -> HTTPoison.post! "#{url_doc_id(id)}/replace", json
    end
  end

  def set(id, doc) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.set(#{inspect(id)})")
    case Poison.encode(doc) do
      {:ok, json} -> HTTPoison.post! "#{url_doc_id(id)}/set", json
    end
  end

  def upsert(id, doc) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.upsert(#{inspect(id)})")
    case Poison.encode(doc) do
      {:ok, json} -> HTTPoison.post! "#{url_doc_id(id)}/upsert", json
    end
  end

  defp bucket do
    Application.get_env(:microcrawler_webapp, MicrocrawlerWebapp.Couchbase)[:bucket]
  end

  defp url() do
    Application.get_env(:microcrawler_webapp, MicrocrawlerWebapp.Couchbase)[:url]
  end

  def url_doc() do
    "#{url}/bucket/#{bucket}/doc/"
  end

  def url_doc_id(id) do
    "#{url}/bucket/#{bucket}/doc/#{id}"
  end
end
