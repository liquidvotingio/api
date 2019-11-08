defmodule LiquidVoting.Repo.Migrations.CreateResults do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :yes, :integer, default: 0
      add :no, :integer, default: 0
      add :proposal_url, :string, default: false, null: false

      timestamps()
    end

    create unique_index(:results, [:proposal_url])
  end
end
