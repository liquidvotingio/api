defmodule LiquidVoting.Voting.Delegation do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiquidVoting.Voting.Participant

  schema "delegations" do
    field :proposal_url, EctoFields.URL
    field :organization_uuid, Ecto.UUID

    belongs_to :delegator, Participant
    belongs_to :delegate, Participant

    timestamps()
  end

  @doc false
  def changeset(delegation, attrs) do
    required_fields = [:delegator_id, :delegate_id, :organization_uuid]
    all_fields = [:proposal_url | required_fields]

    delegation
    |> cast(attrs, all_fields)
    |> assoc_constraint(:delegator)
    |> assoc_constraint(:delegate)
    |> validate_required(required_fields)
    |> unique_constraint(:org_delegator_delegate, name: :uniq_index_org_delegator_delegate)
  end
end
