defmodule LiquidVoting.Repo.Migrations.RenameVotingMethodsVotingMethodToName do
  use Ecto.Migration

  def change do
    rename table(:voting_methods), :voting_method, to: :name
  end
end
