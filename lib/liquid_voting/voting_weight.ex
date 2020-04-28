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
    # :force it because sometimes votes come in with stale associations
    vote = Repo.preload(vote, [participant: :delegations_received], force: true)    
    voter = vote.participant
    
    weight = 1 + delegation_weight(voter.delegations_received)

    Voting.update_vote(vote, %{weight: weight})
  end

  # If no weight is given, default to 0 and recurse
  defp delegation_weight(delegations, weight \\ 0)

  # Traverse up delegation tree and add up the accumulated weight.
  # If you're wondering, [_|_] matches a non-empty array. Equivalent to 
  # matching [head|tail] but ignoring both head and tail variables
  defp delegation_weight(delegations = [_|_], weight) do
    # TODO: Do this in SQL
    #
    #   Not sure yet which tree/hierarchy handling pattern would fit here, 
    #   given there's two tables involved instead of a single one nested onto itself as
    #   in most threaded Comments or Org Chart examples.
    #
    #   Recursive Query might be worth a try, check back with Bill Karwin's SQL Antipatterns book
    #
    # END TODO
    #
    # Add-up 1 unit of weight for each delegation,
    # then recurse on each delegators' own delegations
    Enum.reduce delegations, weight, fn (delegation, weight) ->
      delegation = Repo.preload(delegation, [delegator: :delegations_received])
      delegator = delegation.delegator

      weight = weight + 1

      delegation_weight(delegator.delegations_received, weight)
    end
  end

  # Base case for the above recursion:
  # 
  # If no delegations left, just return the latest weight
  defp delegation_weight(_ = [], weight) do
    weight
  end
end