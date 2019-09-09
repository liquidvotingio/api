defmodule LiquidDem.VotingResults do
  @moduledoc """
  The VotingResults context.
  """

  import Ecto.Query, warn: false
  alias LiquidDem.Repo
  alias LiquidDem.Voting
  alias LiquidDem.VotingResults.Result

  @doc """
  Creates or updates voting result based on votes
  given to a proposal

  ## Examples

      iex> calculate_result!(proposal)
      %Result{}

  """
  def calculate_result(proposal) do
    proposal = Repo.preload(proposal, :votes)

    attrs = %{
      yes: 0,
      no: 0,
      proposal_id: proposal.id
    }

    attrs =
      Enum.reduce proposal.votes, attrs, fn (vote, attrs) ->
        {:ok, vote} = Voting.update_vote_weight(vote)

        if vote.yes do
          Map.update!(attrs, :yes, &(&1 + vote.weight))
        else
          Map.update!(attrs, :no, &(&1 + vote.weight))
        end
      end

    %Result{}
    |> Result.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of results.

  ## Examples

      iex> list_results()
      [%Result{}, ...]

  """
  def list_results do
    Repo.all(Result)
  end

  @doc """
  Gets a single result.

  Raises `Ecto.NoResultsError` if the Result does not exist.

  ## Examples

      iex> get_result!(123)
      %Result{}

      iex> get_result!(456)
      ** (Ecto.NoResultsError)

  """
  def get_result!(id), do: Repo.get!(Result, id)

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