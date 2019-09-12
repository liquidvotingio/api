defmodule LiquidVoting.Repo.Migrations.CreateProposals do
  use Ecto.Migration

  def change do
    create table(:proposals) do
      add :url, :string

      timestamps()
    end

  end
end
