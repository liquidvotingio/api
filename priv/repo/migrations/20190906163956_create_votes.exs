defmodule LiquidVoting.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :yes, :boolean, default: false, null: false
      add :weight, :integer, default: 1
      add :participant_id, references(:participants, on_delete: :nothing)
      add :proposal_url, :string, default: false, null: false

      timestamps()
    end

    create index(:votes, [:participant_id])
    create index(:votes, [:proposal_url])

    create unique_index(:votes, [:participant_id, :proposal_url],
             name: :unique_index_vote_id_participant_id_proposal_url
           )
  end
end
