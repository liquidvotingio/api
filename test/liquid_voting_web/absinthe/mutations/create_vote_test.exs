defmodule LiquidVotingWeb.Absinthe.Mutations.CreateVoteTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "create vote" do
    setup do
      participant = insert(:participant)

      [
        participant_id: participant.id,
        participant_email: participant.email,
        new_participant_email: "noob@email.com",
        proposal_url: "https://github.com/user/repo/pulls/15",
        yes: true,
        organization_id: participant.organization_id
      ]
    end

    test "with a new participant's email", context do
      query = """
      mutation {
        createVote(participantEmail: "#{context[:new_participant_email]}", proposalUrl:"#{
        context[:proposal_url]
      }", yes: #{context[:yes]}) {
          participant {
            email
          }
          yes
        }
      }
      """

      {:ok, %{data: %{"createVote" => vote}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert vote["participant"]["email"] == context[:new_participant_email]
      assert vote["yes"] == context[:yes]
    end

    test "with an existing participant's email", context do
      query = """
      mutation {
        createVote(participantEmail: "#{context[:participant_email]}", proposalUrl:"#{
        context[:proposal_url]
      }", yes: #{context[:yes]}) {
          participant {
            email
          }
          yes
        }
      }
      """

      {:ok, %{data: %{"createVote" => vote}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert vote["participant"]["email"] == context[:participant_email]
      assert vote["yes"] == context[:yes]
    end

    test "including voting results in the response", context do
      query = """
      mutation {
        createVote(participantEmail: "#{context[:participant_email]}", proposalUrl:"#{
        context[:proposal_url]
      }", yes: #{context[:yes]}) {
          participant {
            email
          }
          yes
          proposalUrl
          votingResult {
            in_favor
            against
          }
        }
      }
      """

      {:ok, %{data: %{"createVote" => vote}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert vote["votingResult"]["in_favor"] == 1
      assert vote["votingResult"]["against"] == 0
    end

    test "with participant's id", context do
      query = """
      mutation {
        createVote(participantId: "#{context[:participant_id]}", proposalUrl:"#{
        context[:proposal_url]
      }", yes: #{context[:yes]}) {
          participant {
            email
          }
          yes
        }
      }
      """

      {:ok, %{data: %{"createVote" => vote}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert vote["participant"]["email"] == context[:participant_email]
      assert vote["yes"] == context[:yes]
    end

    test "with no participant identifiers", context do
      query = """
      mutation {
        createVote(proposalUrl:"#{context[:proposal_url]}", yes: #{context[:yes]}) {
          participant {
            email
          }
          yes
        }
      }
      """

      {:ok, %{errors: [%{message: message, details: details}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert message == "Could not create vote"
      assert details == "No participant identifier (id or email) submitted"
    end

    # This tests 2 things:
    #
    # 1. Global and proposal-specific delegations made by same participant (delegator)
    # are correctly counted in voting results when different proposal voting results
    # are calculated (for the same proposal as the proposal-specific delegation, and
    # for proposals not related to a proposal-specific delegation and which should,
    # therefore, be related to the vote of the global delegation delegate).
    #
    # 2. Creating votes after related delegations are created correctly weights the
    # votes cast by the respective delegates.
    test "when created after related global and proposal delegations" do
      global_delegation = insert(:delegation)

      proposal_delegation = insert(:delegation_for_proposal,
        delegator: global_delegation.delegator,
        organization_id: global_delegation.organization_id
      )
      proposal_delegate = proposal_delegation.delegate
      proposal_A_url = proposal_delegation.proposal_url

      proposal_B_url = "https://proposals/b"

      # create a vote cast by the proposal-specific delegation's delegate
      query = """
      mutation {
        createVote(participantEmail: "#{proposal_delegate.email}", proposalUrl: "#{proposal_A_url}", yes: false) {
          proposalUrl
          votingResult {
            inFavor
            against
          }
        }
      }
      """

      {:ok, %{data: %{"createVote" => vote}}} =
        Absinthe.run(query, Schema, context: %{organization_id: global_delegation.organization_id})

      assert vote["proposalUrl"] == proposal_A_url
      assert vote["votingResult"]["inFavor"] == 0
      assert vote["votingResult"]["against"] == 2

      # create a vote cast by the global delegation's delegate
      query = """
      mutation {
        createVote(participantEmail: "#{global_delegation.delegate.email}", proposalUrl: "#{
        proposal_B_url
      }", yes: true) {
          proposalUrl
          votingResult {
            inFavor
            against
          }
        }
      }
      """

      {:ok, %{data: %{"createVote" => vote}}} =
        Absinthe.run(query, Schema, context: %{organization_id: global_delegation.organization_id})

      assert vote["proposalUrl"] == proposal_B_url
      assert vote["votingResult"]["inFavor"] == 2
      assert vote["votingResult"]["against"] == 0
    end
  end
end
