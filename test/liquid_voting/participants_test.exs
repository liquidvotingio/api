defmodule LiquidVoting.ParticipantsTest do
  use LiquidVoting.DataCase
  import LiquidVoting.Factory

  alias LiquidVoting.{Voting, Delegations}
  alias LiquidVoting.Voting.Participant

  describe "participants" do
    @valid_attrs %{
      name: "some name",
      email: "some@email.com",
      organization_id: Ecto.UUID.generate()
    }
    @update_attrs %{
      name: "some updated name",
      email: "another@email.com",
      organization_id: Ecto.UUID.generate()
    }
    @invalid_attrs %{email: nil, organization_id: nil}

    test "list_participants/1 returns all participants for an organization_id" do
      participant = insert(:participant)
      assert Voting.list_participants(participant.organization_id) == [participant]
    end

    test "get_participant!/2 returns the participant with given id and organization_id" do
      participant = insert(:participant)

      assert Voting.get_participant!(participant.id, participant.organization_id) ==
               participant
    end

    test "get_participant_by_email/2 returns the participant with given email and organization_id" do
      participant = insert(:participant)

      assert Voting.get_participant_by_email(participant.email, participant.organization_id) ==
               participant
    end

    test "get_participant_by_email/2 returns nil when a participant is not found" do
      assert Voting.get_participant_by_email(
               "non@participant.com",
               @valid_attrs[:organization_id]
             ) == nil
    end

    test "get_participant_by_email!/2 returns the participant with given email and organization_id" do
      participant = insert(:participant)

      assert Voting.get_participant_by_email!(participant.email, participant.organization_id) ==
               participant
    end

    test "get_participant_by_email!/2 raises Ecto.NoResultsError when participant is not found" do
      assert_raise Ecto.NoResultsError, fn ->
        Voting.get_participant_by_email!("non@participant.com", @valid_attrs[:organization_id])
      end
    end

    test "create_participant/1 with valid data creates a participant" do
      assert {:ok, %Participant{} = participant} = Voting.create_participant(@valid_attrs)
      assert participant.email == @valid_attrs[:email]
      assert participant.name == @valid_attrs[:name]
    end

    test "create_participant/1 with valid data creates an id" do
      assert {:ok, %Participant{} = participant} = Voting.create_participant(@valid_attrs)
      assert {:ok, _uuid_bitstring} = Ecto.UUID.dump(participant.id)
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

      assert {:ok, %Participant{} = participant} =
               Voting.update_participant(participant, @update_attrs)

      assert participant.name == "some updated name"
    end

    test "update_participant/2 with invalid data returns error changeset" do
      participant = insert(:participant)
      assert {:error, %Ecto.Changeset{}} = Voting.update_participant(participant, @invalid_attrs)

      assert participant ==
               Voting.get_participant!(participant.id, participant.organization_id)
    end

    test "delete_participant/1 deletes the participant" do
      participant = insert(:participant)
      assert {:ok, %Participant{}} = Voting.delete_participant(participant)

      assert_raise Ecto.NoResultsError, fn ->
        Voting.get_participant!(participant.id, participant.organization_id)
      end
    end

    test "delete_participant/1 deletes associated vote" do
      participant = insert(:participant)

      {:ok, vote} =
        Voting.create_vote(%{
          participant_id: participant.id,
          organization_id: participant.organization_id,
          proposal_url: "https://proposals.com/1",
          yes: true
        })

      assert {:ok, %Participant{}} = Voting.delete_participant(participant)

      assert_raise Ecto.NoResultsError, fn ->
        Voting.get_vote!(vote.id, participant.organization_id)
      end
    end

    test "delete_participant/1 deletes associated delegation when participant is delegate" do
      delegate = insert(:participant)
      delegator = insert(:participant, organization_id: delegate.organization_id)

      {:ok, delegation} =
        Delegations.create_delegation(%{
          delegate_id: delegate.id,
          delegator_id: delegator.id,
          organization_id: delegate.organization_id,
          proposal_url: "https://proposals.com/1"
        })

      assert {:ok, %Participant{}} = Voting.delete_participant(delegate)

      assert_raise Ecto.NoResultsError, fn ->
        Delegations.get_delegation!(delegation.id, delegate.organization_id)
      end
    end

    test "delete_participant/1 deletes associated delegation when participant is delegator" do
      delegate = insert(:participant)
      delegator = insert(:participant, organization_id: delegate.organization_id)

      {:ok, delegation} =
        Delegations.create_delegation(%{
          delegate_id: delegate.id,
          delegator_id: delegator.id,
          organization_id: delegate.organization_id,
          proposal_url: "https://proposals.com/1"
        })

      assert {:ok, %Participant{}} = Voting.delete_participant(delegator)

      assert_raise Ecto.NoResultsError, fn ->
        Delegations.get_delegation!(delegation.id, delegate.organization_id)
      end
    end

    test "change_participant/1 returns a participant changeset" do
      participant = insert(:participant)
      assert %Ecto.Changeset{} = Voting.change_participant(participant)
    end
  end
end
