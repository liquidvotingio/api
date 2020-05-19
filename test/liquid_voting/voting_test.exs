defmodule LiquidVoting.VotingTest do
  use LiquidVoting.DataCase
  import LiquidVoting.Factory

  alias LiquidVoting.Voting
  alias LiquidVoting.Voting.{Participant,Vote,Delegation}

  describe "votes" do
    setup do
      participant = insert(:participant)

      [
        valid_attrs: %{
          yes: true,
          participant_id: participant.id,
          proposal_url: "http://proposals.com/1",
          organization_uuid: Ecto.UUID.generate
        },
        update_attrs: %{
          yes: false,
          participant_id: participant.id,
          proposal_url: "http://proposals.com/2",
          organization_uuid: Ecto.UUID.generate
        },
        invalid_attrs: %{
          yes: nil,
          participant_id: nil,
          proposal_url: nil,
          organization_uuid: nil
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
      assert {:ok, %Vote{} = vote} = Voting.create_vote(args)
    end

    test "create_vote/1 deletes previous delegation by participant if present" do
      participant = insert(:participant)
      delegation = insert(:delegation, delegator: participant)
      assert {:ok, %Vote{}} = Voting.create_vote(%{
          yes: false,
          participant_id: participant.id,
          proposal_url: "http://proposals.com/any",
          organization_uuid: delegation.organization_uuid
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

    test "list_votes/1 returns all votes for an organization_uuid" do
      vote = insert(:vote)
      assert Voting.list_votes(vote.organization_uuid) == [vote]
    end

    test "list_votes/2 returns all votes for a proposal_url and an organization_uuid" do
      vote = insert(:vote)
      insert(:vote, proposal_url: "https://different.org/proposal")
      assert Voting.list_votes(vote.proposal_url, vote.organization_uuid) == [vote]
    end

    test "get_vote!/2 returns the vote with given id and organization_uuid" do
      vote = insert(:vote)
      assert Voting.get_vote!(vote.id, vote.organization_uuid) == vote
    end

    test "update_vote/2 with valid data updates the vote", context do
      vote = insert(:vote)
      assert {:ok, %Vote{} = vote} = Voting.update_vote(vote, context[:update_attrs])
      assert vote.yes == false
    end

    test "update_vote/2 with invalid data returns error changeset", context do
      vote = insert(:vote)
      assert {:error, %Ecto.Changeset{}} = Voting.update_vote(vote, context[:invalid_attrs])
      assert vote == Voting.get_vote!(vote.id, vote.organization_uuid)
    end

    test "delete_vote/1 deletes the vote" do
      vote = insert(:vote)
      assert {:ok, %Vote{}} = Voting.delete_vote(vote)
      assert_raise Ecto.NoResultsError, fn -> Voting.get_vote!(vote.id, vote.organization_uuid) end
    end

    test "change_vote/1 returns a vote changeset" do
      vote = insert(:vote)
      assert %Ecto.Changeset{} = Voting.change_vote(vote)
    end
  end

  describe "participants" do
    @valid_attrs %{name: "some name", email: "some@email.com", organization_uuid: Ecto.UUID.generate}
    @update_attrs %{name: "some updated name", email: "another@email.com", organization_uuid: Ecto.UUID.generate}
    @invalid_attrs %{email: nil, organization_uuid: nil}

    test "list_participants/1 returns all participants for an organization_uuid" do
      participant = insert(:participant)
      assert Voting.list_participants(participant.organization_uuid) == [participant]
    end

    test "get_participant!/2 returns the participant with given id and organization_uuid" do
      participant = insert(:participant)
      assert Voting.get_participant!(participant.id, participant.organization_uuid) == participant
    end

    test "get_participant_by_email/1 returns the participant with given email and organization_uuid" do
      participant = insert(:participant)
      assert Voting.get_participant_by_email(participant.email, participant.organization_uuid) == participant
    end

    test "create_participant/1 with valid data creates a participant" do
      assert {:ok, %Participant{} = participant} = Voting.create_participant(@valid_attrs)
      assert participant.email == @valid_attrs[:email]
      assert participant.name == @valid_attrs[:name]
    end

    test "create_participant/1 with missing data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Voting.create_participant(@invalid_attrs)
    end

    test "create_participant/1 with invalid email returns error changeset" do
      args = %{email: "invalid", name: "some name"}
      assert {:error, %Ecto.Changeset{}} = Voting.create_participant(args)
    end

    test "create_participant/1 with duplicate data returns error changeset" do
      Voting.create_participant(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Voting.create_participant(@valid_attrs)
    end

    test "upsert_participant/2 with new valid data creates a participant" do
      assert {:ok, %Participant{} = participant} = Voting.upsert_participant(@valid_attrs)
      assert participant.email == @valid_attrs[:email]
      assert participant.name == @valid_attrs[:name]
    end

    test "upsert_participant/2 with existing valid data fetches matching participant" do
      insert(:participant, email: @valid_attrs[:email])
      assert {:ok, %Participant{} = participant} = Voting.upsert_participant(@valid_attrs)
      assert participant.email == @valid_attrs[:email]
      assert participant.name == @valid_attrs[:name]
    end

    test "update_participant/2 with valid data updates the participant" do
      participant = insert(:participant)
      assert {:ok, %Participant{} = participant} = Voting.update_participant(participant, @update_attrs)
      assert participant.name == "some updated name"
    end

    test "update_participant/2 with invalid data returns error changeset" do
      participant = insert(:participant)
      assert {:error, %Ecto.Changeset{}} = Voting.update_participant(participant, @invalid_attrs)
      assert participant == Voting.get_participant!(participant.id, participant.organization_uuid)
    end

    test "delete_participant/1 deletes the participant" do
      participant = insert(:participant)
      assert {:ok, %Participant{}} = Voting.delete_participant(participant)
      assert_raise Ecto.NoResultsError, fn -> Voting.get_participant!(participant.id, participant.organization_uuid) end
    end

    test "change_participant/1 returns a participant changeset" do
      participant = insert(:participant)
      assert %Ecto.Changeset{} = Voting.change_participant(participant)
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
          delegate_id: delegate.id,
          organization_uuid: Ecto.UUID.generate
        },
        update_attrs: %{
          delegator_id: delegator.id,
          delegate_id: another_delegate.id,
          organization_uuid: Ecto.UUID.generate
        },
        invalid_attrs: %{delegator_id: delegator.id, delegate_id: nil, organization_uuid: nil}
      ]
    end

    test "list_delegations/1 returns all delegations for an organization_uuid" do
      delegation = insert(:delegation)
      assert Voting.list_delegations(delegation.organization_uuid) == [delegation]
    end

    test "get_delegation!/2 returns the delegation with given id and organization_uuid" do
      delegation = insert(:delegation)
      assert Voting.get_delegation!(delegation.id, delegation.organization_uuid) == delegation
    end

    test "create_delegation/1 with valid data creates a delegation", context do
      assert {:ok, %Delegation{} = delegation} = Voting.create_delegation(context[:valid_attrs])
    end

    test "create_delegation/1 with invalid data returns error changeset", context do
      assert {:error, %Ecto.Changeset{}} = Voting.create_delegation(context[:invalid_attrs])
    end

    test "create_delegation/1 with proposal urls creates a delegation", context do
      # Test long urls while at it
      proposal_url = """
      https://www.bigassstring.com/search?ei=WdznXfzyIoeT1fAP79yWqAc&q=chrome+extension+popup+js+xhr+onload+document.body&oq=chrome+extension+popup+js+xhr+onload+document.body&gs_l=psy-ab.3...309222.313422..314027...0.0..1.201.1696.5j9j1....2..0....1..gws-wiz.2OvPoKSwZ_I&ved=0ahUKEwi8g5fQspzmAhWHSRUIHW-uBXUQ4dUDCAs&uact=5"
      """
      args = Map.merge(context[:valid_attrs], %{proposal_url: proposal_url})
      assert {:ok, %Delegation{} = delegation} = Voting.create_delegation(args)
    end

    test "update_delegation/2 with valid data updates the delegation", context do
      delegation = insert(:delegation)
      assert {:ok, %Delegation{} = delegation} = Voting.update_delegation(delegation, context[:update_attrs])
    end

    test "delete_delegation/1 deletes the delegation" do
      delegation = insert(:delegation)
      assert {:ok, %Delegation{}} = Voting.delete_delegation(delegation)
      assert_raise Ecto.NoResultsError, fn -> Voting.get_delegation!(delegation.id, delegation.organization_uuid) end
    end

    test "change_delegation/1 returns a delegation changeset" do
      delegation = insert(:delegation)
      assert %Ecto.Changeset{} = Voting.change_delegation(delegation)
    end
  end
end
