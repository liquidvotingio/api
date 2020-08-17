defmodule LiquidVoting.Repo.Migrations.AddDelegationsUniqIndexOrgDelegatorGlobalWhereGlobalTrue do
  use Ecto.Migration

  def change do
    create unique_index(:delegations, [:organization_id, :delegator_id, :global],
             where: "global = true",
             name: :uniq_index_org_delegator_global_where_global_true
           )
  end
end
