defmodule LiquidVoting.VotingMethods do
  @moduledoc """
  The VotingMethods context.
  """

  import Ecto.Query, warn: false

  alias __MODULE__.VotingMethod
  alias LiquidVoting.{Repo}

  @doc """
  Upserts a voting_method (updates or inserts).

  ## Examples

      iex> upsert_voting_method(%{field: value})
      {:ok, %VotingMethod{}}

      iex> upsert_voting_method(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def upsert_voting_method(attrs \\ %{}) do
    attrs =
      if Map.get(attrs, :voting_method) == nil,
        # Workaround: Prevent creation of new record for matching records
        # where voting_method: nil, by providing default string value.
        do: Map.put(attrs, :voting_method, "** no method specified **"),
        else: attrs

    %VotingMethod{}
    |> VotingMethod.changeset(attrs)
    |> Repo.insert_or_update(
      on_conflict: {:replace_all_except, [:id]},
      conflict_target: [:organization_id, :voting_method],
      returning: true
    )
  end
end
