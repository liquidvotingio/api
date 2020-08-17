defmodule LiquidVoting.Delegations.Delegation do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiquidVoting.Voting.Participant

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "delegations" do
    field :proposal_url, EctoFields.URL
    field :organization_id, Ecto.UUID
    field :global, :boolean

    belongs_to :delegator, Participant
    belongs_to :delegate, Participant

    timestamps()
  end

  @doc false
  def changeset(delegation, attrs) do
    required_fields = [:delegator_id, :delegate_id, :organization_id]
    all_fields = [:proposal_url, :global | required_fields]

    delegation
    |> cast(attrs, all_fields)
    |> assoc_constraint(:delegator)
    |> assoc_constraint(:delegate)
    |> validate_required(required_fields)
    |> set_global()
    |> unique_constraint(:org_delegator_delegate, name: :uniq_index_org_delegator_delegate)
    |> unique_constraint(:org_delegator_proposal, name: :uniq_index_org_delegator_proposal)
    |> unique_constraint(:org_delegator_global_where_global_true,
      name: :uniq_index_org_delegator_global_where_global_true
    )
  end

  defp set_global(changeset) do
    case get_field(changeset, :proposal_url) do
      # If proposal_url is nil, delegation is global
      nil -> put_change(changeset, :global, true)
      # If proposal_url is not nil, delegation is not global
      _ -> put_change(changeset, :global, false)
    end
  end
end
