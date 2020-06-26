defmodule LiquidVoting.Repo.Migrations.UpdateVoteCompositeIndexWithOrganizationUuid do
  use Ecto.Migration

  def change do
    drop unique_index(:votes, [:participant_id, :proposal_url],
           name: :unique_index_vote_id_participant_id_proposal_url
         )

    create unique_index(:votes, [:organization_uuid, :participant_id, :proposal_url],
             name: :uniq_index_org_vote_participant_proposal
           )
  end
end
