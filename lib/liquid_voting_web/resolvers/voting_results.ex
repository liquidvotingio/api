defmodule LiquidVotingWeb.Resolvers.VotingResults do
  alias LiquidVoting.{VotingMethods, VotingResults}

  def result(_, %{proposal_url: proposal_url} = args, %{
        context: %{organization_id: organization_id}
      }) do
    voting_method_name = Map.get(args, :voting_method) || "default"
    voting_method = VotingMethods.get_voting_method_by_name!(voting_method_name, organization_id)

    {:ok,
     VotingResults.get_result_by_proposal_url(voting_method.id, proposal_url, organization_id)}
  rescue
    Ecto.NoResultsError -> {:error, message: "No matching result found"}
  end
end
