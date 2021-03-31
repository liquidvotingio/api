defmodule LiquidVoting.Repo.Migrations.CreateVotesUniqIndexOrgParticipantProposalVotingMethod do
  use Ecto.Migration

  def change do
    create unique_index(
             :votes,
             [:organization_id, :participant_id, :proposal_url, :voting_method_id],
             name: :uniq_index_org_vote_participant_proposal_voting_method
           )
  end
end
