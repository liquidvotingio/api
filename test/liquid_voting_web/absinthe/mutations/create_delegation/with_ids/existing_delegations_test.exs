defmodule LiquidVotingWeb.Absinthe.Mutations.CreateDelegation.WithIds.ExistingDelegationsTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "create global delegation when a global delegation for a different delegate already exists" do
    test "overwrites existing global delegation" do
      global_delegation = insert(:delegation)
      another_delegate = insert(:participant, organization_id: global_delegation.organization_id)

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{global_delegation.delegator.email}", delegateEmail: "#{
        another_delegate.email
      }") {
          delegator {
            email
            name
          }
          delegate {
            email
            name
          }
          id
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => updated_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: global_delegation.organization_id})

      assert updated_delegation["delegator"]["email"] == global_delegation.delegator.email
      assert updated_delegation["delegate"]["email"] == another_delegate.email
      assert updated_delegation["id"] == global_delegation.id
    end
  end

  describe "create global delegation when proposal delegation to same delegate already exists" do
    test "returns the new global delegation" do
      proposal_delegation = insert(:delegation_for_proposal)

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{proposal_delegation.delegator.email}", delegateEmail: "#{
        proposal_delegation.delegate.email
      }") {
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => global_delegation}}} =
        Absinthe.run(query, Schema,
          context: %{organization_id: proposal_delegation.organization_id}
        )

      assert global_delegation["delegator"]["email"] == proposal_delegation.delegator.email
      assert global_delegation["delegate"]["email"] == proposal_delegation.delegate.email
    end
  end

  describe "create proposal delegation when delegation for same proposal already exists" do
    test "overwrites existing proposal-specific delegation" do
      proposal_delegation = insert(:delegation_for_proposal)
      another_delegate = insert(:participant, organization_id: proposal_delegation.organization_id)

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{proposal_delegation.delegator.email}", delegateEmail: "#{
        another_delegate.email
      }", proposalUrl: "#{proposal_delegation.proposal_url}") {
          delegator {
            email
          }
          delegate {
            email
          }
          proposalUrl
          id
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => updated_delegation}}} =
        Absinthe.run(query, Schema,
          context: %{organization_id: proposal_delegation.organization_id}
        )

      assert updated_delegation["delegator"]["email"] == proposal_delegation.delegator.email
      assert updated_delegation["delegate"]["email"] == another_delegate.email
      assert updated_delegation["proposalUrl"] == proposal_delegation.proposal_url
      assert updated_delegation["id"] == proposal_delegation.id
    end
  end

  describe "create proposal delegation when global delegation to same delegate already exists" do
    test "returns error" do
      global_delegation = insert(:delegation)

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{global_delegation.delegator.email}", delegateEmail: "#{
        global_delegation.delegate.email
      }", proposalUrl: "https://www.proposal.com/1") {
          delegator {
            email
          }
          delegate {
            email
          }
          proposalUrl
        }
      }
      """

      {:ok, %{errors: [%{details: details, message: message}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: global_delegation.organization_id})

      assert message == "Could not create delegation."
      assert details == "A global delegation for the same participants already exists."
    end
  end
end
