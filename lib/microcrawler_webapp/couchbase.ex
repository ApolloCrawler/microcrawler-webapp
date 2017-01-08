defmodule MicrocrawlerWebapp.Couchbase do
  @moduledoc """
  TODO
  """

  require Logger

  alias MicrocrawlerWebapp.Couchbase

  def add(id, doc) do
    case add_raw(id, doc) do
      {:ok, res} ->
        case Poison.decode(res.body) do
          {:ok, res} ->
            res
          _ -> nil
        end
    end
  end

  def add_raw(id, doc) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.add_raw(#{inspect(id)})")
    case Poison.encode(doc) do
      {:ok, json} -> HTTPoison.post "#{url_doc_id(id)}/add", json
    end
  end

  def append(id, doc) do
    case append_raw(id, doc) do
      {:ok, res} ->
        case Poison.decode(res.body) do
          {:ok, res} ->
            res
          _ -> nil
        end
    end
  end

  def append_raw(id, doc) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.append_raw(#{inspect(id)})")
    case Poison.encode(doc) do
      {:ok, json} -> HTTPoison.post "#{url_doc_id(id)}/append", json
    end
  end

  def get(id) do
    case get_raw(id) do
      {:ok, res} ->
        case Poison.decode(res.body) do
          {:ok, res} ->
            res
          {:err} -> nil
          {:error, :invalid} -> nil
        end
    end
  end

  def get_raw(id) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.get_raw(#{inspect(id)})")
    HTTPoison.get url_doc_id(id)
  end

  def prepend(id, doc) do
    case prepend_raw(id, doc) do
      {:ok, res} ->
        case Poison.decode(res.body) do
          {:ok, res} ->
            res
          _ -> nil
        end
    end
  end

  def prepend_raw(id, doc) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.prepend_raw(#{inspect(id)})")
    case Poison.encode(doc) do
      {:ok, json} -> HTTPoison.post "#{url_doc_id(id)}/prepend", json
    end
  end

  def remove(id) do
    case remove_raw(id) do
      {:ok, res} ->
        case Poison.decode(res.body) do
          {:ok, res} ->
            res
          _ -> nil
        end
    end
  end

  def remove_raw(id) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.remove_raw(#{inspect(id)})")
    HTTPoison.delete url_doc_id(id)
  end

  def replace(id, doc) do
    case replace_raw(id, doc) do
      {:ok, res} ->
        case Poison.decode(res.body) do
          {:ok, res} ->
            res
          _ -> nil
        end
    end
  end

  def replace_raw(id, doc) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.replace_raw(#{inspect(id)})")
    case Poison.encode(doc) do
      {:ok, json} -> HTTPoison.post "#{url_doc_id(id)}/replace", json
    end
  end

  def set(id, doc) do
    case set_raw(id, doc) do
      {:ok, res} ->
        case Poison.decode(res.body) do
          {:ok, res} ->
            res
          _ -> nil
        end
    end
  end

  def set_raw(id, doc) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.set_raw(#{inspect(id)})")
    case Poison.encode(doc) do
      {:ok, json} -> HTTPoison.post "#{url_doc_id(id)}/set", json
    end
  end

  def upsert(id, doc) do
    case upsert_raw(id, doc) do
      {:ok, res} ->
        case Poison.decode(res.body) do
          {:ok, res} ->
            res
          err ->
            Logger.debug(inspect(err))
            nil
        end
    end
  end

  def upsert_raw(id, doc) do
    Logger.debug("MicrocrawlerWebapp.Couchbase.upsert_raw(#{inspect(id)})")
    case Poison.encode(doc) do
      {:ok, json} -> HTTPoison.post("#{url_doc_id(id)}/upsert", json)
    end
  end

  defp bucket do
    Application.get_env(:microcrawler_webapp, Couchbase)[:bucket]
  end

  defp url() do
    Application.get_env(:microcrawler_webapp, Couchbase)[:url]
  end

  def url_doc() do
    "#{url}/bucket/#{bucket}/doc/"
  end

  def url_doc_id(id) do
    "#{url}/bucket/#{bucket}/doc/#{id}"
  end
end
