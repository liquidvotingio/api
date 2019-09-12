defmodule LiquidVoting.Voting.Delegation do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiquidVoting.Voting.Participant

  schema "delegations" do
    belongs_to :delegator, Participant
    belongs_to :delegate, Participant

    timestamps()
  end

  @doc false
  def changeset(delegation, attrs) do
    required_fields = [:delegator_id, :delegate_id]

    delegation
    |> cast(attrs, required_fields)
    |> assoc_constraint(:delegator)
    |> assoc_constraint(:delegate)
    |> validate_required(required_fields)
  end
end
