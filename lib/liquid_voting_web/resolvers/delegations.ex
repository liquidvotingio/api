defmodule LiquidVotingWeb.Resolvers.Delegations do
  alias LiquidVoting.{Voting, Delegations, VotingResults}
  alias LiquidVotingWeb.Schema.ChangesetErrors

  def delegations(_, _, %{context: %{organization_id: organization_id}}),
    do: {:ok, Delegations.list_delegations(organization_id)}

  def delegation(_, %{id: id}, %{context: %{organization_id: organization_id}}),
    do: {:ok, Delegations.get_delegation!(id, organization_id)}

  @doc """
  Creates a delegation.

  Adds participants to the db if they don't exist, or fetches them if they do.

  Valid arguments (args) must include 2 ids (delegator_id and delegate_id)
  OR 2 emails (delegator_email and delegate_email).

  Valid arguments (args) may include a proposal_url.
  Without a proposal_url, an attempt to create a global delegation will occur.

  The participant ids, either directly taken from delegator_id and
  delegate_id, or via searching the db for participants with the emails
  provided, are used when inserting the delegation with
  LiquidVoting.Delegations.create_delegation/1.

  ## Examples

  iex> create_delegation(
    %{},
    %{delegator_email: "alice@somemail.com",
    delegate_email: "bob@somemail.com",
    proposal_url: "https://proposalplace/proposal63"},
    %{context: %{organization_id: "b212ef83-d3df-4a7a-8875-36cca613e8d6"}})
  %Delegation{}

  iex> create_delegation(
    %{},
    %{delegator_email: "alice@somemail.com"},
    %{context: %{organization_id: "b212ef83-d3df-4a7a-8875-36cca613e8d6"}})
  {:error,                                                   
    %{
      details: %{delegate_email: ["can't be blank"]},
      message: "Could not create delegation"
    }}
  """
  def create_delegation(_, args, %{context: %{organization_id: organization_id}}) do
    args = Map.put(args, :organization_id, organization_id)

    with {:ok, args} <- validate_participant_args(args),
         {:ok, delegation} <- Delegations.create_delegation(args) do
      proposal_url = Map.get(args, :proposal_url)

      case proposal_url do
        # Global delegation: We find all votes of the delegate and update related voting result(s).
        nil ->
          Voting.list_votes_by_participant(delegation.delegate_id, delegation.organization_id)
          |> Enum.each(fn vote ->
            VotingResults.publish_voting_result_change(vote.proposal_url, vote.organization_id)
          end)

        # Proposal delegation: We update the voting result for the given proposal_url.
        _proposal_url ->
          VotingResults.publish_voting_result_change(proposal_url, delegation.organization_id)
      end

      {:ok, delegation}
    else
      {:error, %{message: message, details: details}} ->
        {:error, %{message: message, details: details}}

      {:error, changeset} ->
        {:error,
         message: "Could not create delegation", details: ChangesetErrors.error_details(changeset)}

      {:error, name, changeset, _} ->
        {:error,
         message: "Could not create #{name}", details: ChangesetErrors.error_details(changeset)}
    end
  end

  defp validate_participant_args(args) do
    case args do
      %{delegator_email: _, delegate_email: _} ->
        {:ok, args}

      %{delegator_id: _, delegate_id: _} ->
        {:ok, args}

      # delegator_email field provided, but no delegate_email field provided
      %{delegator_email: _} ->
        field_not_found_error(%{delegate_email: ["can't be blank"]})

      # delegate_email field provided, but no delegator_email field provided
      %{delegate_email: _} ->
        field_not_found_error(%{delegator_email: ["can't be blank"]})

      # delegator_id field provided, but no delegate_id field provided
      %{delegator_id: _} ->
        field_not_found_error(%{delegate_id: ["can't be blank"]})

      # delegate_id field provided, but no delegator_id field provided
      %{delegate_id: _} ->
        field_not_found_error(%{delegator_id: ["can't be blank"]})

      # no id or email fields provided for delegator and delegate
      _ ->
        field_not_found_error("emails or ids identifying delegator and delegate can't be blank")
    end
  end

  defp field_not_found_error(details) do
    {:error,
     %{
       message: "Could not create delegation",
       details: details
     }}
  end

  # Delete proposal-specific delegations
  def delete_delegation(
        _,
        %{
          delegator_email: delegator_email,
          delegate_email: delegate_email,
          proposal_url: proposal_url
        },
        %{context: %{organization_id: organization_id}}
      ) do
    deleted_delegation =
      delegator_email
      |> Delegations.get_delegation!(delegate_email, proposal_url, organization_id)
      |> Delegations.delete_delegation!()

    VotingResults.publish_voting_result_change(proposal_url, organization_id)
    {:ok, deleted_delegation}
  rescue
    Ecto.NoResultsError -> {:error, message: "No delegation found to delete"}
  end

  # Delete global delegations
  def delete_delegation(_, %{delegator_email: delegator_email, delegate_email: delegate_email}, %{
        context: %{organization_id: organization_id}
      }) do
    deleted_delegation =
      delegator_email
      |> Delegations.get_delegation!(delegate_email, organization_id)
      |> Delegations.delete_delegation!()

    # VotingResults.publish_voting_result_change(proposal_url, organization_id)
    {:ok, deleted_delegation}
  rescue
    Ecto.NoResultsError -> {:error, message: "No delegation found to delete"}
  end
end
