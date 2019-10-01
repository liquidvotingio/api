defmodule LiquidVoting.VotingTest do
  use LiquidVoting.DataCase
  import LiquidVoting.Factory

  alias LiquidVoting.Voting
  alias LiquidVoting.Voting.{Proposal,Participant,Vote,Delegation}

  describe "proposals" do
    @valid_attrs %{url: "some url"}
    @update_attrs %{url: "some updated url"}
    @invalid_attrs %{url: nil}

    test "list_proposals/0 returns all proposals" do
      proposal = insert(:proposal)
      assert Voting.list_proposals() == [proposal]
    end

    test "get_proposal!/1 returns the proposal with given id" do
      proposal = insert(:proposal)
      assert Voting.get_proposal!(proposal.id) == proposal
    end

    test "create_proposal/1 with valid data creates a proposal" do
      assert {:ok, %Proposal{} = proposal} = Voting.create_proposal(@valid_attrs)
      assert proposal.url == "some url"
    end

    test "create_proposal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Voting.create_proposal(@invalid_attrs)
    end

    test "update_proposal/2 with valid data updates the proposal" do
      proposal = insert(:proposal)
      assert {:ok, %Proposal{} = proposal} = Voting.update_proposal(proposal, @update_attrs)
      assert proposal.url == "some updated url"
    end

    test "update_proposal/2 with invalid data returns error changeset" do
      proposal = insert(:proposal)
      assert {:error, %Ecto.Changeset{}} = Voting.update_proposal(proposal, @invalid_attrs)
      assert proposal == Voting.get_proposal!(proposal.id)
    end

    test "delete_proposal/1 deletes the proposal" do
      proposal = insert(:proposal)
      assert {:ok, %Proposal{}} = Voting.delete_proposal(proposal)
      assert_raise Ecto.NoResultsError, fn -> Voting.get_proposal!(proposal.id) end
    end

    test "change_proposal/1 returns a proposal changeset" do
      proposal = insert(:proposal)
      assert %Ecto.Changeset{} = Voting.change_proposal(proposal)
    end
  end

  describe "participants" do
    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "list_participants/0 returns all participants" do
      participant = insert(:participant)
      assert Voting.list_participants() == [participant]
    end

    test "get_participant!/1 returns the participant with given id" do
      participant = insert(:participant)
      assert Voting.get_participant!(participant.id) == participant
    end

    test "create_participant/1 with valid data creates a participant" do
      assert {:ok, %Participant{} = participant} = Voting.create_participant(@valid_attrs)
      assert participant.name == "some name"
    end

    test "create_participant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Voting.create_participant(@invalid_attrs)
    end

    test "update_participant/2 with valid data updates the participant" do
      participant = insert(:participant)
      assert {:ok, %Participant{} = participant} = Voting.update_participant(participant, @update_attrs)
      assert participant.name == "some updated name"
    end

    test "update_participant/2 with invalid data returns error changeset" do
      participant = insert(:participant)
      assert {:error, %Ecto.Changeset{}} = Voting.update_participant(participant, @invalid_attrs)
      assert participant == Voting.get_participant!(participant.id)
    end

    test "delete_participant/1 deletes the participant" do
      participant = insert(:participant)
      assert {:ok, %Participant{}} = Voting.delete_participant(participant)
      assert_raise Ecto.NoResultsError, fn -> Voting.get_participant!(participant.id) end
    end

    test "change_participant/1 returns a participant changeset" do
      participant = insert(:participant)
      assert %Ecto.Changeset{} = Voting.change_participant(participant)
    end
  end

  describe "votes" do
    setup do
      participant = insert(:participant)
      proposal = insert(:proposal)
      another_proposal = insert(:proposal, url: "another.url")

      [
        valid_attrs: %{
          yes: true,
          participant_id: participant.id,
          proposal_id: proposal.id
        },
        update_attrs: %{
          yes: false,
          participant_id: participant.id,
          proposal_id: another_proposal.id
        },
        invalid_attrs: %{yes: nil}
      ]
    end

    test "list_votes/0 returns all votes", context do
      vote = insert(:vote, context[:valid_attrs])
      assert Voting.list_votes() == [vote]
    end

    test "get_vote!/1 returns the vote with given id", context do
      vote = insert(:vote, context[:valid_attrs])
      assert Voting.get_vote!(vote.id) == vote
    end

    test "create_vote/1 with valid data creates a vote", context do
      assert {:ok, %Vote{} = vote} = Voting.create_vote(context[:valid_attrs])
      assert vote.yes == true
    end

    test "create_vote/1 with invalid data returns error changeset", context do
      assert {:error, %Ecto.Changeset{}} = Voting.create_vote(context[:invalid_attrs])
    end

    test "update_vote/2 with valid data updates the vote", context do
      vote = insert(:vote, context[:valid_attrs])
      assert {:ok, %Vote{} = vote} = Voting.update_vote(vote, context[:update_attrs])
      assert vote.yes == false
    end

    test "update_vote/2 with invalid data returns error changeset", context do
      vote = insert(:vote, context[:valid_attrs])
      assert {:error, %Ecto.Changeset{}} = Voting.update_vote(vote, context[:invalid_attrs])
      assert vote == Voting.get_vote!(vote.id)
    end

    test "delete_vote/1 deletes the vote", context do
      vote = insert(:vote, context[:valid_attrs])
      assert {:ok, %Vote{}} = Voting.delete_vote(vote)
      assert_raise Ecto.NoResultsError, fn -> Voting.get_vote!(vote.id) end
    end

    test "change_vote/1 returns a vote changeset", context do
      vote = insert(:vote, context[:valid_attrs])
      assert %Ecto.Changeset{} = Voting.change_vote(vote)
    end
  end

  describe "delegations" do
    setup do
      delegator = insert(:participant)
      delegate = insert(:participant)
      another_delegate = insert(:participant)

      [
        valid_attrs: %{
          delegator_id: delegator.id,
          delegate_id: delegate.id
        },
        update_attrs: %{
          delegator_id: delegator.id,
          delegate_id: another_delegate.id
        },
        invalid_attrs: %{delegator_id: delegator.id, delegate_id: nil}
      ]
    end

    test "list_delegations/0 returns all delegations" do
      delegation = insert(:delegation)
      assert Voting.list_delegations() == [delegation]
    end

    test "get_delegation!/1 returns the delegation with given id" do
      delegation = insert(:delegation)
      assert Voting.get_delegation!(delegation.id) == delegation
    end

    test "create_delegation/1 with valid data creates a delegation", context do
      assert {:ok, %Delegation{} = delegation} = Voting.create_delegation(context[:valid_attrs])
    end

    test "create_delegation/1 with invalid data returns error changeset", context do
      assert {:error, %Ecto.Changeset{}} = Voting.create_delegation(context[:invalid_attrs])
    end

    test "update_delegation/2 with valid data updates the delegation", context do
      delegation = insert(:delegation)
      assert {:ok, %Delegation{} = delegation} = Voting.update_delegation(delegation, context[:update_attrs])
    end

    test "update_delegation/2 with invalid data returns error changeset", context do
      delegation = insert(:delegation)
      assert {:error, %Ecto.Changeset{}} = Voting.update_delegation(delegation, context[:invalid_attrs])
      assert delegation == Voting.get_delegation!(delegation.id)
    end

    test "delete_delegation/1 deletes the delegation" do
      delegation = insert(:delegation)
      assert {:ok, %Delegation{}} = Voting.delete_delegation(delegation)
      assert_raise Ecto.NoResultsError, fn -> Voting.get_delegation!(delegation.id) end
    end

    test "change_delegation/1 returns a delegation changeset" do
      delegation = insert(:delegation)
      assert %Ecto.Changeset{} = Voting.change_delegation(delegation)
    end
  end
end
