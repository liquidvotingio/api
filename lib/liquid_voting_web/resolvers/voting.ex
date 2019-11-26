defmodule LiquidVotingWeb.Resolvers.Voting do
  alias LiquidVoting.{Voting,VotingResults}
  alias LiquidVotingWeb.Schema.ChangesetErrors

  def participants(_, _, _) do
    {:ok, Voting.list_participants()}
  end

  def participant(_, %{id: id}, _) do
    {:ok, Voting.get_participant!(id)}
  end

  def create_participant(_, args, _) do
    case Voting.create_participant(args) do
      {:error, changeset} ->
        {:error,
         message: "Could not create participant",
         details: ChangesetErrors.error_details(changeset)
        }

      {:ok, participant} ->
        {:ok, participant}
    end
  end

  def votes(_, %{proposal_url: proposal_url}, _) do
    {:ok, Voting.list_votes(proposal_url)}
  end

  def votes(_, _, _) do
    {:ok, Voting.list_votes()}
  end

  def vote(_, %{id: id}, _) do
    {:ok, Voting.get_vote!(id)}
  end

  def create_vote(_, %{participant_email: email, proposal_url: _, yes: _} = args, _) do
    case Voting.upsert_participant(%{email: email}) do
      {:error, changeset} ->
        {:error,
         message: "Could not create vote with given email",
         details: ChangesetErrors.error_details(changeset)
        }

      {:ok, participant} ->
        args_with_participant_id = Map.put(args, :participant_id, participant.id)

        create_vote_with_valid_arguments(args_with_participant_id)
    end
  end

  def create_vote(_, %{participant_id: _, proposal_url: _, yes: _} = args, _) do
    create_vote_with_valid_arguments(args)
  end

  def create_vote(_, %{proposal_url: _, yes: _}, _) do
    {:error, message: "Could not create vote", details: "No participant identifier (id or email) submitted"}
  end

  defp create_vote_with_valid_arguments(args) do
    case Voting.create_vote(args) do
      {:error, changeset} ->
        {:error,
         message: "Could not create vote",
         details: ChangesetErrors.error_details(changeset)
        }

      {:ok, vote} ->
        VotingResults.publish_voting_result_change(vote.proposal_url)
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