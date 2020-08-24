defmodule LiquidVoting.Delegations do
  @moduledoc """
  The Delegations context.
  """

  import Ecto.Query, warn: false

  alias __MODULE__.Delegation
  alias LiquidVoting.{Repo, Voting}
  alias Ecto.Multi

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

  The delegation will be global if no `proposal_url` is passed in.
  The delegation can be created by ID or by email.

  ## Examples

      iex> create_delegation(%{field: value})
      {:ok, %Delegation{}}

      iex> create_delegation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_delegation(attrs \\ %{})

  def create_delegation(%{delegator_email: _, delegate_email: _} = args) do
    delegator_attrs = %{email: args.delegator_email, organization_id: args.organization_id}
    delegate_attrs = %{email: args.delegate_email, organization_id: args.organization_id}
    attrs = Map.take(args, [:organization_id, :proposal_url])

    Multi.new()
    |> Multi.run(:delegator, fn _repo, _changes -> Voting.upsert_participant(delegator_attrs) end)
    |> Multi.run(:delegate, fn _repo, _changes -> Voting.upsert_participant(delegate_attrs) end)
    |> Multi.run(:delegation, fn _repo, changes ->
      attrs
      |> Map.put(:delegator_id, changes.delegator.id)
      |> Map.put(:delegate_id, changes.delegate.id)
      |> upsert_delegation()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, resources} -> {:ok, resources.delegation}
      error -> error
    end
  end

  def create_delegation(attrs) do
    %Delegation{}
    |> Delegation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Upserts a delegation (updates or inserts).

  Updates existing global delegation for a specific delegator
  if a new global delegation for the same delegator is passed in.
  Updates existing proposal-specific delegation for a specific delegator
  if a delegation for the same proposal and delegator is passed in.
  Creates a new delegation if neither aforementioned condition is true.

  ## Examples

      iex> upsert_delegation(%{field: value})
      {:ok, %Delegation{}}

      iex> upsert_delegation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def upsert_delegation(attrs \\ %{}) do
    %{delegator_id: delegator_id} = attrs
    proposal_url = Map.get(attrs, :proposal_url)

    Delegation
    |> where([d], d.delegator_id == ^delegator_id)
    |> where_proposal(proposal_url)
    |> Repo.one()
    |> case do
      # Delegation not found, we build one
      nil -> %Delegation{}
      # Delegation exists, let's use it
      delegation -> delegation
    end
    |> Delegation.changeset(attrs)
    |> Repo.insert_or_update()
  end

  defp where_proposal(query, _proposal_url = nil),
    do: query |> where([d], is_nil(d.proposal_url))

  defp where_proposal(query, proposal_url),
    do: query |> where([d], d.proposal_url == ^proposal_url)

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
