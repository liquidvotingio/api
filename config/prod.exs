use Mix.Config

config :liquid_voting, LiquidVotingWeb.Endpoint,
  url: [
    host: System.fetch_env!("APP_HOSTNAME"),
    port: String.to_integer(System.fetch_env!("APP_PORT"))
  ],
  server: true

config :logger, level: :info

config :liquid_voting, LiquidVotingWeb.Endpoint, server: true


