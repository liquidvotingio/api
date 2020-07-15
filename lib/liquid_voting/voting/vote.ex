defmodule LiquidVoting.Voting.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiquidVoting.Voting.Participant

  @primary_key {:uuid, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "votes" do
    field :yes, :boolean, default: false
    field :weight, :integer, default: 1
    field :proposal_url, EctoFields.URL
    field :organization_uuid, Ecto.UUID

    belongs_to :participant, Participant,
      references: :uuid,
      foreign_key: :participant_uuid,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    required_fields = [:yes, :weight, :participant_uuid, :proposal_url, :organization_uuid]

    vote
    |> cast(attrs, required_fields)
    |> assoc_constraint(:participant)
    |> validate_required(required_fields)
    |> unique_constraint(:participant_uuid, name: :uniq_index_org_vote_participant_proposal)
  end
end
