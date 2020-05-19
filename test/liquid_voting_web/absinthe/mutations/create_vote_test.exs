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
        yes: true
      ]
    end

    test "with a new participant's email", context do
      query = """
      mutation {
        createVote(participantEmail: "#{context[:new_participant_email]}", proposalUrl:"#{context[:proposal_url]}", yes: #{context[:yes]}) {
          participant {
            email
          }
          yes
        }
      }
      """

      {:ok, %{data: %{"createVote" => vote}}} = Absinthe.run(query, Schema, context: %{organization_uuid: Ecto.UUID.generate})

      assert vote["participant"]["email"] == context[:new_participant_email]
      assert vote["yes"] == context[:yes]
    end

    test "with an existing participant's email", context do
      query = """
      mutation {
        createVote(participantEmail: "#{context[:participant_email]}", proposalUrl:"#{context[:proposal_url]}", yes: #{context[:yes]}) {
          participant {
            email
          }
          yes
        }
      }
      """

      {:ok, %{data: %{"createVote" => vote}}} = Absinthe.run(query, Schema, context: %{organization_uuid: Ecto.UUID.generate})

      assert vote["participant"]["email"] == context[:participant_email]
      assert vote["yes"] == context[:yes]
    end

    test "including voting results in the response", context do
      query = """
      mutation {
        createVote(participantEmail: "#{context[:participant_email]}", proposalUrl:"#{context[:proposal_url]}", yes: #{context[:yes]}) {
          participant {
            email
          }
          yes
          proposalUrl
          votingResult {
            yes
            no
          }
        }
      }
      """

      {:ok, %{data: %{"createVote" => vote}}} = Absinthe.run(query, Schema, context: %{organization_uuid: Ecto.UUID.generate})

      assert vote["votingResult"]["yes"] == 1
      assert vote["votingResult"]["no"] == 0
    end

    test "with participant's id", context do
      query = """
      mutation {
        createVote(participantId: "#{context[:participant_id]}", proposalUrl:"#{context[:proposal_url]}", yes: #{context[:yes]}) {
          participant {
            email
          }
          yes
        }
      }
      """

      {:ok, %{data: %{"createVote" => vote}}} = Absinthe.run(query, Schema, context: %{organization_uuid: Ecto.UUID.generate})

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

      {:ok, %{errors: [%{message: message, details: details}]}} = Absinthe.run(query, Schema, context: %{organization_uuid: Ecto.UUID.generate})

      assert message == "Could not create vote"
      assert details == "No participant identifier (id or email) submitted"
    end
  end
end