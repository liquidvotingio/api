defmodule LiquidVotingWeb.Resolvers.VotingResults do
  alias LiquidVoting.VotingResults

  def result(_, %{proposal_url: proposal_url}, %{context: %{organization_uuid: organization_uuid}}),
      do: {:ok, VotingResults.get_result_by_proposal_url(proposal_url, organization_uuid)}
end
