defmodule LiquidDemWeb.Schema.Schema do
  use Absinthe.Schema
  alias LiquidDem.{Voting, VotingResults}

  import_types Absinthe.Type.Custom
  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 3]

  alias LiquidDemWeb.Resolvers

  query do
    @desc "Get a list of participants"
    field :participants, list_of(:participant) do
      resolve &Resolvers.Voting.participants/3
    end

    @desc "Get a participant by its id"
    field :participant, :participant do
      arg :id, non_null(:id)
      resolve &Resolvers.Voting.participant/3
    end

    @desc "Get a list of proposals"
    field :proposals, list_of(:proposal) do
      resolve &Resolvers.Voting.proposals/3
    end

    @desc "Get a proposal by its id"
    field :proposal, :proposal do
      arg :id, non_null(:id)
      resolve &Resolvers.Voting.proposal/3
    end

    @desc "Get a list of votess"
    field :votes, list_of(:vote) do
      resolve &Resolvers.Voting.votes/3
    end

    @desc "Get a vote by its id"
    field :vote, :vote do
      arg :id, non_null(:id)
      resolve &Resolvers.Voting.vote/3
    end
  end

  object :participant do
    field :id, non_null(:id)
    field :name, non_null(:string)
  end

  object :proposal do
    field :id, non_null(:id)
    field :url, non_null(:string)
  end

  object :vote do
    field :id, non_null(:id)
    field :yes, non_null(:boolean)
    field :proposal, non_null(:proposal), resolve: dataloader(Voting)
    field :participant, non_null(:participant), resolve: dataloader(Voting)
  end

  def context(ctx) do
    source = Dataloader.Ecto.new(LiquidDem.Repo)

    loader =
      Dataloader.new
      |> Dataloader.add_source(Voting, source)

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
