defmodule LiquidVoting.Repo.Migrations.DropDelegationsUniqIndexOrgDelegatorDelegateProposal do
  use Ecto.Migration

  def change do
    drop unique_index(
           :delegations,
           [:organization_id, :delegator_id, :delegate_id, :proposal_url],
           name: :uniq_index_org_delegator_delegate_proposal
         )
  end
end
