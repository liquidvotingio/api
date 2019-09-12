defmodule LiquidVoting.Repo.Migrations.CreateResults do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :yes, :integer, default: 0
      add :no, :integer, default: 0
      add :proposal_id, references(:proposals, on_delete: :nothing)

      timestamps()
    end

    create index(:results, [:proposal_id])
  end
end
