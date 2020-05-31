defmodule LiquidVotingWeb.Absinthe.Mutations.DeleteDelegationTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "delete delegation specific to a proposal" do
    setup do
      delegation = insert(:delegation_for_proposal)
      insert(:vote, participant: delegation.delegate, proposal_url: delegation.proposal_url, organization_uuid: delegation.organization_uuid)
      insert(:voting_result, yes: 2, proposal_url: delegation.proposal_url, organization_uuid: delegation.organization_uuid)
      [
        delegator_email: delegation.delegator.email,
        delegate_email: delegation.delegate.email,
        proposal_url: delegation.proposal_url,
        organization_uuid: delegation.organization_uuid
      ]
    end

    test "with participant emails", context do
      query = """
      mutation {
        deleteDelegation(delegatorEmail: "#{context[:delegator_email]}", delegateEmail: "#{context[:delegate_email]}", proposalUrl: "#{context[:proposal_url]}") {
          proposalUrl
          votingResult {
            yes
            no
          }
        }
      }
      """

      {:ok, %{data: %{"deleteDelegation" => delegation}}} = Absinthe.run(query, Schema, context: %{organization_uuid: context[:organization_uuid]})

      assert delegation["proposalUrl"] == context[:proposal_url]
      assert delegation["votingResult"]["yes"] == 1
      assert delegation["votingResult"]["no"] == 0
    end

    test "when delegation doesn't exist", context do
      query = """
      mutation {
        deleteDelegation(delegatorEmail: "random@person.com", delegateEmail: "random2@person.com", proposalUrl: "https://random.com") {
          proposalUrl
          votingResult {
            yes
            no
          }
        }
      }
      """

      {:ok, %{errors: [%{message: message}]}} = Absinthe.run(query, Schema, context: %{organization_uuid: context[:organization_uuid]})

      assert message == "No delegation found to delete"
    end
  end
end