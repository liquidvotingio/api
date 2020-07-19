defmodule LiquidVotingWeb.Router do
  use LiquidVotingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug LiquidVotingWeb.Plugs.Context
  end

  scope "/" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: LiquidVotingWeb.Schema.Schema,
      socket: LiquidVotingWeb.UserSocket,
      interface: :advanced

    forward "/", Absinthe.Plug, schema: LiquidVotingWeb.Schema.Schema
  end
end
