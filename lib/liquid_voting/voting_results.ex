defmodule LiquidVoting.VotingResults do
  @moduledoc """
  The VotingResults context.
  """

  import Ecto.Query, warn: false
  alias LiquidVoting.Repo
  alias LiquidVoting.Voting
  alias LiquidVoting.VotingWeight
  alias LiquidVoting.VotingResults.Result

  @doc """
  Creates or updates voting result based on votes
  given to a proposal within the scope of a organization_uuid

  ## Examples

      iex> calculate_result!("https://www.medium/user/eloquent_proposal", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Result{}

  """
  def calculate_result!(proposal_url, organization_uuid) do
    votes = Voting.list_votes(proposal_url, organization_uuid)

    attrs = %{
      yes: 0,
      no: 0,
      proposal_url: proposal_url,
      organization_uuid: organization_uuid
    }

    attrs =
      Enum.reduce votes, attrs, fn (vote, attrs) ->
        {:ok, vote} = VotingWeight.update_vote_weight(vote)

        if vote.yes do
          Map.update!(attrs, :yes, &(&1 + vote.weight))
        else
          Map.update!(attrs, :no, &(&1 + vote.weight))
        end
      end

    %Result{}
    |> Result.changeset(attrs)
    |> Repo.insert!(
      on_conflict: :replace_all_except_primary_key,
      conflict_target: [:organization_uuid, :proposal_url]
      )
  end

  @doc """
  Publishes voting result changes to Absinthe's pubsub, so clients can receive updates in real-time

  ## Examples

      iex> publish_voting_result_change("https://www.medium/user/eloquent_proposal", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      :ok

  """
  def publish_voting_result_change(proposal_url, organization_uuid) do
    result = calculate_result!(proposal_url, organization_uuid)

    Absinthe.Subscription.publish(
      LiquidVotingWeb.Endpoint,
      result,
      voting_result_change: proposal_url
    )
  end

  @doc """
  Returns the list of results in the scope of a organization_uuid.

  ## Examples

      iex> list_results("a6158b19-6bf6-4457-9d13-ef8b141611b4")
      [%Result{}, ...]

  """
  def list_results(organization_uuid) do
    Result
    |> where(organization_uuid: ^organization_uuid)
    |> Repo.all()
  end

  @doc """
  Gets a single result for an organization_uuid

  Raises `Ecto.NoResultsError` if the Result does not exist.

  ## Examples

      iex> get_result!(123, "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Result{}

      iex> get_result!(456, "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      ** (Ecto.NoResultsError)

  """
  def get_result!(id, organization_uuid) do
    Result
    |> Repo.get_by!([id: id, organization_uuid: organization_uuid])
  end

  @doc """
  Gets a single result by its proposal url and organization_uuid

  Raises `Ecto.NoResultsError` if the Result does not exist.

  ## Examples

      iex> get_result_by_proposal_url("https://www.myproposal.com/", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Result{}

      iex> get_result_by_proposal_url("https://nonexistentproposal.com/", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      nil

  """
  def get_result_by_proposal_url(proposal_url, organization_uuid) do
    Result
    |> Repo.get_by([proposal_url: proposal_url, organization_uuid: organization_uuid])
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

  def create_result!(attrs \\ %{}) do
    %Result{}
    |> Result.changeset(attrs)
    |> Repo.insert!
  end
end