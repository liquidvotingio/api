defmodule LiquidVoting.Delegations do
  @moduledoc """
  The Delegations context.
  """

  import Ecto.Query, warn: false

  alias __MODULE__.Delegation
  alias LiquidVoting.{Repo, Voting}

  @doc """
  Returns the list of delegations for an organization id

  ## Examples

      iex> list_delegations("a6158b19-6bf6-4457-9d13-ef8b141611b4")
      [%Delegation{}, ...]

  """
  def list_delegations(organization_id) do
    Delegation
    |> where(organization_id: ^organization_id)
    |> Repo.all()
    |> Repo.preload([:delegator, :delegate])
  end

  @doc """
  Gets a single delegation for an organization id

  Raises `Ecto.NoResultsError` if the Delegation does not exist.

  ## Examples

      iex> get_delegation!(123, "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Delegation{}

      iex> get_delegation!(456, "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      ** (Ecto.NoResultsError)

  """
  def get_delegation!(id, organization_id) do
    Delegation
    |> Repo.get_by!(id: id, organization_id: organization_id)
    |> Repo.preload([:delegator, :delegate])
  end

  @doc """
  Gets a single delegation by delegator email, delegate email, proposal_url and organization id

  Raises `Ecto.NoResultsError` if the Delegation does not exist.

  ## Examples

      iex> get_delegation!("delegator@email.com", "delegate@email.com", "https://aproposal.com", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Delegation{}

      iex> get_delegation!("participant-without-delegation@email.com", "some@body.com", "https://aproposal.com", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      ** (Ecto.NoResultsError)

  """
  def get_delegation!(delegator_email, delegate_email, proposal_url, organization_id) do
    delegator = Voting.get_participant_by_email!(delegator_email, organization_id)
    delegate = Voting.get_participant_by_email!(delegate_email, organization_id)

    Repo.get_by!(
      Delegation,
      delegator_id: delegator.id,
      delegate_id: delegate.id,
      proposal_url: proposal_url,
      organization_id: organization_id
    )
  end

  @doc """
  Gets a single global delegation by delegator email, delegate email and organization id

  Raises `Ecto.NoResultsError` if the Delegation does not exist.

  ## Examples

      iex> get_delegation!("delegator@email.com", "delegate@email.com", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Delegation{}

      iex> get_delegation!("participant-without-delegation@email.com", "some@body.com", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      ** (Ecto.NoResultsError)

  """
  def get_delegation!(delegator_email, delegate_email, organization_id) do
    delegator = Voting.get_participant_by_email!(delegator_email, organization_id)
    delegate = Voting.get_participant_by_email!(delegate_email, organization_id)

    Repo.get_by!(
      Delegation,
      delegator_id: delegator.id,
      delegate_id: delegate.id,
      organization_id: organization_id
    )
  end

  @doc """
  Creates a delegation.

  ## Examples

      iex> create_delegation(%{field: value})
      {:ok, %Delegation{}}

      iex> create_delegation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_delegation(attrs \\ %{}) do
    %Delegation{}
    |> Delegation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a delegation.

  ## Examples

      iex> create_delegation(%{field: value})
      %Delegation{}

      iex> create_delegation(%{field: bad_value})
      Ecto.*Error

  """
  def create_delegation!(attrs \\ %{}) do
    %Delegation{}
    |> Delegation.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a delegation.

  ## Examples

      iex> update_delegation(delegation, %{field: new_value})
      {:ok, %Delegation{}}

      iex> update_delegation(delegation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_delegation(%Delegation{} = delegation, attrs) do
    delegation
    |> Delegation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Delegation.

  ## Examples

      iex> delete_delegation(delegation)
      {:ok, %Delegation{}}

      iex> delete_delegation(delegation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_delegation(%Delegation{} = delegation), do: Repo.delete(delegation)

  @doc """
  Deletes a Delegation.

  ## Examples

      iex> delete_delegation!(delegation)
      %Delegation{}

      iex> delete_delegation!(delegation)
      ** (Ecto.NoResultsError)

  """
  def delete_delegation!(%Delegation{} = delegation), do: Repo.delete!(delegation)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking delegation changes.

  ## Examples

      iex> change_delegation(delegation)
      %Ecto.Changeset{source: %Delegation{}}

  """
  def change_delegation(%Delegation{} = delegation), do: Delegation.changeset(delegation, %{})
end
