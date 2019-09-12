import Config

# ecto://USER:PASS@HOST/DATABASE
database_url = System.fetch_env!("DATABASE_URL") 

config :liquid_voting, LiquidVoting.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")

config :liquid_voting, LiquidVotingWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base

# to test the release locally:
# $ SECRET_KEY_BASE=$(mix phx.gen.secret) DATABASE_URL=ecto://postgres:postgres@localhost/liquid_voting_dev _build/prod/rel/liquid_voting/bin/liquid_voting start
