defmodule LiquidVotingWeb.Resolvers.VotingResults do
  alias LiquidVoting.VotingResults

  def result(_, %{proposal_url: proposal_url}, %{context: %{org_uuid: org_uuid}}) do
    {:ok, VotingResults.get_result_by_proposal_url(proposal_url, org_uuid)}
  end
end