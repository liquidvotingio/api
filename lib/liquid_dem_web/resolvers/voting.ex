defmodule LiquidDemWeb.Resolvers.Voting do
  alias LiquidDem.Voting

  def participants(_, _, _) do
    {:ok, Voting.list_participants()}
  end

  def participant(_, %{id: id}, _) do
    {:ok, Voting.get_participant!(id)}
  end

  def proposals(_, _, _) do
    {:ok, Voting.list_proposals()}
  end

  def proposal(_, %{id: id}, _) do
    {:ok, Voting.get_proposal!(id)}
  end

  def votes(_, _, _) do
    {:ok, Voting.list_votes()}
  end

  def vote(_, %{id: id}, _) do
    {:ok, Voting.get_vote!(id)}
  end
end