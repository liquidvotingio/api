defmodule LiquidVoting.Factory do
  use ExMachina.Ecto, repo: LiquidVoting.Repo

  alias LiquidVoting.Voting.{Proposal,Participant,Vote,Delegation}
  alias LiquidVoting.VotingResults.Result

  def proposal_factory do
    %Proposal{url: "some url"}
  end

  def participant_factory do
    %Participant{name: sequence(:name, &"Jane Doe #{&1}")}
  end

  def vote_factory do
    %Vote{
      yes: true,
      participant: build(:participant),
      proposal: build(:proposal)
    }
  end

  def delegation_factory do
    %Delegation{
      delegator: build(:participant),
      delegate: build(:participant),
    }
  end

  def voting_result_factory do
    %Result{no: 0, yes: 0}
  end
end