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

  def votes(_, %{proposal_url: proposal_url} = args, %{
        context: %{organization_id: organization_id}
      }) do
    voting_method_name = Map.get(args, :voting_method) || "default"
    voting_method = VotingMethods.get_voting_method_by_name(voting_method_name, organization_id)

    case voting_method do
      nil -> {:ok, []}
      _ -> {:ok, Voting.list_votes_by_proposal(voting_method.id, proposal_url, organization_id)}
    end
  end

  def votes(_, %{voting_method: _voting_method}, _),
    do: {:error, message: "A proposal url must also be given when a voting method is specified"}

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
        %{participant_email: email, proposal_url: _, yes: _} = args,
        %{
          context: %{organization_id: organization_id}
        }
      ) do
    voting_method_name = Map.get(args, :voting_method)

    Tracer.with_span "#{__MODULE__} #{inspect(__ENV__.function)}" do
      Tracer.set_attributes([
        {:request_id, Logger.metadata()[:request_id]},
        {:params,
         [
           {:organization_id, organization_id},
           {:email, email},
           {:voting_method, voting_method_name}
         ]}
      ])

      Multi.new()
      |> Multi.run(:upsert_voting_method, fn _repo, _changes ->
        VotingMethods.upsert_voting_method(%{
          organization_id: organization_id,
          name: voting_method_name
        })
      end)
      |> Multi.run(:upsert_participant, fn _repo, _changes ->
        Voting.upsert_participant(%{email: email, organization_id: organization_id})
      end)
      |> Multi.run(:create_vote, fn _repo, changes ->
        args
        |> Map.put(:organization_id, organization_id)
        |> Map.put(:voting_method_id, changes.upsert_voting_method.id)
        |> Map.put(:participant_id, changes.upsert_participant.id)
        |> create_vote_with_valid_arguments()
      end)
      |> Repo.transaction()
      |> case do
        {:ok, resources} ->
          {:ok, resources.create_vote}

        {:error, action, changeset, _} ->
          changeset = Ecto.Changeset.add_error(changeset, :action, "#{action}")

          {:error,
           message: "Could not create vote", details: ChangesetErrors.error_details(changeset)}

        error ->
          error
      end
    end
  end

  def create_vote(
        _,
        %{participant_id: _, proposal_url: _, yes: _, voting_method: voting_method} = args,
        %{
          context: %{organization_id: organization_id}
        }
      ) do
    case VotingMethods.upsert_voting_method(%{
           organization_id: organization_id,
           name: voting_method
         }) do
      {:error, changeset} ->
        changeset = Ecto.Changeset.add_error(changeset, :action, "voting_method")

        {:error,
         message: "Could not create voting method",
         details: ChangesetErrors.error_details(changeset)}

      {:ok, voting_method} ->
        args
        |> Map.put(:organization_id, organization_id)
        |> Map.put(:voting_method_id, voting_method.id)
        |> create_vote_with_valid_arguments()
    end
  end

  def create_vote(_, %{proposal_url: _, yes: _, voting_method: _}, _),
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
           {:voting_method, args[:voting_method]},
           {:voting_method_id, args[:voting_method_id]},
           {:yes, args[:yes]}
         ]}
      ])

      case Voting.create_vote(args) do
        {:error, changeset} ->
          {:error, changeset}

        {:ok, vote} ->
          Tracer.set_attributes([{:result, ":ok, Voting.create_vote"}])

          VotingResults.publish_voting_result_change(
            vote.voting_method_id,
            vote.proposal_url,
            vote.organization_id
          )

          {:ok, vote}
      end
    end
  end

  def delete_vote(
        _,
        %{
          participant_email: email,
          proposal_url: proposal_url
        } = args,
        %{
          context: %{organization_id: organization_id}
        }
      ) do
    voting_method_name = Map.get(args, :voting_method) || "default"

    voting_method = VotingMethods.get_voting_method_by_name!(voting_method_name, organization_id)

    deleted_vote =
      Voting.get_vote!(email, voting_method.id, proposal_url, organization_id)
      |> Voting.delete_vote!()

    VotingResults.publish_voting_result_change(
      voting_method.id,
      deleted_vote.proposal_url,
      deleted_vote.organization_id
    )

    {:ok, deleted_vote}
  rescue
    Ecto.NoResultsError -> {:error, message: "No vote found to delete"}
  end
end
