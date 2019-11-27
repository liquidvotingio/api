defmodule LiquidVotingWeb.Absinthe.Mutations.CreateDelegationTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "create delegation" do
    setup do
      delegator = insert(:participant)  
      delegate = insert(:participant)  
      [
        delegator: delegator,
        delegate: delegate
      ]
    end

    test "with existing delegator and delegate ids", context do
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
  end
end