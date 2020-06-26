defmodule LiquidVoting.Repo.Migrations.AddOrgUuidToResultProposalIndex do
  use Ecto.Migration

  def change do
    drop unique_index(:results, [:proposal_url])

    create unique_index(:results, [:organization_uuid, :proposal_url],
             name: :uniq_index_organization_uuid_proposal_url
           )
  end
end
