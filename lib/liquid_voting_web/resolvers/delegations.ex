defmodule LiquidVotingWeb.Resolvers.Delegations do
  alias LiquidVoting.{Delegations, VotingResults}
  alias LiquidVotingWeb.Schema.ChangesetErrors

  def delegations(_, _, %{context: %{organization_uuid: organization_uuid}}),
    do: {:ok, Delegations.list_delegations(organization_uuid)}

  def delegation(_, %{id: id}, %{context: %{organization_uuid: organization_uuid}}),
    do: {:ok, Delegations.get_delegation!(id, organization_uuid)}

  # Will add participants to the db if they don't exist yet, or fetch them if they do. 
  # Their ids are used for delegator_id and delegate_id when inserting the delegation
  # with create_delegation_with_valid_arguments/1
  def create_delegation(
        _,
        %{delegator_email: _, delegate_email: _} = args,
        %{context: %{organization_uuid: organization_uuid}}
      ) do
    args
    |> Map.put(:organization_uuid, organization_uuid)
    |> Delegations.make_delegation()
    |> case do
      {:ok, new_resources} ->
        {:ok, new_resources.delegation}

      {:error, name, changeset, _} ->
        {:error,
         message: "Could not create #{name}", details: ChangesetErrors.error_details(changeset)}
    end
  end

  # Create delegation with IDs
  #  We assume participants already exist if IDs are passed in: no upsert necessary.
  # NOTE: inconsistent validation with pattern match in this clause and the above
  def create_delegation(_, %{} = args, %{context: context}) do
    args
    |> Map.put(:organization_uuid, context.organization_uuid)
    |> create_delegation_with_valid_arguments()
  end

  defp create_delegation_with_valid_arguments(args) do
    case Delegations.create_delegation(args) do
      {:error, changeset} ->
        {:error,
         message: "Could not create delegation", details: ChangesetErrors.error_details(changeset)}

      {:ok, delegation} ->
        {:ok, delegation}
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
        %{context: %{organization_uuid: organization_uuid}}
      ) do
    deleted_delegation =
      delegator_email
      |> Delegations.get_delegation!(delegate_email, proposal_url, organization_uuid)
      |> Delegations.delete_delegation!()

    VotingResults.publish_voting_result_change(proposal_url, organization_uuid)
    {:ok, deleted_delegation}
  rescue
    Ecto.NoResultsError -> {:error, message: "No delegation found to delete"}
  end

  # Delete global delegations
  def delete_delegation(_, %{delegator_email: delegator_email, delegate_email: delegate_email}, %{
        context: %{organization_uuid: organization_uuid}
      }) do
    deleted_delegation =
      delegator_email
      |> Delegations.get_delegation!(delegate_email, organization_uuid)
      |> Delegations.delete_delegation!()

    # VotingResults.publish_voting_result_change(proposal_url, organization_uuid)
    {:ok, deleted_delegation}
  rescue
    Ecto.NoResultsError -> {:error, message: "No delegation found to delete"}
  end
end
