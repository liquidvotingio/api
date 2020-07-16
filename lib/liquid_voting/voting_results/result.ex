defmodule LiquidVoting.VotingResults.Result do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "results" do
    field :in_favor, :integer, default: 0
    field :against, :integer, default: 0
    field :proposal_url, :string
    field :organization_id, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(result, attrs) do
    required_fields = [:proposal_url, :organization_id]
    all_fields = [:in_favor | [:against | required_fields]]

    result
    |> cast(attrs, all_fields)
    |> validate_required(required_fields)
    |> unique_constraint(:organization_id_proposal_url,
      name: :uniq_index_organization_id_proposal_url
    )
  end
end
