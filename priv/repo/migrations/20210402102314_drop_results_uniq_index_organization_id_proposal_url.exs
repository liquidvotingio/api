defmodule LiquidVoting.Repo.Migrations.DropResultsUniqIndexOrganizationIdProposalUrl do
  use Ecto.Migration

  def change do
    drop unique_index(:results, [:organization_id, :proposal_url],
           name: :uniq_index_organization_id_proposal_url
         )
  end
end
