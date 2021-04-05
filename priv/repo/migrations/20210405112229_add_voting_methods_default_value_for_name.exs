defmodule LiquidVoting.Repo.Migrations.AddVotingMethodsDefaultValueForName do
  use Ecto.Migration

  def change do
    alter table(:voting_methods) do
      modify :name, :string, default: "default"
    end
  end
end
