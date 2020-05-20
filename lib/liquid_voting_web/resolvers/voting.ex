defmodule LiquidVotingWeb.Resolvers.Voting do
  alias LiquidVoting.{Voting,VotingResults}
  alias LiquidVotingWeb.Schema.ChangesetErrors

  def participants(_, _, %{context: %{organization_uuid: organization_uuid}}) do
    {:ok, Voting.list_participants(organization_uuid)}
  end

  def participant(_, %{id: id}, %{context: %{organization_uuid: organization_uuid}}) do
    {:ok, Voting.get_participant!(id, organization_uuid)}
  end

  def create_participant(_, args, %{context: %{organization_uuid: organization_uuid}}) do
    args = Map.put(args, :organization_uuid, organization_uuid)

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

  def votes(_, %{proposal_url: proposal_url}, %{context: %{organization_uuid: organization_uuid}}) do
    {:ok, Voting.list_votes(proposal_url, organization_uuid)}
  end

  def votes(_, _, %{context: %{organization_uuid: organization_uuid}}) do
    {:ok, Voting.list_votes(organization_uuid)}
  end

  def vote(_, %{id: id}, %{context: %{organization_uuid: organization_uuid}}) do
    {:ok, Voting.get_vote!(id, organization_uuid)}
  end

  def create_vote(_, %{participant_email: email, proposal_url: _, yes: _} = args, %{context: %{organization_uuid: organization_uuid}}) do
    case Voting.upsert_participant(%{email: email, organization_uuid: organization_uuid}) do
      {:error, changeset} ->
        {:error,
         message: "Could not create vote with given email",
         details: ChangesetErrors.error_details(changeset)
        }

      {:ok, participant} ->
        args = Map.put(args, :organization_uuid, organization_uuid)
        args = Map.put(args, :participant_id, participant.id)
        create_vote_with_valid_arguments(args)
    end
  end

  def create_vote(_, %{participant_id: _, proposal_url: _, yes: _} = args, %{context: %{organization_uuid: organization_uuid}}) do
    args = Map.put(args, :organization_uuid, organization_uuid)
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
        VotingResults.publish_voting_result_change(vote.proposal_url, vote.organization_uuid)
        {:ok, vote}
    end
  end

  def delegations(_, _, %{context: %{organization_uuid: organization_uuid}}) do
    {:ok, Voting.list_delegations(organization_uuid)}
  end

  def delegation(_, %{id: id}, %{context: %{organization_uuid: organization_uuid}}) do
    {:ok, Voting.get_delegation!(id, organization_uuid)}
  end

  def create_delegation(_, %{delegator_email: delegator_email, delegate_email: delegate_email} = args, %{context: %{organization_uuid: organization_uuid}}) do
    case Voting.upsert_participant(%{email: delegator_email, organization_uuid: organization_uuid}) do
      {:error, changeset} ->
        {:error,
         message: "Could not create delegation with given email",
         details: ChangesetErrors.error_details(changeset)
        }

      {:ok, delegator} ->
        args = Map.put(args, :delegator_id, delegator.id)
        args = Map.put(args, :organization_uuid, organization_uuid)

        case Voting.upsert_participant(%{email: delegate_email, organization_uuid: organization_uuid}) do
          {:error, changeset} ->
            {:error,
             message: "Could not create delegation with given email",
             details: ChangesetErrors.error_details(changeset)
            }

          {:ok, delegate} ->
            args = Map.put(args, :delegate_id, delegate.id)
            create_delegation_with_valid_arguments(args)
        end
    end
  end

  def create_delegation(_, %{} = args, %{context: %{organization_uuid: organization_uuid}}) do
    args = Map.put(args, :organization_uuid, organization_uuid)
    create_delegation_with_valid_arguments(args)
  end

  def create_delegation_with_valid_arguments(args) do
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