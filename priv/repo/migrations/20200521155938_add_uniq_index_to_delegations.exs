defmodule LiquidVoting.Repo.Migrations.AddUniqIndexToDelegations do
  use Ecto.Migration

  def change do
    create unique_index(:delegations, [:organization_uuid, :delegator_id, :delegate_id],
             name: :uniq_index_org_delegator_delegate
           )
  end
end
