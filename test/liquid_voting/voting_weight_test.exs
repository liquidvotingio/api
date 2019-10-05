defmodule LiquidVoting.VotingWeightTest do
  use LiquidVoting.DataCase
  import LiquidVoting.Factory
  alias LiquidVoting.Repo

  alias LiquidVoting.VotingWeight

  describe "update_vote_weight/1 simplest scenario" do
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

  describe "update_vote_weight/1 when delegators also have delegations given to them" do
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
      insert(:delegation, delegate: delegator, delegator: delegator_to_the_delegator_of_the_delegator)

      {:ok, vote} = VotingWeight.update_vote_weight(vote)

      assert vote.weight == 5

      insert(:delegation, delegate: voter)
      insert(:delegation, delegate: delegator)
      insert(:delegation, delegate: delegator_to_the_delegator_of_the_delegator)

      {:ok, vote} = VotingWeight.update_vote_weight(vote)

      assert vote.weight == 8
    end
  end
end