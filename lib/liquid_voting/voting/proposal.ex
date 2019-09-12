defmodule LiquidVoting.Voting.Proposal do
  use Ecto.Schema
  import Ecto.Changeset

  schema "proposals" do
    field :url, :string

    has_many :votes, LiquidVoting.Voting.Vote
    has_one :voting_result, LiquidVoting.VotingResults.Result

    timestamps()
  end

  @doc false
  def changeset(proposal, attrs) do
    proposal
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
