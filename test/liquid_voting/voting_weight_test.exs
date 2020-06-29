defmodule LiquidVoting.VotingWeightTest do
  use LiquidVoting.DataCase

  import LiquidVoting.Factory

  alias LiquidVoting.{Repo, VotingWeight}

  describe "update_vote_weight/1 simplest scenario (global delegations)" do
    test "updates vote weight based on the number of delegations given to voter" do
      vote = insert(:vote)
      voter = Repo.preload(vote.participant, :delegations_received)

      assert length(voter.delegations_received) == 0
      assert vote.weight == 1

      insert(:delegation, delegate: voter)

      {:ok, vote} = VotingWeight.update_vote_weight(vote)

      assert vote.weight == 2
    end
  end

  describe "update_vote_weight/1 when delegators also have delegations given to them (global delegations)" do
    test "adds number of delegations the delegator received to the weight " do
      vote = insert(:vote)
      voter = vote.participant

      delegator = insert(:participant)
      delegator_to_the_delegator = insert(:participant)

      insert(:delegation, delegate: voter, delegator: delegator)
      insert(:delegation, delegate: delegator, delegator: delegator_to_the_delegator)

      {:ok, vote} = VotingWeight.update_vote_weight(vote)

      assert vote.weight == 3

      delegator_to_the_delegator_of_the_delegator = insert(:participant)

      insert(:delegation, delegate: delegator, delegator: delegator_to_the_delegator)

      insert(:delegation,
        delegate: delegator,
        delegator: delegator_to_the_delegator_of_the_delegator
      )

      {:ok, vote} = VotingWeight.update_vote_weight(vote)

      assert vote.weight == 5

      insert(:delegation, delegate: voter)
      insert(:delegation, delegate: delegator)
      insert(:delegation, delegate: delegator_to_the_delegator_of_the_delegator)

      {:ok, vote} = VotingWeight.update_vote_weight(vote)

      assert vote.weight == 8
    end
  end

  describe "update_vote_weight/1 when voter has delegations for specific proposals" do
    test "only takes delegations for current proposal into account" do
      vote = insert(:vote)
      voter = Repo.preload(vote.participant, :delegations_received)

      assert length(voter.delegations_received) == 0
      assert vote.weight == 1

      insert(:delegation, delegate: voter, proposal_url: vote.proposal_url)
      insert(:delegation, delegate: voter, proposal_url: "https://anotherproposal.com")

      {:ok, vote} = VotingWeight.update_vote_weight(vote)

      assert vote.weight == 2
    end
  end
end
