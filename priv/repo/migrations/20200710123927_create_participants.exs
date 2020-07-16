defmodule LiquidVoting.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :name, :string
      add :email, :string
      add :organization_id, :uuid, null: false

      timestamps()
    end

    create index(:participants, [:organization_id])

    create unique_index(:participants, [:organization_id, :email],
             name: :uniq_index_organization_id_participant_email
           )
  end
end
