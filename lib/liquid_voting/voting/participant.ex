defmodule LiquidVoting.Voting.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiquidVoting.Voting.{Vote, Delegation}

  schema "participants" do
    field :name, :string
    field :email, EctoFields.Email
    field :organization_uuid, Ecto.UUID

    has_many :votes, Vote
    has_many :delegations_received, Delegation, foreign_key: :delegate_id

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    required_fields = [:email, :organization_uuid]
    all_fields = [:name | required_fields]

    participant
    |> cast(attrs, all_fields)
    |> validate_required(required_fields)
    |> unique_constraint(:email)
  end
end
