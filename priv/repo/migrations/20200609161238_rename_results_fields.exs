defmodule LiquidVoting.Repo.Migrations.RenameResultsFields do
  use Ecto.Migration

  def change do
    rename table("results"), :yes, to: :in_favor
    rename table("results"), :no,  to: :against
  end
end
