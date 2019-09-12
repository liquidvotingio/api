defmodule LiquidVoting.Repo do
  use Ecto.Repo,
    otp_app: :liquid_voting,
    adapter: Ecto.Adapters.Postgres
end
