defmodule LiquidVoting.Delegations.Delegation do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiquidVoting.Voting.Participant

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "delegations" do
    field :proposal_url, EctoFields.URL
    field :organization_id, Ecto.UUID

    belongs_to :delegator, Participant
    belongs_to :delegate, Participant

    timestamps()
  end

  @doc false
  def changeset(delegation, attrs) do
    required_fields = [:delegator_id, :delegate_id, :organization_id]
    all_fields = [:proposal_url | required_fields]

    delegation
    |> cast(attrs, all_fields)
    |> assoc_constraint(:delegator)
    |> assoc_constraint(:delegate)
    |> validate_required(required_fields)
    |> unique_constraint(:org_delegator_delegate, name: :uniq_index_org_delegator_delegate)
    |> unique_constraint(:org_delegator_proposal, name: :uniq_index_org_delegator_proposal)
  end
end
