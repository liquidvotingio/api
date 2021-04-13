defmodule LiquidVoting.Repo.Migrations.CreateDelegationsUniqIndexOrgDelegatorDelegateProposalVotingMethod do
  use Ecto.Migration

  def change do
    create unique_index(
             :delegations,
             [:organization_id, :delegator_id, :delegate_id, :proposal_url, :voting_method_id],
             name: :uniq_index_org_delegator_delegate_proposal_voting_method
           )
  end
end
