defmodule LiquidVoting.Repo.Migrations.CreateVotingMethodsUniqIndexOrgName do
  use Ecto.Migration

  def change do
    create unique_index(:voting_methods, [:organization_id, :name],
             name: :uniq_index_org_name
           )
  end
end
