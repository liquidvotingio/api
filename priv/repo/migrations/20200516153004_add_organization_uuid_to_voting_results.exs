defmodule LiquidVoting.Repo.Migrations.AddOrganizationUuidToVotingResults do
  use Ecto.Migration

  def change do
    alter table(:results) do
      add :organization_uuid, :uuid
    end

    create index(:results, [:organization_uuid])
  end
end
