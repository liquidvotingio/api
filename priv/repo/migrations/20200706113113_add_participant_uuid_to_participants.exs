defmodule LiquidVoting.Repo.Migrations.AddParticipantUuidToParticipants do
  use Ecto.Migration

  def change do
    alter table(:participants) do
      add :uuid, :uuid
    end
  end
end
