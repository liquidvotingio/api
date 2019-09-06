defmodule LiquidDem.Repo do
  use Ecto.Repo,
    otp_app: :liquid_dem,
    adapter: Ecto.Adapters.Postgres
end
