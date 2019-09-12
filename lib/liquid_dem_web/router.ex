defmodule LiquidDemWeb.Router do
  use LiquidDemWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward "/api", Absinthe.Plug,
      schema: LiquidDemWeb.Schema.Schema

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: LiquidDemWeb.Schema.Schema,
      socket: LiquidDemWeb.UserSocket,
      interface: :simple
  end
end
