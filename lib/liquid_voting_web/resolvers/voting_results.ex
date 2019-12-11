defmodule LiquidVotingWeb.Resolvers.VotingResults do
  alias LiquidVoting.VotingResults

  def result(_, %{proposal_url: proposal_url}, _) do
    {:ok, VotingResults.get_result_by_proposal_url(proposal_url)}
  end
end