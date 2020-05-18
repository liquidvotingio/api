defmodule LiquidVoting.Repo.Migrations.AddOrganizationUuidToDelegations do
  use Ecto.Migration

  def change do
    alter table(:delegations) do
      add :organization_uuid, :uuid
    end

    create index(:delegations, [:organization_uuid])
  end
end
