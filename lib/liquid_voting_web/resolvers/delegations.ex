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
    |> validate_participant_args
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

  defp validate_participant_args(args) do
    args
    |> case do
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
