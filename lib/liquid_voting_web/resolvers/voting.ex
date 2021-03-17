defmodule LiquidVotingWeb.Resolvers.Voting do
  require OpenTelemetry.Tracer, as: Tracer

  alias LiquidVoting.{Voting, VotingResults}
  alias LiquidVotingWeb.Schema.ChangesetErrors

  def participants(_, _, %{context: %{organization_id: organization_id}}),
    do: {:ok, Voting.list_participants(organization_id)}

  def participant(_, %{id: id}, %{context: %{organization_id: organization_id}}),
    do: {:ok, Voting.get_participant!(id, organization_id)}

  def create_participant(_, args, %{context: %{organization_id: organization_id}}) do
    args = Map.put(args, :organization_id, organization_id)

    case Voting.create_participant(args) do
      {:error, changeset} ->
        {:error,
         message: "Could not create participant",
         details: ChangesetErrors.error_details(changeset)}

      {:ok, participant} ->
        {:ok, participant}
    end
  end

  def votes(_, %{proposal_url: proposal_url}, %{context: %{organization_id: organization_id}}),
    do: {:ok, Voting.list_votes_by_proposal(proposal_url, organization_id)}

  def votes(_, _, %{context: %{organization_id: organization_id}}) do
    Tracer.with_span "resolvers/voting" do
      Tracer.set_attributes([
        {:action, "votes"},
        {:request_id, Logger.metadata()[:request_id]},
        {:organization_id, organization_id}
      ])

      {:ok, Voting.list_votes(organization_id)}
    end
  end

  def vote(_, %{id: id}, %{context: %{organization_id: organization_id}}),
    do: {:ok, Voting.get_vote!(id, organization_id)}

  def create_vote(_, %{participant_email: email, proposal_url: _, yes: _} = args, %{
        context: %{organization_id: organization_id}
      }) do
    case Voting.upsert_participant(%{email: email, organization_id: organization_id}) do
      {:error, changeset} ->
        {:error,
         message: "Could not create vote with given email",
         details: ChangesetErrors.error_details(changeset)}

      {:ok, participant} ->
        args
        |> Map.put(:organization_id, organization_id)
        |> Map.put(:participant_id, participant.id)
        |> create_vote_with_valid_arguments()
    end
  end

  def create_vote(_, %{participant_id: _, proposal_url: _, yes: _} = args, %{
        context: %{organization_id: organization_id}
      }) do
    args
    |> Map.put(:organization_id, organization_id)
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
        VotingResults.publish_voting_result_change(vote.proposal_url, vote.organization_id)
        {:ok, vote}
    end
  end

  def delete_vote(_, %{participant_email: email, proposal_url: proposal_url}, %{
        context: %{organization_id: organization_id}
      }) do
    deleted_vote = Voting.get_vote!(email, proposal_url, organization_id) |> Voting.delete_vote!()

    VotingResults.publish_voting_result_change(
      deleted_vote.proposal_url,
      deleted_vote.organization_id
    )

    {:ok, deleted_vote}
  rescue
    Ecto.NoResultsError -> {:error, message: "No vote found to delete"}
  end
end
