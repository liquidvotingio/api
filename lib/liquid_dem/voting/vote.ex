defmodule LiquidDem.Voting.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    field :yes_or_no, :boolean, default: false

    belongs_to :participant, LiquidDem.Voting.Participant
    belongs_to :proposal, LiquidDem.Voting.Proposal

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    required_fields = [:yes_or_no, :proposal_id, :participant_id]
    
    vote
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
  end
end
