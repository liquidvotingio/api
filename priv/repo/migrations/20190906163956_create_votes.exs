defmodule LiquidDem.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :yes_or_no, :boolean, default: false, null: false
      add :participant_id, references(:participants, on_delete: :nothing)
      add :proposal_id, references(:proposals, on_delete: :nothing)

      timestamps()
    end

    create index(:votes, [:participant_id])
    create index(:votes, [:proposal_id])
  end
end
