defmodule LiquidVoting.Repo.Migrations.AddProposalUrlToDelegations do
  use Ecto.Migration

  def change do
    alter table(:delegations) do
      add :proposal_url, :text
    end

    create index(:delegations, [:proposal_url])
  end
end
