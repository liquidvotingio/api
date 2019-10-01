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
    participant = insert(:participant)
    proposal = insert(:proposal)
    %Vote{
      yes: true,
      participant_id: participant.id,
      proposal_id: proposal.id
    }
  end

  def delegation_factory do
    delegator = insert(:participant)
    delegate = insert(:participant)
    %Delegation{
      delegator_id: delegator.id,
      delegate_id: delegate.id,
    }
  end

  def voting_result_factory do
    %Result{no: 42, yes: 42}
  end
end