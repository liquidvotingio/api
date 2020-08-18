defmodule LiquidVoting.Repo.Migrations.AddDelegationsUniqIndexOrgDelegatorGlobal do
  use Ecto.Migration

  def change do
    create unique_index(:delegations, [:organization_id, :delegator_id, :global],
             name: :uniq_index_org_delegator_global
           )
  end
end
