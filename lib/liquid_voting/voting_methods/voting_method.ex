defmodule LiquidVoting.VotingMethods.VotingMethod do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiquidVoting.Voting.Vote
  alias LiquidVoting.VotingResults.Result

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "voting_methods" do
    field :name, :string
    field :organization_id, Ecto.UUID

    has_many :votes, Vote
    has_many :results, Result

    timestamps()
  end

  @doc false
  def changeset(voting_method, attrs) do
    required_fields = [:organization_id, :name]

    voting_method
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> unique_constraint(:org_method_name,
      name: :uniq_index_org_name
    )
  end
end
