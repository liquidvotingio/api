defmodule LiquidVoting.Repo.Migrations.AddDelegationsUniqIndexOrgDelegatorProposal do
  use Ecto.Migration

  def change do
    create unique_index(:delegations, [:organization_id, :delegator_id, :proposal_url],
             name: :uniq_index_org_delegator_proposal
           )
  end
end
