defmodule LiquidVotingWeb.Resolvers.Voting do
  require OpenTelemetry.Tracer, as: Tracer

  alias LiquidVoting.{Repo, Voting, VotingMethods, VotingResults}
  alias LiquidVotingWeb.Schema.ChangesetErrors
  alias Ecto.Multi

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
           {:email, email},
           {:voting_method, voting_method}
         ]}
      ])

      Multi.new()
      |> Multi.run(:upsert_voting_method, fn _repo, _changes ->
        VotingMethods.upsert_voting_method(%{
          organization_id: organization_id,
          name: voting_method
        })
      end)
      |> Multi.run(:upsert_participant, fn _repo, _changes ->
        Voting.upsert_participant(%{email: email, organization_id: organization_id})
      end)
      |> Multi.run(:create_vote_with_valid_arguments, fn _repo, changes ->
        args
        |> Map.put(:organization_id, organization_id)
        |> Map.put(:voting_method_id, changes.upsert_voting_method.id)
        |> Map.put(:participant_id, changes.upsert_participant.id)
        |> create_vote_with_valid_arguments()
      end)
      |> Repo.transaction()
      |> case do
        {:ok, resources} ->
          IO.inspect(resources)
          {:ok, resources.create_vote_with_valid_arguments}

        {:error, :upsert_voting_method, changeset, _} ->
          {:error,
           message: "Could not create vote", details: ChangesetErrors.error_details(changeset)}

        {:error, :upsert_participant, changeset, _} ->
          {:error,
           message: "Could not create vote", details: ChangesetErrors.error_details(changeset)}

        {:error, :create_vote_with_valid_arguments, value, _} ->
          {:error, value}

        error ->
          error
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

  def create_vote(_, %{participant_email: _, proposal_url: _, yes: _}, _),
    do: {:error, message: "Could not create vote", details: "No voting method specified"}

  def create_vote(_, %{proposal_url: _, yes: _, voting_method: voting_method}, _),
    do:
      {:error,
       message: "Could not create vote",
       details: "No participant identifier (id or email) submitted"}

  defp create_vote_with_valid_arguments(args) do
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
