# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :liquid_voting,
  ecto_repos: [LiquidVoting.Repo]

# Configures the endpoint
config :liquid_voting, LiquidVotingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JnwIS2wvbN45zqsUjKCgZ1kq8ifWd4lsP08y89uFS5w3uHoFJ9UmdcgiFI3GcKBl",
  render_errors: [view: LiquidVotingWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: LiquidVoting.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
