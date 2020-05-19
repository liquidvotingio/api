defmodule LiquidVoting.VotingResults.Result do
  use Ecto.Schema
  import Ecto.Changeset

  schema "results" do
    field :no, :integer, default: 0
    field :yes, :integer, default: 0
    field :proposal_url, :string
    field :organization_uuid, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(result, attrs) do
    required_fields = [:proposal_url, :organization_uuid]
    all_fields = [:yes | [:no | required_fields]]
    result
    |> cast(attrs, all_fields)
    |> validate_required(required_fields)
  end
end
