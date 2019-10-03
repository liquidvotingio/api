defmodule LiquidVoting.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :yes, :boolean, default: false, null: false
      add :weight, :integer, default: 1
      add :participant_id, references(:participants, on_delete: :nothing)
      add :proposal_id, references(:proposals, on_delete: :delete_all)

      timestamps()
    end

    create index(:votes, [:participant_id])
    create index(:votes, [:proposal_id])
    create unique_index(:votes, [:participant_id, :proposal_id], name: :unique_index_vote_participant_proposal)
  end
end
