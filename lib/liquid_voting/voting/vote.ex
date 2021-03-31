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
    required_fields = [
      :yes,
      :weight,
      :participant_id,
      :proposal_url,
      :voting_method_id,
      :organization_id
    ]

    all_fields = required_fields

    vote
    |> cast(attrs, all_fields)
    |> assoc_constraint(:participant)
    |> assoc_constraint(:voting_method)
    |> validate_required(required_fields)
    |> unique_constraint(:org_participant_proposal_voting_method,
      name: :uniq_index_org_participant_proposal_voting_method
    )
  end
end
