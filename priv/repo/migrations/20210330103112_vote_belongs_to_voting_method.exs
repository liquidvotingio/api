defmodule LiquidVoting.Repo.Migrations.VoteBelongsToVotingMethod do
  use Ecto.Migration

  def change do
    alter table(:votes) do
      add :voting_method_id, references(:voting_methods, on_delete: :nothing)
    end
  end
end
