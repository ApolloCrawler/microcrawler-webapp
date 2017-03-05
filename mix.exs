defmodule MicrocrawlerWebapp.Mixfile do
  use Mix.Project

  def project do
    [app: :microcrawler_webapp,
     version: "0.0.2",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {MicrocrawlerWebapp, []},
      # TODO: Try to keep in
      applications: [
        :elastix,
        :graphql,
        :phoenix,
        # :phoenix_pubsub_rabbitmq,
        :phoenix_pubsub,
        :phoenix_html,
        :cowboy,
        :logger,
        :gettext,
        :phoenix_ecto,
        :amqp,
        :httpoison
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:comeonin, "~> 2.3"},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:dialyxir, "~> 0.3.5", only: [:dev]},
      {:elastix, "~> 0.2.0"},
      {:graphql, "~> 0.3"},
      {:guardian, "~> 0.13.0"},
      {:httpoison, "~> 0.9.2"},
      {:phoenix, "~> 1.2.1", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:poison, "~> 2.2.0", override: true},
      {:poolboy, "~> 1.5.1", override: true},
      {:uuid, "~> 1.1" },
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:amqp_client, git: "https://github.com/jbrisbin/amqp_client.git", override: true},
      {:amqp, "~> 0.1.4"},
      {:execjs, "~> 1.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
