defmodule LiquidVoting.Delegations do
  @moduledoc """
  The Delegations context.
  """

  import Ecto.Query, warn: false

  alias __MODULE__.Delegation
  alias LiquidVoting.{Repo, Voting, VotingMethods}
  alias Voting.Vote
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
  Gets a single delegation by delegator email, delegate email, voting_method_name, proposal_url and organization id

  Raises `Ecto.NoResultsError` if the Delegation does not exist.

  ## Examples

      iex> get_delegation!("delegator@email.com", "delegate@email.com", "https://aproposal.com", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Delegation{}

      iex> get_delegation!("participant-without-delegation@email.com", "some@body.com", "https://aproposal.com", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      ** (Ecto.NoResultsError)

  """
  def get_delegation!(
        delegator_email,
        delegate_email,
        voting_method_name,
        proposal_url,
        organization_id
      ) do
    delegator = Voting.get_participant_by_email!(delegator_email, organization_id)
    delegate = Voting.get_participant_by_email!(delegate_email, organization_id)
    voting_method = VotingMethods.get_voting_method_by_name!(voting_method_name, organization_id)

    Repo.get_by!(
      Delegation,
      delegator_id: delegator.id,
      delegate_id: delegate.id,
      voting_method_id: voting_method.id,
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

    Delegation
    |> where(
      [d],
      d.delegator_id == ^delegator.id and
        d.delegate_id == ^delegate.id and
        d.organization_id == ^organization_id and
        is_nil(d.proposal_url)
    )
    |> Repo.one!()
  end

  @doc """
  Creates a delegation.

  The delegation will be global if no `proposal_url` is passed in.
  The delegation can be created using participant IDs or emails.

  If created using participant emails, new participant(s) will be created if
  they do not already exist.

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
    delegation_attrs = Map.take(args, [:organization_id, :proposal_url])

    # If a proposal_url is specified, we upsert a voting_method and return the voting_method_id,
    # If a proposal_url is specified, we simply return voting_method_id == nil.
    voting_method_id =
      if Map.get(args, :proposal_url) do
        {:ok, voting_method} =
          VotingMethods.upsert_voting_method(%{
            name: Map.get(args, :voting_method),
            organization_id: args.organization_id
          })

        voting_method.id
      else
        nil
      end

    Multi.new()
    |> Multi.run(:upsert_delegator, fn _repo, _changes ->
      Voting.upsert_participant(delegator_attrs)
    end)
    |> Multi.run(:upsert_delegate, fn _repo, _changes ->
      Voting.upsert_participant(delegate_attrs)
    end)
    |> Multi.run(:upsert_delegation, fn _repo, changes ->
      delegation_attrs
      |> Map.put(:delegator_id, changes.upsert_delegator.id)
      |> Map.put(:delegate_id, changes.upsert_delegate.id)
      |> Map.put(:voting_method_id, voting_method_id)
      |> upsert_delegation()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, resources} ->
        delegation =
          resources.upsert_delegation
          |> Repo.preload([:voting_method])

        {:ok, delegation}

      {:error, :upsert_delegation, value, _} ->
        {:error, value}

      error ->
        error
    end
  end

  def create_delegation(%{delegator_id: _, delegate_id: _} = attrs) do
    upsert_delegation(attrs)
  end

  @doc """
  Upserts a delegation (updates or inserts).

  Updates existing global delegation for a specific delegator if attributes
  for a global delegation for the same delegator are passed in.

  Updates existing proposal-specific delegation for a specific delegator if
  attributes for a delegation for the same proposal and delegator are passed in.

  Creates a new delegation if neither aforementioned condition is true.

  Also resolves conflicts with existing delegations.

  ## Examples

      iex> upsert_delegation(%{
          delegate_id: "66aa035a-58e0-4396-b5f7-15314cf6123d",
          delegator_id: "c9c2fa04-a35b-427b-80b4-894043264d25",
          organization_id: "a880e0e6-da9c-4f43-8560-b228586d680e",
          proposal_url: "https://proposal.com/1"
      })
      {:ok, %Delegation{}}

      iex> upsert_delegation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def upsert_delegation(
        %{delegator_id: delegator_id, delegate_id: delegate_id, organization_id: organization_id} =
          attrs
      ) do
    proposal_url = Map.get(attrs, :proposal_url)

    with {:ok} <- check_vote_conflict(delegator_id, proposal_url, organization_id) do
      Delegation
      |> where(delegator_id: ^delegator_id)
      |> Repo.all()
      |> resolve_conflicts(delegate_id, proposal_url, organization_id)
      |> case do
        {:ok, delegations} ->
          delegations
          |> find_similar_delegation_or_return_new_struct(proposal_url, organization_id)
          |> Delegation.changeset(attrs)
          |> Repo.insert_or_update()

        {:error, %{message: message, details: details}} ->
          {:error, %{message: message, details: details}}
      end
    end
  end

  # Checks for a conflicting vote, in the case where a proposal-specific delegation creation is attempted.
  #
  # Returns {:ok} if delegation creation is for a global delegation.
  #
  # Or returns {:ok} if delegation creation is for a proposal delegation & no conflicting vote is found.
  # Returns an error, if a conflicting vote is found.
  defp check_vote_conflict(_delegator_id, _proposal_url = nil, _organization_id) do
    {:ok}
  end

  defp check_vote_conflict(delegator_id, proposal_url, organization_id) do
    case Voting.get_vote_by_participant_id(delegator_id, proposal_url, organization_id) do
      %Vote{} ->
        {
          :error,
          message: "Could not create delegation.",
          details: "Delegator has already voted on this proposal."
        }

      # Happy path: no conflicting vote found.
      nil ->
        {:ok}
    end
  end

  # Resolves conflicting delegations (2 clauses).
  #
  # Used by upsert_delegation/1 (above).
  #
  # Clause 1: Matches an attempt to upsert a global delegation.
  # Looks for conflicting proposal-specific delegations and deletes any found.
  #
  # Clause 2: Matches an attempt to upsert a proposal-specific delegation.
  # Looks for conflicting global delegation, and returns an error if found.
  defp resolve_conflicts(delegations, delegate_id, _proposal_url = nil, organization_id) do
    delegations
    |> Stream.filter(fn d ->
      d.delegate_id == delegate_id and d.proposal_url != nil and
        d.organization_id == organization_id
    end)
    |> Enum.each(fn d ->
      delete_delegation!(d)
    end)

    {:ok, delegations}
  end

  defp resolve_conflicts(delegations, delegate_id, _proposal_url, organization_id) do
    delegations
    |> Enum.filter(fn d ->
      d.proposal_url == nil and d.delegate_id == delegate_id and
        d.organization_id == organization_id
    end)
    |> case do
      [] ->
        {:ok, delegations}

      [_conflicting_global_delegation] ->
        {:error,
         %{
           message: "Could not create delegation.",
           details: "A global delegation for the same participants already exists."
         }}
    end
  end

  # Looks for a delegator's existing delegation of matching type (global or for
  # same proposal).Returns a matching delegation type, if found, or returns an
  #  empty Delegation struct.
  #
  # Used by upsert_delegation/1 (above.)
  defp find_similar_delegation_or_return_new_struct(delegations, proposal_url, organization_id) do
    delegations
    |> Enum.filter(fn d ->
      d.proposal_url == proposal_url and d.organization_id == organization_id
    end)
    |> case do
      # Delegation (of same type) not found, so we build one
      [] -> %Delegation{}
      # Delegation (of same type) exists - let's use it
      [delegation] -> delegation
    end
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
