defmodule LiquidVoting.Voting.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    field :yes, :boolean, default: false
    field :weight, :integer, default: 1
    field :proposal_url, EctoFields.URL

    belongs_to :participant, LiquidVoting.Voting.Participant

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    required_fields = [:yes, :weight, :participant_id, :proposal_url]

    vote
    |> cast(attrs, required_fields)
    |> assoc_constraint(:participant)
    |> validate_required(required_fields)
    |> unique_constraint(:participant_id, name: :unique_index_vote_id_participant_id_proposal_url)
  end
end
