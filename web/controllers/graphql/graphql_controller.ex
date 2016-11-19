defmodule MicrocrawlerWebapp.GraphqlController do
  use MicrocrawlerWebapp.Web, :controller

  alias MicrocrawlerWebapp.TestSchema

  def index(conn, %{"query" => query}) do
    res = GraphQL.execute(TestSchema.schema, query)
    case res do
        {:ok, data} -> json conn, data
        {:error, %{:errors => errors}} -> json conn, %{:errors => errors}
        {:error, errors} -> json conn, %{:errors => errors}
    end
  end

  def index(conn, _params) do
    # IO.inspect params
    json conn, %{}
  end
end
