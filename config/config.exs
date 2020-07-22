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

config :prometheus, LiquidVoting.Metrics.PipelineInstrumenter,
  labels: [:status_class, :method, :host, :scheme, :request_path],
  duration_buckets: [
    10,
    100,
    1_000,
    10_000,
    100_000,
    300_000,
    500_000,
    750_000,
    1_000_000,
    1_500_000,
    2_000_000,
    3_000_000
  ],
  registry: :default,
  duration_unit: :microseconds

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
