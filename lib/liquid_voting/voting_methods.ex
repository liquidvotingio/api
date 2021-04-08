defmodule LiquidVoting.VotingMethods do
  @moduledoc """
  The VotingMethods context.
  """

  import Ecto.Query, warn: false

  alias __MODULE__.VotingMethod
  alias LiquidVoting.{Repo}

  @doc """
  Gets a single voting method by id and organization id

  Raises `Ecto.NoResultsError` if the VotingMethod does not exist.

  ## Examples

      iex> get_voting_method!(
        "61dbd65c-2c1f-4c29-819c-bbd27112a868",
        "a6158b19-6bf6-4457-9d13-ef8b141611b4"
        )
      %VotingMethod{}

      iex> get_voting_method!(456, 123)
      ** (Ecto.NoResultsError)

  """
  def get_voting_method!(id, organization_id) do
    VotingMethod
    |> Repo.get_by!(id: id, organization_id: organization_id)
  end

  @doc """
  Gets a single voting method by name and organization id

  Raises `Ecto.NoResultsError` if the VotingMethod does not exist.

  ## Examples

      iex> get_voting_method!("our-voting-method", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %VotingMethod{}

      iex> get_voting_method!("non-existant-method", 456)
      ** (Ecto.NoResultsError)

  """
  def get_voting_method_by_name!(name, organization_id) do
    VotingMethod
    |> Repo.get_by!(name: name, organization_id: organization_id)
  end

  @doc """
  Returns the list of voting methods for an organization id.

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
  Upserts a voting method (updates or inserts)

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
      conflict_target: [:organization_id, :name],
      returning: true
    )
  end
end
