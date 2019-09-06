defmodule LiquidDemWeb.Router do
  use LiquidDemWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LiquidDemWeb do
    pipe_through :api
  end
end
