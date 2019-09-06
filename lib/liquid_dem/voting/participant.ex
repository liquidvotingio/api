defmodule LiquidDem.Voting.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiquidDem.Voting.{Vote, Delegation}

  schema "participants" do
    field :name, :string

    has_many :votes, Vote
    has_many :delegations_received, Delegation, foreign_key: :delegate_id

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
