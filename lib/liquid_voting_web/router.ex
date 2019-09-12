defmodule LiquidVotingWeb.Router do
  use LiquidVotingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward "/api", Absinthe.Plug,
      schema: LiquidVotingWeb.Schema.Schema

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: LiquidVotingWeb.Schema.Schema,
      socket: LiquidVotingWeb.UserSocket,
      interface: :simple
  end
end
