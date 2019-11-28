defmodule LiquidVoting.Voting.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiquidVoting.Voting.{Vote, Delegation}

  @email_format ~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/

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
    |> validate_format(:email, @email_format)
    |> unique_constraint(:email)
  end
end
