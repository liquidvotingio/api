defmodule LiquidVoting.Release do
  @app :liquid_voting

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
  Deletes votes, participants and delegations for a smoke tests organization_id.
  For use before and after running smoke tests.
  """

  def teardown() do
    organization_id = "bc7eeccb-5e10-4004-8bfb-7fc68536bbd7"

    votes = Voting.list_votes(organization_id)
    Enum.each(votes, fn vote -> Voting.delete_vote!(vote) end)

    participants = Voting.list_participants(organization_id)

    Enum.each(participants, fn participant ->
      {:ok, _participant} = Voting.delete_participant(participant)
    end)

    delegations = Delegations.list_delegations(organization_id)
    Enum.each(delegations, fn delegation -> Delegations.delete_delegation!(delegation) end)
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
