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
            if delegation = Repo.get_by(Delegation, delegator_id: attrs[:participant_id]) do
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
  Returns the list of votes.

  ## Examples

      iex> list_votes()
      [%Vote{}, ...]

  """
  def list_votes do
    Repo.all(Vote) |> Repo.preload([:participant])
  end

  @doc """
  Returns the list of votes for a proposal_url

  ## Examples

      iex> list_votes("https://docs.google.com/document/d/someid")
      [%Vote{}, ...]

  """
  def list_votes(proposal_url) do
    Vote
    |> where(proposal_url: ^proposal_url)
    |> Repo.all()
    |> Repo.preload([:participant])
  end

  @doc """
  Gets a single vote.

  Raises `Ecto.NoResultsError` if the Vote does not exist.

  ## Examples

      iex> get_vote!(123)
      %Vote{}

      iex> get_vote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vote!(id) do
    Repo.get!(Vote, id) |> Repo.preload([:participant])
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
  Returns the list of participants.

  ## Examples

      iex> list_participants()
      [%Participant{}, ...]

  """
  def list_participants do
    Repo.all(Participant)
  end

  @doc """
  Gets a single participant.

  Raises `Ecto.NoResultsError` if the Participant does not exist.

  ## Examples

      iex> get_participant!(123)
      %Participant{}

      iex> get_participant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_participant!(id), do: Repo.get!(Participant, id)

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
      conflict_target: [:email]
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
  Returns the list of delegations.

  ## Examples

      iex> list_delegations()
      [%Delegation{}, ...]

  """
  def list_delegations do
    Repo.all(Delegation) |> Repo.preload([:delegator,:delegate])
  end

  @doc """
  Gets a single delegation.

  Raises `Ecto.NoResultsError` if the Delegation does not exist.

  ## Examples

      iex> get_delegation!(123)
      %Delegation{}

      iex> get_delegation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_delegation!(id) do
    Repo.get!(Delegation, id) |> Repo.preload([:delegator,:delegate])
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
