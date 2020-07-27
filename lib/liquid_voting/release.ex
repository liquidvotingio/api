defmodule LiquidVoting.Release do
  @app :liquid_voting
  @test_organization_id "bc7eeccb-5e10-4004-8bfb-7fc68536bbd7"

  alias LiquidVoting.{Delegations, Voting}

  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  @doc """
  Deletes votes, participants and delegations for the smoke tests organization_id.
  For use before and after running smoke tests.
  """
  def smoke_test_teardown() do
    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn repo ->
          Ecto.Migrator.run(repo, :up, all: true)
          run_teardown()
        end)
    end
  end

  defp run_teardown() do
    @test_organization_id
    |> Voting.list_votes()
    |> Enum.each(fn vote -> Voting.delete_vote!(vote) end)

    @test_organization_id
    |> Voting.list_participants()
    |> Enum.each(fn participant ->
      {:ok, _participant} = Voting.delete_participant(participant)
    end)

    @test_organization_id
    |> Delegations.list_delegations()
    |> Enum.each(fn delegation -> Delegations.delete_delegation!(delegation) end)
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
