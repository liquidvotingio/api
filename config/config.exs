# This configuration file is loaded before any dependency
use Mix.Config

config :liquid_voting,
  ecto_repos: [LiquidVoting.Repo]

config :liquid_voting, LiquidVoting.Repo, migration_primary_key: [name: :id, type: :binary_id]

config :liquid_voting, LiquidVotingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JnwIS2wvbN45zqsUjKCgZ1kq8ifWd4lsP08y89uFS5w3uHoFJ9UmdcgiFI3GcKBl",
  render_errors: [view: LiquidVotingWeb.ErrorView, accepts: ~w(json)],
  pubsub_server: LiquidVoting.PubSub

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# You can also supply opentelemetry resources using environment variables, eg.:
# OTEL_RESOURCE_ATTRIBUTES=service.name=name,service.namespace=namespace

config :opentelemetry, :resource,
  service: [
    name: "service-name",
    namespace: "service-namespace"
]

config :opentelemetry,
  processors: [
    otel_batch_processor: %{
      exporter:
        {OpenTelemetry.Honeycomb.Exporter, write_key: System.get_env("HONEYCOMB_WRITEKEY")}
    }
  ]
