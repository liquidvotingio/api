defmodule LiquidVotingWeb.Resolvers.Delegations do
  alias LiquidVoting.Voting
  alias LiquidVoting.Delegations
  alias LiquidVotingWeb.Schema.ChangesetErrors

  def delegations(_, _, %{context: %{organization_uuid: organization_uuid}}) do
    {:ok, Delegations.list_delegations(organization_uuid)}
  end

  def delegation(_, %{id: id}, %{context: %{organization_uuid: organization_uuid}}) do
    {:ok, Delegations.get_delegation!(id, organization_uuid)}
  end

  # Will add participants to the db if they don't exist yet, or fetch them if they do. 
  # Their ids are used for delegator_id and delegate_id when inserting the delegation
  # with create_delegation_with_valid_arguments/1
  def create_delegation(_, %{delegator_email: delegator_email, delegate_email: delegate_email} = args, %{context: %{organization_uuid: organization_uuid}}) do
    case Voting.upsert_participant(%{email: delegator_email, organization_uuid: organization_uuid}) do
      {:error, changeset} ->
        {:error,
         message: "Could not create delegation with given email",
         details: ChangesetErrors.error_details(changeset)
        }

      {:ok, delegator} ->
        args = Map.put(args, :delegator_id, delegator.id)
        args = Map.put(args, :organization_uuid, organization_uuid)

        case Voting.upsert_participant(%{email: delegate_email, organization_uuid: organization_uuid}) do
          {:error, changeset} ->
            {:error,
             message: "Could not create delegation with given email",
             details: ChangesetErrors.error_details(changeset)
            }

          {:ok, delegate} ->
            args = Map.put(args, :delegate_id, delegate.id)
            create_delegation_with_valid_arguments(args)
        end
    end
  end

  def create_delegation(_, %{} = args, %{context: %{organization_uuid: organization_uuid}}) do
    args = Map.put(args, :organization_uuid, organization_uuid)
    create_delegation_with_valid_arguments(args)
  end

  def create_delegation_with_valid_arguments(args) do
    case Delegations.create_delegation(args) do
      {:error, changeset} ->
        {:error,
         message: "Could not create delegation",
         details: ChangesetErrors.error_details(changeset)
        }

      {:ok, delegation} ->
        {:ok, delegation}
    end
  end
end