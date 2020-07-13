defmodule LiquidVoting.Delegations.Delegation do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiquidVoting.Voting.Participant

  @primary_key {:uuid, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "delegations" do
    field :proposal_url, EctoFields.URL
    field :organization_uuid, Ecto.UUID

    belongs_to :delegator, Participant,
      references: :uuid,
      foreign_key: :delegator_uuid,
      type: :binary_id

    belongs_to :delegate, Participant,
      references: :uuid,
      foreign_key: :delegate_uuid,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(delegation, attrs) do
    required_fields = [:delegator_uuid, :delegate_uuid, :organization_uuid]
    all_fields = [:proposal_url | required_fields]

    delegation
    |> cast(attrs, all_fields)
    |> assoc_constraint(:delegator)
    |> assoc_constraint(:delegate)
    |> validate_required(required_fields)
    |> unique_constraint(:org_delegator_delegate, name: :uniq_index_org_delegator_delegate)
  end
end
