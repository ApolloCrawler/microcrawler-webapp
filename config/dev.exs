use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :microcrawler_webapp, MicrocrawlerWebapp.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../", __DIR__)]]


# Watch static and templates for browser reloading.
config :microcrawler_webapp, MicrocrawlerWebapp.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your AMQP
config :amqp,
  username: System.get_env("AMQP_USERNAME") || "guest",
  password: System.get_env("AMQP_PASSWORD") || "guest",
  vhost: System.get_env("AMQP_VHOST") || "/",
  hostname: System.get_env("AMQP_HOSTNAME") || "localhost"

config :microcrawler_webapp, MicrocrawlerWebapp.Couchbase,
  url: System.get_env("GAUC_URL") || "http://localhost:5000",
  bucket: System.get_env("GAUC_BUCKET") || "default"

config :microcrawler_webapp, MicrocrawlerWebapp.Elasticsearch,
  url: System.get_env("ELASTIC_URL") || "http://elastic:changeme@localhost:9200",
  index: System.get_env("ELASTIC_INDEX") || "default",
  doc_type: System.get_env("ELASTIC_DOC_TYPE") || "default"
