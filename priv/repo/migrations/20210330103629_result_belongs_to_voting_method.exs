defmodule LiquidVoting.Repo.Migrations.ResultBelongsToVotingMethod do
  use Ecto.Migration

  def change do
    alter table(:results) do
      add :voting_method_id, references(:voting_methods, on_delete: :nothing)
    end
  end
end
