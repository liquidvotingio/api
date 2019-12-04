defmodule LiquidVoting.Repo.Migrations.ChangeVotesProposalUrlToText do
  use Ecto.Migration

  def change do
    alter table(:votes) do
      modify :proposal_url, :text
    end
  end
end
