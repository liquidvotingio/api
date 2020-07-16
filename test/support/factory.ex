defmodule LiquidVoting.Factory do
  use ExMachina.Ecto, repo: LiquidVoting.Repo

  alias LiquidVoting.Voting.{Vote, Participant}
  alias LiquidVoting.Delegations.Delegation
  alias LiquidVoting.VotingResults.Result

  def participant_factory do
    %Participant{
      name: sequence(:name, &"Jane Doe #{&1}"),
      email: sequence(:email, &"jane#{&1}@somedomain.com"),
      organization_id: Ecto.UUID.generate()
    }
  end

  def vote_factory do
    organization_id = Ecto.UUID.generate()

    %Vote{
      yes: true,
      proposal_url: sequence(:proposal_url, &"https://proposals.com/#{&1}"),
      participant: build(:participant, organization_id: organization_id),
      organization_id: organization_id
    }
  end

  def delegation_factory do
    organization_id = Ecto.UUID.generate()

    %Delegation{
      delegator: build(:participant, organization_id: organization_id),
      delegate: build(:participant, organization_id: organization_id),
      organization_id: organization_id
    }
  end

  def delegation_for_proposal_factory do
    organization_id = Ecto.UUID.generate()

    %Delegation{
      delegator: build(:participant, organization_id: organization_id),
      delegate: build(:participant, organization_id: organization_id),
      proposal_url: sequence(:proposal_url, &"https://proposals.com/#{&1}"),
      organization_id: organization_id
    }
  end

  def voting_result_factory do
    %Result{
      in_favor: 0,
      against: 0,
      proposal_url: sequence(:proposal_url, &"https://proposals.com/#{&1}"),
      organization_id: Ecto.UUID.generate()
    }
  end
end
