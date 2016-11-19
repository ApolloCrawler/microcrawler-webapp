# For more details see https://github.com/graphql-elixir/graphql

defmodule MicrocrawlerWebapp.TestSchema do
  @moduledoc """
  TODO
  """

  alias MicrocrawlerWebapp.TestSchema

  def schema do
    %GraphQL.Schema{
      query: %GraphQL.Type.ObjectType{
        name: "RootQueryType",
        fields: %{
          greeting: %{
            type: %GraphQL.Type.String{},
            resolve: &TestSchema.greeting/3,
            description: "Greeting",
            args: %{
              name: %{
                type: %GraphQL.Type.String{},
                description: "The name of who you'd like to greet."
              },
            }
          }
        }
      }
    }
  end

  def greeting(_, %{name: name}, _), do: "Hello, #{name}!"
  def greeting(_, _, _), do: "Hello, world!"
end
