use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :microcrawler_webapp, MicrocrawlerWebapp.Endpoint,
  secret_key_base: "idp4gK1qNO+lkycasJP4ouLM+uiHYJNkRpwAlB99DSRkNYfY7+w2+us2/NVPqphb"

# Configure your database
config :microcrawler_webapp, MicrocrawlerWebapp.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "microcrawler_webapp_prod",
  pool_size: 20
