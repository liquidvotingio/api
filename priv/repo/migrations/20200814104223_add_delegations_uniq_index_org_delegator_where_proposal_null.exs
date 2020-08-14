defmodule LiquidVoting.Repo.Migrations.AddDelegationsUniqIndexOrgDelegatorWhereProposalNull do
  use Ecto.Migration

  def up do
    execute """
    CREATE UNIQUE INDEX uniq_index_org_delegator_where_proposal_null ON delegations (organization_id, delegator_id)
    WHERE proposal_url IS NULL;
    """
  end

  def down do
    drop unique_index(:delegations, [:organization_id, :delegator_id],
           name: :uniq_index_org_delegator_where_proposal_null
         )
  end
end
