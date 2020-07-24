defmodule LiquidVoting.Release do
  @app :liquid_voting

  alias LiquidVoting.{Delegations, Voting}
  alias LiquidVoting.Voting.Participant

  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  @doc """
  Deletes votes, participants and delegations data created by smoke tests.
  For use before and after running smoke tests.
  """
  def teardown(organization_id) do
    votes = Voting.list_votes(organization_id)
    Enum.each(votes, fn vote -> Voting.delete_vote!(vote) end)

    participants = Voting.list_participants(organization_id)

    Enum.each(participants, fn %Participant{} = participant ->
      Voting.delete_participant(participant)
    end)

    delegations = Delegations.list_delegations(organization_id)
    Enum.each(delegations, fn delegation -> Delegations.delete_delegation!(delegation) end)
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
