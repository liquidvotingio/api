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

  def create_vote(_, args, _) do
    case Voting.create_vote(args) do
      {:error, changeset} ->
        {:error,
         message: "Could not create vote",
         details: ChangesetErrors.error_details(changeset)
        }

      {:ok, vote} ->
        {:ok, vote}
    end
  end

  def delegations(_, _, _) do
    {:ok, Voting.list_delegations()}
  end

  def delegation(_, %{id: id}, _) do
    {:ok, Voting.get_delegation!(id)}
  end

  def create_delegation(_, args, _) do
    case Voting.create_delegation(args) do
      {:error, changeset} ->
        {:error,
         message: "Could not create delegation",
         details: ChangesetErrors.error_details(changeset)
        }

      {:ok, delegation} ->
        {:ok, delegation}
    end
  end
end