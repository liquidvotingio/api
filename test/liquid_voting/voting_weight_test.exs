defmodule LiquidVoting.VotingWeightTest do
  use LiquidVoting.DataCase
  import LiquidVoting.Factory
  alias LiquidVoting.Repo

  alias LiquidVoting.Voting
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

  describe "update_vote_weight/1 when delegators also had delegations given to them" do
    test "multiplies delegation weight by number of delegations the delegator received" do
      vote = insert(:vote)
      voter = vote.participant

      delegator = insert(:participant)
      insert(:delegation, delegate: delegator)
      insert(:delegation, delegate: delegator)
      insert(:delegation, delegate: voter, delegator: delegator)

      {:ok, vote} = VotingWeight.update_vote_weight(vote)

      assert vote.weight == 4
    end
  end
end