defmodule LiquidVoting.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :yes, :boolean, default: false, null: false
      add :weight, :integer, default: 1
      add :participant_id, references(:participants, on_delete: :nothing)
      add :proposal_id, references(:proposals, on_delete: :delete_all)

      timestamps()
    end

    create index(:votes, [:participant_id])
    create index(:votes, [:proposal_id])
  end
end
