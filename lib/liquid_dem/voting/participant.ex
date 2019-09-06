defmodule LiquidDem.Voting.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "participants" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
