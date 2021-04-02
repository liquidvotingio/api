defmodule LiquidVoting.VotingTest do
  use LiquidVoting.DataCase
  import LiquidVoting.Factory

  alias LiquidVoting.Voting
  alias LiquidVoting.Voting.Vote
  alias LiquidVoting.Delegations.Delegation

  describe "votes" do
    setup do
      participant = insert(:participant)
      voting_method = insert(:voting_method)

      [
        valid_attrs: %{
          yes: true,
          participant_id: participant.id,
          proposal_url: "http://proposals.com/1",
          voting_method_id: voting_method.id,
          organization_id: Ecto.UUID.generate()
        },
        update_attrs: %{
          yes: false,
          participant_id: participant.id,
          proposal_url: "http://proposals.com/2",
          voting_method_id: voting_method.id,
          organization_id: Ecto.UUID.generate()
        },
        invalid_attrs: %{
          yes: nil,
          participant_id: nil,
          proposal_url: nil,
          voting_method_id: nil,
          organization_id: nil
        }
      ]
    end

    test "create_vote/1 with valid data creates a vote", context do
      assert {:ok, %Vote{} = vote} = Voting.create_vote(context[:valid_attrs])
      assert vote.yes == true
    end

    test "create_vote/1 with really long proposal urls still creates a vote", context do
      proposal_url = """
      https://www.bigassstring.com/search?ei=WdznXfzyIoeT1fAP79yWqAc&q=chrome+extension+popup+js+xhr+onload+document.body&oq=chrome+extension+popup+js+xhr+onload+document.body&gs_l=psy-ab.3...309222.313422..314027...0.0..1.201.1696.5j9j1....2..0....1..gws-wiz.2OvPoKSwZ_I&ved=0ahUKEwi8g5fQspzmAhWHSRUIHW-uBXUQ4dUDCAs&uact=5"
      """

      args = Map.merge(context[:valid_attrs], %{proposal_url: proposal_url})
      assert {:ok, %Vote{}} = Voting.create_vote(args)
    end

    test "create_vote/1 deletes previous delegation by participant if present" do
      participant = insert(:participant)
      delegation = insert(:delegation, delegator: participant)
      voting_method = insert(:voting_method, name: "one-member-one-vote")

      assert {:ok, %Vote{}} =
               Voting.create_vote(%{
                 yes: false,
                 participant_id: participant.id,
                 proposal_url: "http://proposals.com/any",
                 voting_method_id: voting_method.id,
                 organization_id: delegation.organization_id
               })

      assert LiquidVoting.Repo.get(Delegation, delegation.id) == nil
    end

    test "create_vote/1 with missing data returns error changeset", context do
      assert {:error, %Ecto.Changeset{}} = Voting.create_vote(context[:invalid_attrs])
    end

    test "create_vote/1 with invalid proposal url returns error changeset", context do
      args = Map.merge(context[:valid_attrs], %{proposal_url: "bad url"})
      assert {:error, %Ecto.Changeset{}} = Voting.create_vote(args)
    end

    test "create_vote/1 with duplicate data returns error changeset", context do
      Voting.create_vote(context[:valid_attrs])
      assert {:error, %Ecto.Changeset{}} = Voting.create_vote(context[:valid_attrs])
    end

    test "list_votes/1 returns all votes for an organization_id" do
      vote = insert(:vote)
      assert Voting.list_votes(vote.organization_id) == [vote]
    end

    test "list_votes_by_proposal/3 returns all votes for a voting_method_id, proposal_url and an organization_id" do
      vote = insert(:vote)
      insert(:vote, proposal_url: "https://different.org/different-proposal")
      assert Voting.list_votes_by_proposal(vote.voting_method_id, vote.proposal_url, vote.organization_id) == [vote]
    end

    test "list_votes_by_participant/2 returns all votes for a participant_id and an organization_id" do
      vote = insert(:vote)
      assert Voting.list_votes_by_participant(vote.participant_id, vote.organization_id) == [vote]
    end

    test "get_vote!/2 returns the vote for given id and organization_id" do
      vote = insert(:vote)
      assert Voting.get_vote!(vote.id, vote.organization_id) == vote
    end

    test "get_vote!/4 returns the vote for given email, voting_method_id, proposal url and organization_id" do
      vote = insert(:vote)
      participant = Voting.get_participant!(vote.participant_id, vote.organization_id)

      assert Voting.get_vote!(
               participant.email,
               vote.voting_method_id,
               vote.proposal_url,
               vote.organization_id
             ) == vote
    end

    test "get_vote!/4 raises Ecto.NoResultsError if invalid attrs are passed in" do
      assert_raise Ecto.NoResultsError, fn ->
        Voting.get_vote!(
          "novote@gmail.com",
          "ad02e32c-6b18-4f62-9794-ac3c1e406e55",
          "https://apropos.com/not",
          "a6158b19-6bf6-4457-9d13-ef8b141611b4"
        )
      end
    end

    test "get_vote_by_participant_id/2 returns the vote for a given participant id and proposal url" do
      vote = insert(:vote)

      assert Voting.get_vote_by_participant_id(
               vote.participant_id,
               vote.proposal_url,
               vote.organization_id
             ) == vote
    end

    test "get_vote_by_participant_id/2 returns nil if no result found matching arguments" do
      vote = insert(:vote)

      assert Voting.get_vote_by_participant_id(
               vote.participant_id,
               "https://proposals.com/non-existant-proposal",
               vote.organization_id
             ) == nil
    end

    test "update_vote/2 with valid data updates the vote", context do
      vote = insert(:vote)
      assert {:ok, %Vote{} = vote} = Voting.update_vote(vote, context[:update_attrs])
      assert vote.yes == false
    end

    test "update_vote/2 with invalid data returns error changeset", context do
      vote = insert(:vote)
      assert {:error, %Ecto.Changeset{}} = Voting.update_vote(vote, context[:invalid_attrs])
    end

    test "delete_vote/1 deletes the vote" do
      vote = insert(:vote)
      assert {:ok, %Vote{}} = Voting.delete_vote(vote)
    end

    test "delete_vote!/1 deletes the vote" do
      vote = insert(:vote)
      assert %Vote{} = Voting.delete_vote!(vote)
      assert_raise Ecto.StaleEntryError, fn -> Voting.delete_vote!(vote) end
    end

    test "change_vote/1 returns a vote changeset" do
      vote = insert(:vote)
      assert %Ecto.Changeset{} = Voting.change_vote(vote)
    end
  end
end
