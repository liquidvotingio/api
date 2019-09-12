use Mix.Config

# Configure your database
config :liquid_voting, LiquidVoting.Repo,
  username: "postgres",
  password: "postgres",
  database: "liquid_voting_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :liquid_voting, LiquidVotingWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
