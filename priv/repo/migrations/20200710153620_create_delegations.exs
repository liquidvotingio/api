defmodule LiquidVoting.Repo.Migrations.CreateDelegations do
  use Ecto.Migration

  def change do
    create table(:delegations) do
      add :delegator_id, references(:participants, on_delete: :delete_all)
      add :delegate_id, references(:participants, on_delete: :delete_all)
      add :proposal_url, :text
      add :organization_id, :uuid, null: false

      timestamps()
    end

    create index(:delegations, [:organization_id, :delegator_id],
             name: :index_delegation_delegator_org
           )

    create index(:delegations, [:organization_id, :delegate_id],
             name: :index_delegation_delegate_org
           )

    create index(:delegations, [:organization_id, :proposal_url],
             name: :index_delegation_proposal_org
           )

    create index(:delegations, [:organization_id])

    create unique_index(:delegations, [:organization_id, :delegator_id, :delegate_id],
             name: :uniq_index_org_delegator_delegate
           )
  end
end
