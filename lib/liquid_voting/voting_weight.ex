defmodule LiquidVoting.VotingWeight do
  @moduledoc """
  The VotingWeight context.
  """

  import Ecto.Query, warn: false
  alias LiquidVoting.Repo

  alias LiquidVoting.Voting

  @doc """
  Updates vote weight based on delegations given to voter

  ## Examples

      iex> update_vote_weight(vote)
      {:ok, %Vote{}}

      iex> update_vote_weight(vote)
      {:error, %Ecto.Changeset{}}

  """
  def update_vote_weight(vote) do
    vote = Repo.preload(vote, participant: :delegations_received)    
    voter = vote.participant
    
    weight = 1 + delegation_weight(voter.delegations_received)

    Voting.update_vote(vote, %{weight: weight})
  end

  defp delegation_weight(delegations, weight \\ 0)

  defp delegation_weight(delegations = [_|_], weight) do
    # TODO: Do this in SQL
    #
    #   Not sure yet which tree/hierarchy handling pattern would fit here, 
    #   given there's two tables involved instead a single one nested onto itself as
    #   in most threaded Comments or Org Chart examples.
    #
    #   Recursive Query might be worth a try, check back with Bill Karwin's SQL Antipatterns book
    #
    Enum.reduce delegations, weight, fn (delegation, weight) ->
      delegation = Repo.preload(delegation, [delegator: :delegations_received])
      delegator = delegation.delegator

      weight = weight + 1

      delegation_weight(delegator.delegations_received, weight)
    end
  end

  defp delegation_weight(_ = [], weight) do
    weight
  end
end