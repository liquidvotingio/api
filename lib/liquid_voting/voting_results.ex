defmodule LiquidVoting.VotingResults do
  @moduledoc """
  The VotingResults context.
  """

  import Ecto.Query, warn: false

  alias __MODULE__.Result
  alias LiquidVoting.{Repo, Voting, VotingWeight}

  @doc """
  Creates or updates voting result based on votes
  given to a proposal within the scope of a organization_id

  ## Examples

      iex> calculate_result!("https://www.medium/user/eloquent_proposal", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Result{}

  """
  def calculate_result!(proposal_url, organization_id) do
    votes = Voting.list_votes(proposal_url, organization_id)

    attrs = %{
      in_favor: 0,
      against: 0,
      proposal_url: proposal_url,
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
      conflict_target: [:organization_id, :proposal_url],
      returning: true
    )
  end

  @doc """
  Publishes voting result changes to Absinthe's pubsub, so clients can receive updates in real-time

  ## Examples

      iex> publish_voting_result_change("https://www.medium/user/eloquent_proposal", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      :ok

  """
  def publish_voting_result_change(proposal_url, organization_id) do
    result = calculate_result!(proposal_url, organization_id)

    Absinthe.Subscription.publish(
      LiquidVotingWeb.Endpoint,
      result,
      voting_result_change: proposal_url
    )
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
  end

  @doc """
  Gets a single result for an organization_id

  Raises `Ecto.NoResultsError` if the Result does not exist.

  ## Examples

      iex> get_result!(123, "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Result{}

      iex> get_result!(456, "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      ** (Ecto.NoResultsError)

  """
  def get_result!(id, organization_id),
    do: Repo.get_by!(Result, id: id, organization_id: organization_id)

  @doc """
  Gets a single result by its proposal url and organization_id

  Raises `Ecto.NoResultsError` if the Result does not exist.

  ## Examples

      iex> get_result_by_proposal_url("https://www.myproposal.com/", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Result{}

      iex> get_result_by_proposal_url("https://nonexistentproposal.com/", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      nil

  """
  def get_result_by_proposal_url(proposal_url, organization_id),
    do: Repo.get_by(Result, proposal_url: proposal_url, organization_id: organization_id)

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
    |> Repo.insert!()
  end
end
