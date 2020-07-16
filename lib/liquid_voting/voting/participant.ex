defmodule LiquidVoting.Voting.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiquidVoting.Voting.Vote
  alias LiquidVoting.Delegations.Delegation

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "participants" do
    field :name, :string
    field :email, EctoFields.Email
    field :organization_id, Ecto.UUID

    has_many :votes, Vote
    has_many :delegations_received, Delegation, foreign_key: :delegate_id

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    required_fields = [:email, :organization_id]
    all_fields = [:name | required_fields]

    participant
    |> cast(attrs, all_fields)
    |> validate_required(required_fields)
    |> unique_constraint(:email, name: :uniq_index_organization_id_participant_email)
  end
end
