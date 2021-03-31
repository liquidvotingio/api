defmodule LiquidVoting.Repo.Migrations.DropVotingMethodsUniqIndexOrgVotingMethod do
  use Ecto.Migration

  def change do
    drop unique_index(:voting_methods, [:organization_id, :voting_method],
             name: :uniq_index_org_voting_method
           )
  end
end
