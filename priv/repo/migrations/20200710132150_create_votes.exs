defmodule LiquidVoting.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :yes, :boolean, default: false, null: false
      add :weight, :integer, default: 1
      add :participant_id, references(:participants, on_delete: :nothing)
      add :proposal_url, :text, default: false, null: false
      add :organization_id, :uuid, null: false

      timestamps()
    end

    create index(:votes, [:participant_id, :organization_id], name: :index_vote_participant_org)
    create index(:votes, [:proposal_url, :organization_id], name: :index_vote_proposal_org)
    create index(:votes, [:organization_id])

    create unique_index(:votes, [:organization_id, :participant_id, :proposal_url],
             name: :uniq_index_org_vote_participant_proposal
           )
  end
end
