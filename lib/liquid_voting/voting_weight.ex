defmodule LiquidVoting.VotingWeight do
  @moduledoc """
  The VotingWeight context.
  """

  import Ecto.Query, warn: false

  alias LiquidVoting.{Repo, Voting}

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

    # IO.inspect(vote)

    # , vote.voting_method_id
    weight =
      1 + delegation_weight(voter.delegations_received, vote.proposal_url, vote.voting_method_id)

    IO.puts(">>> Final vote weight: #{weight} <<<")

    Voting.update_vote(vote, %{weight: weight})
  end

  # If no weight is given, adds default of 0 for it, and recurses with
  # delegation_weight/3. This is the starting point for traversing
  # a voter's delegation tree and incrementing the voting weight
  defp delegation_weight(delegations, proposal_url, voting_method_id, weight \\ 0)

  # Traverse up delegation tree and add up the accumulated weight.
  # If you're wondering, [_|_] matches a non-empty array. Equivalent to
  # matching [head|tail] but ignoring both head and tail variables
  defp delegation_weight(delegations = [_ | _], proposal_url, voting_method_id, weight) do
    IO.puts("***************************")
    IO.inspect(delegations)
    IO.inspect(proposal_url)
    IO.inspect(voting_method_id)
    IO.inspect(weight)

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
    Enum.reduce(delegations, weight, fn delegation, weight ->
      # Only proceed if delegation is global or is meant for the
      # proposal being voted on:

      # TODO: This need to involve delegation.voting_method IF proposal_url not nil

      if (delegation.proposal_url == proposal_url &&
            delegation.voting_method_id == voting_method_id) || delegation.proposal_url == nil do
        delegation = Repo.preload(delegation, delegator: :delegations_received)
        delegator = delegation.delegator

        weight = weight + 1

        delegation_weight(delegator.delegations_received, proposal_url, voting_method_id, weight)

        # If delegation is for a different proposal, just return the unchanged weight
      else
        weight
      end
    end)
  end

  # Base case for the above recursion:
  #
  # If no delegations left, just return the latest weight
  defp delegation_weight(_ = [], _, _, weight) do
    IO.puts(">>> No delegations left: final weight to add: #{weight} <<<")
    weight
  end
end
