defmodule LiquidVoting.Factory do
  use ExMachina.Ecto, repo: LiquidVoting.Repo

  alias LiquidVoting.Voting.{Participant,Vote,Delegation}
  alias LiquidVoting.VotingResults.Result

  def participant_factory do
    %Participant{
      name: sequence(:name, &"Jane Doe #{&1}"),
      email: sequence(:email, &"jane#{&1}@somedomain.com")
    }
  end

  def vote_factory do
    %Vote{
      yes: true,
      proposal_url: sequence(:proposal_url, &"https://proposals.com/#{&1}"),
      participant: build(:participant)
    }
  end

  def delegation_factory do
    %Delegation{
      delegator: build(:participant),
      delegate: build(:participant),
    }
  end

  def voting_result_factory do
    %Result{no: 0, yes: 0, proposal_url: sequence(:proposal_url, &"https://proposals.com/#{&1}")}
  end
end