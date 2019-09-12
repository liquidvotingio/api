defmodule LiquidDemWeb.Schema.Schema do
  use Absinthe.Schema
  alias LiquidDem.Voting

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

    @desc "Get a list of votes"
    field :votes, list_of(:vote) do
      resolve &Resolvers.Voting.votes/3
    end

    @desc "Get a vote by its id"
    field :vote, :vote do
      arg :id, non_null(:id)
      resolve &Resolvers.Voting.vote/3
    end

    @desc "Get a list of delegations"
    field :delegations, list_of(:delegation) do
      resolve &Resolvers.Voting.delegations/3
    end

    @desc "Get a delegation by its id"
    field :delegation, :delegation do
      arg :id, non_null(:id)
      resolve &Resolvers.Voting.delegation/3
    end
  end

  mutation do
    @desc "Create a vote for a proposal"
    field :create_vote, :vote do
      arg :proposal_id, non_null(:id)
      arg :participant_id, non_null(:id)
      arg :yes, non_null(:boolean)
      resolve &Resolvers.Voting.create_vote/3
    end

    @desc "Create a delegation for a proposal"
    field :create_delegation, :delegation do
      arg :proposal_id, non_null(:id)
      arg :delegator_id, non_null(:id)
      arg :delegate_id, non_null(:id)
      resolve &Resolvers.Voting.create_delegation/3
    end
  end

  subscription do
    @desc "Subscribe to voting results changes for a proposal"
    field :voting_result_change, :result do
      arg :proposal_id, non_null(:id)
      config fn args, _res ->
        {:ok, topic: args.proposal_id}
      end
    end
  end

  object :participant do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :delegations_received, list_of(:delegation),
      resolve: dataloader(Voting, :delegations_received, args: %{scope: :participant, foreign_key: :delegate_id})
  end

  object :proposal do
    field :id, non_null(:id)
    field :url, non_null(:string)
  end

  object :vote do
    field :id, non_null(:id)
    field :yes, non_null(:boolean)
    field :weight, non_null(:integer)
    field :proposal, non_null(:proposal), resolve: dataloader(Voting)
    field :participant, non_null(:participant), resolve: dataloader(Voting)
  end

  object :delegation do
    field :id, non_null(:id)
    field :delegator, non_null(:participant), resolve: dataloader(Voting)
    field :delegate, non_null(:participant), resolve: dataloader(Voting)
  end

  object :result do
    field :id, non_null(:id)
    field :yes, non_null(:integer)
    field :no, non_null(:integer)
    field :proposal, non_null(:proposal), resolve: dataloader(Voting)
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
