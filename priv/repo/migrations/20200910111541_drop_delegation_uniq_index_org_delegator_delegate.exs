defmodule LiquidVoting.Repo.Migrations.DropDelegationUniqIndexOrgDelegatorDelegate do
  use Ecto.Migration

  def change do
    drop unique_index(:delegations, [:organization_id, :delegator_id, :delegate_id],
           name: :uniq_index_org_delegator_delegate
         )
  end
end
