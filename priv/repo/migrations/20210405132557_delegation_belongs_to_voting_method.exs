defmodule LiquidVoting.Repo.Migrations.DelegationBelongsToVotingMethod do
  use Ecto.Migration

  def change do
    alter table(:delegations) do
      add :voting_method_id, references(:voting_methods, on_delete: :nothing)
    end
  end
end
