defmodule LiquidDemWeb.Schema.Schema do
  use Absinthe.Schema
  alias LiquidDem.{Voting, VotingResults}

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

    @desc "Get a list of participants"
    field :proposals, list_of(:proposal) do
      resolve &Resolvers.Voting.proposals/3
    end

    @desc "Get a proposal by its id"
    field :proposal, :proposal do
      arg :id, non_null(:id)
      resolve &Resolvers.Voting.proposal/3
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
end
