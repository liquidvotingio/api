defmodule LiquidVotingWeb.Absinthe.Mutations.CreateDelegation.NewParticipantsTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  @delegator_email "delegator@email.com"
  @delegate_email "delegate@email.com"
  @proposal_url "https://www.proposal.com/my"

  describe "create delegation with new participants" do
    test "with emails" do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{@delegate_email}") {
          delegator {
            email
            name
          }
          delegate {
            email
            name
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: Ecto.UUID.generate()})

      assert delegation["delegator"]["email"] == @delegator_email
      assert delegation["delegator"]["name"] == nil
      assert delegation["delegate"]["email"] == @delegate_email
      assert delegation["delegate"]["name"] == nil
    end

    test "including a proposal url" do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{@delegate_email}", proposalUrl: "#{
        @proposal_url
      }") {
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

      {:ok, %{data: %{"createDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: Ecto.UUID.generate()})

      assert delegation["proposalUrl"] == @proposal_url
    end

    test "including results in response, if present" do
      result = insert(:voting_result, proposal_url: @proposal_url)

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{@delegate_email}", proposalUrl: "#{
        @proposal_url
      }") {
          delegator {
            email
          }
          delegate {
            email
          }
          proposalUrl
          votingResult {
            in_favor
            against
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: result.organization_id})

      assert delegation["votingResult"]["in_favor"] == 0
      assert delegation["votingResult"]["against"] == 0
    end

    test "with missing fields" do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}") {
          delegator {
            email
            name
          }
          delegate {
            email
            name
          }
        }
      }
      """

      {:ok, %{errors: [%{message: message, details: details}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: Ecto.UUID.generate()})

      assert message == "Could not create delegation"
      assert details == %{delegate_email: ["can't be blank"]}
    end
  end
end
