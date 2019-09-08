defmodule LiquidDem.VotingResults.Result do
  use Ecto.Schema
  import Ecto.Changeset

  schema "results" do
    field :no, :integer, default: 0
    field :yes, :integer, default: 0

    belongs_to :proposal, LiquidDem.Voting.Proposal

    timestamps()
  end

  @doc false
  def changeset(result, attrs) do
    result
    |> cast(attrs, [:yes, :no, :proposal_id])
    |> assoc_constraint(:proposal)
    |> validate_required([:proposal_id])
  end
end
