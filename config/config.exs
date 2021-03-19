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

config :opentelemetry,
  processors: [
    otel_batch_processor: %{
      exporter:
        {OpenTelemetry.Honeycomb.Exporter,
         write_key: "520527fcecf7c6b38bd1775da111ead3", dataset: "api-telemetry"}
    }
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
