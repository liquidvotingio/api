defmodule LiquidVoting.Repo.Migrations.CreateDelegations do
  use Ecto.Migration

  def change do
    create table(:delegations) do
      add :delegator_id, references(:participants, on_delete: :delete_all)
      add :delegate_id, references(:participants, on_delete: :delete_all)

      timestamps()
    end

    create index(:delegations, [:delegator_id])
    create index(:delegations, [:delegate_id])
  end
end
