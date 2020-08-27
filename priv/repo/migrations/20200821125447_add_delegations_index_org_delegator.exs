defmodule LiquidVoting.Repo.Migrations.AddDelegationsIndexOrgDelegator do
  use Ecto.Migration

  def change do
    create index(:delegations, [:organization_id, :delegator_id],
             name: :index_delegation_org_delegator
           )
  end
end
