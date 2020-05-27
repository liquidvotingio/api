defmodule LiquidVotingWeb.Absinthe.Mutations.DeleteVoteTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "delete vote" do
    setup do
      vote = insert(:vote)
      [
        participant_email: vote.participant.email,
        proposal_url: vote.proposal_url,
        organization_uuid: vote.organization_uuid
      ]
    end

    test "with a participant's email and proposal_url", context do
      query = """
      mutation {
        deleteVote(participantEmail: "#{context[:participant_email]}", proposalUrl:"#{context[:proposal_url]}") {
          participant {
            email
          }
        }
      }
      """

      {:ok, %{data: %{"deleteVote" => vote}}} = Absinthe.run(query, Schema, context: %{organization_uuid: context[:organization_uuid]})

      assert vote["participant"]["email"] == context[:participant_email]
    end

    test "when vote doesn't exist", context do
      another_participant = insert(:participant, organization_uuid: context[:organization_uuid])

      query = """
      mutation {
        deleteVote(participantEmail: "#{another_participant.email}", proposalUrl:"#{context[:proposal_url]}") {
          participant {
            email
          }
        }
      }
      """
      {:ok, %{errors: [%{message: message}]}} = Absinthe.run(query, Schema, context: %{organization_uuid: context[:organization_uuid]})

      assert message == "No vote found to delete"
    end
  end
end