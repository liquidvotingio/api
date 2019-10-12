defmodule LiquidVoting.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :name, :string
      add :email, :string

      timestamps()
    end

    create unique_index(:participants, [:email])
  end
end
