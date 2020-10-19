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

      # proposal-specific delegation for SAME participants as global delegation (and same organization id)
      insert(:delegation_for_proposal,
        delegator: global_delegation.delegator,
        delegate: global_delegation.delegate,
        organization_id: global_delegation.organization_id
      )

      # proposal-specific delegation for DIFFERENT participants to global delegation (and same organization id)
      proposal_delegation_different_participants =
        insert(:delegation_for_proposal, organization_id: global_delegation.organization_id)

      [
        delegator_email: global_delegation.delegator.email,
        delegate_email: global_delegation.delegate.email,
        global_delegation_id: global_delegation.id,
        organization_id: global_delegation.organization_id,
        proposal_only_delegator_email: proposal_delegation_different_participants.delegator.email,
        proposal_only_delegate_email: proposal_delegation_different_participants.delegate.email
      ]
    end

    test "with participant emails", context do
      query = """
      mutation {
        deleteDelegation(delegatorEmail: "#{context[:delegator_email]}", delegateEmail: "#{
        context[:delegate_email]
      }") {
          proposalUrl
          id
        }
      }
      """

      {:ok, %{data: %{"deleteDelegation" => deleted_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert deleted_delegation["proposal_url"] == nil
      assert deleted_delegation["id"] == context[:global_delegation_id]
    end

    # test case where a proposal-specific delegation already exists and we wish to delete an
    # existing global delegation for the same delegator & delegate.
    # NOTE: this case should never occur when we prevent global AND proposal-specific delegations
    # existing simultaneously for same delegator/delegate pair.
    test "when a similar proposal-specific delegation exists", context do
      query = """
      mutation {
        deleteDelegation(delegatorEmail: "#{context[:delegator_email]}", delegateEmail: "#{
        context[:delegate_email]
      }") {
          id
        }
      }
      """

      {:ok, %{data: %{"deleteDelegation" => deleted_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert deleted_delegation["id"] == context[:global_delegation_id]
    end

    # test case where a proposal-specific delegation already exists and we try to delete a
    # non-existent global delegation for the same delegator & delegate.
    test "when no matching global delegation exists, but a similar proposal-specific delegation exists",
         context do
      query = """
      mutation {
        deleteDelegation(delegatorEmail: "#{context[:proposal_only_delegator_email]}", delegateEmail: "#{
        context[:proposal_only_delegate_email]
      }") {
          proposalUrl
        }
      }
      """

      {:ok, %{errors: [%{message: message}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert message == "No delegation found to delete"
    end

    test "when delegation doesn't exist", context do
      query = """
      mutation {
        deleteDelegation(delegatorEmail: "random@person.com", delegateEmail: "random2@person.com") {
          proposalUrl
        }
      }
      """

      {:ok, %{errors: [%{message: message}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: context[:organization_id]})

      assert message == "No delegation found to delete"
    end

    test "updates a related voting result" do
      global_delegation = insert(:delegation)

      # TODO - check if we can use this factory when issue resolved.
      # vote =
      #   insert(:vote,
      #     yes: true,
      #     participant: global_delegation.delegate,
      #     organization_id: global_delegation.organization_id
      #   )

      # For now, use absinthe mutation to create vote, to ensure voting result also created.
      # voter = global_delegation.delegate
      proposal_url = "https://prop/a"

      query = """
      mutation {
        createVote(participantEmail: "#{global_delegation.delegate.email}", proposalUrl: "#{
        proposal_url
      }", yes: true) {
          proposalUrl
          votingResult {
            inFavor
            against
          }
        }
      }
      """

      {:ok, %{data: %{"createVote" => vote}}} =
        Absinthe.run(query, Schema, context: %{organization_id: global_delegation.organization_id})

      IO.inspect(vote)

      # Assert voting includes vote weight of deleted delegation.
      assert vote["proposalUrl"] == proposal_url
      assert vote["votingResult"]["against"] == 0
      assert vote["votingResult"]["inFavor"] == 2

      # Delete the global delegation which was created at beginning of test.
      query = """
      mutation {
        deleteDelegation(delegatorEmail: "#{global_delegation.delegator.email}", delegateEmail: "#{
        global_delegation.delegate.email
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

      {:ok, _} =
        Absinthe.run(query, Schema, context: %{organization_id: global_delegation.organization_id})

      # Query the voting result for the vote proposal.
      query = """
      query {
        votingResult(proposalUrl: "#{proposal_url}") {
          inFavor
          against
          proposalUrl
        }
      }
      """

      {:ok, %{data: %{"votingResult" => result}}} =
        Absinthe.run(query, Schema, context: %{organization_id: global_delegation.organization_id})

      # Assert voting result does not include vote weight of deleted delegation.
      assert result["proposalUrl"] == proposal_url
      assert result["against"] == 0
      assert result["inFavor"] == 1
    end
  end
end
