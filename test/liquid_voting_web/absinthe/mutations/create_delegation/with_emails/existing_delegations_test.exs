defmodule LiquidVotingWeb.Absinthe.Mutations.CreateDelegation.WithEmails.ExistingDelegationsTest do
  use LiquidVotingWeb.ConnCase

  alias LiquidVotingWeb.Schema.Schema

  @delegator_email "delegator@email.com"
  @delegate_email "delegate@email.com"
  @another_delegate_email "another-delegate@email.com"
  @proposal_url "https://www.proposal.com/my"
  @organization_id Ecto.UUID.generate()

  describe "with existing global delegation" do
    test "overwrites existing global delegation" do
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

      {:ok, %{data: %{"createDelegation" => original_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      assert original_delegation["delegator"]["email"] == @delegator_email
      assert original_delegation["delegate"]["email"] == @delegate_email

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{
        @another_delegate_email
      }") {
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

      {:ok, %{data: %{"createDelegation" => modified_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      assert modified_delegation["delegator"]["email"] == @delegator_email
      assert modified_delegation["delegate"]["email"] == @another_delegate_email
    end
  end

  describe "create new proposal-specific delegation for delegator with existing delegation for same proposal" do
    test "overwrites existing proposal-specific delegation" do
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

      {:ok, %{data: %{"createDelegation" => original_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      assert original_delegation["delegator"]["email"] == @delegator_email
      assert original_delegation["delegate"]["email"] == @delegate_email

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{
        @another_delegate_email
      }", proposalUrl: "#{@proposal_url}") {
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

      {:ok, %{data: %{"createDelegation" => modified_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      assert modified_delegation["delegator"]["email"] == @delegator_email
      assert modified_delegation["delegate"]["email"] == @another_delegate_email
      assert original_delegation["proposalUrl"] == modified_delegation["proposalUrl"]
    end
  end
end
