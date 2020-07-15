defmodule LiquidVoting.Repo.Migrations.CreateResults do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :in_favor, :integer, default: 0
      add :against, :integer, default: 0
      add :proposal_url, :string, default: false, null: false
      add :organization_uuid, :uuid

      timestamps()
    end

    create index(:results, [:organization_uuid])

    create unique_index(:results, [:organization_uuid, :proposal_url],
             name: :uniq_index_organization_uuid_proposal_url
           )
  end
end
