defmodule LiquidVotingWeb.Absinthe.Mutations.CreateDelegationTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "create delegation with new participants" do
    @new_delegator_email "new-delegator@email.com"
    @new_delegate_email "new-delegate@email.com"

    test "with emails" do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@new_delegator_email}", delegateEmail: "#{@new_delegate_email}") {
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => delegation}}} = Absinthe.run(query, Schema, context: %{})

      assert delegation["delegator"]["email"] == @new_delegator_email
      assert delegation["delegate"]["email"] == @new_delegate_email
    end
  end

  describe "create delegation with existing delegator and delegate" do
    setup do
      delegator = insert(:participant)  
      delegate = insert(:participant)  
      [
        delegator: delegator,
        delegate: delegate
      ]
    end

    test "with ids", context do
      query = """
      mutation {
        createDelegation(delegatorId: "#{context[:delegator].id}", delegateId: "#{context[:delegate].id}") {
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => delegation}}} = Absinthe.run(query, Schema, context: %{})

      assert delegation["delegator"]["email"] == context[:delegator].email
      assert delegation["delegate"]["email"] == context[:delegate].email
    end

    test "with emails", context do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{context[:delegator].email}", delegateEmail: "#{context[:delegate].email}") {
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => delegation}}} = Absinthe.run(query, Schema, context: %{})

      assert delegation["delegator"]["email"] == context[:delegator].email
      assert delegation["delegate"]["email"] == context[:delegate].email
    end

    test "with missing field", context do
      query = """
      mutation {
        createDelegation(delegatorId: "#{context[:delegator].id}") {
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{errors: [%{message: message, details: details}]}} = Absinthe.run(query, Schema, context: %{})

      assert message == "Could not create delegation"
      assert details == %{delegate_id: ["can't be blank"]}
    end
  end
end