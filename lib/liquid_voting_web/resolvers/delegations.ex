defmodule LiquidVotingWeb.Resolvers.Delegations do
  alias LiquidVoting.{Delegations, VotingResults}
  alias LiquidVotingWeb.Schema.ChangesetErrors

  def delegations(_, _, %{context: %{organization_id: organization_id}}),
    do: {:ok, Delegations.list_delegations(organization_id)}

  def delegation(_, %{id: id}, %{context: %{organization_id: organization_id}}),
    do: {:ok, Delegations.get_delegation!(id, organization_id)}

  # Will add participants to the db if they don't exist yet, or fetch them if they do. 
  # Their ids are used for delegator_id and delegate_id when inserting the delegation
  # with create_delegation_with_valid_arguments/1
  def create_delegation(_, args, %{context: %{organization_id: organization_id}}) do
    args
    |> validate_participants
    |> case do
      {:ok, args} ->
        args
        |> Map.put(:organization_id, organization_id)
        |> Delegations.create_delegation()
        |> case do
          {:ok, delegation} ->
            {:ok, delegation}

          {:error, changeset} ->
            {:error,
             message: "Could not create delegation",
             details: ChangesetErrors.error_details(changeset)}

          {:error, name, changeset, _} ->
            {:error,
             message: "Could not create #{name}",
             details: ChangesetErrors.error_details(changeset)}
        end

      {:error, message} ->
        {:error, message}
    end
  end

  defp validate_participants(args) do
    args
    |> case do
      %{delegator_email: _, delegate_email: _} ->
        {:ok, args}
      
      %{delegator_id: _, delegate_id: _} ->
        {:ok, args}

      # if delegator_email field exists, but no delegate_email field exists
      %{delegator_email: _} ->
        {:error, %{
          message: "Could not create delegation",
          details: %{delegate_email: ["field not found"]}
        }}

      # if delegate_email field exists, but no delegator_email field exists
      %{delegate_email: _} ->
        {:error, %{
          message: "Could not create delegation",
          details: %{delegator_email: ["field not found"]}
        }}

      # if delegator_id field exists, but no delegate_id field exists
      %{delegator_id: _} ->
        {:error, %{
          message: "Could not create delegation",
          details: %{delegate_id: ["field not found"]}
        }}

      # if delegate_id field exists, but no delegator_id field exists
      %{delegate_id: _} ->
        {:error, %{
          message: "Could not create delegation",
          details: %{delegator_id: ["field not found"]}
        }}

      _ -> {:error, "some generic error - as yet undecided"}
    end
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
