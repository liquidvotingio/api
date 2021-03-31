defmodule LiquidVotingWeb.Resolvers.Voting do
  require OpenTelemetry.Tracer, as: Tracer

  alias LiquidVoting.{Voting, VotingMethods, VotingResults}
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
    Tracer.with_span "#{__MODULE__} #{inspect(__ENV__.function)}" do
      Tracer.set_attributes([
        {:request_id, Logger.metadata()[:request_id]},
        {:params, [{:organization_id, organization_id}]}
      ])

      {:ok, Voting.list_votes(organization_id)}
    end
  end

  def vote(_, %{id: id}, %{context: %{organization_id: organization_id}}),
    do: {:ok, Voting.get_vote!(id, organization_id)}

  def create_vote(
        _,
        %{participant_email: email, proposal_url: _, yes: _, voting_method: voting_method} = args,
        %{
          context: %{organization_id: organization_id}
        }
      ) do
    Tracer.with_span "#{__MODULE__} #{inspect(__ENV__.function)}" do
      Tracer.set_attributes([
        {:request_id, Logger.metadata()[:request_id]},
        {:params,
         [
           {:organization_id, organization_id},
           {:email, email}
         ]}
      ])

      case VotingMethods.upsert_voting_method(%{
             organization_id: organization_id,
             name: voting_method
           }) do
        {:error, changeset} ->
          {:error,
           message: "Could not create voting_method with given method",
           details: ChangesetErrors.error_details(changeset)}

        {:ok, voting_method} ->
          case Voting.upsert_participant(%{email: email, organization_id: organization_id}) do
            {:error, changeset} ->
              Tracer.set_attributes([
                {:result,
                 ":error, Voting.upsert_participant\nmessage: Could not create vote with given email', details: '#{
                   inspect(ChangesetErrors.error_details(changeset))
                 }'"}
              ])

              {:error,
               message: "Could not create vote with given email",
               details: ChangesetErrors.error_details(changeset)}

            {:ok, participant} ->
              Tracer.set_attributes([{:result, ":ok, Voting.upsert_participant"}])

              args
              |> Map.put(:organization_id, organization_id)
              |> Map.put(:participant_id, participant.id)
              |> Map.put(:voting_method_id, voting_method.id)
              |> create_vote_with_valid_arguments()
          end
      end
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
    IO.inspect(args)

    Tracer.with_span "#{__MODULE__} #{inspect(__ENV__.function)}" do
      Tracer.set_attributes([
        {:request_id, Logger.metadata()[:request_id]},
        {:params,
         [
           {:organization_id, args[:organization_id]},
           {:participant_email, args[:participant_email]},
           {:participant_id, args[:participant_id]},
           {:proposal_url, args[:proposal_url]},
           {:yes, args[:yes]},
           {:voting_method, args[:voting_method]}
         ]}
      ])

      case Voting.create_vote(args) do
        {:error, changeset} ->
          Tracer.set_attributes([
            {:result,
             ":error, Voting.create_vote\nmessage: Could not create vote', details: '#{
               inspect(ChangesetErrors.error_details(changeset))
             }'"}
          ])

          {:error,
           message: "Could not create vote", details: ChangesetErrors.error_details(changeset)}

        {:ok, vote} ->
          Tracer.set_attributes([{:result, ":ok, Voting.create_vote"}])

          VotingResults.publish_voting_result_change(vote.proposal_url, vote.organization_id)
          {:ok, vote}
      end
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
