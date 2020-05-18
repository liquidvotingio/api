defmodule LiquidVoting.Repo.Migrations.AddOrganizationUuidToVotes do
  use Ecto.Migration

  def change do
    alter table(:votes) do
      add :organization_uuid, :uuid
    end

    create index(:votes, [:organization_uuid])
  end
end
