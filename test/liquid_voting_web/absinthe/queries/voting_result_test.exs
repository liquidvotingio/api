defmodule LiquidVotingWeb.Absinthe.Queries.VotingResultTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "query voting result" do
    test "for a given proposal url" do
      result = insert(:voting_result)

      query = """
      query {
        votingResult(proposalUrl: "#{result.proposal_url}") {
          yes
          no
          proposalUrl
        }
      }
      """

      {:ok, %{data: %{"votingResult" => result_payload}}} = Absinthe.run(query, Schema, context: %{organization_uuid: Ecto.UUID.generate})

      assert result_payload["yes"] == result.yes
      assert result_payload["no"] == result.no
      assert result_payload["proposalUrl"] == result.proposal_url
    end
  end
end