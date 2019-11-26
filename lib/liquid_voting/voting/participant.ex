defmodule LiquidVoting.Voting.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiquidVoting.Voting.{Vote, Delegation}

  schema "participants" do
    field :name, :string
    field :email, :string

    has_many :votes, Vote
    has_many :delegations_received, Delegation, foreign_key: :delegate_id

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:name, :email])
    |> validate_required(:email)
    |> unique_constraint(:email)
  end
end
