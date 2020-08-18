defmodule LiquidVoting.Repo.Migrations.AddDelegationsGlobalString do
  use Ecto.Migration

  def change do
    alter table(:delegations) do
      add :global, :string
    end
  end
end
