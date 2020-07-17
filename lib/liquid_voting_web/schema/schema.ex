defmodule LiquidVotingWeb.Schema.Schema do
  use Absinthe.Schema
  alias LiquidVoting.{Voting, VotingResults}

  import_types(Absinthe.Type.Custom)
  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 3]

  alias LiquidVotingWeb.Resolvers

  query do
    @desc "Get a voting result by its proposal url"
    field :voting_result, :result do
      arg(:proposal_url, non_null(:string))
      resolve(&Resolvers.VotingResults.result/3)
    end

    @desc "Get a list of participants"
    field :participants, list_of(:participant) do
      resolve(&Resolvers.Voting.participants/3)
    end

    @desc "Get a participant by its id"
    field :participant, :participant do
      arg(:id, non_null(:string))
      resolve(&Resolvers.Voting.participant/3)
    end

    @desc "Get a list of votes"
    field :votes, list_of(:vote) do
      resolve(&Resolvers.Voting.votes/3)
    end

    @desc "Get a vote by its id"
    field :vote, :vote do
      arg(:id, non_null(:string))
      resolve(&Resolvers.Voting.vote/3)
    end

    @desc "Get a list of delegations"
    field :delegations, list_of(:delegation) do
      resolve(&Resolvers.Delegations.delegations/3)
    end

    @desc "Get a delegation by its id"
    field :delegation, :delegation do
      arg(:id, non_null(:string))
      resolve(&Resolvers.Delegations.delegation/3)
    end
  end

  mutation do
    @desc "Create a participant"
    field :create_participant, :participant do
      arg(:name, non_null(:string))
      arg(:email, non_null(:string))
      resolve(&Resolvers.Voting.create_participant/3)
    end

    @desc "Delete a participant"
    field :delete_participant, :participant do
      arg(:participant_email, non_null(:string))
      resolve(&Resolvers.Voting.delete_participant/3)
    end

    @desc "Create a vote for a proposal"
    field :create_vote, :vote do
      arg(:proposal_url, non_null(:string))
      arg(:participant_id, :string)
      arg(:participant_email, :string)
      arg(:yes, non_null(:boolean))
      resolve(&Resolvers.Voting.create_vote/3)
    end

    @desc "Delete a vote for a proposal"
    field :delete_vote, :vote do
      arg(:proposal_url, non_null(:string))
      arg(:participant_id, :string)
      arg(:participant_email, :string)
      resolve(&Resolvers.Voting.delete_vote/3)
    end

    @desc "Create a delegation"
    field :create_delegation, :delegation do
      arg(:delegator_id, :string)
      arg(:delegate_id, :string)
      arg(:delegator_email, :string)
      arg(:delegate_email, :string)
      arg(:proposal_url, :string)
      resolve(&Resolvers.Delegations.create_delegation/3)
    end

    @desc "Delete a delegation"
    field :delete_delegation, :delegation do
      arg(:delegator_id, :string)
      arg(:delegate_id, :string)
      arg(:delegator_email, :string)
      arg(:delegate_email, :string)
      arg(:proposal_url, :string)
      resolve(&Resolvers.Delegations.delete_delegation/3)
    end
  end

  subscription do
    @desc "Subscribe to voting results changes for a proposal"
    field :voting_result_change, :result do
      arg(:proposal_url, non_null(:string))

      config(fn args, _res ->
        {:ok, topic: args.proposal_url}
      end)
    end
  end

  object :participant do
    field :id, non_null(:string)
    field :name, :string
    field :email, non_null(:string)

    field :delegations_received, list_of(:delegation),
      resolve:
        dataloader(Voting, :delegations_received,
          args: %{scope: :participant, foreign_key: :delegate_id}
        )
  end

  object :vote do
    field :id, non_null(:string)
    field :yes, non_null(:boolean)
    field :weight, non_null(:integer)
    field :proposal_url, non_null(:string)
    field :participant, non_null(:participant), resolve: dataloader(Voting)

    field :voting_result, :result,
      resolve: fn vote, _, _ ->
        {:ok, VotingResults.get_result_by_proposal_url(vote.proposal_url, vote.organization_id)}
      end
  end

  object :delegation do
    field :id, non_null(:string)
    field :delegator, non_null(:participant), resolve: dataloader(Voting)
    field :delegate, non_null(:participant), resolve: dataloader(Voting)
    field :proposal_url, :string

    field :voting_result, :result,
      resolve: fn delegation, _, _ ->
        if delegation.proposal_url do
          {:ok,
           VotingResults.get_result_by_proposal_url(
             delegation.proposal_url,
             delegation.organization_id
           )}
        else
          {:ok, nil}
        end
      end
  end

  object :result do
    field :id, non_null(:string)
    field :in_favor, non_null(:integer)
    field :against, non_null(:integer)
    field :proposal_url, non_null(:string)
  end

  def context(ctx) do
    source = Dataloader.Ecto.new(LiquidVoting.Repo)

    loader =
      Dataloader.new()
      |> Dataloader.add_source(Voting, source)
      |> Dataloader.add_source(Delegations, source)

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
