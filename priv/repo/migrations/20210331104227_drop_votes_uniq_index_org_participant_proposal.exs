defmodule LiquidVoting.Repo.Migrations.DropVotesUniqIndexOrgParticipantProposal do
  use Ecto.Migration

  def change do
    drop unique_index(:votes, [:organization_id, :participant_id, :proposal_url],
           name: :uniq_index_org_vote_participant_proposal
         )
  end
end
