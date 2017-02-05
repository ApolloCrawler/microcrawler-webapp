# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :guardian, Guardian,
  issuer: "MicrocrawlerWebapp",
  hooks: MicrocrawlerWebapp.GuardianSerializer,
  ttl: {5, :minutes},
  verify_issuer: true,
  secret_key: "not so secret key",
  serializer: MicrocrawlerWebapp.GuardianSerializer

# Configures the endpoint
config :microcrawler_webapp, MicrocrawlerWebapp.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "I8KYfnxoW5r+uZQwmqxFrbVsZSm9QdNfqTWdhMo7Mkey2hzSYnr9eGh/xi88Sou7",
  render_errors: [view: MicrocrawlerWebapp.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MicrocrawlerWebapp.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
