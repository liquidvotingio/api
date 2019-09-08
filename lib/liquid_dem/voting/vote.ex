defmodule LiquidDem.Voting.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    field :yes, :boolean, default: false
    field :weight, :integer, default: 1

    belongs_to :participant, LiquidDem.Voting.Participant
    belongs_to :proposal, LiquidDem.Voting.Proposal

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    required_fields = [:yes, :weight, :participant_id, :proposal_id]

    vote
    |> cast(attrs, required_fields)
    |> assoc_constraint(:participant)
    |> assoc_constraint(:proposal)
    |> validate_required(required_fields)
  end
end
