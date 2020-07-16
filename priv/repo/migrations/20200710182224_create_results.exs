defmodule LiquidVoting.Repo.Migrations.CreateResults do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :in_favor, :integer, default: 0
      add :against, :integer, default: 0
      add :proposal_url, :string, default: false, null: false
      add :organization_id, :uuid

      timestamps()
    end

    create index(:results, [:organization_id])

    create unique_index(:results, [:organization_id, :proposal_url],
             name: :uniq_index_organization_id_proposal_url
           )
  end
end
