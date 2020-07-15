defmodule LiquidVoting.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :name, :string
      add :email, :string
      add :organization_uuid, :uuid

      timestamps()
    end

    create index(:participants, [:organization_uuid])

    create unique_index(:participants, [:organization_uuid, :email],
             name: :uniq_index_organization_uuid_participant_email
           )
  end
end
