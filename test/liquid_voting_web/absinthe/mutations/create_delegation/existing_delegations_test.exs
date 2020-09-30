defmodule LiquidVotingWeb.Absinthe.Mutations.CreateDelegation.ExistingDelegationsTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "create global delegation when a global delegation for a different delegate already exists" do
    setup do
      global_delegation = insert(:delegation)
      another_delegate = insert(:participant)

      [
        organization_id: global_delegation.organization_id,
        global_delegation_id: global_delegation.id,
        delegator: global_delegation.delegator,
        another_delegate: another_delegate
      ]
    end

    test "overwrites existing global delegation", context do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{context[:delegator].email}", delegateEmail: "#{
        context[:another_delegate].email
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
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert updated_delegation["delegator"]["email"] == context[:delegator].email
      assert updated_delegation["delegate"]["email"] == context[:another_delegate].email
      assert updated_delegation["id"] == context[:global_delegation_id]
    end
  end

  describe "create global delegation when proposal delegations to same delegate already exist" do
    setup do
      # First, create a proposal-specific delegation.
      proposal_delegation_1 = insert(:delegation_for_proposal)

      # Second, create another proposal-specific delegation (same participants & organization, different proposalUrl).
      proposal_delegation_2 =
        insert(:delegation_for_proposal,
          delegator: proposal_delegation_1.delegator,
          delegate: proposal_delegation_1.delegate,
          organization_id: proposal_delegation_1.organization_id
        )

      [
        organization_id: proposal_delegation_1.organization_id,
        delegator: proposal_delegation_1.delegator,
        delegate: proposal_delegation_1.delegate,
        proposal_delegation_1_id: proposal_delegation_1.id,
        proposal_delegation_2_id: proposal_delegation_2.id
      ]
    end

    test "deletes proposal specific delegations for same delegator/delegate pair", context do
      # Third, create a global delegation for the same participants.
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{context[:delegator].email}", delegateEmail: "#{
        context[:delegate].email
      }") {
          delegator {
            email
          }
          delegate {
            email
          }
          id
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => global_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert global_delegation["delegator"]["email"] == context[:delegator].email
      assert global_delegation["delegate"]["email"] == context[:delegate].email

      # Fourth, search for proposal_delegation_1 (should return error).
      query = """
      query {
        delegation(id: "#{context[:proposal_delegation_1_id]}") {
          id
        }
      }
      """

      assert_raise Ecto.NoResultsError, fn ->
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})
      end

      # Lastly, search for proposal_delegation_2 (should return error).
      query = """
      query {
        delegation(id: "#{context[:proposal_delegation_2_id]}") {
          id
        }
      }
      """

      assert_raise Ecto.NoResultsError, fn ->
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})
      end
    end
  end

  describe "create proposal delegation when delegation for same proposal already exists" do
    setup do
      proposal_delegation = insert(:delegation_for_proposal)
      another_delegate = insert(:participant)

      [
        organization_id: proposal_delegation.organization_id,
        delegator: proposal_delegation.delegator,
        proposal_url: proposal_delegation.proposal_url,
        another_delegate: another_delegate
      ]
    end

    test "overwrites existing proposal-specific delegation", context do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{context[:delegator].email}", delegateEmail: "#{
        context[:another_delegate].email
      }", proposalUrl: "#{context[:proposal_url]}") {
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

      {:ok, %{data: %{"createDelegation" => updated_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert updated_delegation["delegator"]["email"] == context[:delegator].email
      assert updated_delegation["delegate"]["email"] == context[:another_delegate].email
      assert updated_delegation["proposalUrl"] == context[:proposal_url]
    end
  end

  describe "create proposal delegation when global delegation to same delegate already exists" do
    setup do
      global_delegation = insert(:delegation)

      [
        organization_id: global_delegation.organization_id,
        delegator: global_delegation.delegator,
        delegate: global_delegation.delegate
      ]
    end

    test "returns error", context do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{context[:delegator].email}", delegateEmail: "#{
        context[:delegate].email
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
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert message == "Could not create delegation."
      assert details == "A global delegation for the same participants already exists."
    end
  end
end
