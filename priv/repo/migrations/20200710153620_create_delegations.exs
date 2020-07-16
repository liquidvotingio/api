defmodule LiquidVoting.Repo.Migrations.CreateDelegations do
  use Ecto.Migration

  def change do
    create table(:delegations) do
      add :delegator_id, references(:participants, on_delete: :delete_all)
      add :delegate_id, references(:participants, on_delete: :delete_all)
      add :proposal_url, :text
      add :organization_id, :uuid

      timestamps()
    end

    create index(:delegations, [:delegator_id, :organization_id],
             name: :index_delegation_delegator_org
           )

    create index(:delegations, [:delegate_id, :organization_id],
             name: :index_delegation_delegate_org
           )

    create index(:delegations, [:proposal_url, :organization_id],
             name: :index_delegation_proposal_org
           )

    create index(:delegations, [:organization_id])

    create unique_index(:delegations, [:organization_id, :delegator_id, :delegate_id],
             name: :uniq_index_org_delegator_delegate
           )
  end
end
