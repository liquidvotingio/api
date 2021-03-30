defmodule LiquidVoting.VotingMethods do
  @moduledoc """
  The VotingMethods context.
  """

  import Ecto.Query, warn: false

  alias __MODULE__.VotingMethod
  alias LiquidVoting.{Repo}

  @doc """
  Returns the list of voting_methods for an organization id.

  ## Examples

      iex> list_voting_methods_by_org("a6158b19-6bf6-4457-9d13-ef8b141611b4")
      [%VotingMethod{}, ...]

  """
  def list_voting_methods_by_org(organization_id) do
    VotingMethod
    |> where(organization_id: ^organization_id)
    |> Repo.all()
  end

  @doc """
  Upserts a voting_method (updates or inserts).

  ## Examples

      iex> upsert_voting_method(%{field: value})
      {:ok, %VotingMethod{}}

      iex> upsert_voting_method(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def upsert_voting_method(attrs \\ %{}) do
    %VotingMethod{}
    |> VotingMethod.changeset(attrs)
    |> Repo.insert_or_update(
      on_conflict: {:replace_all_except, [:id]},
      conflict_target: [:organization_id, :voting_method],
      returning: true
    )
  end
end
