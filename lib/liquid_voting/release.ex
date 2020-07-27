defmodule LiquidVoting.Release do
  @app :liquid_voting
  @test_organization_id "f30bfc59-d699-4a91-8950-6c6e0169d44a"

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
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, fn _repo -> run_teardown() end)
    end
  end

  defp print_teardown_resources_counts() do
    votes_count = fn ->
      @test_organization_id
      |> Voting.list_votes()
      |> Enum.count()
    end

    participants_count = fn ->
      @test_organization_id
      |> Voting.list_participants()
      |> Enum.count()
    end

    delegations_count = fn ->
      @test_organization_id
      |> Delegations.list_delegations()
      |> Enum.count()
    end

    IO.puts(
      "#{participants_count.()} Participants, #{votes_count.()} Votes, #{delegations_count.()} Delegations"
    )
  end

  defp run_teardown() do
    IO.puts("## About to run smoke test teardown")
    IO.puts("Current resource counts:")
    print_teardown_resources_counts()
    IO.puts("## Running smoke test teardown on test organization data")

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

    IO.puts("## Teardown ran successfully")
    IO.puts("End resource counts:")
    print_teardown_resources_counts()
    IO.puts("## Have a nice day!")
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
