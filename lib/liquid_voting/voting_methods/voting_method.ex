defmodule LiquidVoting.VotingMethods.VotingMethod do
  use Ecto.Schema
  import Ecto.Changeset

  #alias LiquidVoting.Voting.Vote
  #alias LiquidVoting.VotingResults.Result

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "voting_method" do
    field :method, :string
    field :organization_id, Ecto.UUID

    #has_many :votes, Vote
    #has_many :results, Result

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    required_fields = [:organization_id]
    all_fields = [:method | required_fields]

    participant
    |> cast(attrs, all_fields)
    |> validate_required(required_fields)
    |> unique_constraint(:org_method,
      name: :uniq_index_org_voting_method
    )
  end
end
