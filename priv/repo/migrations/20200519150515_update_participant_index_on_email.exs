defmodule LiquidVoting.Repo.Migrations.UpdateParticipantIndexOnEmail do
  use Ecto.Migration

  def change do
    drop unique_index(:participants, [:email])

    create unique_index(:participants, [:organization_uuid, :email],
             name: :uniq_index_organization_uuid_participant_email
           )
  end
end
