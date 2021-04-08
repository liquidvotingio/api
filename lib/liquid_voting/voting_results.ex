defmodule LiquidVoting.VotingResults do
  @moduledoc """
  The VotingResults context.
  """

  require OpenTelemetry.Tracer, as: Tracer

  import Ecto.Query, warn: false

  alias __MODULE__.Result
  alias LiquidVoting.{Repo, Voting, VotingWeight}

  @doc """
  Creates or updates voting result based on votes
  given to a proposal within the scope of a organization_id

  ## Examples

      iex> calculate_result!(
        "https://www.medium/user/eloquent_proposal",
        "a6158b19-6bf6-4457-9d13-ef8b141611b4"
        )
      %Result{}

  """
  def calculate_result!(voting_method_id, proposal_url, organization_id) do
    Tracer.with_span "#{__MODULE__} #{inspect(__ENV__.function)}" do
      Tracer.set_attributes([
        {:request_id, Logger.metadata()[:request_id]},
        {:params,
         [
           {:organization_id, organization_id},
           {:proposal_url, proposal_url},
           {:voting_method_id, voting_method_id}
         ]}
      ])

      votes = Voting.list_votes_by_proposal(voting_method_id, proposal_url, organization_id)

      attrs = %{
        in_favor: 0,
        against: 0,
        proposal_url: proposal_url,
        voting_method_id: voting_method_id,
        organization_id: organization_id
      }

      attrs =
        Enum.reduce(votes, attrs, fn vote, attrs ->
          {:ok, vote} = VotingWeight.update_vote_weight(vote)

          if vote.yes do
            Map.update!(attrs, :in_favor, &(&1 + vote.weight))
          else
            Map.update!(attrs, :against, &(&1 + vote.weight))
          end
        end)

      %Result{}
      |> Result.changeset(attrs)
      |> Repo.insert!(
        on_conflict: {:replace_all_except, [:id]},
        conflict_target: [:organization_id, :proposal_url, :voting_method_id],
        returning: true
      )
    end
  end

  @doc """
  Publishes voting result changes to Absinthe's pubsub, so clients can receive updates in real-time

  ## Example

      iex> publish_voting_result_change(
        "https://www.medium/user/eloquent_proposal",
        "a6158b19-6bf6-4457-9d13-ef8b141611b4"
        )
      :ok

  """
  def publish_voting_result_change(voting_method_id, proposal_url, organization_id) do
    Tracer.with_span "#{__MODULE__} #{inspect(__ENV__.function)}" do
      Tracer.set_attributes([
        {:request_id, Logger.metadata()[:request_id]},
        {:params,
         [
           {:organization_id, organization_id},
           {:proposal_url, proposal_url},
           {:voting_method_id, voting_method_id}
         ]}
      ])

      result = calculate_result!(voting_method_id, proposal_url, organization_id)

      Absinthe.Subscription.publish(
        LiquidVotingWeb.Endpoint,
        result,
        voting_result_change: proposal_url
      )
    end
  end

  @doc """
  Publishes voting result changes to Absinthe's pubsub for all results related
  to a specific user's votes.

  This is called by both the create_delegation/3 and delete_delegation/3 defs in
  the absinthe layer lib/liquid_voting/reolvers/delegations.ex file. This ensures
  that related voting results AND Absinthe's pubsub are updated accordingly.

  ## Example

      iex> publish_voting_result_changes_for_participant(
        "377ead47-05f1-46b5-a676-f13b619623a7",
        "a6158b19-6bf6-4457-9d13-ef8b141611b4"
        )
      :ok

  """
  def publish_voting_result_changes_for_participant(participant_id, organization_id) do
    Voting.list_votes_by_participant(participant_id, organization_id)
    |> Enum.each(fn vote ->
      publish_voting_result_change(vote.voting_method_id, vote.proposal_url, organization_id)
    end)
  end

  @doc """
  Returns the list of results in the scope of a organization_id.

  ## Examples

      iex> list_results("a6158b19-6bf6-4457-9d13-ef8b141611b4")
      [%Result{}, ...]

  """
  def list_results(organization_id) do
    Result
    |> where(organization_id: ^organization_id)
    |> Repo.all()
    |> Repo.preload([:voting_method])
  end

  @doc """
  Returns the list of results for a proposal_url, in the scope of a organization_id.

  ## Examples

      iex> list_results("https://our-proposals/proposal1", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      [%Result{}, ...]

  """
  def list_results_for_proposal_url(proposal_url, organization_id) do
    Result
    |> where(organization_id: ^organization_id, proposal_url: ^proposal_url)
    |> Repo.all()
    |> Repo.preload([:voting_method])
  end

  @doc """
  Gets a single result for an organization_id

  Raises `Ecto.NoResultsError` if the Result does not exist.

  ## Examples

      iex> get_result!(
        "ec15b5d3-bfff-4ca6-a56a-78a460b2d38f",
        "a6158b19-6bf6-4457-9d13-ef8b141611b4"
        )
      %Result{}

      iex> get_result!(
        "1a1d0de6-1706-4a8e-8e34-d6aea3fa9e19",
        "a6158b19-6bf6-4457-9d13-ef8b141611b4"
        )
      ** (Ecto.NoResultsError)

  """
  def get_result!(id, organization_id) do
    Repo.get_by!(Result, id: id, organization_id: organization_id)
    |> Repo.preload([:voting_method])
  end

  @doc """
  Gets a single result by its voting_method_id, proposal url and organization_id

  Returns `nil` if the Result does not exist.

  ## Examples

      iex> get_result_by_proposal_url(
        "377ead47-05f1-46b5-a676-f13b619623a7",
        "https://www.myproposal.com/",
        "a6158b19-6bf6-4457-9d13-ef8b141611b4"
        )
      %Result{}

      iex> get_result_by_proposal_url(
        "377ead47-05f1-46b5-a676-f13b619623a7",
        "https://nonexistentproposal.com/",
        "a6158b19-6bf6-4457-9d13-ef8b141611b4"
        )
      nil

  """
  def get_result_by_proposal_url(voting_method_id, proposal_url, organization_id) do
    Repo.get_by(Result,
      voting_method_id: voting_method_id,
      proposal_url: proposal_url,
      organization_id: organization_id
    )
    |> Repo.preload([:voting_method])
  end

  @doc """
  Creates a result.

  ## Examples

      iex> create_result(%{field: value})
      {:ok, %Result{}}

      iex> create_result(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_result(attrs \\ %{}) do
    %Result{}
    |> Result.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a result.

  ## Examples

      iex> create_result(%{field: value})
      %Result{}

      iex> create_result(%{field: bad_value})
      Ecto.*Error

  """
  def create_result!(attrs \\ %{}) do
    %Result{}
    |> Result.changeset(attrs)
    |> Repo.insert!()
  end
end
