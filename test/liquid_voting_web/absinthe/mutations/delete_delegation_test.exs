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
      delegation = insert(:delegation)

      [
        delegator_email: delegation.delegator.email,
        delegate_email: delegation.delegate.email,
        organization_id: delegation.organization_id
      ]
    end

    test "with participant emails", context do
      query = """
      mutation {
        deleteDelegation(delegatorEmail: "#{context[:delegator_email]}", delegateEmail: "#{
        context[:delegate_email]
      }") {
          proposalUrl
        }
      }
      """

      {:ok, %{data: %{"deleteDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert delegation["proposalUrl"] == context[:proposal_url]
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
