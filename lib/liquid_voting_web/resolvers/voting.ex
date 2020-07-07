defmodule LiquidVotingWeb.Resolvers.Voting do
  alias LiquidVoting.{Voting, VotingResults}
  alias LiquidVotingWeb.Schema.ChangesetErrors

  def participants(_, _, %{context: %{organization_uuid: organization_uuid}}),
    do: {:ok, Voting.list_participants(organization_uuid)}

  def participant(_, %{uuid: uuid}, %{context: %{organization_uuid: organization_uuid}}),
    do: {:ok, Voting.get_participant!(uuid, organization_uuid)}

  #def participant(_, %{uuid: uuid}, %{context: %{organization_uuid: organization_uuid}}),
    #do: {:ok, Voting.get_participant_by_uuid(uuid, organization_uuid)}

  def create_participant(_, args, %{context: %{organization_uuid: organization_uuid}}) do
    args = Map.put(args, :organization_uuid, organization_uuid)

    case Voting.create_participant(args) do
      {:error, changeset} ->
        {:error,
         message: "Could not create participant",
         details: ChangesetErrors.error_details(changeset)}

      {:ok, participant} ->
        {:ok, participant}
    end
  end

  def votes(_, %{proposal_url: proposal_url}, %{context: %{organization_uuid: organization_uuid}}),
    do: {:ok, Voting.list_votes(proposal_url, organization_uuid)}

  def votes(_, _, %{context: %{organization_uuid: organization_uuid}}),
    do: {:ok, Voting.list_votes(organization_uuid)}

  def vote(_, %{id: id}, %{context: %{organization_uuid: organization_uuid}}),
    do: {:ok, Voting.get_vote!(id, organization_uuid)}

  def create_vote(_, %{participant_email: email, proposal_url: _, yes: _} = args, %{
        context: %{organization_uuid: organization_uuid}
      }) do
    case Voting.upsert_participant(%{email: email, organization_uuid: organization_uuid}) do
      {:error, changeset} ->
        {:error,
         message: "Could not create vote with given email",
         details: ChangesetErrors.error_details(changeset)}

      {:ok, participant} ->
        args
        |> Map.put(:organization_uuid, organization_uuid)
        |> Map.put(:participant_id, participant.id)
        |> create_vote_with_valid_arguments()
    end
  end

  def create_vote(_, %{participant_id: _, proposal_url: _, yes: _} = args, %{
        context: %{organization_uuid: organization_uuid}
      }) do
    args
    |> Map.put(:organization_uuid, organization_uuid)
    |> create_vote_with_valid_arguments()
  end

  def create_vote(_, %{proposal_url: _, yes: _}, _),
    do:
      {:error,
       message: "Could not create vote",
       details: "No participant identifier (id or email) submitted"}

  defp create_vote_with_valid_arguments(args) do
    case Voting.create_vote(args) do
      {:error, changeset} ->
        {:error,
         message: "Could not create vote", details: ChangesetErrors.error_details(changeset)}

      {:ok, vote} ->
        VotingResults.publish_voting_result_change(vote.proposal_url, vote.organization_uuid)
        {:ok, vote}
    end
  end

  def delete_vote(_, %{participant_email: email, proposal_url: proposal_url}, %{
        context: %{organization_uuid: organization_uuid}
      }) do
    deleted_vote =
      Voting.get_vote!(email, proposal_url, organization_uuid) |> Voting.delete_vote!()

    VotingResults.publish_voting_result_change(
      deleted_vote.proposal_url,
      deleted_vote.organization_uuid
    )

    {:ok, deleted_vote}
  rescue
    Ecto.NoResultsError -> {:error, message: "No vote found to delete"}
  end
end
