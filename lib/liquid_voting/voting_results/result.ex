defmodule LiquidVoting.VotingResults.Result do
  use Ecto.Schema
  import Ecto.Changeset

  schema "results" do
    field :in_favor, :integer, default: 0
    field :against, :integer, default: 0
    field :proposal_url, :string
    field :organization_uuid, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(result, attrs) do
    required_fields = [:proposal_url, :organization_uuid]
    all_fields = [:in_favor | [:against | required_fields]]

    result
    |> cast(attrs, all_fields)
    |> validate_required(required_fields)
    |> unique_constraint(:organization_uuid_proposal_url, name: :uniq_index_organization_uuid_proposal_url)
  end
end
