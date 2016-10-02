defmodule MicrocrawlerWebapp.GraphqlController do
  use MicrocrawlerWebapp.Web, :controller

  def index(conn, %{"query" => query}) do
    {:ok, data} = GraphQL.execute(MicrocrawlerWebapp.TestSchema.schema, query)
    json conn, data
  end

  def index(conn, params) do
    IO.inspect params
    json conn, %{id: 1}
  end
end
