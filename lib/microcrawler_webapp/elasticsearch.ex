defmodule MicrocrawlerWebapp.Elasticsearch do
  @moduledoc """
  TODO
  """
  require Logger

  alias MicrocrawlerWebapp.Elasticsearch
  alias Elastix.Document
  alias Elastix.Search

  def index(id, index_data, doc_type \\ get_doc_type()) do
    Document.index(
      get_elastic_url(), get_index_name(), doc_type, id, index_data
    )
  end

  def search(search_in, search_payload) do
    Search.search(
      get_elastic_url(), get_index_name(), search_in, search_payload
    )
  end

  def delete(id, doc_type \\ get_doc_type()) do
    Document.delete(get_elastic_url(), get_index_name(), doc_type, id)
  end

  defp get_elastic_url do
    Application.get_env(:microcrawler_webapp, Elasticsearch)[:url]
  end

  defp get_index_name do
    Application.get_env(:microcrawler_webapp, Elasticsearch)[:index]
  end

  defp get_doc_type do
    Application.get_env(:microcrawler_webapp, Elasticsearch)[:doc_type]
  end
end
