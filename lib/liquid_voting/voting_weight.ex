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
    vote = Repo.preload(vote, [
      {:participant, [
        {:delegations_received, [
          {:delegator, :delegations_received}
        ]}
      ]}
    ])
    delegations = vote.participant.delegations_received

    weight = Enum.reduce delegations, 1, fn (delegation, weight) ->
      weight + delegator_vote_weight(delegation.delegator)
    end

    Voting.update_vote(vote, %{weight: weight})
  end

  defp delegator_vote_weight(delegator) do
    length(delegator.delegations_received) + 1
  end
end