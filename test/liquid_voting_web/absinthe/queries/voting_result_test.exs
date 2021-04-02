defmodule LiquidVotingWeb.Absinthe.Queries.VotingResultTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "query voting result" do
    test "for a given proposal url" do
      result = insert(:voting_result)

      query = """
      query {
        votingResult(votingMethod: "#{result.voting_method.name}", proposalUrl: "#{
        result.proposal_url
      }") {
          in_favor
          against
          proposalUrl
        }
      }
      """

      {:ok, %{data: %{"votingResult" => result_payload}}} =
        Absinthe.run(query, Schema, context: %{organization_id: result.organization_id})

      assert result_payload["in_favor"] == result.in_favor
      assert result_payload["against"] == result.against
      assert result_payload["proposalUrl"] == result.proposal_url
    end
  end
end
