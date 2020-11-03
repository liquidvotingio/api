defmodule LiquidVotingWeb.Absinthe.Mutations.CreateDelegation.AfterCreatingRelatedVotesTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "create proposal-specific delegation" do
    test "after creating related proposal vote by delegate" do
      # Insert vote and get related participant and proposal_url.
      vote = insert(:vote, yes: true)
      voter = vote.participant
      proposal_url = vote.proposal_url

      # Insert participant to act as delegator.
      delegator = insert(:participant, organization_id: vote.organization_id)

      # Create proposal_url delegation to participant (as delegate) and get
      # voting result for proposal_url.
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{delegator.email}", delegateEmail: "#{voter.email}", proposalUrl: "#{
        proposal_url
      }") {
          proposalUrl
          votingResult {
            inFavor
            against
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: vote.organization_id})

      # Assert 'in favor' vount count now == 2, due to the delegation given to the voter
      assert delegation["proposalUrl"] == proposal_url
      assert delegation["votingResult"]["inFavor"] == 2
      assert delegation["votingResult"]["against"] == 0
    end

    test "when conflicting vote exists" do
      delegator = insert(:participant)
      vote = insert(:vote, participant: delegator, organization_id: delegator.organization_id)
      delegate = insert(:participant, organization_id: delegator.organization_id)

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{delegator.email}", delegateEmail: "#{delegate.email}", proposalUrl: "#{
        vote.proposal_url
      }") {
          proposalUrl
          id
         }
      }
      """

      {:ok, %{errors: [%{message: message, details: details}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: delegator.organization_id})

      assert message == "Could not create delegation."
      assert details == "Vote for same delegator & proposal exists."
    end
  end

  describe "create global delegation" do
    test "after creating vote by delegate" do
      # Insert vote and get related participant and proposal_url.
      vote = insert(:vote, yes: false)
      voter = vote.participant
      proposal_url = vote.proposal_url

      # Insert participant to act as delegator
      delegator = insert(:participant, organization_id: vote.organization_id)

      # Create global delegation to participant (as delegate).
      #
      # This setup step needs to involve a call to create_delegation, as simply
      # inserting a factory delegation cannot be expected to call
      # calculate_result!, and thus we could not test the expected result is
      # returned in the final related query. Hence, an absinthe mutation is used.
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{delegator.email}", delegateEmail: "#{voter.email}") {
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
        Absinthe.run(query, Schema, context: %{organization_id: vote.organization_id})

      assert delegation["delegator"]["email"] == delegator.email
      assert delegation["delegate"]["email"] == voter.email

      # Get result for proposal_B_url (should be 'against == 2').
      query = """
      query {
        votingResult(proposalUrl: "#{proposal_url}") {
          inFavor
          against
          proposalUrl
        }
      }
      """

      {:ok, %{data: %{"votingResult" => result}}} =
        Absinthe.run(query, Schema, context: %{organization_id: vote.organization_id})

      assert result["proposalUrl"] == proposal_url
      assert result["inFavor"] == 0
      assert result["against"] == 2
    end
  end

  describe "create proposal-specific and global delegations" do
    test "after creating related votes" do
      # Insert vote_A and get related participant and proposal_url.
      vote_A = insert(:vote, yes: true)
      voter_A = vote_A.participant
      proposal_A_url = vote_A.proposal_url

      # Insert vote_B and get related participant and proposal_url.
      vote_B = insert(:vote, yes: false, organization_id: vote_A.organization_id)
      voter_B = vote_B.participant
      proposal_B_url = vote_B.proposal_url

      # Insert participant to act as delegator.
      delegator = insert(:participant, organization_id: vote_A.organization_id)

      # Create proposal_A_url delegation to voter_A (as delegate) and get
      # voting result for proposal_A_url.
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{delegator.email}", delegateEmail: "#{voter_A.email}", proposalUrl: "#{
        proposal_A_url
      }") {
          proposalUrl
          votingResult {
            inFavor
            against
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: vote_A.organization_id})

      # Assert 'in favor' vote count == 2, due to delegation given to voter_A.
      assert delegation["proposalUrl"] == proposal_A_url
      assert delegation["votingResult"]["inFavor"] == 2
      assert delegation["votingResult"]["against"] == 0

      # Create global delegation to voter_B (as delegate).
      #
      # This setup step needs to involve a call to create_delegation, as simply
      # inserting a factory delegation cannot be expected to call
      # calculate_result!, and thus we could not test the expected result is
      # returned in the final related query. Hence, an absinthe mutation is used.
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{delegator.email}", delegateEmail: "#{voter_B.email}") {
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
      assert delegation["delegate"]["email"] == voter_B.email

      # Get result for proposal_B_url.
      query = """
      query {
        votingResult(proposalUrl: "#{proposal_B_url}") {
          inFavor
          against
          proposalUrl
        }
      }
      """

      {:ok, %{data: %{"votingResult" => result}}} =
        Absinthe.run(query, Schema, context: %{organization_id: vote_A.organization_id})

      # Assert 'against' vote count == 2, due to delegation given to voter_B.
      assert result["proposalUrl"] == proposal_B_url
      assert result["inFavor"] == 0
      assert result["against"] == 2
    end
  end
end
