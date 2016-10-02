defmodule MicrocrawlerWebapp.GraphqlController do
  use MicrocrawlerWebapp.Web, :controller

  def index(conn, %{"query" => query}) do
    res = GraphQL.execute(MicrocrawlerWebapp.TestSchema.schema, query)
    case res do
        {:ok, data} -> json conn, data
        {:error, reasons} -> json conn, %{:errors => reasons}
    end
  end

  def index(conn, params) do
    IO.inspect params
    json conn, %{}
  end
end
