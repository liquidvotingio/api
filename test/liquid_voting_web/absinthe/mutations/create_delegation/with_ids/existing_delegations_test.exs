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
        createDelegation(delegatorId: "#{global_delegation.delegator.id}", delegateId: "#{
        another_delegate.id
      }") {
          delegator {
            id
            name
          }
          delegate {
            id
            name
          }
          id
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => updated_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: global_delegation.organization_id})

      assert updated_delegation["delegator"]["id"] == global_delegation.delegator.id
      assert updated_delegation["delegate"]["id"] == another_delegate.id
      assert updated_delegation["id"] == global_delegation.id
    end
  end

  describe "create global delegation when proposal delegation to same delegate already exists" do
    test "returns the new global delegation" do
      proposal_delegation = insert(:delegation_for_proposal)

      query = """
      mutation {
        createDelegation(delegatorId: "#{proposal_delegation.delegator.id}", delegateId: "#{
        proposal_delegation.delegate.id
      }") {
          delegator {
            id
          }
          delegate {
            id
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => global_delegation}}} =
        Absinthe.run(query, Schema,
          context: %{organization_id: proposal_delegation.organization_id}
        )

      assert global_delegation["delegator"]["id"] == proposal_delegation.delegator.id
      assert global_delegation["delegate"]["id"] == proposal_delegation.delegate.id
    end
  end

  describe "create proposal delegation when delegation for same proposal already exists" do
    test "overwrites existing proposal-specific delegation" do
      proposal_delegation = insert(:delegation_for_proposal)
      proposal_voting_method_name = proposal_delegation.voting_method.name

      another_delegate =
        insert(:participant, organization_id: proposal_delegation.organization_id)

      query = """
      mutation {
        createDelegation(delegatorId: "#{proposal_delegation.delegator.id}", delegateId: "#{
        another_delegate.id
      }", votingMethod: "#{proposal_voting_method_name}", proposalUrl: "#{
        proposal_delegation.proposal_url
      }") {
          delegator {
            id
          }
          delegate {
            id
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

      assert updated_delegation["delegator"]["id"] == proposal_delegation.delegator.id
      assert updated_delegation["delegate"]["id"] == another_delegate.id
      assert updated_delegation["proposalUrl"] == proposal_delegation.proposal_url
      assert updated_delegation["id"] == proposal_delegation.id
    end
  end

  describe "create proposal delegation when global delegation to same delegate already exists" do
    test "returns error" do
      global_delegation = insert(:delegation)

      query = """
      mutation {
        createDelegation(delegatorId: "#{global_delegation.delegator.id}", delegateId: "#{
        global_delegation.delegate.id
      }", proposalUrl: "https://www.proposal.com/1") {
          delegator {
            id
          }
          delegate {
            id
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
