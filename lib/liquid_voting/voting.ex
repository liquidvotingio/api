defmodule LiquidVoting.Voting do
  @moduledoc """
  The Voting context.
  """

  import Ecto.Query, warn: false
  alias LiquidVoting.Repo

  alias LiquidVoting.Voting.{Vote,Participant,Delegation}

  @doc """
  Creates a vote, and deletes a voter's previous
  delegation if present

  ## Examples

      iex> create_vote(%{field: value})
      {:ok, %Vote{}}

      iex> create_vote(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vote(attrs \\ %{}) do
    Repo.transaction(
      fn ->
        case %Vote{} |> Vote.changeset(attrs) |> Repo.insert() do
          {:ok, vote} ->
            if delegation = Repo.get_by(Delegation, [delegator_id: attrs[:participant_id], organization_uuid: attrs[:organization_uuid]]) do
              case delete_delegation(delegation) do
                {:ok, _delegation} -> vote
                {:error, changeset} -> Repo.rollback(changeset)
              end
            else
              vote
            end
          {:error, changeset} -> Repo.rollback(changeset)
        end
      end
    )
  end

  @doc """
  Returns the list of votes for an organization uuid.

  ## Examples

      iex> list_votes("a6158b19-6bf6-4457-9d13-ef8b141611b4")
      [%Vote{}, ...]

  """
  def list_votes(organization_uuid) do
    Vote
    |> where(organization_uuid: ^organization_uuid)
    |> Repo.all()
    |> Repo.preload([:participant])
  end

  @doc """
  Returns the list of votes for a proposal_url and organization uuid

  ## Examples

      iex> list_votes("https://docs.google.com/document/d/someid", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      [%Vote{}, ...]

  """
  def list_votes(proposal_url, organization_uuid) do
    Vote
    |> where([proposal_url: ^proposal_url, organization_uuid: ^organization_uuid])
    |> Repo.all()
    |> Repo.preload([:participant])
  end

  @doc """
  Gets a single vote by id and organization uuid

  Raises `Ecto.NoResultsError` if the Vote does not exist.

  ## Examples

      iex> get_vote!(123, "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Vote{}

      iex> get_vote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vote!(id, organization_uuid) do
    Vote
    |> Repo.get_by!([id: id, organization_uuid: organization_uuid])
    |> Repo.preload([:participant])
  end

  @doc """
  Gets a single vote by participant email, proposal_url and organization uuid

  ## Examples

      iex> get_vote!("alice@email.com, "https://proposals.net/2", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Vote{}

      iex> get_vote!("hasno@votes.com", "https://proposals.net/2", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      ** (Ecto.NoResultsError)


  """
  def get_vote!(email, proposal_url, organization_uuid) do
    participant = get_participant_by_email!(email, organization_uuid)
    Vote
    |> Repo.get_by!([participant_id: participant.id, proposal_url: proposal_url, organization_uuid: organization_uuid])
    |> Repo.preload([:participant])    
  end

  # Just for seeding
  def create_vote!(attrs \\ %{}) do
    %Vote{}
    |> Vote.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a vote.

  ## Examples

      iex> update_vote(vote, %{field: new_value})
      {:ok, %Vote{}}

      iex> update_vote(vote, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vote(%Vote{} = vote, attrs) do
    vote
    |> Vote.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Vote.

  ## Examples

      iex> delete_vote(vote)
      {:ok, %Vote{}}

      iex> delete_vote(vote)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vote(%Vote{} = vote) do
    Repo.delete(vote)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vote changes.

  ## Examples

      iex> change_vote(vote)
      %Ecto.Changeset{source: %Vote{}}

  """
  def change_vote(%Vote{} = vote) do
    Vote.changeset(vote, %{})
  end

  @doc """
  Returns the list of participants for an organization uuid

  ## Examples

      iex> list_participants("a6158b19-6bf6-4457-9d13-ef8b141611b4")
      [%Participant{}, ...]

  """
  def list_participants(organization_uuid) do
    Participant
    |> where(organization_uuid: ^organization_uuid)
    |> Repo.all()
  end

  @doc """
  Gets a single participant for an organization uuid

  Raises `Ecto.NoResultsError` if the Participant does not exist.

  ## Examples

      iex> get_participant!(123, "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Participant{}

      iex> get_participant!(456, "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      ** (Ecto.NoResultsError)

  """
  def get_participant!(id, organization_uuid) do
    Participant
    |> Repo.get_by!([id: id, organization_uuid: organization_uuid])
  end

  @doc """
  Gets a single participant for an organization uuid by their email

  Returns nil if the Participant does not exist.

  ## Examples

      iex> get_participant_by_email("existing@email.com", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Participant{}

      iex> get_participant_by_email("unregistered@email.com", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      nil

  """
  def get_participant_by_email(email, organization_uuid) do
    Participant
    |> Repo.get_by([email: email, organization_uuid: organization_uuid])
  end

  @doc """
  Gets a single participant for an organization uuid by their email

  Returns nil if the Participant does not exist.

  ## Examples

      iex> get_participant_by_email!("existing@email.com", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Participant{}

      iex> get_participant_by_email!("unregistered@email.com", "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      ** (Ecto.NoResultsError)

  """
  def get_participant_by_email!(email, organization_uuid) do
    Participant
    |> Repo.get_by!([email: email, organization_uuid: organization_uuid])
  end

  @doc """
  Creates a participant.

  ## Examples

      iex> create_participant(%{field: value})
      {:ok, %Participant{}}

      iex> create_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_participant(attrs \\ %{}) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert()
  end

  def create_participant!(attrs \\ %{}) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert!()
  end

  def upsert_participant(attrs \\ %{}) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert(
      on_conflict: :replace_all_except_primary_key,
      conflict_target: [:organization_uuid, :email]
      )
  end

  @doc """
  Updates a participant.

  ## Examples

      iex> update_participant(participant, %{field: new_value})
      {:ok, %Participant{}}

      iex> update_participant(participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_participant(%Participant{} = participant, attrs) do
    participant
    |> Participant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Participant.

  ## Examples

      iex> delete_participant(participant)
      {:ok, %Participant{}}

      iex> delete_participant(participant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_participant(%Participant{} = participant) do
    Repo.delete(participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking participant changes.

  ## Examples

      iex> change_participant(participant)
      %Ecto.Changeset{source: %Participant{}}

  """
  def change_participant(%Participant{} = participant) do
    Participant.changeset(participant, %{})
  end

  @doc """
  Returns the list of delegations for an organization uuid

  ## Examples

      iex> list_delegations("a6158b19-6bf6-4457-9d13-ef8b141611b4")
      [%Delegation{}, ...]

  """
  def list_delegations(organization_uuid) do
    Delegation
    |> where(organization_uuid: ^organization_uuid)
    |> Repo.all
    |> Repo.preload([:delegator,:delegate])
  end

  @doc """
  Gets a single delegation for an organization uuid

  Raises `Ecto.NoResultsError` if the Delegation does not exist.

  ## Examples

      iex> get_delegation!(123, "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      %Delegation{}

      iex> get_delegation!(456, "a6158b19-6bf6-4457-9d13-ef8b141611b4")
      ** (Ecto.NoResultsError)

  """
  def get_delegation!(id, organization_uuid) do
    Delegation
    |> Repo.get_by!(id: id, organization_uuid: organization_uuid)
    |> Repo.preload([:delegator,:delegate])
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

  def create_delegation!(attrs \\ %{}) do
    %Delegation{}
    |> Delegation.changeset(attrs)
    |> Repo.insert
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
  def delete_delegation(%Delegation{} = delegation) do
    Repo.delete(delegation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking delegation changes.

  ## Examples

      iex> change_delegation(delegation)
      %Ecto.Changeset{source: %Delegation{}}

  """
  def change_delegation(%Delegation{} = delegation) do
    Delegation.changeset(delegation, %{})
  end
end
