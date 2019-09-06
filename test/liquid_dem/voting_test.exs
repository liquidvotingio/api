defmodule LiquidDem.VotingTest do
  use LiquidDem.DataCase

  alias LiquidDem.Voting

  describe "proposals" do
    alias LiquidDem.Voting.Proposal

    @valid_attrs %{url: "some url"}
    @update_attrs %{url: "some updated url"}
    @invalid_attrs %{url: nil}

    def proposal_fixture(attrs \\ %{}) do
      {:ok, proposal} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Voting.create_proposal()

      proposal
    end

    test "list_proposals/0 returns all proposals" do
      proposal = proposal_fixture()
      assert Voting.list_proposals() == [proposal]
    end

    test "get_proposal!/1 returns the proposal with given id" do
      proposal = proposal_fixture()
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
      proposal = proposal_fixture()
      assert {:ok, %Proposal{} = proposal} = Voting.update_proposal(proposal, @update_attrs)
      assert proposal.url == "some updated url"
    end

    test "update_proposal/2 with invalid data returns error changeset" do
      proposal = proposal_fixture()
      assert {:error, %Ecto.Changeset{}} = Voting.update_proposal(proposal, @invalid_attrs)
      assert proposal == Voting.get_proposal!(proposal.id)
    end

    test "delete_proposal/1 deletes the proposal" do
      proposal = proposal_fixture()
      assert {:ok, %Proposal{}} = Voting.delete_proposal(proposal)
      assert_raise Ecto.NoResultsError, fn -> Voting.get_proposal!(proposal.id) end
    end

    test "change_proposal/1 returns a proposal changeset" do
      proposal = proposal_fixture()
      assert %Ecto.Changeset{} = Voting.change_proposal(proposal)
    end
  end

  describe "participants" do
    alias LiquidDem.Voting.Participant

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def participant_fixture(attrs \\ %{}) do
      {:ok, participant} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Voting.create_participant()

      participant
    end

    test "list_participants/0 returns all participants" do
      participant = participant_fixture()
      assert Voting.list_participants() == [participant]
    end

    test "get_participant!/1 returns the participant with given id" do
      participant = participant_fixture()
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
      participant = participant_fixture()
      assert {:ok, %Participant{} = participant} = Voting.update_participant(participant, @update_attrs)
      assert participant.name == "some updated name"
    end

    test "update_participant/2 with invalid data returns error changeset" do
      participant = participant_fixture()
      assert {:error, %Ecto.Changeset{}} = Voting.update_participant(participant, @invalid_attrs)
      assert participant == Voting.get_participant!(participant.id)
    end

    test "delete_participant/1 deletes the participant" do
      participant = participant_fixture()
      assert {:ok, %Participant{}} = Voting.delete_participant(participant)
      assert_raise Ecto.NoResultsError, fn -> Voting.get_participant!(participant.id) end
    end

    test "change_participant/1 returns a participant changeset" do
      participant = participant_fixture()
      assert %Ecto.Changeset{} = Voting.change_participant(participant)
    end
  end
end
