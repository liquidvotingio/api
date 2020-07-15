defmodule LiquidVoting.ParticipantsTest do
  use LiquidVoting.DataCase
  import LiquidVoting.Factory

  alias LiquidVoting.Voting
  alias LiquidVoting.Voting.Participant

  describe "participants" do
    @valid_attrs %{
      name: "some name",
      email: "some@email.com",
      organization_uuid: Ecto.UUID.generate()
    }
    @update_attrs %{
      name: "some updated name",
      email: "another@email.com",
      organization_uuid: Ecto.UUID.generate()
    }
    @invalid_attrs %{email: nil, organization_uuid: nil}

    test "list_participants/1 returns all participants for an organization_uuid" do
      participant = insert(:participant)
      assert Voting.list_participants(participant.organization_uuid) == [participant]
    end

    test "get_participant!/2 returns the participant with given uuid and organization_uuid" do
      participant = insert(:participant)

      assert Voting.get_participant!(participant.uuid, participant.organization_uuid) ==
               participant
    end

    test "get_participant_by_email/2 returns the participant with given email and organization_uuid" do
      participant = insert(:participant)

      assert Voting.get_participant_by_email(participant.email, participant.organization_uuid) ==
               participant
    end

    test "get_participant_by_email/2 returns nil when a participant is not found" do
      assert Voting.get_participant_by_email(
               "non@participant.com",
               @valid_attrs[:organization_uuid]
             ) == nil
    end

    test "get_participant_by_email!/2 returns the participant with given email and organization_uuid" do
      participant = insert(:participant)

      assert Voting.get_participant_by_email!(participant.email, participant.organization_uuid) ==
               participant
    end

    test "get_participant_by_email!/2 raises Ecto.NoResultsError when participant is not found" do
      assert_raise Ecto.NoResultsError, fn ->
        Voting.get_participant_by_email!("non@participant.com", @valid_attrs[:organization_uuid])
      end
    end

    test "create_participant/1 with valid data creates a participant" do
      assert {:ok, %Participant{} = participant} = Voting.create_participant(@valid_attrs)
      assert participant.email == @valid_attrs[:email]
      assert participant.name == @valid_attrs[:name]
    end

    test "create_participant/1 with valid data creates a uuid" do
      assert {:ok, %Participant{} = participant} = Voting.create_participant(@valid_attrs)
      assert {:ok, _uuid_bitstring} = Ecto.UUID.dump(participant.uuid)
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
               Voting.get_participant!(participant.uuid, participant.organization_uuid)
    end

    test "delete_participant/1 deletes the participant" do
      participant = insert(:participant)
      assert {:ok, %Participant{}} = Voting.delete_participant(participant)

      assert_raise Ecto.NoResultsError, fn ->
        Voting.get_participant!(participant.uuid, participant.organization_uuid)
      end
    end

    test "change_participant/1 returns a participant changeset" do
      participant = insert(:participant)
      assert %Ecto.Changeset{} = Voting.change_participant(participant)
    end
  end
end
