defmodule LiquidVoting.Voting.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    field :yes, :boolean, default: false
    field :weight, :integer, default: 1

    belongs_to :participant, LiquidVoting.Voting.Participant
    belongs_to :proposal, LiquidVoting.Voting.Proposal

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
    |> unique_constraint(:participant_id, name: :unique_index_vote_participant_proposal)
  end
end
