defmodule LiquidVotingWeb.Absinthe.Mutations.CreateDelegation.AfterCreatingrelatedVotesTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "create global and proposal-specific delegations" do
    # Currently skipped because create_delegation does not update voting results
    # by calling calculate_result! (See #52)
    @tag :skip
    test "when created after related proposal votes" do
      # Create vote_A and get related participant and proposal_url.
      vote_A = insert(:vote, yes: true)

      participant_A = vote_A.participant
      proposal_A_url = vote_A.proposal_url

      # Create vote_B and get related participant asnd proposal_url
      vote_B = insert(:vote, yes: false, organization_id: vote_A.organization_id)

      participant_B = vote_B.participant
      proposal_B_url = vote_B.proposal_url

      delegator = insert(:participant, organization_id: vote_A.organization_id)

      # create global delegation to participant_A (as delegate)
      #
      # This setup step needs to involve a call to create_delegation, as simply
      # inserting a factory delegation cannot be expected to call
      # calculate_result!, and thus we could not test the expected result is
      # returned in the final related query. Thus, an absinthe mutation is used.
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{delegator.email}", delegateEmail: "#{
        participant_A.email
      }") {
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: vote_A.organization_id})

      assert delegation["delegator"]["email"] == delegator.email
      assert delegation["delegate"]["email"] == participant_A.email

      # create proposal_B_url delegation to participant_B (as delegate)
      #
      # This setup step needs to involve a call to create_delegation, as simply
      # inserting a factory delegation cannot be expected to call
      # calculate_result!, and thus we could not test the expected result is
      # returned in the final related query. Thus, an absinthe mutation is used.

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{delegator.email}", delegateEmail: "#{
        participant_B.email
      }", proposalUrl: "#{proposal_B_url}") {
          delegator {
            email
          }
          delegate {
            email
          }
          proposalUrl
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: vote_A.organization_id})

      assert delegation["delegator"]["email"] == delegator.email
      assert delegation["delegate"]["email"] == participant_B.email
      assert delegation["proposalUrl"] == proposal_B_url

      # Get result for proposal_A_url (should be 'in favor == 2')
      query = """
      query {
        votingResult(proposalUrl: "#{proposal_A_url}") {
          inFavor
          against
          proposalUrl
        }
      }
      """

      {:ok, %{data: %{"votingResult" => result}}} =
        Absinthe.run(query, Schema, context: %{organization_id: vote_A.organization_id})

      assert result["proposalUrl"] == proposal_A_url
      assert result["votingResult"]["inFavor"] == 2
      assert result["votingResult"]["against"] == 0

      # Get result for proposal_B_url (should be 'against == 2')
    end
  end
end
