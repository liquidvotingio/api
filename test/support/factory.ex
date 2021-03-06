defmodule LiquidVoting.Factory do
  use ExMachina.Ecto, repo: LiquidVoting.Repo

  alias LiquidVoting.Voting.{Vote, Participant}
  alias LiquidVoting.Delegations.Delegation
  alias LiquidVoting.VotingResults.Result
  alias LiquidVoting.VotingMethods.VotingMethod

  def participant_factory(attrs) do
    organization_id = Map.get(attrs, :organization_id, Ecto.UUID.generate())

    participant = %Participant{
      name: sequence(:name, &"Jane Doe #{&1}"),
      email: sequence(:email, &"jane#{&1}@somedomain.com"),
      organization_id: organization_id
    }

    merge_attributes(participant, attrs)
  end

  def vote_factory(attrs) do
    organization_id = Map.get(attrs, :organization_id, Ecto.UUID.generate())

    voting_method_name =
      Map.get(attrs, :voting_method_name, sequence(:name, &"voting-method-name#{&1}"))

    voting_method =
      Map.get(
        attrs,
        :voting_method,
        build(:voting_method, organization_id: organization_id, name: voting_method_name)
      )

    vote = %Vote{
      yes: true,
      proposal_url: sequence(:proposal_url, &"https://proposals.com/#{&1}"),
      participant: build(:participant, organization_id: organization_id),
      voting_method: voting_method,
      organization_id: organization_id
    }

    merge_attributes(vote, attrs)
  end

  def delegation_factory(attrs) do
    organization_id = Map.get(attrs, :organization_id, Ecto.UUID.generate())

    delegation = %Delegation{
      delegator: build(:participant, organization_id: organization_id),
      delegate: build(:participant, organization_id: organization_id),
      organization_id: organization_id
    }

    merge_attributes(delegation, attrs)
  end

  def delegation_for_proposal_factory(attrs) do
    organization_id = Map.get(attrs, :organization_id, Ecto.UUID.generate())

    voting_method_name =
      Map.get(attrs, :voting_method_name, sequence(:name, &"voting-method-name#{&1}"))

    voting_method =
      Map.get(
        attrs,
        :voting_method,
        build(:voting_method, organization_id: organization_id, name: voting_method_name)
      )

    delegation = %Delegation{
      delegator: build(:participant, organization_id: organization_id),
      delegate: build(:participant, organization_id: organization_id),
      voting_method: voting_method,
      proposal_url: sequence(:proposal_url, &"https://proposals.com/#{&1}"),
      organization_id: organization_id
    }

    merge_attributes(delegation, attrs)
  end

  def voting_result_factory(attrs) do
    organization_id = Map.get(attrs, :organization_id, Ecto.UUID.generate())

    voting_method_name =
      Map.get(attrs, :voting_method_name, sequence(:name, &"voting-method-name#{&1}"))

    voting_method =
      Map.get(
        attrs,
        :voting_method,
        build(:voting_method, organization_id: organization_id, name: voting_method_name)
      )

    voting_result = %Result{
      in_favor: 0,
      against: 0,
      voting_method: voting_method,
      proposal_url: sequence(:proposal_url, &"https://proposals.com/#{&1}"),
      organization_id: organization_id
    }

    merge_attributes(voting_result, attrs)
  end

  def voting_method_factory(attrs) do
    organization_id = Map.get(attrs, :organization_id, Ecto.UUID.generate())
    name = Map.get(attrs, :name, sequence(:name, &"voting-method-name#{&1}"))

    voting_method = %VotingMethod{
      name: name,
      organization_id: organization_id
    }

    merge_attributes(voting_method, attrs)
  end
end
