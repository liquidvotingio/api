defmodule LiquidVotingWeb.Absinthe.Mutations.CreateDelegation.BeforeCreatingRelatedVotesTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "create proposal-specific delegation" do
    test "before creating related vote for delegator" do
      organization_id = Ecto.UUID.generate()
      voting_method = insert(:voting_method, organization_id: organization_id)

      delegation =
        insert(:delegation_for_proposal,
          voting_method: voting_method,
          organization_id: organization_id
        )

      # Create vote by delegator and get details in queries.
      query = """
      mutation {
        createVote(participantEmail: "#{delegation.delegator.email}", votingMethod: "#{
        voting_method.name
      }", proposalUrl: "#{delegation.proposal_url}", yes: true) {
          proposalUrl
          participant {
            email
          }
          yes
          votingResult {
            inFavor
            against
          }
          votingMethod {
            name
          }
        }
      }
      """

      {:ok, %{data: %{"createVote" => vote}}} =
        Absinthe.run(query, Schema, context: %{organization_id: organization_id})

      assert vote["proposalUrl"] == delegation.proposal_url
      assert vote["participant"]["email"] == delegation.delegator.email
      assert vote["yes"] == true
      assert vote["votingResult"]["inFavor"] == 1
      assert vote["votingResult"]["against"] == 0
      assert vote["votingMethod"]["name"] == voting_method.name
    end

    test "before creating related vote for delegate" do
      organization_id = Ecto.UUID.generate()
      voting_method = insert(:voting_method, organization_id: organization_id)

      delegation =
        insert(:delegation_for_proposal,
          voting_method: voting_method,
          organization_id: organization_id
        )

      # Create vote by delegator and get details in queries.
      query = """
      mutation {
        createVote(participantEmail: "#{delegation.delegate.email}", votingMethod: "#{
        voting_method.name
      }", proposalUrl: "#{delegation.proposal_url}", yes: true) {
          proposalUrl
          participant {
            email
          }
          yes
          votingResult {
            inFavor
            against
          }
          votingMethod {
            name
          }
        }
      }
      """

      {:ok, %{data: %{"createVote" => vote}}} =
        Absinthe.run(query, Schema, context: %{organization_id: organization_id})

      assert vote["proposalUrl"] == delegation.proposal_url
      assert vote["participant"]["email"] == delegation.delegate.email
      assert vote["yes"] == true
      assert vote["votingResult"]["inFavor"] == 2
      assert vote["votingResult"]["against"] == 0
      assert vote["votingMethod"]["name"] == voting_method.name
    end
  end
end
