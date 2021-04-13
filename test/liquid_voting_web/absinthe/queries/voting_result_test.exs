defmodule LiquidVotingWeb.Absinthe.Queries.VotingResultTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "query voting result" do
    test "for a given proposal url and voting_method name" do
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

    test "for a given proposal url, without voting_method name, when a 'default' voting method exists" do
      voting_method = insert(:voting_method, name: "default")

      result =
        insert(:voting_result,
          voting_method: voting_method,
          organization_id: voting_method.organization_id
        )

      query = """
      query {
        votingResult(proposalUrl: "#{result.proposal_url}") {
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

    test "for a given proposal url, without voting_method name, when no 'default' voting method exists" do
      voting_method = insert(:voting_method, name: "specific_voting_method")

      result =
        insert(:voting_result,
          voting_method: voting_method,
          organization_id: voting_method.organization_id
        )

      query = """
      query {
        votingResult(proposalUrl: "#{result.proposal_url}") {
          in_favor
          against
          proposalUrl
        }
      }
      """

      {:ok, %{errors: [%{message: message}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: result.organization_id})

      assert message == "No matching result found"
    end
  end
end
