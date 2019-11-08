defmodule LiquidVoting.VotingResults.Result do
  use Ecto.Schema
  import Ecto.Changeset

  schema "results" do
    field :no, :integer, default: 0
    field :yes, :integer, default: 0
    field :proposal_url, :string

    timestamps()
  end

  @doc false
  def changeset(result, attrs) do
    result
    |> cast(attrs, [:yes, :no, :proposal_url])
    |> validate_required([:proposal_url])
  end
end
