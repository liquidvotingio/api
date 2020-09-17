defmodule LiquidVotingWeb.Absinthe.Mutations.DeleteDelegationTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "delete delegation specific to a proposal" do
    setup do
      delegation = insert(:delegation_for_proposal)

      insert(:vote,
        participant: delegation.delegate,
        proposal_url: delegation.proposal_url,
        organization_id: delegation.organization_id
      )

      insert(:voting_result,
        in_favor: 2,
        proposal_url: delegation.proposal_url,
        organization_id: delegation.organization_id
      )

      [
        delegator_email: delegation.delegator.email,
        delegate_email: delegation.delegate.email,
        proposal_url: delegation.proposal_url,
        organization_id: delegation.organization_id
      ]
    end

    test "with participant emails", context do
      query = """
      mutation {
        deleteDelegation(delegatorEmail: "#{context[:delegator_email]}", delegateEmail: "#{
        context[:delegate_email]
      }", proposalUrl: "#{context[:proposal_url]}") {
          proposalUrl
          votingResult {
            in_favor
            against
          }
        }
      }
      """

      {:ok, %{data: %{"deleteDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert delegation["proposalUrl"] == context[:proposal_url]
      assert delegation["votingResult"]["in_favor"] == 1
      assert delegation["votingResult"]["against"] == 0
    end

    test "when delegation doesn't exist", context do
      query = """
      mutation {
        deleteDelegation(delegatorEmail: "random@person.com", delegateEmail: "random2@person.com", proposalUrl: "https://random.com") {
          proposalUrl
          votingResult {
            in_favor
            against
          }
        }
      }
      """

      {:ok, %{errors: [%{message: message}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert message == "No delegation found to delete"
    end
  end

  describe "delete global delegation" do
    setup do
      global_delegation = insert(:delegation)

      [
        delegator_email: global_delegation.delegator.email,
        delegate_email: global_delegation.delegate.email,
        organization_id: global_delegation.organization_id,
        delegation_id: global_delegation.id,
        proposal_url: "https://proposals.com/1"
      ]
    end

    test "with participant emails", context do
      query = """
      mutation {
        deleteDelegation(delegatorEmail: "#{context[:delegator_email]}", delegateEmail: "#{
        context[:delegate_email]
      }") {
          id
        }
      }
      """

      {:ok, %{data: %{"deleteDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert delegation["id"] == context[:delegation_id]
    end

    test "when a similar proposal-specific delegation exists", context do
      # test case where a proposal-specific delegation already exists and we wish to delete
      # an existing global delegation for the same delegator & delegate.

      # first, create a proposal-specific delegation, using same emails as for existing global delegation
      query1 = """
      mutation {
        createDelegation(delegatorEmail: "#{context[:delegator_email]}", delegateEmail: "#{
        context[:delegate_email]
      }", proposalUrl: "#{context[:proposal_url]}") {
          id
          proposalUrl
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => original_delegation}}} =
        Absinthe.run(query1, Schema, context: %{organization_id: context[:organization_id]})

      assert original_delegation["proposalUrl"] == context[:proposal_url]

      # now delete delegation, using same details as above, except without proposalUrl field:
      query2 = """
      mutation {
        deleteDelegation(delegatorEmail: "#{original_delegation["delegator"]["email"]}", delegateEmail: "#{
        original_delegation["delegate"]["email"]
      }") {
          id
        }
      }
      """

      {:ok, %{data: %{"deleteDelegation" => deleted_delegation}}} =
        Absinthe.run(query2, Schema, context: %{organization_id: context[:organization_id]})

      assert deleted_delegation["id"] != original_delegation["id"]
    end

    test "when no matching global delegation exists, but a similar proposal-specific delegation exists",
         context do
      # test case where a proposal-specific delegation already exists and we try to delete
      # a global delegation (non-existent) for the same delegator & delegate.

      # first, create a proposal-specific delegation
      query1 = """
      mutation {
        createDelegation(delegatorEmail: "delegator@email.com", delegateEmail: "delegate@email.com", proposalUrl: "#{
        context[:proposal_url]
      }") {
          proposalUrl
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => original_delegation}}} =
        Absinthe.run(query1, Schema, context: %{organization_id: context[:organization_id]})

      assert original_delegation["proposalUrl"] == context[:proposal_url]

      # now delete delegation, using same details as above, except without proposalUrl field:
      query2 = """
      mutation {
        deleteDelegation(delegatorEmail: "delegator@email.com", delegateEmail: "delegate@email.com") {
          proposalUrl
        }
      }
      """

      {:ok, %{errors: [%{message: message}]}} =
        Absinthe.run(query2, Schema, context: %{organization_id: context[:organization_id]})

      assert message == "No delegation found to delete"
    end

    test "when delegation doesn't exist", context do
      query = """
      mutation {
        deleteDelegation(delegatorEmail: "random@person.com", delegateEmail: "random2@person.com") {
          proposalUrl
          votingResult {
            in_favor
            against
          }
        }
      }
      """

      {:ok, %{errors: [%{message: message}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert message == "No delegation found to delete"
    end
  end
end
