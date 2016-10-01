use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :microcrawler_webapp, MicrocrawlerWebapp.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :microcrawler_webapp, MicrocrawlerWebapp.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "microcrawler_webapp_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
