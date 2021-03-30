defmodule LiquidVoting.Repo.Migrations.AddVotingMethodsTable do
  use Ecto.Migration

  def change do
    create table(:voting_methods) do
      add :voting_method, :string, default: nil, null: false
      add :organization_id, :uuid, null: false

      timestamps()
    end

    create unique_index(:voting_methods, [:organization_id, :voting_method],
             name: :uniq_index_org_voting_method
           )
  end
end
