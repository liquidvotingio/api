defmodule LiquidVotingWeb.Absinthe.Mutations.DeleteParticipantTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "delete participant" do
    setup do
      participant = insert(:participant)

      [
        participant_email: participant.email,
        organization_id: participant.organization_id
      ]
    end

    @nonexistent_participant_email 'nonexistent@email.com'

    test "with a participant's email", context do
      query = """
      mutation {
        deleteParticipant(participantEmail: "#{context[:participant_email]}"){
          email
        }
      }
      """

      {:ok, %{data: %{"deleteParticipant" => participant}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert participant["email"] == context[:participant_email]
    end

    test "when participantEmail doesn't exist", context do
      query = """
      mutation {
        deleteParticipant(participantEmail: "#{@nonexistent_participant_email}"){
          email
        }
      }
      """

      {:ok, %{errors: [%{message: message}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert message == "No participant found to delete"
    end
  end
end
