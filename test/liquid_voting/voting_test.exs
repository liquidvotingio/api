defmodule LiquidVoting.VotingTest do
  use LiquidVoting.DataCase

  alias LiquidVoting.Voting

  describe "proposals" do
    alias LiquidVoting.Voting.Proposal

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
    alias LiquidVoting.Voting.Participant

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

  describe "votes" do
    alias LiquidVoting.Voting.Vote

    @valid_attrs %{yes: true}
    @update_attrs %{yes: false}
    @invalid_attrs %{yes: nil}

    def vote_fixture(attrs \\ %{}) do
      {:ok, vote} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Voting.create_vote()

      vote
    end

    test "list_votes/0 returns all votes" do
      vote = vote_fixture()
      assert Voting.list_votes() == [vote]
    end

    test "get_vote!/1 returns the vote with given id" do
      vote = vote_fixture()
      assert Voting.get_vote!(vote.id) == vote
    end

    test "create_vote/1 with valid data creates a vote" do
      assert {:ok, %Vote{} = vote} = Voting.create_vote(@valid_attrs)
      assert vote.yes == true
    end

    test "create_vote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Voting.create_vote(@invalid_attrs)
    end

    test "update_vote/2 with valid data updates the vote" do
      vote = vote_fixture()
      assert {:ok, %Vote{} = vote} = Voting.update_vote(vote, @update_attrs)
      assert vote.yes == false
    end

    test "update_vote/2 with invalid data returns error changeset" do
      vote = vote_fixture()
      assert {:error, %Ecto.Changeset{}} = Voting.update_vote(vote, @invalid_attrs)
      assert vote == Voting.get_vote!(vote.id)
    end

    test "delete_vote/1 deletes the vote" do
      vote = vote_fixture()
      assert {:ok, %Vote{}} = Voting.delete_vote(vote)
      assert_raise Ecto.NoResultsError, fn -> Voting.get_vote!(vote.id) end
    end

    test "change_vote/1 returns a vote changeset" do
      vote = vote_fixture()
      assert %Ecto.Changeset{} = Voting.change_vote(vote)
    end
  end

  describe "delegations" do
    alias LiquidVoting.Voting.Delegation

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def delegation_fixture(attrs \\ %{}) do
      {:ok, delegation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Voting.create_delegation()

      delegation
    end

    test "list_delegations/0 returns all delegations" do
      delegation = delegation_fixture()
      assert Voting.list_delegations() == [delegation]
    end

    test "get_delegation!/1 returns the delegation with given id" do
      delegation = delegation_fixture()
      assert Voting.get_delegation!(delegation.id) == delegation
    end

    test "create_delegation/1 with valid data creates a delegation" do
      assert {:ok, %Delegation{} = delegation} = Voting.create_delegation(@valid_attrs)
    end

    test "create_delegation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Voting.create_delegation(@invalid_attrs)
    end

    test "update_delegation/2 with valid data updates the delegation" do
      delegation = delegation_fixture()
      assert {:ok, %Delegation{} = delegation} = Voting.update_delegation(delegation, @update_attrs)
    end

    test "update_delegation/2 with invalid data returns error changeset" do
      delegation = delegation_fixture()
      assert {:error, %Ecto.Changeset{}} = Voting.update_delegation(delegation, @invalid_attrs)
      assert delegation == Voting.get_delegation!(delegation.id)
    end

    test "delete_delegation/1 deletes the delegation" do
      delegation = delegation_fixture()
      assert {:ok, %Delegation{}} = Voting.delete_delegation(delegation)
      assert_raise Ecto.NoResultsError, fn -> Voting.get_delegation!(delegation.id) end
    end

    test "change_delegation/1 returns a delegation changeset" do
      delegation = delegation_fixture()
      assert %Ecto.Changeset{} = Voting.change_delegation(delegation)
    end
  end

  describe "results" do
    alias LiquidVoting.VotingResults.Result

    @valid_attrs %{no: 42, yes: 42}
    @update_attrs %{no: 43, yes: 43}
    @invalid_attrs %{no: nil, yes: nil}

    def result_fixture(attrs \\ %{}) do
      {:ok, result} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Voting.create_result()

      result
    end

    test "list_results/0 returns all results" do
      result = result_fixture()
      assert Voting.list_results() == [result]
    end

    test "get_result!/1 returns the result with given id" do
      result = result_fixture()
      assert Voting.get_result!(result.id) == result
    end

    test "create_result/1 with valid data creates a result" do
      assert {:ok, %Result{} = result} = Voting.create_result(@valid_attrs)
      assert result.no == 42
      assert result.yes == 42
    end

    test "create_result/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Voting.create_result(@invalid_attrs)
    end

    test "update_result/2 with valid data updates the result" do
      result = result_fixture()
      assert {:ok, %Result{} = result} = Voting.update_result(result, @update_attrs)
      assert result.no == 43
      assert result.yes == 43
    end

    test "update_result/2 with invalid data returns error changeset" do
      result = result_fixture()
      assert {:error, %Ecto.Changeset{}} = Voting.update_result(result, @invalid_attrs)
      assert result == Voting.get_result!(result.id)
    end

    test "delete_result/1 deletes the result" do
      result = result_fixture()
      assert {:ok, %Result{}} = Voting.delete_result(result)
      assert_raise Ecto.NoResultsError, fn -> Voting.get_result!(result.id) end
    end

    test "change_result/1 returns a result changeset" do
      result = result_fixture()
      assert %Ecto.Changeset{} = Voting.change_result(result)
    end
  end
end
