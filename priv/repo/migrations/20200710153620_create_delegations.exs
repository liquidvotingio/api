defmodule LiquidVoting.Repo.Migrations.CreateDelegations do
  use Ecto.Migration

  def change do
    create table(:delegations, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :delegator_id,
          references(:participants, column: :id, type: :uuid, on_delete: :delete_all)

      add :delegate_id,
          references(:participants, column: :id, type: :uuid, on_delete: :delete_all)

      add :proposal_url, :text
      add :organization_uuid, :uuid

      timestamps()
    end

    create index(:delegations, [:delegator_id, :organization_uuid],
             name: :index_delegation_delegator_org
           )

    create index(:delegations, [:delegate_id, :organization_uuid],
             name: :index_delegation_delegate_org
           )

    create index(:delegations, [:proposal_url, :organization_uuid],
             name: :index_delegation_proposal_org
           )

    create index(:delegations, [:organization_uuid])

    create unique_index(:delegations, [:organization_uuid, :delegator_id, :delegate_id],
             name: :uniq_index_org_delegator_delegate
           )
  end
end
