# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :twinkly_maha, TwinklyMahaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Kvx4WCG57Wq4GMXuYWddoLL3N1aUrto576ET6szpLd1m6dqSmQ4VmquJTB7uIJ1W",
  render_errors: [view: TwinklyMahaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TwinklyMaha.PubSub,
  live_view: [signing_salt: "Znb5qa77"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :twinkly_maha,
  deploy_env: System.get_env("DEPLOY_ENV", "local")

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# esbuild config
config :esbuild,
  version: "0.14.14",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

rand_suffix = :crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower)

config :twinkly_maha, Emqtt.Hivemq,
  host: ~c"#{System.fetch_env!("HIVEMQ_HOST")}",
  port: String.to_integer(System.fetch_env!("HIVEMQ_PORT")),
  client_id: System.fetch_env!("HIVEMQ_CLIENT_ID") <> rand_suffix,
  clean_start: false

rand_suffix = :crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower)

config :twinkly_maha, Emqtt.Emqx,
  host: ~c"#{System.fetch_env!("MQTT_HOST")}",
  port: String.to_integer(System.fetch_env!("MQTT_PORT")),
  client_id: System.fetch_env!("CLIENT_ID") <> rand_suffix,
  clean_start: false

# name = String.to_atom(System.fetch_env!("USER_NAME"))

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
