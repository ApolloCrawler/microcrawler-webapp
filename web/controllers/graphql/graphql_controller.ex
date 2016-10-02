defmodule MicrocrawlerWebapp.GraphqlController do
  use MicrocrawlerWebapp.Web, :controller

  def index(conn, %{"query" => query}) do
    res = GraphQL.execute(MicrocrawlerWebapp.TestSchema.schema, query)
    case res do
        {:ok, data} -> json conn, data
        {:error, %{:errors => errors}} -> json conn, %{:errors => errors}
        {:error, errors} -> json conn, %{:errors => errors}
    end
  end

  def index(conn, params) do
    IO.inspect params
    json conn, %{}
  end
end
