defmodule LiquidVoting.Repo.Migrations.AddDelegationsGlobalBoolean do
  use Ecto.Migration

  def change do
    alter table(:delegations) do
      add :global, :boolean
    end
  end
end
