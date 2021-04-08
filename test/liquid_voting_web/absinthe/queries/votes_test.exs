defmodule LiquidVotingWeb.Absinthe.Queries.VotesTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "query votes" do
    setup do
      org_id = Ecto.UUID.generate()
      # We create 3 votes for the same organization.
      #    Including, 2 votes for the same proposal url and voting method:
      voting_method_A = insert(:voting_method, name: "methodA", organization_id: org_id)

      insert(:vote,
        proposal_url: "https://proposals/p1",
        voting_method: voting_method_A,
        organization_id: org_id
      )

      insert(:vote,
        proposal_url: "https://proposals/p1",
        voting_method: voting_method_A,
        organization_id: org_id
      )

      #    ... and 1 vote for the same proposal url, but "default" voting method:
      voting_method_default = insert(:voting_method, name: "default", organization_id: org_id)

      insert(:vote,
        proposal_url: "https://proposals/p1",
        voting_method: voting_method_default,
        organization_id: org_id
      )

      # We create 1 vote for a different organization:
      insert(:vote,
        proposal_url: "https://proposals/p1",
        voting_method: voting_method_A,
        organization_id: Ecto.UUID.generate()
      )

      [
        organization_id: org_id
      ]
    end

    test "without a proposal url or voting_method", context do
      query = """
      query {
        votes {
          id
          proposalUrl
          votingMethod{
            name
          }
        }
      }
      """

      {:ok, %{data: %{"votes" => result_payload}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      # Assert we retrieve results for 3 votes for same organization, created in setup,
      # and not 4 (excluding the vote created in setup for a different organization).
      assert Enum.count(result_payload) == 3
    end

    test "for a proposal url and voting_method", context do
      query = """
      query {
        votes(votingMethod: "methodA", proposal_url: "https://proposals/p1") {
          id
          proposalUrl
          votingMethod{
            name
          }
        }
      }
      """

      {:ok, %{data: %{"votes" => result_payload}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      # Assert we retrieve results for 2 votes for same voting method.
      assert Enum.count(result_payload) == 2
      # Assert both votes are for the correct voting method.
      assert Enum.at(result_payload, 0)["votingMethod"]["name"] == "methodA"
      assert Enum.at(result_payload, 1)["votingMethod"]["name"] == "methodA"
    end

    test "for a proposal url only", context do
      query = """
      query {
        votes(proposal_url: "https://proposals/p1") {
          id
          proposalUrl
          votingMethod{
            name
          }
        }
      }
      """

      {:ok, %{data: %{"votes" => result_payload}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      # Assert we retrieve results for 1 vote
      assert Enum.count(result_payload) == 1
      # Assert the vote is for the "default" voting method.
      assert Enum.at(result_payload, 0)["votingMethod"]["name"] == "default"
    end

    test "for a non-existent proposal url", context do
      query = """
      query {
        votes(proposal_url: "https://proposals/non-existent") {
          id
          proposalUrl
          votingMethod{
            name
          }
        }
      }
      """

      {:ok, %{data: %{"votes" => result_payload}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      IO.inspect(result_payload)

      # Assert we retrieve an empty list
      assert result_payload == []
    end

    test "for a valid proposal url and non-existent voting method", context do
      query = """
      query {
        votes(votingMethod: "non-existent-method", proposal_url: "https://proposals/p1") {
          id
          proposalUrl
          votingMethod{
            name
          }
        }
      }
      """

      {:ok, %{data: %{"votes" => result_payload}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      # Assert we retrieve an empty list
      assert result_payload == []
    end

    test "for a voting method, with no proposal url specified", context do
      query = """
      query {
        votes(votingMethod: "methodA") {
          id
          proposalUrl
          votingMethod{
            name
          }
        }
      }
      """

      {:ok, %{errors: [%{message: message}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      # Assert we receive the correct error message.
      assert message == "A proposal url must also be given when a voting method is specified"
    end
  end
end
