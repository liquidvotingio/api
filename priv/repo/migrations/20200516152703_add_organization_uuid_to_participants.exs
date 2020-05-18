defmodule LiquidVoting.Repo.Migrations.AddOrganizationUuidToParticipants do
  use Ecto.Migration

  def change do
    alter table(:participants) do
      add :organization_uuid, :uuid
    end

    create index(:participants, [:organization_uuid])
  end
end
