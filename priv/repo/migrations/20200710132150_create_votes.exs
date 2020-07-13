defmodule LiquidVoting.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :yes, :boolean, default: false, null: false
      add :weight, :integer, default: 1

      add :participant_uuid,
          references(:participants, column: :uuid, type: :uuid, on_delete: :nothing)

      add :proposal_url, :text, default: false, null: false
      add :organization_uuid, :uuid

      timestamps()
    end

    create index(:votes, [:participant_uuid, :organization_uuid],
             name: :index_vote_participant_org
           )

    create index(:votes, [:proposal_url, :organization_uuid], name: :index_vote_proposal_org)

    create index(:votes, [:organization_uuid])

    create unique_index(:votes, [:organization_uuid, :participant_uuid, :proposal_url],
             name: :uniq_index_org_vote_participant_proposal
           )
  end
end
