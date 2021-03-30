defmodule LiquidVoting.Voting.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiquidVoting.Voting.Participant
  alias LiquidVoting.VotingMethods.VotingMethod

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "votes" do
    field :yes, :boolean, default: false
    field :weight, :integer, default: 1
    field :proposal_url, EctoFields.URL
    field :organization_id, Ecto.UUID

    belongs_to :participant, Participant
    belongs_to :voting_method, VotingMethod

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    required_fields = [:yes, :weight, :participant_id, :proposal_url, :organization_id]

    vote
    |> cast(attrs, required_fields)
    |> assoc_constraint(:participant)
    |> validate_required(required_fields)
    |> unique_constraint(:participant_id, name: :uniq_index_org_vote_participant_proposal)
  end
end
