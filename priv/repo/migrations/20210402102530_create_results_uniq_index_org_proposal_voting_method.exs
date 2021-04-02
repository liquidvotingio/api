defmodule LiquidVoting.Repo.Migrations.CreateResultsUniqIndexOrgProposalVotingMethod do
  use Ecto.Migration

  def change do
    create unique_index(:results, [:organization_id, :proposal_url, :voting_method_id],
             name: :uniq_index_org_proposal_voting_method
           )
  end
end
